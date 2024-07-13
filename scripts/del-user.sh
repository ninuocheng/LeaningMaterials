#!/bin/bash
user="ops"
pkill -u $user
userdel -r $user
