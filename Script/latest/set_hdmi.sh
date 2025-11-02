#!/bin/sh
sleep 1
v4l2-ctl -d /dev/video0 --set-edid=file=/home/$USER/edid.txt
sleep 1
v4l2-ctl --set-dv-bt-timings query
