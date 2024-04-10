#!/bin/bash
# Set variables
url="http://172.25.9.91:1081/suspend/phone"
data='{
    "metrics_type":3,
    "machine": "183.178.32.69:222",
    "address": "f01098835"
}'

# Send POST request with cURL
curl -v -X POST $url -d "$data"
