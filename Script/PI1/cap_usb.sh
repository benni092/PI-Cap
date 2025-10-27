#!/bin/bash
sudo cpufreq-set -g performance
#v4l2-ctl -c brightness=0 &&
#v4l2-ctl -c contrast=0 &&
#v4l2-ctl -c saturation=0 &&
#v4l2-ctl -c hue=0 &&
sudo mount -a
while true
do
key=0
read -n1 -s key
if [ $key = 2 ]; then
sudo umount -l /home/$USER/cap
echo "USB unmounted!"
#cd /home/$USER/cap
#last=$(ls *.mkv | sort -V | tail -1)
#cd
#cvlc --play-and-exit /home/$USER/cap/$last &
fi
if [ $key = 3 ]; then
#sudo pkill vlc
sudo mount -a
echo "USB mounted!"
fi
if [ $key = 1 ]; then
sudo mount -a &&
cd /home/$USER/cap
num=$(ls picap*.mkv | sort -V | tail -1 | grep -Eo "[0-9]{1,4}")
num=$(( $num + 1 ))
filename="picap-$num.mkv"
result=`ps -ef | grep "ffmpeg" | grep -v "grep" | wc -l`
if [ $result = 0 ]; then
#gst-launch-1.0 v4l2src device=/dev/video0 ! 'image/jpeg,colorimetry=2:4:5:1,width=720,height=576,framerate=30/1' ! jpegparse ! v4l2jpegdec ! videoconvert  ! v4l2h264enc output-io-mode=5 extra-controls=controls,video_bitrate=5000000 ! "video/x-h264,profile=high,preset=veryfast,framerate=30/1,level=(string)4.2" ! mpegtsmux name=mux ! filesink location=/home/$USER/cap/$filename alsasrc device="default" ! audio/x-raw,rate=48000,channels=2,provide-clock=false ! audioconvert ! voaacenc bitrate=256000 ! aacparse ! queue ! mux. &
ffmpeg -y -f v4l2 -standard PAL -s 720x576 -input_format mjpeg -framerate 60 -thread_queue_size 128 -i /dev/video0 -f alsa -thread_queue_size 128 -i default -c:a mp2 -c:v copy -map 0:v:0 -map 1:a:0 -f matroska -r 60 /home/$USER/cap/$filename &
key=0
sleep 4
echo "recording..."
gpioset gpiochip0 26=1
while true
do
read -n1 -s key
if [ $key = 1 ]; then
kill -SIGINT $!
echo "stopped"
echo "writing buffer to USB..."
sync
echo "Done! You can now unplug"
gpioset gpiochip0 26=0
break
else
echo "wrong input!"
fi
done
fi
fi
sleep 1
done
