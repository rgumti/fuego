#!/bin/bash
# Author: Raymond "papiFresco" Gumti
# Description: Start PCoIP Client Softare.

set  -eu

#Allow Docker to Access Display
xhost +local:docker

docker run --rm -it -d \
	-e DISPLAY=$DISPLAY \
	-h localhost \
	-v $(pwd)/.config/:/home/fresco/.config/Teradici \
       	-v $(pwd)/.logs:/tmp/Teradici/$USER/PCoIPClient/logs \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	pcoip-client
