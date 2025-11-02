#gpio -g mode 4 out
led=0
while true
do
result=`ps -ef | grep "gst-launch-1.0" | grep -v "grep" | wc -l`
#echo $result
if [ $result = 1 ]; then
if [ $led = 0 ]; then
#gpio -g write 4 1
gpioset -z -t 0 -c /dev/gpiochip0 26=1
led=1
fi
else
if [ $led = 1 ]; then
#gpio -g write 4 0
gpioset -z -t 0 -c /dev/gpiochip0 26=0
led=0
fi
fi
sleep 1
done
