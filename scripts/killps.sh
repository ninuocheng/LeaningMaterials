#!/bin/bash
ps  -u ops |grep -v PID |awk '{print $1}' |xargs kill -9
