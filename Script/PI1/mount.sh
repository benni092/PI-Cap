#!/usr/bin/env bash
sudo umount -l /home/pi/cap
sleep 1
sudo fsck /dev/sda1
sudo fsck /dev/sdb1
sudo mount /home/pi/cap
