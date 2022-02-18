#!/usr/bin/env bash

echo "Building Container"
docker build --tag doh-proxy --file Containerfile . 
 
for provider in $( jq -r 'keys[]' src/etc/doh-proxy/providers.json ); do
  echo "Testing Provider: ${provider}"
  echo "---> Starting Container [ ${provider} ]"
  dockerRun=$( docker run --detach --env PROVIDER=${provider} --name ${provider} doh-proxy )

  sleep 2

  echo "---> Sending Test Request"
  sendTest=$( docker exec ${provider} dig +time=2 +tries=1 @127.0.0.1 -p 5053 cloudflarestatus.com +short || echo "TEST_FAILED" )
  if [[ "${sendTest}" == *"TEST_FAILED"* ]]; then
    echo "---> Test Failed"
    dockerRm=$( docker rm --force ${provider} )
    exit 1
  else
    echo "---> Test Passed"
  fi
  
  echo "---> Deleting Container [ ${provider} ]"
  dockerRm=$( docker rm --force ${provider} )
done
