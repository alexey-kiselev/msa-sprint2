#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/results/check_all.txt"

# shellcheck source=lib.sh
source "$ROOT/lib.sh"

mkdir -p "$ROOT/results"
ensure_ingress_port_forward

{
  failed=0
  for name in check-istio.sh check-canary.sh check-fallback.sh check-feature-flag.sh; do
    echo "$name"
    if bash "$ROOT/$name"; then
      echo
      echo "(exit 0)"
    else
      code=$?
      echo
      echo "(exit $code)"
      failed=1
    fi
    echo
  done

  if ((failed == 0)); then
    echo "Итог: все проверки завершились с кодом 0"
  else
    echo "Итог: были ошибки"
    exit 1
  fi
} 2>&1 | tee "$OUT"
