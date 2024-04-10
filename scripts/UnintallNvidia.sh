#!/bin/bash
/usr/bin/nvidia-uninstall
apt-get --purge remove nvidia*
apt-get purge nvidia*
apt-get purge libnvidia*
dpkg --list | grep nvidia-*
