#!/usr/bin/env bash

echo "Setting expected result"
CLOUDFLARE_STATUS_EXPECTED_RESULT=$( dig cloudflarestatus.com +short )

echo "Building container"
docker build --file Containerfile --tag doh-proxy .

# Testing providers that require no extra configuration
for provider in $( jq -r 'keys[]' src/etc/doh-proxy/providers.json ); do
  echo "Testing Provider: ${provider}"
  docker run --detach --env PROVIDER=${provider} --name ${provider} doh-proxy

  sleep 2

  testCommand=$( docker exec ${provider} dig +time=2 +tries=1 @127.0.0.1 -p 53 cloudflarestatus.com +short )

  if [[ "${testCommand}" != "${CLOUDFLARE_STATUS_EXPECTED_RESULT}" ]]; then
    echo "Fail"
  else
    echo "Pass"
  fi

  docker rm --force ${provider}
done

# Testing providers that require configuration
if [[ "${GITHUB_ACTIONS}" == "true" ]]; then
  export provider="cloudflare-zero-trust"
  echo "Testing Provider: ${provider}"

  docker run --detach --env PROVIDER=${provider} --env CLOUDFLARE_ZERO_TRUST_ID=${CLOUDFLARE_ZERO_TRUST_ID} --name ${provider} doh-proxy

  sleep 2

  testCommand=$( docker exec ${provider} dig +time=2 +tries=1 @127.0.0.1 -p 53 cloudflarestatus.com +short || echo "TEST_FAILED" )
  
  if [[ "${testCommand}" == *"TEST_FAILED"* ]]; then
    echo "Failed"
  else
    echo "Pass"
  fi

  docker rm --force ${provider}

  #######

  export provider="nextdns"
  echo "Testing Provider: ${provider}"
  
  docker run --detach --env PROVIDER=${provider} --env NEXTDNS_ID=${NEXTDNS_ID} --name ${provider} doh-proxy

  sleep 2

  testCommand=$( docker exec ${provider} dig +time=2 +tries=1 @127.0.0.1 -p 53 cloudflarestatus.com +short || echo "TEST_FAILED" )
  
  if [[ "${testCommand}" == *"TEST_FAILED"* ]]; then
    echo "Failed"
  else
    echo "Pass"
  fi

  docker rm --force ${provider}
