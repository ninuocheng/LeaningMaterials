#!/bin/bash
MinerID="f01777770 f02229760"
for i in $MinerID
do
	echo "$i"
	lotus state market balance $i 2> /dev/null
done
