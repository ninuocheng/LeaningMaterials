#!/bin/bash
# Set variables
url="http://172.24.100.81:1081/suspend/phone"
data='{
    "metrics_type":5,
    "machine": "172.25.3.9:22",
    "address": "f01658888"
}'

# Send POST request with cURL
curl -v -X POST $url -d "$data"
