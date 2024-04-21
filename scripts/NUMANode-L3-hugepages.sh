#!/bin/bash
echo 252| tee /sys/devices/system/node/node{{0..2},{4..7}}/hugepages/hugepages-1048576kB/nr_hugepages
n=$(cat /sys/devices/system/node/node{{0..2},{4..7}}/hugepages/hugepages-1048576kB/nr_hugepages|awk '{i+=$1}END{print 1792-i}')
sleep 10
echo $n > /sys/devices/system/node/node3/hugepages/hugepages-1048576kB/nr_hugepages
