#!/usr/bin/python
import os
import requests as rt
import sys

if(len(sys.argv) != 3 ):
    print("Usage: ./get-input.py <DAY> <SESSION-COOKIE-FILE>")
    exit(1)

year = "2024"
day = int(sys.argv[1])
cookieFile = sys.argv[2]

f = open(cookieFile, "r")
cookie = f.read().strip()
f.close
print(cookie)


userAgent = "AocGetter (Local python script)"

if os.path.isfile(f"day{day}/input.txt"):
    print(f"Input for year: {year} day: {day} is already cached.")
    exit(0)

print(f"Getting input for year: {year} day: {day}")

s = rt.Session()
s.cookies.set('session', cookie, domain='.adventofcode.com')

#make request
r = s.get('https://adventofcode.com/' + str(year) + '/day/' + str(day) + '/input')
if r.status_code != 200:
    if r.status_code == 500:
        print('error: there was a server error. maybe your session cookie is wrong? (500)')
    elif r.status_code == 404:
        print('error: looks like there is no problem on the given date. (404)')
    else:
        print('error: http code ' + str(r.status_code))
    exit(1)
    
input = r.text

print(input)

# Put input in correct directory
os.makedirs(f"day{day}",exist_ok=True)
f = open(f"day{day}/input.txt", "w")
f.write(input)
f.close()

