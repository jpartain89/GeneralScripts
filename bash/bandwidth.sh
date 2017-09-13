#!/bin/bash -e

# Run speedtests against 3 servers and save all output results in CSV file for import to sqlite db
# run by cronjob once per hour
# from https://www.howtoforge.com/tutorial/how-to-use-speedtest-on-a-linux-server-to-check-store-and-report-internet-speeds-graphically/

function getCSVString () {
  # if speedtest failed (e.g. it couldn't access a server) we need to create a dummy
  # zero entry for this time slot
  # Get a timestamp string in the same format that speedtest generates - and we need UTC time
  local RIGHTNOW=$(date --utc +%Y-%m-%dT%H:%M:%SZ)

# test/debug case only
    if [ $1 = "199999999" ]
    then
        echo "99999,Test,Test,$RIGHTNOW,99.99,0.0,0.0,0.0"
    fi
}

function runTest () {
  # run speedtest against named server with csv output saved in tmp file
  /usr/local/bin/speedtest --csv --server $1 > /usr/local/etc/speedtest.tmp

  if [ $? -gt 0 ]; then
    # speedtest failed so create a zero entry in place of any error message
    getCSVString $1 > /usr/local/etc/speedtest.tmp
  fi

  # save output ready for next server test
  cat /usr/local/etc/speedtest.tmp >> /usr/local/etc/speedtest.csv
}

# main
#######
# run speedtest against 3 servers and save all output results in csv file
cd /usr/local/etc

# clear csv file - needs to be empty at start of run
rm -f /usr/local/etc/speedtest.csv

############################################
# test/debug case - forces speedtest to fail
############################################
# runTest "199999999"
# sleep 5
####### comment out after testing ##########
############################################

runTest "5023"
sleep 10

runTest "10386"
sleep 10

runTest "3501"
sleep 1

# now import the csv data in to sqlite db
sqlite3 -batch /usr/local/etc/bandwidth.db << "EOF"
.separator ","
.import /usr/local/etc/speedtest.csv bandwidth
EOF

# add current run csv to backup
cat /usr/local/etc/speedtest.csv >> /usr/local/etc/speedtest.bak
