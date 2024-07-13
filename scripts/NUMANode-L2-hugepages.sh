#!/bin/bash
echo 252| tee /sys/devices/system/node/node{{3..7},{0..1}}/hugepages/hugepages-1048576kB/nr_hugepages
n=$(cat /sys/devices/system/node/node{{3..7},{0..1}}/hugepages/hugepages-1048576kB/nr_hugepages|awk '{i+=$1}END{print 1792-i}')
sleep 10
echo $n > /sys/devices/system/node/node2/hugepages/hugepages-1048576kB/nr_hugepages
