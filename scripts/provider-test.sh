#!/usr/bin/env bash

CLOUDFLARE_STATUS_EXPECTED_RESULT=$( dig cloudflarestatus.com +short )

echo "Building Container"
dockerBuild=$( docker build --tag doh-proxy . )

# Testing providers that require no extra configuration
for provider in $( jq -r 'keys[]' src/etc/doh-proxy/providers.json ); do
  echo "Testing Provider: ${provider}"
  echo "---> Starting Container [ ${provider} ]"
  dockerRun=$( docker run --detach --env PROVIDER=${provider} --name ${provider} doh-proxy )

  sleep 2

  echo "---> Sending Test Request"
  sendTest=$( docker exec ${provider} dig +time=2 +tries=1 @127.0.0.1 -p 53 cloudflarestatus.com +short )
  if [[ "${sendTest}" != "${CLOUDFLARE_STATUS_EXPECTED_RESULT}" ]]; then
    echo "---> Test Failed"
    dockerRm=$( docker rm --force ${provider} )
    exit 1
  else
    echo "---> Test Passed"
  fi
  
  echo "---> Deleting Container [ ${provider} ]"
  dockerRm=$( docker rm --force ${provider} )
done

if [[ "${GITHUB_ACTIONS}" == "true" ]]; then
  # Testing Cloudflare Zero Trust
  export provider="cloudflare-zero-trust"
  echo "Testing Provider: ${provider}"
  echo "---> Starting Container [ ${provider} ]"
  dockerRun=$( docker run --detach --env PROVIDER=${provider} --env CLOUDFLARE_ZERO_TRUST_ID=${CLOUDFLARE_ZERO_TRUST_ID} --name ${provider} doh-proxy )

  sleep 2

  echo "---> Sending Test Request"
  sendTest=$( docker exec ${provider} dig +time=2 +tries=1 @127.0.0.1 -p 53 cloudflarestatus.com +short || echo "TEST_FAILED" )
  if [[ "${sendTest}" == *"TEST_FAILED"* ]]; then
    echo "---> Test Failed"
    dockerRm=$( docker rm --force ${provider} )
    exit 1
  else
    echo "---> Test Passed"
  fi

  echo "---> Deleting Container [ ${provider} ]"
  dockerRm=$( docker rm --force ${provider} )

  # Testing NextDNS
  export provider="nextdns"
  echo "Testing Provider: ${provider}"
  echo "---> Starting Container [ ${provider} ]"
  dockerRun=$( docker run --detach --env PROVIDER=${provider} --env NEXTDNS_ID=${NEXTDNS_ID} --name ${provider} doh-proxy )

  sleep 2

  echo "---> Sending Test Request"
  sendTest=$( docker exec ${provider} dig +time=2 +tries=1 @127.0.0.1 -p 53 cloudflarestatus.com +short || echo "TEST_FAILED" )
  if [[ "${sendTest}" == *"TEST_FAILED"* ]]; then
    echo "---> Test Failed"
    dockerRm=$( docker rm --force ${provider} )
    exit 1
  else
    echo "---> Test Passed"
  fi

  echo "---> Deleting Container [ ${provider} ]"
  dockerRm=$( docker rm --force ${provider} )
fi