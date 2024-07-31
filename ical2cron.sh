#!/bin/bash

#Requres ical2list.py

listFile=~/.list
cronFile=~/.cron
icalFile=~/basic.ics
icalURL="https://calendar.google.com/calendar/ical/7717b1706fdaa08763580988cae03a162366314fcd9bad0700369b7234eb7a02%40group.calendar.google.com/public/basic.ics"
lookAheadDays=7
commonCommand="ring.sh"

#Clean up and retrieve ical file
rm ~/basic.ics
rm .list
mv "${cronFile}" ~/bkp/cron"$(date +%F)".bkp
echo "00 01  *  *  * ~/bin/ical2cron.sh                                 > /dev/null 2>&1" > "${cronFile}"
wget "${icalURL}"

#Exit if ical file does not exist
if [[ ! -f "${icalFile}" ]];then
  exit
fi

#Set Dates
dayStart=$(date -d today +%_d | sed 's/^[[:space:]]*//g')
monthStart=$(date -d today +%_m | sed 's/^[[:space:]]*//g')
dayEnd=$(date -d today+"${lookAheadDays}"days +%_d | sed 's/^[[:space:]]*//g')
monthEnd=$(date -d today+"${lookAheadDays}"days +%_m | sed 's/^[[:space:]]*//g')

#Run List Gen
~/bin/ical2list.py "${monthStart}" "${dayStart}" "${monthEnd}" "${dayEnd}" | sort > "${listFile}"

#Process List to Cron
lines=$(wc -l < "${listFile}")

while  [[ count -lt lines  ]]; do
    count=$((count+1))
    line=$(sed -n "${count}"\ p "${listFile}")
    lineDateTime=$(echo "${line}" | cut -d " " -f 1-2)
    lineCMD=$(echo "${line}" | cut -d " " -f 3-)
    lineCmdPad=$(printf '%-40s' "${lineCMD}")
    lineMinute=$(date -d "${lineDateTime}" +%M)
    lineHour=$(date -d "${lineDateTime}" +%H)
    lineDOM=$(date -d "${lineDateTime}" +%d)
    lineMonth=$(date -d "${lineDateTime}" +%b)
    if [[ -n "${lineCMD}" ]]; then
      echo "${lineMinute} ${lineHour} ${lineDOM} ${lineMonth} * ${commonCommand} \"${lineCmdPad}\" > /dev/null 2>&1" >> "${cronFile}"
    fi
done

crontab < .cron
