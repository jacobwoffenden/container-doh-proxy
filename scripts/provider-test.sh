#!/usr/bin/env bash
# shellcheck disable=SC2059

if [[ -z "${GITHUB_ACTIONS}" ]]; then
  echo "Running locally"
  export GITHUB_STEP_SUMMARY="provider-test.md"
fi

echo "Setting expected result"
CLOUDFLARE_STATUS_EXPECTED_RESULT=$( dig cloudflarestatus.com +short )
export CLOUDFLARE_STATUS_EXPECTED_RESULT

echo "Building container"
docker build \
  --file Dockerfile \
  --tag doh-proxy \
  .

echo "# Test Report" >> "${GITHUB_STEP_SUMMARY}"
echo "| Provider | Result |" >> "${GITHUB_STEP_SUMMARY}"
echo "|:---:|:---:|" >> "${GITHUB_STEP_SUMMARY}"

# Testing providers that require no extra configuration
for provider in $( jq -r 'keys[]' src/etc/doh-proxy/providers.json ); do
  echo "Testing Provider: ${provider}"
  docker run --detach \
    --env PROVIDER="${provider}" \
    --name "${provider}" \
    doh-proxy

  sleep 2

  testCommand=$( docker exec "${provider}" dig +time=2 +tries=1 @127.0.0.1 -p 53 cloudflarestatus.com +short )

  if [[ "${testCommand}" != "${CLOUDFLARE_STATUS_EXPECTED_RESULT}" ]]; then
    echo "Fail"
    echo "| ${provider} | ❌ |" >> "${GITHUB_STEP_SUMMARY}"
  else
    echo "Pass"
    echo "| ${provider} | ✅ |" >> "${GITHUB_STEP_SUMMARY}"
  fi

  docker rm --force "${provider}"
done

# Testing providers that require configuration
if [[ "${GITHUB_ACTIONS}" == "true" ]]; then
  export provider="cloudflare-zero-trust"

  echo "Testing Provider: ${provider}"
  docker run --detach \
    --env PROVIDER="${provider}" \
    --env CLOUDFLARE_ZERO_TRUST_ID="${CLOUDFLARE_ZERO_TRUST_ID}" \
    --name "${provider}" \
    doh-proxy
  
  sleep 2
  
  testCommand=$( docker exec "${provider}" dig +time=2 +tries=1 @127.0.0.1 -p 53 cloudflarestatus.com +short || echo "TEST_FAILED" )

  if [[ "${testCommand}" == *"TEST_FAILED"* ]]; then
    echo "Fail"
    echo "| ${provider} | ❌ |" >> "${GITHUB_STEP_SUMMARY}"
  else
    echo "Pass"
    echo "| ${provider} | ✅ |" >> "${GITHUB_STEP_SUMMARY}"
  fi

  docker rm --force "${provider}"

  #######

  export provider="nextdns"

  echo "Testing Provider: ${provider}"
  docker run --detach --env PROVIDER="${provider}" --env NEXTDNS_ID="${NEXTDNS_ID}" --name "${provider}" doh-proxy

  sleep 2

  testCommand=$( docker exec "${provider}" dig +time=2 +tries=1 @127.0.0.1 -p 53 cloudflarestatus.com +short || echo "TEST_FAILED" )

  if [[ "${testCommand}" == *"TEST_FAILED"* ]]; then
    echo "Fail"
    echo "| ${provider} | ❌ |" >> "${GITHUB_STEP_SUMMARY}"
  else
    echo "Pass"
    echo "| ${provider} | ✅ |" >> "${GITHUB_STEP_SUMMARY}"
  fi

  docker rm --force "${provider}"
fi
