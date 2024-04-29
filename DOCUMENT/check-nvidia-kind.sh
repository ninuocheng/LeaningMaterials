#GPU设备对应的型号
NVIDIA Corporation Device 2204  ---->   NVIDIA GeForce RTX 3090
NVIDIA Corporation Device 2484  ---->   NVIDIA GeForce RTX 3070
NVIDIA Corporation Device 2231  ---->   NVIDIA RTX A5000
#查看GPU设备名称
lspci |grep VGA |grep NVIDIA
#查看GPU型号名称
nvidia-smi -L
