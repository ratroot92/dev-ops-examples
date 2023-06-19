#!/bin/bash

# Execute the kubectl command and store the output
output=$(kubectl get pods -l app=redis-cluster -o jsonpath='{range.items[*]}{.status.podIP}:6379 ')

# Remove the last ":6379" from the output using sed
formatted_output=$(echo "$output" | sed 's/:6379 $//')

# Print the formatted output
kubectl exec -it redis-cluster-0 -- redis-cli --cluster create --cluster-replicas 1 $formatted_output