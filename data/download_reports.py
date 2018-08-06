#import pip

#pip.main(['install','gspread'])

import gspread
from datetime import date 
from datetime import timedelta
import urllib.request as urllib2

link = "https://www.spc.noaa.gov/climo/reports/"
hailCsv= "_rpts_hail.csv"
today = str(date.today() - timedelta(1))
today = today.replace("20", "")
today = today.replace("-", "")

#retrieve stuff
hailUrl = link + today + hailCsv
response = urllib2.urlopen(hailUrl)
for row in response:
    print (row)
