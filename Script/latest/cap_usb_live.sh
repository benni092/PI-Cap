#!/bin/bash
#v4l2-ctl -c brightness=0 &&
#v4l2-ctl -c contrast=148 &&
#v4l2-ctl -c saturation=180 &&
#v4l2-ctl -c hue=0 &&
while true
do
key=0
gst-launch-1.0 v4l2src device=/dev/video0 ! videoscale ! videoconvert ! video/x-raw,width=720,height=480,framerate=30/1 ! glimagesink > /dev/null &
sleep 5
wmctrl -r OpenGL renderer -b toggle,maximized_vert,maximized_horz
wmctrl -a cap_usb_live.sh
read -n1 -s key
if [ $key = 2 ]; then
cd /home/$USER/cap
last=$(ls *.flv | sort -V | tail -1)
cd
cvlc --play-and-exit /home/$USER/cap/$last &
sleep 3
wmctrl -r VLC media player -b toggle,maximized_vert,maximized_horz
fi
if [ $key = 3 ]; then
sudo pkill vlc
fi
if [ $key = 1 ]; then
kill -SIGINT $!
cd /home/$USER/cap
num=$(ls picap*.flv | sort -V | tail -1 | grep -Eo "[0-9]{1,4}")
num=$(( $num + 1 ))
filename="picap-$num.flv"
sleep 1
result=0
if [ $result = 0 ]; then
gst-launch-1.0 -e v4l2src device=/dev/video0 do-timestamp=true ! videoscale ! videoconvert ! video/x-raw,width=720,height=480,framerate=30/1 ! tee name=t ! queue ! glimagesink t. ! queue ! v4l2h264enc extra-controls="controls,h264_profile=4,h264_level=13,video_bitrate=5000000;" ! "video/x-h264,profile=high,level=(string)4.2" ! h264parse ! queue ! flvmux name=mux ! filesink location=/home/$USER/cap/$filename alsasrc device="default" ! audio/x-raw,rate=48000,channels=1 ! audioconvert ! voaacenc bitrate=128000 ! aacparse ! queue ! mux. > /dev/null &
key=0
sleep 2
echo -e "\e[5;31;107mrec\e[0m"
wmctrl -r OpenGL renderer -b toggle,maximized_vert,maximized_horz
wmctrl -a cap_usb_live.sh
while true
do
read -n1 -s key
if [ $key = 1 ]; then
kill -SIGINT $!
sync
echo "stop"
break
else
echo "wrong input!"
fi
done
fi
fi
sleep 1
done

