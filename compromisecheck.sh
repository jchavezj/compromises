#!/bin/bash
# This script locates possible code exploits
# in php. Not all files detected
# are compromised
#
# Author: Johnny Chavez
# Version: 0.1.0
# Version: 0.1.1
# date 20July2016
# colors to be used as a reference:
# Script: compromisecheck.sh

SCRIPTVER=0.1.1

red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
end=$'\e[0m'

# Defining the functions that will be used:

# this creates the header that will be used by the various functions

function write_header(){
	local h="$@"
	echo ${red}"*************************************************************************"${end}
	echo "     ${h}"
	echo ${red}"*************************************************************************"${end}
}

# searches for exploit scan
function xpscan {
	write_header "Now scanning /var/www/ "
	find ./ \( -regex '.*\.php$' -o -regex '.*\.cgi$' -o -regex '.*\.inc$' \) -print0 | xargs -0 egrep -il "$PATTERN" | sort
}

# searching for worpress versions

function wp {
	write_header "Now checking for wordpress versions"

        LATESTVERSION=$(curl -s http://api.wordpress.org/core/version-check/1.5/ | head -n 4 | tail -n 1)

        find /var/www -iname version.php > /root/version.txt
        grep "wp-includes" /root/version.txt > /root/version.txt1
        for i in `cat /root/version.txt1`; do echo "Installed path=`echo $i|dirname $i|awk -Fwp {'print $1'}`" ;
	    echo ${cyn}"The latest Wordpress version is $LATESTVERSION "${end} ;
	    echo "Currently Installed version = `grep "wp_version =" $i |cut -d '=' -f2`"; echo " ";
    	done
}

# This function will search the logs for injections

function process {
	write_header "Need to review these log files if they  have data from log file"
       for i in `locate access_log` ; do echo $i ; egrep -i '(chr\(|system\()|(wget|curl|perl|gcc|chmod|post)%20' $i ; done
}

# This will run unix-privesc-check which will search for security issues on the server

function pentest {
 	if [ ! -d "/home/rack/unix-privesc-check-1.4" ]
             then
                 cd /home/rack/
                 wget -q  http://pentestmonkey.net/tools/unix-privesc-check/unix-privesc-check-1.4.tar.gz
                 tar -xzvf unix-privesc-check-1.4.tar.gz
                 cd unix-privesc-check-1.4
  	         write_header "Checking for privilege escalation "
                 echo "Now writing to file /home/rack/compromise-$(date +%F).txt"
                ./unix-privesc-check detailed >  /home/rack/compromise-$(date +%F).txt
                echo ${cyn}"These are the warnings"${end}
                grep WARNING /home/rack/compromise-$(date +%F).txt
	        echo ${cyn} "These are the errors "${end}
	        grep -C2 "ERROR" /home/rack/compromise-$(date +%F).txt
             else
		cd /home/rack/unix-privesc-check-1.4
	        write_header "Checking for privilege escalation "
	        echo "Now writing to file /home/rack/compromise-$(date +%F).txt"
                ./unix-privesc-check detailed > /home/rack/compromise-$(date +%F).txt
                echo ${cyn}"These are the warnings"${end}
                grep WARNING /home/rack/compromise-$(date +%F).txt
                echo ${cyn} "These are the errors "${end}
                grep -C2 "ERROR" /home/rack/compromise-$(date +%F).txt
	fi
}

# This is the pattern to look for
PATTERN='base64_decode|r0nin|m0rtix|upl0ad|r57shell|99shell|shellbot|phpshell|void\.ru|phpremoteview|directmail|bash_history|\.ru/|brute*force|multiviews|cwings|vandal|bitchx|eggdrop|guardservices|psybnc|dalnet|undernet|vulnscan|spymeta|raslan58|Webshell'

# searches various sripts for possible exploints
printf "%s\n" ${mag}"**************** Beginning of  Scan  ****************"${end} ""
cd /var/www/
printf "%s\n" ${yel}"These are the files that match the pattern being searched"${end}
printf "%s\n" ${yel}"Have your developer verify these scripts before deleting or modifying"${end} ""

# Now calling the functions to work their foo.
  xpscan
  wp
  process
  pentest


printf "%s\n" ${mag}"**************** Scan complete ****************"${end}
