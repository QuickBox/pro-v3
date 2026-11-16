#!/usr/bin/env bash
#shellcheck disable=SC2249
set -euo pipefail

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
# Inputs
INV="${INV:-$(find ~/quickbox_backup/ -maxdepth 1 -name 'qb_inventory_*.json' -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -n1)}"
[ -f "${INV}" ] || { echo "Inventory JSON not found. Set INV=/path/to/qb_inventory.json" >&2; exit 1; }

DB="${DB:-/opt/quickbox/config/db/qbpro.db}"
[ -f "${DB}" ] || DB="/srv/quickbox/db/qbpro.db"
[ -f "${DB}" ] || { echo "QuickBox DB not found at /opt or /srv" >&2; exit 1; }

# Exclusions (no services)
EXCLUDE_RE='^(rutorrent|lecert)$'

echo "[i] Building service name map from DB..."
declare -A SVC
while IFS=$'\t' read -r NAME SERVICE; do
  [[ -z "${NAME:-}" ]] && continue
  NAME="${NAME,,}"; SERVICE="${SERVICE,,}"
  [[ -z "${SERVICE}" || "${SERVICE}" == "null" ]] && SERVICE="${NAME}"
  SVC["${NAME}"]="${SERVICE}"
done < <(sqlite3 -tabs "${DB}" \
  "SELECT software_name, COALESCE(software_service_name, software_name)
   FROM software_information;")

echo "[i] Discovering user/application services from API..."
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

echo "[i] Gathering services to stop..."
declare -a to_stop=()

to_stop+=("nginx.service")
# Stop any php-fpm variants if present
mapfile -O "${#to_stop[@]}" -t php_services < <(systemctl list-units --all --type=service 'php*-fpm.service' --no-legend 2>/dev/null | awk '{print $1}')
to_stop+=("${php_services[@]}")

WSD_DONE=0
for row in "${UA[@]}"; do
  USER="${row%%$'\t'*}"
  APP="${row#*$'\t'}"
  APP_LC="${APP,,}"
  [[ "${APP_LC}" =~ ${EXCLUDE_RE} ]] && continue

  svc="${SVC[${APP_LC}]:-${APP_LC}}"

  case "${APP_LC}" in
    wsdashboard)
      if (( WSD_DONE == 0 )); then
        to_stop+=("qbwsd.service")
        to_stop+=("qbwsd-log-server.service")
        WSD_DONE=1
      fi
      continue
      ;;
    webconsole)
      to_stop+=("ttyd@${USER}.service")
      to_stop+=("ttyd.service")
      continue
      ;;
    deluge)
      # daemon + web (cover templated and singleton)
      to_stop+=("deluged@${USER}.service")
      to_stop+=("deluged.service")
      to_stop+=("deluge-web@${USER}.service")
      to_stop+=("deluge-web.service")
      continue
      ;;
  esac

  # Generic: try templated first, then singleton
  to_stop+=("${svc}@${USER}.service")
  to_stop+=("${svc}.service")
done

if (( ${#to_stop[@]} > 0 )); then
  echo "[i] Stopping batched services..."
  mapfile -t unique_to_stop < <(printf "%s\n" "${to_stop[@]}" | sort -u)
  systemctl stop "${unique_to_stop[@]}" >/dev/null 2>&1 || true
fi

echo "[✓] Service stop pass complete."
fi