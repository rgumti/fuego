#!/bin/bash
#Author Ray "papiFresco" Gumti

set -eu

if [ -f /etc/netdata/netdata.conf ]; then
	logger -t "$(basename "$0")" "/etc/netdata/netdata.conf found. Netdata already installed"
	exit 1
else
	#make a working directory
	mkdir /tmp/netdata

	#download the installer
	wget -qP /tmp/netdata https://my-netdata.io/kickstart.sh

	#make it executable
	chmod +x /tmp/netdata/kickstart.sh

	#run the installer without requiring user interaction
	/tmp/netdata/kickstart.sh --non-interactive

	#log that badboi
	logger -t "$(basename "$0")" echo "NETDATA INSTALLED and can be reached at http://$(hostname -f):19999"

	#enable netdata
	systemctl enable netdata
	logger -t "$(basename "$0")" "Netdata enabled on boot via systemctl"

	#check if KSM is available. If its available enable it, if not don't.
	KSM_CHECK=$(grep KSM /boot/config-"$(uname -r)")

	if [ "$KSM_CHECK" = 'CONFIG_KSM=y' ]; then

        	echo 1 >/sys/kernel/mm/ksm/run
        	echo 1000 >/sys/kernel/mm/ksm/sleep_millisecs
		systemctl enable ksm
	        logger -t "$(basename "$0")" "Kernel Same-Page Merging Enabled"

	else

        	logger -t "$(basename "$0")" echo "Kernel Same-Page Merging NOT AVAILABLE"
	        

	fi

fi

NVIDIA_USED=$(lsmod | awk '$1 == "nvidia"' |awk '{print $3}')
NVIDIA_STATUS=$([[ ! -z "$NVIDIA_USED" ]] && echo "Not_Empty" || echo "Empty")
if [ "$NVIDIA_STATUS" = "Not_Empty" ] && (( "$NVIDIA_USED" > 0 )) && ! [ -f /etc/netdata/python.d/nv.conf ] ; then
	logger -t "$(basename "$0")" "Installing Netdata Nvidia Plugin"

	#make working directory
	logger -t "$(basename "$0")" "making an installation directory /tmp/netdata/nvidia"
	mkdir /tmp/netdata/nvidia && cd /tmp/netdata/nvidia/
	
	#clone nv_plugin repo
	logger -t "$(basename "$0")" "Cloning required repo"
	git clone https://github.com/Splo0sh/netdata_nv_plugin --depth 1 /tmp/netdata/nvidia/
	
	#nv.chart.py
	if ! [ -f /usr/libexec/netdata/python.d/nv.chart.py ]; then
		cp /tmp/netdata/nvidia/nv.chart.py /usr/libexec/netdata/python.d/
		logger -t "$(basename "$0")" "/usr/libexec/netdata/python.d/nv.chart.py created"

	else

		logger -t "$(basename "$0")" "/usr/libexec/netdata/python.d/nv.chart.py already exists"

	fi
	
	#pynvml.py
	if ! [ -f /usr/libexec/netdata/python.d/python_modules/pynvml.py ]; then
		cp /tmp/netdata/nvidia/python_modules/pynvml.py /usr/libexec/netdata/python.d/python_modules/
		logger -t "$(basename "$0")" "/usr/libexec/netdata/python.d/python_modules/pynvml.py created"

	else

		logger -t "$(basename "$0")" "/usr/libexec/netdata/python.d/python_modules/pynvml.py already exists"

	fi
	
	#nv.conf
	if ! [ -f /etc/netdata/python.d/nv.conf ]; then
		cp /tmp/netdata/nvidia/nv.conf /etc/netdata/python.d/
		logger -t "$(basename "$0")" "/etc/netdata/python.d/nv.conf created"

	else

		logger -t "$(basename "$0")" "/etc/netdata/python.d/nv.conf already exists"


	fi

	#restart service to start polling nvidia card
	systemctl restart netdata
else
	logger -t "$(basename "$0")" "Nvidia Netdata Plugin already installed or no Nvidia card present"
	exit 0
	
fi

        rm -rf /tmp/netdata
        logger -t "$(basename "$0")" "Netdata installation directory removed"
        logger -t "$(basename "$0")" "TO UNINSTALL NETDATA: /usr/libexec/netdata/netdata-uninstaller.sh --yes -f "
	exit 0
