#!/bin/bash
[ ! -f /root/NVIDIA-Linux-x86_64-535.154.05.run ] && echo "/root/NVIDIA-Linux-x86_64-535.154.05.run not exist,please check." && exit 1
expect << EOF
  set timeout -1
  spawn /root/NVIDIA-Linux-x86_64-535.154.05.run -no-opengl-files -no-x-check -no-nouveau-check
  expect {
     "WARNING" { send "\n"; exp_continue }
     "Install NVIDIA's 32-bit compatibility libraries?" { send "No\n"; exp_continue }
     "Would you like to run the nvidia-xconfig utility to automatically update your X configuration file so that the NVIDIA X driver will be used when you restart X?  Any pre-existing X configuration file will be backed up." { send "Yes\n"; exp_continue }
     "Your X configuration file has been successfully updated.  Installation of the NVIDIA Accelerated Graphics Driver for Linux-x86_64 (version: 535.154.05) is now complete" { send "\n"; exp_continue }
     "OK" { send "\n"; exp_continue }
  }
EOF
nvidia-smi -L
echo "success"
