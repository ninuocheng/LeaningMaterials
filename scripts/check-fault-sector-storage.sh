#!/bin/bash
#遍历循环的变量n是deadline窗口号
for n in `seq 3`;do echo "deadline $n" ; for i in `lotus-miner proving deadline -n $n 2>/dev/null|awk -F'[]|[]' '/Faulty Sector Numbers:/{print $(NF-1)}' |sed '/^$/d'`; do lotus-miner storage find $i 2>/dev/null|awk -F'[(|)]' '/Local/{print "du -sh",$2"/*/s-t02528-"'$i'}'|bash; done; done
