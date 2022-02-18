#!/usr/bin/env sh

# Set SYSTEM_ARCH
SYSTEM_ARCH=$( uname -m )

# Set CLOUDFLARED_ARCH and CLOUDFLARED_CHECKSUM
if [[ "${SYSTEM_ARCH}" == "aarch64" ]]; then
  CLOUDFLARED_ARCH="arm64"
  CLOUDFLARED_CHECKSUM="${CLOUDFLARED_CHECKSUM_ARM64}"
elif [[ "${SYSTEM_ARCH}" == "x86_64" ]]; then
  CLOUDFLARED_ARCH="amd64"
  CLOUDFLARED_CHECKSUM="${CLOUDFLARED_CHECKSUM_AMD64}"
else
  echo "${SYSTEM_ARCH} not supported yet."
  exit 1
fi

# Create doh-proxy user
adduser -S doh-proxy

# Install packages
apk add --no-cache \
  bind-tools \
  curl \
  jq

# Download cloudflared release
getCloudflaredLatest=$( curl --silent https://api.github.com/repos/cloudflare/cloudflared/releases/latest | jq -r .tag_name )
CLOUDFLARED_VERSION=${CLOUDFLARED_VERSION:-${getCloudflaredLatest}}
curl \
  --location https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${CLOUDFLARED_ARCH} \
  --output /usr/local/bin/cloudflared

# Set executable permissions
chmod +x /usr/local/bin/cloudflared
chmod +x /usr/local/bin/entrypoint.sh
chmod +x /usr/local/bin/healthcheck.sh