#!/usr/bin/env bash

proxy_name="eliasproxy"
endpoint=""

echo "Getting proxy endpoints..."

endpoints=$(aws rds describe-db-proxy-endpoints --db-proxy-name "$proxy_name" --query "DBProxyEndpoints[*].Endpoint")

echo "Building template configmap"

for i in ${endpoints}; do
  if [ "$i" != "[" ] && [ "$i" != "]" ]; then
    endpoint="ENDPOINT: ${i//[,\"]/}"
    break
  fi
done

echo "Applying on cluster"

cat <<-END | kubectl apply -f -
  apiVersion: v1
  kind: ConfigMap
  metadata:
    name: ${proxy_name}
  data:
    ${endpoint}
END
