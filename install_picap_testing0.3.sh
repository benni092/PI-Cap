echo "
 +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+
 |P|i|c|a|p| |i|n|s|t|a|l|l|e|r|
 +-+-+-+-+-+ +-+-+-+-+-+-+-+-+-+"
 
sleep 3

read -p "Welcome to the PiCap install script.
What do you want?

1= Install PiCap for USB Capturecards (cheap mjpeg ones)
2= Install PiCap for CSI to HDMI bridge (tc358743)
3= Install PiCap for EZ-Cap capturing raw mjpeg with mp2 audio on a pi1 or zero (comming soon)
4= Uninstall PiCap
" userselect

if [ $userselect = 4 ]; then
rm /home/$USER/cap_csi.sh
rm /home/$USER/cap_csi_live.sh
rm /home/$USER/cap_usb.sh
rm /home/$USER/set_hdmi.sh
rm /home/$USER/check_gstreamer.sh
rm /home/$USER/edid.txt
mv /home/$USER/.bashrc.bak /home/$USER/.bashrc
sudo mv /boot/firmware/config.txt.old /boot/firmware/config.txt
else

sudo apt update
sudo apt -y install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-ugly gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-tools gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-alsa gpiod
if [ $? = 0 ]
then
if [ -d /home/$USER/cap ]
then
echo "folder cap already there, skipping"
else
mkdir /home/$USER/cap
fi
if [ -e /home/$USER/check_gstreamer.sh ]
then
echo "file check_gstreamer.sh already there, skipping"
else
cat > /home/$USER/check_gstreamer.sh <<EOF
#gpio -g mode 4 out
led=0
while true
do
result=\`ps -ef | grep "gst-launch-1.0" | grep -v "grep" | wc -l\`
#echo \$result
if [ \$result = 1 ]; then
if [ \$led = 0 ]; then
#gpio -g write 4 1
gpioset -z -t 0 -c /dev/gpiochip0 26=1
led=1
fi
else
if [ \$led = 1 ]; then
#gpio -g write 4 0
gpioset -z -t 0 -c /dev/gpiochip0 26=0
led=0
fi
fi
sleep 1
done
EOF
chmod 777 /home/$USER/check_gstreamer.sh
fi

if [ $userselect = 1 ]; then
if [ -e /home/$USER/cap_usb.sh ]
then
echo "file cap_usb.sh already there, skipping"
else
cat > /home/$USER/cap_usb.sh <<EOF
#!/bin/bash
#sudo cpufreq-set -g performance
v4l2-ctl -c brightness=0 &&
v4l2-ctl -c contrast=148 &&
v4l2-ctl -c saturation=180 &&
v4l2-ctl -c hue=0 &&
while true
do
key=0
read -n1 -s key
if [ \$key = 2 ]; then
cd /home/\$USER/cap
last=\$(ls *.ts | sort -V | tail -1)
cd
cvlc --play-and-exit /home/\$USER/cap/\$last &
fi
if [ \$key = 3 ]; then
sudo pkill vlc
fi
if [ \$key = 1 ]; then
cd /home/\$USER/cap
num=\$(ls picap*.ts | sort -V | tail -1 | grep -Eo "[0-9]{1,4}")
num=\$(( \$num + 1 ))
filename="picap-\$num.ts"
result=\`ps -ef | grep "gst-launch-1.0" | grep -v "grep" | wc -l\`
if [ \$result = 0 ]; then
gst-launch-1.0 v4l2src device=/dev/video0 ! 'image/jpeg,colorimetry=2:4:5:1,width=1280,height=720,framerate=30/1' ! jpegparse ! v4l2jpegdec ! v4l2convert  ! v4l2h264enc output-io-mode=5 extra-controls=controls,video_bitrate=5000000 ! "video/x-h264,profile=high,preset=veryfast,framerate=30/1,level=(string)4.2" ! mpegtsmux name=mux ! filesink location=/home/\$USER/cap/\$filename alsasrc device="default" ! audio/x-raw,rate=48000,channels=2,provide-clock=false ! audioconvert ! voaacenc bitrate=256000 ! aacparse ! queue ! mux. &
key=0
sleep 2
echo "recording..."
while true
do
read -n1 -s key
if [ \$key = 1 ]; then
kill -SIGINT \$!
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
EOF
chmod 777 /home/$USER/cap_usb.sh
fi
fi

if [ $userselect = 2 ]; then
if [ -e /home/$USER/cap_csi.sh ]
then
echo "file cap_csi.sh already there, skipping"
else
cat > /home/$USER/cap_csi.sh <<EOF
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
if [ \$key = 2 ]; then
cd /home/\$USER/cap
last=\$(ls *.mkv | sort -V | tail -1)
cd
cvlc --play-and-exit /home/\$USER/cap/\$last &
fi
if [ \$key = 3 ]; then
sudo pkill vlc
fi
if [ \$key = 1 ]; then
cd /home/\$USER/cap
num=\$(ls picap*.mkv | sort -V | tail -1 | grep -Eo "[0-9]{1,4}")
num=\$(( \$num + 1 ))
filename="picap-\$num.mkv"
result=`ps -ef | grep "gst-launch-1.0" | grep -v "grep" | wc -l`
if [ \$result = 0 ]; then
gst-launch-1.0 -e v4l2src ! "video/x-raw,framerate=60/1,format=UYVY" ! v4l2h264enc extra-controls="controls,h264_profile=4,h264_level=13,video_bitrate=5000000;" ! "video/x-h264,profile=high,level=(string)4.2" ! h264parse ! queue ! matroskamux name=mux ! filesink location=/home/\$USER/cap/\$filename alsasrc device="default" ! audio/x-raw,rate=48000,channels=2 ! audioconvert ! voaacenc bitrate=256000 ! aacparse ! queue ! mux. &
key=0
sleep 2
echo "recording..."
while true
do
read -n1 -s key
if [ \$key = 1 ]; then
kill -SIGINT \$!
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
EOF
chmod 777 /home/$USER/cap_csi.sh
fi
fi

if [ $userselect = 2 ]; then
if [ -e /home/$USER/cap_csi_live.sh ]
then
echo "file cap_csi_live.sh already there, skipping"
else
cat > /home/$USER/cap_csi_live.sh <<EOF
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
if [ \$key = 2 ]; then
cd /home/\$USER/cap
last=\$(ls *.ts| sort -V | tail -1)
cd
cvlc --play-and-exit /home/\$USER/cap/\$last &
fi
if [ \$key = 3 ]; then
sudo pkill vlc
fi
if [ \$key = 1 ]; then
cd /home/\$USER/cap
num=\$(ls picap*.ts | sort -V | tail -1 | grep -Eo "[0-9]{1,4}")
num=\$(( \$num + 1 ))
filename="picap-\$num.ts"
result=\`ps -ef | grep "gst-launch-1.0" | grep -v "grep" | wc -l\`
if [ \$result = 0 ]; then
gst-launch-1.0 -e v4l2src ! "video/x-raw,framerate=60/1,format=RGB,colorimetry=sRGB" ! capssetter caps="video/x-raw,format=BGR" ! tee name=t ! queue ! kmssink t. ! queue ! v4l2h264enc output-io-mode=5 extra-controls="controls,h264_profile=4.2,h264_level=13,video_bitrate=5000000;" ! "video/x-h264,profile=high,level=(string)4.2,tune=zerolatency" ! mpegtsmux name=mux ! filesink location=/home/\$USER/cap/\$filename alsasrc device="default" ! audio/x-raw,rate=48000,channels=2 ! tee name=a ! queue ! audioconvert ! voaacenc bitrate=256000 ! aacparse ! queue ! mux. a. ! queue ! autoaudiosink &
key=0
sleep 2
echo "recording..."
while true
do
read -n1 -s key
if [ \$key = 1 ]; then
kill -SIGINT \$!
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
EOF
chmod 777 /home/$USER/cap_csi_live.sh
fi
fi

if [ $userselect = 2 ]; then
if [ -e /home/$USER/set_hdmi.sh ]
then
echo "file set_hdmi.sh already there, skipping"
else
cat > /home/$USER/set_hdmi.sh <<EOF
#!/bin/sh
sleep 1
v4l2-ctl -d /dev/video0 --set-edid=file=/home/\$USER/edid.txt
sleep 1
v4l2-ctl --set-dv-bt-timings query
EOF
chmod 777 /home/$USER/set_hdmi.sh
fi
fi

if [ $userselect = 2 ]; then
if [ -e /home/$USER/edid.txt ]
then
echo "file edid.txt already there, skipping"
else
echo "00ffffffffffff005262888800888888
1c150103800000780aEE91A3544C9926
0F505400000001010101010101010101
010101010101011d007251d01e206e28
5500c48e2100001e8c0ad08a20e02d10
103e9600138e2100001e000000fc0054
6f73686962612d4832430a20000000FD
003b3d0f2e0f1e0a202020202020014f
020321434e041303021211012021a23c
3d3e1f2309070766030c00300080E300
7F8c0ad08a20e02d10103e9600c48e21
0000188c0ad08a20e02d10103e960013
8e210000188c0aa01451f01600267c43
00138e21000098000000000000000000
00000000000000000000000000000000
00000000000000000000000000000028" > /home/$USER/edid.txt
fi
fi

if [ $userselect = 3 ]; then
if [ -e /home/$USER/cap_usb.sh ]
then
echo "file cap_usb.sh already there, skipping"
else
#cat > /home/$USER/cap_usb.sh <<EOF
echo "this will be added in the future"
#EOF
fi
fi

read -p "Do you want to autostart with bashrc? " test
if [ $test = y ]; then
if [ $userselect = 1 ]; then
cp /home/$USER/.bashrc /home/$USER/.bashrc.bak

cat >> /home/$USER/.bashrc <<EOF

if [[ -z \$DISPLAY ]]
then
/home/\$USER/check_gstreamer.sh &
/home/\$USER/cap_usb.sh
fi
EOF
fi

if [ $userselect = 2 ]; then
read -p "Do you want a live video output via kms?" test2
if [ $test2 = y ]; then
cp /home/$USER/.bashrc /home/$USER/.bashrc.bak

cat >> /home/$USER/.bashrc <<EOF

if [[ -z \$DISPLAY ]]
then
/home/\$USER/set_hdmi.sh
/home/\$USER/check_gstreamer.sh &
#/home/\$USER/cap_csi.sh
/home/\$USER/cap_csi_live.sh
fi
EOF
else
cp /home/$USER/.bashrc /home/$USER/.bashrc.bak

cat >> /home/$USER/.bashrc <<EOF

if [[ -z \$DISPLAY ]]
then
/home/\$USER/set_hdmi.sh
/home/\$USER/check_gstreamer.sh &
/home/\$USER/cap_csi.sh
#/home/\$USER/cap_csi_live.sh
fi
EOF
fi
fi
fi

if [ $userselect = 1 ]; then
read -p "Do you want some entrys for gpio-key,gpio-shutdown in config.txt? " test4
if [ $test4 = y ]; then

sudo cp /boot/firmware/config.txt /boot/firmware/config.txt.old

sudo sh -c "cat >> /boot/firmware/config.txt <<EOF
dtoverlay=gpio-shutdown
dtoverlay=gpio-key,gpio=16,keycode=2,label=\"KEY_1\",gpio_pull=2
EOF"
echo "
----------------------------------------------------------------
| powerbutton is set to gpio3 and record/stop button to gpio16 |
----------------------------------------------------------------"
fi
fi

if [ $userselect = 2 ]; then
read -p "Do you want some entrys for tc358743,gpio-key,gpio-shutdown in config.txt?" test5
if [ $test5 = y ]; then

sudo cp /boot/firmware/config.txt /boot/firmware/config.txt.old

sudo sh -c "cat >> /boot/firmware/config.txt <<EOF
dtoverlay=gpio-shutdown
dtoverlay=gpio-key,gpio=16,keycode=2,label=\"KEY_1\",gpio_pull=2
dtoverlay=tc358743
dtoverlay=tc358743-audio
EOF"
echo "
-----------------------------------------------------------------
| powerbutton is set to gpio3 and record/stop button to gpio16  |
| tc358743 loaded                                               |
-----------------------------------------------------------------"
fi
fi

read -p "Install Samba-share? " test3
if [ $test3 = y ]; then
username=$USER
sudo apt install -y samba samba-common smbclient
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf_alt
cat >> /home/$USER/smb.conf <<EOF
[global]
workgroup = WORKGROUP
security = user
encrypt passwords = yes
client min protocol = SMB2
client max protocol = SMB3
[Video]
comment = PiCap-share
path = /home/$username/cap
read only = no
EOF
sudo mv /home/$USER/smb.conf /etc/samba/smb.conf
sleep 1
sudo service smbd restart
sudo service nmbd restart
sudo smbpasswd -a pi
fi
else
echo "An error happens :-("
fi
fi
if [ $userselect = 4 ]; then
echo "Uninstall complete!"
else
echo "All done! Have fun with PiCap!"
fi
sleep 3
