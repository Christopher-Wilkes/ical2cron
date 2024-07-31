#!/usr/bin/python

from sys import argv
import icalendar
import recurring_ical_events
import urllib.request

startMonth = int(argv[1])
startDay = int(argv[2])
stopMonth = int(argv[3])
stopDay = int(argv[4])

start_date = (2024, startMonth, startDay)
end_date =   (2024, stopMonth, stopDay)
url = "file:///home/pi/basic.ics"

ical_string = urllib.request.urlopen(url).read()
calendar = icalendar.Calendar.from_ical(ical_string)
events = recurring_ical_events.of(calendar).between(start_date, end_date)
for event in events:
    start = event["DTSTART"].dt
    summary = event.get('summary', default='')
    description = event.get('description', '').split('\n')
    description = '\n'.join(map(lambda s: s.rjust(len(s)), description))
    print("{} {}".format(start, description))
