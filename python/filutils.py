import json
import sys
import urllib.request

# minerLst = sys.argv[1]
# minerLst = ['f02236965','f02528','f0753213']
minerLst = ['f02528']
for minerID in minerLst:
    url = f'https://filfox.info/api/v1/address/{minerID}'
    headers = {
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
    }
    req = urllib.request.Request(url=url,headers=headers)
    with urllib.request.urlopen(req) as response:
        content = json.load(response)
    print(content)
    robust = content['robust']
    robustBalance = int(content['balance'])/(10**18)
    owner = content['miner']['owner']['address']
    ownerBalance = int(content['miner']['owner']['balance'])/(10**18)
    worker = content['miner']['worker']['address']
    workerBalance = int(content['miner']['worker']['balance'])/(10**18)
    beneficiary = content['miner']['beneficiary']['address']
    beneficiaryBalance = int(content['miner']['beneficiary']['balance'])/(10**18)
    controlAddresses = content['miner']['controlAddresses']
    peerId = content['miner']['peerId']
    multiAddresses = content['miner']['multiAddresses']
    rawBytePower = content['miner']['rawBytePower']
    qualityAdjPower = content['miner']['qualityAdjPower']
    rawBytePower = int(rawBytePower)/(1024**5)
    qualityAdjPower = int(qualityAdjPower)/(1024**5)
    networkRawBytePower = int(content['miner']['networkRawBytePower'])/(1024**6)
    networkQualityAdjPower = int(content['miner']['networkQualityAdjPower'])/(1024**6)
    live = content['miner']['sectors']['live']
    active = content['miner']['sectors']['active']
    faulty = content['miner']['sectors']['faulty']
    recovering = content['miner']['sectors']['recovering']
    preCommitDeposits = content['miner']['preCommitDeposits']
    vestingFunds = int(content['miner']['vestingFunds'])/(10**18)
    initialPledgeRequirement = int(content['miner']['initialPledgeRequirement'])/(10**18)
    availableBalance = int(content['miner']['availableBalance'])/(10**18)
    sectorPledgeBalance = int(content['miner']['sectorPledgeBalance'])/(10**18)
    pledgeBalance = int(content['miner']['pledgeBalance'])/(10**18)
    print(f'{minerID}')
    print('账户地址: {0},余额: {1:,} FIL'.format(robust,robustBalance))
    print('Owner: {0},余额: {1} FIL\nWorker: {2},余额: {3} FIL'.format(owner,ownerBalance,worker,workerBalance))
    print('受益人: {0},余额: {1} FIL'.format(beneficiary,beneficiaryBalance))
    for i in range(len(controlAddresses)):
        controlAddr = controlAddresses[i]['address']
        controlAddrBalance = int(controlAddresses[i]['balance'])/(10**18)
        print('control-{0}: {1},余额: {2} FIL'.format(i,controlAddr,controlAddrBalance))
    print(f'peerId: {peerId}')
    for item in multiAddresses:
        print(f'multiAddresses: {item}')
    print('原值算力: {0:.2f} PiB'.format(rawBytePower))
    print('有效算力: {0:.2f} PiB'.format(qualityAdjPower))
    print('全网原值算力: {0:.2f} EiB'.format(networkRawBytePower))
    print('全网有效算力: {0:.2f} EiB'.format(networkQualityAdjPower))
    print(f'{live} 存活, {active} 有效, {faulty} 错误, {recovering} 恢复中')
    print('preCommitDeposits: {0},奖励锁仓: {1:,} FIL,initialPledgeRequirement: {2:,} FIL'.format(preCommitDeposits,vestingFunds,initialPledgeRequirement))
    print('可用余额: {0:,} FIL,扇区质押: {1:,} FIL,pledgeBalance: {2:,} FIL'.format(availableBalance,sectorPledgeBalance,pledgeBalance))