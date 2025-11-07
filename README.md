# PI-Cap
Various scripts for recording Video an Audio with an Raspberry pi using the integrated encoder
![camera](https://github.com/benni092/PI-Cap/blob/main/Images/20251024_131558.jpg)
To change video from pal to ntsc:

Open /home/pi/cap_usb.sh in a editor and find the line that contains gst-launch. Than change video/x-raw,width=720,height=576,framerate=30/1 to video/x-raw,width=720,height=480,framerate=30/1 and save it.

On the pi you can stop the script pressing strg+c and then type nano cap_usb.sh. Change the line and then press strg+x and y to save.

Feel free to change the bitrate too. I set it to 5mb/s but if you have a fast usb drive you can set it to 10mb/s or more.
