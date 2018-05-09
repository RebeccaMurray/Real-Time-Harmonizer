#!/bin/bash

# HARMO_PLAYER.SH
#
# This script is intended for a raspberry pi. It creates a pipe between the input
# and output default audio devices, and pitch-shifts the audio input before sending
# it to the output. The pitch-shift amount switches between three and four semitones
# depending on the state of GPIO pin 7.
#
# The script works by checking the state of GPIO pin 7 every 2 seconds. If the state has
# changed, it stops and then re-starts the pipe with the alternate semitone. For headless
# Raspberry Pi operation, this script should be called in ~/etc/rc.local like this:
#
# /home/pi/harmo_player.sh &
#
# The ampersand starts this script in the background, allowing the rest of rc.local to
# run and for the pi to finish starting up.
#
# The AlsaMixer Xox and WiringPi libraries must be installed for this script to work.

AUDIODEV=hw:1 play "| rec --buffer 1024 -d pitch +$(( 310 + 76 * $( gpio read 7  
) )) band 1.2k 1.5k" &

pstree $$

list_descendants ()
{
        local children=$(ps -o pid= --ppid "$1")

        for pid in $children
        do
                list_descendants "$pid"
        done

        echo "$children"
}

gpio_last=$( gpio read 7)
echo "starting gpio: $gpio_last"

jif [ $( gpio read 3) -eq "1" ]
then
        exit 1
fi

echo "exit command failed"

while true; do
        sleep 2
        gpio_now=$( gpio read 7)
        echo "current: $gpio_now"
        if [ $gpio_now -eq $gpio_last ]
        then
                continue
        fi

        echo "change detected, killing descendents"
        kill $(list_descendants $$)
        echo "changing!"
        sleep 1
        AUDIODEV=hw:1 play "| rec --buffer 1024 -d pitch +$(( 310 + 76 * $gpio_n
ow )) band 1.2k 1.5k" &
        echo "switched pitch"
        gpio_last=$gpio_now
        echo "end of loop"
done

pstree $$
kill $(list_descendants $$)
sleep 2
pstree $$