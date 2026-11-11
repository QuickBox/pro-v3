#!/usr/bin/env bash
set -euo pipefail

# Reload certificates by restarting the mailserver container
# This is typically called by a post-renewal hook in lecert
echo "[i] Reloading Mail Stack certificates..."
docker restart mailserver
