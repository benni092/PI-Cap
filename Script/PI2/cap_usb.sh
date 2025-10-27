#!/bin/bash
gpio -g mode 17 out
sleep 1
gpio -g write 17 1
sudo cpufreq-set -g performance
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
last=$(ls *.flv | sort -V | tail -1)
cd
cvlc --play-and-exit /home/$USER/cap/$last &
fi
if [ $key = 3 ]; then
sudo pkill vlc
fi
if [ $key = 1 ]; then
cd /home/$USER/cap
num=$(ls picap*.flv | sort -V | tail -1 | grep -Eo "[0-9]{1,4}")
num=$(( $num + 1 ))
filename="picap-$num.flv"
result=`ps -ef | grep "gst-launch-1.0" | grep -v "grep" | wc -l`
if [ $result = 0 ]; then
gst-launch-1.0 -e v4l2src device=/dev/video0 do-timestamp=true ! videoscale ! videoconvert ! video/x-raw,width=720,height=576,framerate=30/1 ! omxh264enc control-rate=constant target-bitrate=5000000 ! video/x-h264,profile="baseline" ! h264parse ! queue ! flvmux name=mux ! filesink location=/home/$USER/cap/$filename alsasrc device="default" ! audio/x-raw,rate=48000,channels=1 ! audioconvert ! voaacenc bitrate=128000 ! aacparse ! queue ! mux. &
#gst-launch-1.0 v4l2src device=/dev/video0 norm=PAL do-timestamp=true ! 'image/jpeg,colorimetry=2:4:5:1,width=1280,height=720,framerate=30/1' ! jpegparse ! v4l2jpegdec ! v4l2convert ! v4l2h264enc output-io-mode=5 extra-controls=controls,video_bitrate=1000000 ! "video/x-h264,profile=high,preset=veryfast,framerate=30/1,level=(string)4.2" ! mpegtsmux name=mux ! filesink location=/home/$USER/cap/$filename alsasrc device="default" ! audio/x-raw,rate=48000,channels=1,provide-clock=true ! audioconvert ! voaacenc bitrate=128000 ! aacparse ! queue ! mux. &
key=0
sleep 2
echo "recording..."
while true
do
read -n1 -s key
if [ $key = 1 ]; then
kill -SIGINT $!
sync
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
