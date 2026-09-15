#!/usr/bin/env bash
# Общий helper: проброс Istio Ingress Gateway на localhost:9090
set -euo pipefail

PF_PID_FILE="${TMPDIR:-/tmp}/istio-ingress-9090.pid"

ensure_ingress_port_forward() {
  if curl -sf --max-time 1 "http://127.0.0.1:9090/ping" >/dev/null 2>&1; then
    return 0
  fi

  if [[ -f "$PF_PID_FILE" ]] && kill -0 "$(cat "$PF_PID_FILE")" 2>/dev/null; then
    :
  else
    kubectl -n istio-system port-forward svc/istio-ingressgateway 9090:80 >/tmp/istio-ingress-9090.log 2>&1 &
    echo $! >"$PF_PID_FILE"
  fi

  local i
  for i in $(seq 1 30); do
    if curl -sf --max-time 1 "http://127.0.0.1:9090/ping" >/dev/null 2>&1; then
      return 0
    fi
    sleep 0.5
  done
  echo "❌ Ingress Gateway не отвечает на http://127.0.0.1:9090/ping" >&2
  echo "   Лог port-forward: /tmp/istio-ingress-9090.log" >&2
  return 1
}
