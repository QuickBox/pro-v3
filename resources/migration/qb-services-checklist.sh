#!/usr/bin/env bash
# shellcheck disable=SC2249
set -euo pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
# Inputs
INV="${INV:-$(find ~/quickbox_backup/ -maxdepth 1 -type f -name 'qb_inventory_*.json' -print0 2>/dev/null | xargs -0 stat --format '%Y %n' 2>/dev/null | sort -nr | head -n1 | cut -d' ' -f2-)}"
[ -f "${INV}" ] || { echo "Inventory JSON not found. Set INV=/path/to/qb_inventory.json" >&2; exit 1; }

DB="${DB:-/opt/quickbox/config/db/qbpro.db}"
[ -f "${DB}" ] || DB="/srv/quickbox/db/qbpro.db"
[ -f "${DB}" ] || { echo "QuickBox DB not found at /opt or /srv" >&2; exit 1; }

# Exclusions (no services)
EXCLUDE_RE='^(rutorrent|lecert)$'

# Map software_name -> software_service_name (lowercased; fallback to name)
declare -A SVC
while IFS=$'\t' read -r NAME SERVICE; do
  [[ -z "${NAME:-}" ]] && continue
  NAME="${NAME,,}"; SERVICE="${SERVICE,,}"
  [[ -z "${SERVICE}" || "${SERVICE}" == "null" ]] && SERVICE="${NAME}"
  SVC["${NAME}"]="${SERVICE}"
done < <(sqlite3 -tabs "${DB}" \
  "SELECT software_name, COALESCE(software_service_name, software_name) FROM software_information;")

# Snapshot both unit FILES and unit INSTANCES for robust existence checks
mapfile -t UNITFILES < <(systemctl list-unit-files --type=service --no-legend 2>/dev/null | awk '{print $1}')
mapfile -t UNITS     < <(systemctl list-units --all --type=service --no-legend 2>/dev/null | awk '{print $1}')
declare -A HAS
for u in "${UNITFILES[@]}" "${UNITS[@]}"; do [[ -n "${u}" ]] && HAS["${u}"]=1; done

has_unit()      { [[ -n "${HAS[$1]:-}" ]]; }
has_template()  { [[ -n "${HAS[$1@.service]:-}" ]]; }              # e.g., name@.service
has_instance()  { local n="$1" u="$2"; [[ -n "${HAS[$n@${u}.service]:-}" ]]; }  # name@user.service

print_line() {
  local unit="$1"
  printf " - systemctl start %s && journalctl -u %s -n 100 --no-pager\n" "${unit}" "${unit}"
}

echo "=== Dashboard layer (start once) ==="
has_unit "nginx.service" && print_line "nginx.service"
for u in "${UNITFILES[@]}"; do
  [[ "${u}" =~ ^php([0-9\.]+)?-fpm\.service$ ]] && print_line "${u}"
done
echo

# Collect (user, app) pairs from API
mapfile -t UA < <(
  jq -r '
    .data
    | to_entries[]
    | .value as $v
    | $v.user_information.username as $user
    | ($v.installed_software // $v.user_information.installed_software)
    | keys[]? as $app
    | [$user, $app]
    | @tsv
  ' "${INV}" | sort -u
)

current_user=""
WSD_PRINTED=0
for row in "${UA[@]}"; do
  USER="${row%%$'\t'*}"
  APP="${row#*$'\t'}"
  APP_LC="${APP,,}"
  [[ "${APP_LC}" =~ ${EXCLUDE_RE} ]] && continue

  # Header per user (once)
  if [[ "${USER}" != "${current_user}" ]]; then
    [[ -n "${current_user}" ]] && echo
    echo "=== user: ${USER} ==="
    current_user="${USER}"
  fi

  # Resolve official service name via DB
  svc="${SVC[${APP_LC}]:-${APP_LC}}"

  # Special cases
  case "${APP_LC}" in
    wsdashboard)
      if (( WSD_PRINTED == 0 )); then
        has_unit "qbwsd.service" && print_line "qbwsd.service"
        has_unit "qbwsd-log-server.service" && print_line "qbwsd-log-server.service"
        WSD_PRINTED=1
      fi
      continue
      ;;
    webconsole)
      if has_instance "ttyd" "${USER}" || has_template "ttyd"; then
        print_line "ttyd@${USER}.service"
      elif has_unit "ttyd.service"; then
        print_line "ttyd.service"
      fi
      continue
      ;;
    deluge)
      # daemon is deluged; web is deluge-web
      if has_instance "deluged" "${USER}" || has_template "deluged"; then
        print_line "deluged@${USER}.service"
      elif has_unit "deluged.service"; then
        print_line "deluged.service"
      fi
      if has_instance "deluge-web" "${USER}" || has_template "deluge-web"; then
        print_line "deluge-web@${USER}.service"
      elif has_unit "deluge-web.service"; then
        print_line "deluge-web.service"
      fi
      continue
      ;;
    resilio-sync|btsync)
      # QuickBox runs Resilio Sync as multi-user; prefer instance when present
      if has_instance "resilio-sync" "${USER}" || has_template "resilio-sync"; then
        print_line "resilio-sync@${USER}.service"
      elif has_unit "resilio-sync.service"; then
        print_line "resilio-sync.service"
      fi
      continue
      ;;
  esac

  # Generic: prefer templated <svc>@user, else singleton <svc>
  if has_instance "$svc" "${USER}" || has_template "$svc"; then
    print_line "${svc}@${USER}.service"
  elif has_unit "${svc}.service"; then
    print_line "${svc}.service"
  fi
done

echo
echo "# Start one unit at a time from the list above, verify behind nginx, then proceed to the next."
fi