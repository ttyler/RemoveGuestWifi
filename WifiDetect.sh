#!/bin/bash

    #######################################################################################
	#			Copyright (c) 2015, D8 Services Ltd.  All rights reserved.                #
	#                                                                                     #
	#                                                                                     #
	#       THIS SOFTWARE IS PROVIDED BY D8 SERVICES LTD. "AS IS" AND ANY                 #
	#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED     #
	#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE        #
	#       DISCLAIMED. IN NO EVENT SHALL D8 SERVICES LTD. BE LIABLE FOR ANY              #
	#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    #
	#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;  #
	#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND   #
	#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT    #
	#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS #
	#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                  #
	#                                                                                     #
	#######################################################################################
# Written By Tomos Tyler 2015
		
# Version 1.1 - Added removal of "Preferred Network List"
# Version 1.0 - Inital Creation, only disconnect if Wifi ON and Network Found

disableNetwork="exampleSSID"
# Gather Port and current SSID
wifiPort=`networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/,/Ethernet/' | awk 'NR==2' | cut -d " " -f 2`
wifiPower=`networksetup -getairportpower en0 | cut -d " " -f 4`
preferredNetworks=`networksetup -listpreferredwirelessnetworks ${wifiPort}`

saveIFS=$IFS
IFS=$'\n\r\t'
parm=($preferredNetworks)
IFS=$saveIFS

GroupsTotal=${#parm[@]}
countGroups=$(( $GroupsTotal - 1 ))

if [[ $wifiPower == "On" ]];then
	SSID=`networksetup -getairportnetwork $wifiPort | cut -d " " -f 4`
	#echo "Notice: Wifi power available."
	else
	echo "Notice: Wifi power turned off, exiting."
	exit 0
fi

if [[ $SSID == "${disableNetwork}" ]];then
		echo "WARNING: Guest Wifi Detected, Disabling."
		networksetup -setairportpower ${wifiPort} off
		networksetup -removepreferredwirelessnetwork ${wifiPort} ${disableNetwork}
		networksetup -setairportpower ${wifiPort} on
fi

echo "Wifi List Total is $GroupsTotal"
echo "Count of Wifi networks is $countGroups"

for ((p=1;p<=$countGroups; p++)); do
	current=${parm[p]}
	   if [[ ${current} = ${disableNetwork} ]];then
			echo "NOTICE: Found item ${parm[p]}"
			echo "NOTICE: Removing ${parm[p]} from preferred list."
	      networksetup -removepreferredwirelessnetwork ${wifiPort} "${disableNetwork}"
	   fi
done
exit 0