#!/bin/bash
MinerID="f01566485"
SectorFile="2.txt"
echo "Sector                       Activation                                        Expiration                          InitialPledge          ExpectedDayReward        ExpectedStoragePledge" > StoreSectorInfo
for i in `awk 'NR>1{print $1}' $SectorFile`
do
	#lotus state sector $MinerID $i |awk -F: '/SectorNumber:/{SectorNumber=$2} /Activation:/{Activation=$2":"$3} /Expiration:/{Expiration=$2":"$3} /InitialPledge:/{InitialPledge=$2} /ExpectedDayReward:/{ExpectedDayReward=$2} /ExpectedStoragePledge:/{ExpectedStoragePledge=$2} /Partition:/ {print SectorNumber,Activation,Expiration,InitialPledge,ExpectedDayReward,ExpectedStoragePledge;SectorNumber="";Activation="";Expiration="";InitialPledge="";ExpectedDayReward="";ExpectedStoragePledge=""}' |sed 's#^[ ]*##g' >> StoreSectorInfo
	lotus state sector $MinerID $i |awk '/SectorNumber:/{$1="";SectorNumber=$0} /Activation:/{$1="";Activation=$0} /Expiration:/{$1="";Expiration=$0} /InitialPledge:/{$1="";InitialPledge=$0} /ExpectedDayReward:/{$1="";ExpectedDayReward=$0} /ExpectedStoragePledge:/{$1="";ExpectedStoragePledge=$0} /Partition:/ {print SectorNumber,Activation,Expiration,InitialPledge,ExpectedDayReward,ExpectedStoragePledge;SectorNumber="";Activation="";Expiration="";InitialPledge="";ExpectedDayReward="";ExpectedStoragePledge=""}' |sed 's#^[ ]*##g' >> StoreSectorInfo
done
