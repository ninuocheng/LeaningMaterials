#!/bin/bash
source /opt/raid0/profile
source /opt/raid0/lotusminer-sealing/profile
Name=`hostname |awk -F'-' '{print $1}'`
lotus-miner actor control list --verbose |awk '/control/{print "'$Name' "$1,$(NF-1)$NF}'
