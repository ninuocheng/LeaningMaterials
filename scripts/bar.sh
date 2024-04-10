#!/bin/bash
echo "Started bar.sh"
echo "Started foo.sh"
/bin/bash foo.sh &
pid=$!
wait $pid
echo "Completed foo.sh"
for j in {1..5}
do
   echo "bar.sh - Looping ... number $j"
done
