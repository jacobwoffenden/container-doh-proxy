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
curl \
  --location https://github.com/cloudflare/cloudflared/releases/download/${CLOUDFLARED_VERSION}/cloudflared-linux-${CLOUDFLARED_ARCH} \
  --output /usr/local/bin/cloudflared

if [[ "$( sha256sum /usr/local/bin/cloudflared | awk '{ print $1 }' )" != "${CLOUDFLARED_CHECKSUM}" ]]; then
  echo "Checksum doesn't match expected value."
  exit 1
fi

# Set executable permissions
chmod +x /usr/local/bin/cloudflared
chmod +x /usr/local/bin/entrypoint.sh
chmod +x /usr/local/bin/healthcheck.sh