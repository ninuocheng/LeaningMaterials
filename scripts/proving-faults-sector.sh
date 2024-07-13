#!/bin/bash
lotus-miner proving faults |awk 'NR>2{print $3}' > proving-faults-sector
