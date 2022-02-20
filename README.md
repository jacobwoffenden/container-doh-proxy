# container-doh-proxy

> A multi-arch container to proxy DNS over HTTPS providers such as Cloudflare and Google

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/doh-proxy)](https://artifacthub.io/packages/search?repo=doh-proxy)


## Usage

### `cosign` Verification (Optional)

```
COSIGN_EXPERIMENTAL=1 cosign verify ghcr.io/jacobwoffenden/doh-proxy:latest | jq
```

### Running

#### Default (Cloudflare)

```
docker run \
  --name doh-proxy \
  --publish 53:53/udp \
  ghcr.io/jacobwoffenden/doh-proxy:latest
```

#### With Metrics Exposed (http://<address>:9100/metrics)

```
docker run \
  --name doh-proxy \
  --publish 53:53/udp \
  --publish 9100:9100/tcp \
  ghcr.io/jacobwoffenden/doh-proxy:latest
```

#### Alternative Providers

See [providers.json](src/etc/doh-proxy/providers.json) for a list of providers

```
docker run \
  --env PROVIDER="cloudflare-family" \
  --name doh-proxy \
  --publish 53:53/udp \
  ghcr.io/jacobwoffenden/doh-proxy:latest
```

#### Cloudflare Zero Trust (a.k.a Cloudflare Teams)

If your Cloudflare Zero Trust URL is `https://abcdefghij.cloudflare-gateway.com/dns-query`, the `CLOUDFLARE_ZERO_TRUST_ID` is `abcdefghij`

```
docker run \
  --env PROVIDER="cloudflare-zero-trust" \
  --env CLOUDFLARE_ZERO_TRUST_ID="abcdefghij" \
  --name doh-proxy \
  --publish 53:53/udp \
  ghcr.io/jacobwoffenden/doh-proxy:latest
```

#### NextDNS

if your NextDNS URL is `https://dns.nextdns.io/abc123`, the `NEXTDNS_ID` is `abc123`

```
docker run \
  --env PROVIDER="nextdns" \
  --env NEXTDNS_ID="abc123" \
  --name doh-proxy \
  --publish 53:53/udp \
  ghcr.io/jacobwoffenden/doh-proxy:latest
```

### Entrypoint Overrides

|Variable|Default|
|:----------------:|:---------:|
|`PROVIDER`|`cloudflare`|
|`LISTEN_ADDRESS`|`0.0.0.0`|
|`LISTEN_PORT`|`53`|
|`METRICS_ADDRESS`|`0.0.0.0`|
|`METRICS_PORT`|`9100`|
|`MAX_UPSTREAM_CONNS`|`0`|
