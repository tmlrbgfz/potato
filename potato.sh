#!/bin/bash

WORK=25
PAUSE=5
INTERACTIVE=true
CLEARLINE="\r"
MUTE=false
AUDIOFILE=/usr/share/sounds/speech-dispatcher/test.wav
PLAYER=aplay

#I'm not sure whether there are other packages providing a command named 'play'
# thus testing for sox and hoping that there is no package providing 'play' while sox is installed.
command -v sox 2>&1 >/dev/null
if [ $? -eq 0 ]; then
    PLAYER=play
else
    #check whether aplay is installed
    command -v aplay 2>&1 >/dev/null
    if [ $? -ne 0 ]; then
        MUTE=true
    fi
fi

show_help() {
	cat <<-END
		usage: potato [-i] [-m] [-w m] [-b m] [-a path] [-h]
		    -s: simple output. Intended for use in scripts
		        When enabled, potato outputs one line for each minute, and doesn't print the bell character
		        (ascii 007)

		    -m: mute -- don't play sounds when work/break is over
		    -w m: let work periods last m minutes (default is 25)
		    -b m: let break periods last m minutes (default is 5)
		    -a path: try to play file with aplay or sox, if installed and work/pause is over
		    -h: print this message
	END
}

while getopts :sw:b:a:m opt; do
	case "$opt" in
	s)
		INTERACTIVE=false
		CLEARLINE=""
	;;
	m)
		MUTE=true
	;;
	w)
		WORK=$OPTARG
	;;
	b)
		PAUSE=$OPTARG
	;;
    a)
        AUDIOFILE=$OPTARG
    ;;
	h|\?)
		show_help
		exit 1
	;;
	esac
done

time_left="%im left of %s"

if $INTERACTIVE; then
	time_left="\r$time_left"
else 
	time_left="$time_left\n"
fi

while true
do
	for ((i=$WORK; i>0; i--))
	do
		printf "$time_left" $i "work"
		sleep 1m
	done

	! $MUTE && $PLAYER $AUDIOFILE &>/dev/null &

	if $INTERACTIVE; then
		echo -e "\a"
		echo "Work over"
		read
	fi

	for ((i=$PAUSE; i>0; i--))
	do
		printf "$time_left" $i "pause"
		sleep 1m
	done
	! $MUTE && $PLAYER $AUDIOFILE &>/dev/null &
	if $INTERACTIVE; then
		echo -e "\a"
		echo "Pause over"
		read
	fi
done
