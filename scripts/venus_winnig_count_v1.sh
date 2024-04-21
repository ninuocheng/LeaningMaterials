#!/bin/bash
#f01179295 f0428661 f01658888 f0716775
#小节点：f0716775 f01179295 f0428661   大节点：f01658888
#小节点调用cpu证明
TOKEN=$3
#TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiZHVkdSIsInBlcm0iOiJ3cml0ZSIsImV4dCI6IiJ9.XiZj23AEa6BkMKS81EqRUdysD7NSMA-jDGTb4EpujSk"
#大节点调用gpu证明
#TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiaHVqdW4iLCJwZXJtIjoid3JpdGUiLCJleHQiOiIifQ.2EtT0YmlPlu0IXC8i_VAYL2RNMN7lSN90rodUGncUm4"
INCREMENT=288
LIMIT=288
TOTAL_ITERATIONS=10

print_usage() {
  echo "Usage: $0 <MINER_ADDRESS> <START_EPOCH>"
  echo "Example: $0 f01179295 3151430"
}

if [ $# -ne 3 ]; then
  echo "Error: Invalid number of arguments"
  print_usage
  exit 1
fi

MINER=$1
current_epoch=$2

total_eligible_count=0
total_win_count=0
for ((i=1; i<=$TOTAL_ITERATIONS; i++)); do
  response=$(curl -s "https://gateway.filincubator.com:83/rpc/v0" -X POST -H "X-VENUS-API-NAMESPACE: miner.MinerAPI" -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "{\"method\": \"Filecoin.QueryRecord\", \"params\": [{ \"Miner\": \"$MINER\", \"Epoch\":$current_epoch , \"Limit\":$LIMIT }], \"id\": 0}" | jq '.result')

  #eligible_count=$(echo "$response" | jq '[ .[] | select(.isEligible == "true")] | length')
  eligible_count=$(echo "$response" |jq '[ .[] | select(.isEligible == "true") |select(.info == "not to be winner")] |length')
  win_count=$(echo "$response" | jq '[ .[] | select(.winCount)] | length')
  
  echo "开始高度: $current_epoch,结束高度: $((current_epoch + 288))"
  echo "Iteration $i:"
  echo "\"isEligible\": \"true\" count: $eligible_count"
  echo "\"winCount\" count: $win_count"
  echo ""

  total_eligible_count=$(( total_eligible_count + eligible_count + win_count))
  total_win_count=$((total_win_count + win_count))

  current_epoch=$((current_epoch + INCREMENT))
done
echo "$1 抽奖次数：$total_eligible_count 中奖次数：$total_win_count"
