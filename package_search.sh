#!/bin/bash

###########################
# Simple Package Searcher #
###########################


read -p "Username: " username
read -s -p "Password: " passw
read -p "What package do you whant to find?: " fin


comm_rpm="rpm -qa | grep "$fin
comm_dpkg="dpkg -l | grep "$fin
comm_hostname="hostname -s"
comm_os="which rpm >&/dev/null; echo $?"


readarray arr < ips.txt #Array of ips in file
for ip in ${arr[*]}
do
	ping -c 1 $ip >&/dev/null #Pinging hosts
	if [ $? -eq 0 ]
	then
		sshp="sshpass -p $passw ssh -q -o StrictHostKeyChecking=no $username@$ip "
		$sshp"exit"
		if [ $? -eq 0 ]
		then
			hostname=$($sshp"$comm_hostname; exit")
			os=$($sshp"$comm_os; exit")
			if [ $os -eq 0 ] #Rpm or dpkg?
			then
				packet=$($sshp"$comm_rpm; exit")
			else
				packet=$($sshp"$comm_dpkg; exit")
			fi
			if [ "$packet" == "" ]
			then
				echo -e "\n>>>>>ip: $ip\n>>>>>hostname: $hostname\n---------------\nNONE\n---------------\n"
			else
				echo -e "\n>>>>>ip: $ip\n>>>>>hostname: $hostname\n---------------\n$packet\n--------------\n"
			fi
		else
			echo ">>>WRONG LOGIN OR PASS<<<"
			exit 1
		fi
	else
		echo -e "\n>>>>>ip: $ip\n>>>>>host unreacheble\n---------------\n.....\n---------------"
	fi
done
exit 0
