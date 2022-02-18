#!/usr/bin/env sh

PROVIDER="${PROVIDER:-cloudflare}"
LISTEN_ADDRESS="${LISTEN_ADDRESS:-0.0.0.0}"
LISTEN_PORT="${LISTEN_PORT:-53}"
METRICS_ADDRESS="${METRICS_ADDRESS:-0.0.0.0}"
METRICS_PORT="${METRICS_PORT:-9100}"
MAX_UPSTREAM_CONNS="${MAX_UPSTREAM_CONNS:-0}"

if [[ "${PROVIDER}" == "cloudflare-zero-trust" ]]; then
  UPSTREAM="https://${CLOUDFLARE_ZERO_TRUST_ID}.cloudflare-gateway.com/dns-query"
else
  UPSTREAM=$( jq -r ".\"${PROVIDER}\"" /etc/doh-proxy/providers.json )
fi

/usr/local/bin/cloudflared \
  proxy-dns \
  --address ${LISTEN_ADDRESS} \
  --port ${LISTEN_PORT} \
  --upstream ${UPSTREAM} \
  --metrics ${METRICS_ADDRESS}:${METRICS_PORT} \
  --max-upstream-conns ${MAX_UPSTREAM_CONNS}