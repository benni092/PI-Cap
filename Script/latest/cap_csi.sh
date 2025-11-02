#!/bin/bash
#sudo cpufreq-set -g performance
#v4l2-ctl -c brightness=0 &&
#v4l2-ctl -c contrast=148 &&
#v4l2-ctl -c saturation=180 &&
#v4l2-ctl -c hue=0 &&
while true
do
key=0
read -n1 -s key
if [ $key = 2 ]; then
cd /home/$USER/cap
last=$(ls *.mkv | sort -V | tail -1)
cd
cvlc --play-and-exit /home/$USER/cap/$last &
fi
if [ $key = 3 ]; then
sudo pkill vlc
fi
if [ $key = 1 ]; then
cd /home/$USER/cap
num=$(ls picap*.mkv | sort -V | tail -1 | grep -Eo "[0-9]{1,4}")
num=$(( $num + 1 ))
filename="picap-$num.mkv"
result=0
if [ $result = 0 ]; then
gst-launch-1.0 -e v4l2src ! "video/x-raw,framerate=60/1,format=UYVY" ! v4l2h264enc extra-controls="controls,h264_profile=4,h264_level=13,video_bitrate=5000000;" ! "video/x-h264,profile=high,level=(string)4.2" ! h264parse ! queue ! matroskamux name=mux ! filesink location=/home/$USER/cap/$filename alsasrc device="default" ! audio/x-raw,rate=48000,channels=2 ! audioconvert ! voaacenc bitrate=256000 ! aacparse ! queue ! mux. &
key=0
sleep 2
echo "recording..."
while true
do
read -n1 -s key
if [ $key = 1 ]; then
kill -SIGINT $!
echo "stopped"
break
else
echo "wrong input!"
fi
done
fi
fi
sleep 1
done
