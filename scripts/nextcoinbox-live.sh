#!/bin/bash
set -x

file_url='http://files.nxtbase.com/nrs-0.4.7e.zip'
expected_sha='a30fb505e2f16709caba9f920436fb6db28c675b  nrs-0.4.7e.zip'
welcome_url='http://nextcoinbox.github.io/nextcoinbox/live_homepage.html'

if ! BROWSER=$(which firefox >/dev/null 2>/dev/null) ; then
  if ! BROWSER=$(which chromium 2>/dev/null) ; then
    if ! BROWSER=$(which google-chrome 2>/dev/null) ; then
      echo "no browser found!"
      exit 2
    fi
  fi
fi

#extract file name from url
downloaded_file=${file_url##*/}

echo "Downloading file"
#wget $file_url

if  echo $expected_sha | sha1sum -c ; then
  # check is fine, we can continue
  echo "file validity checked"
  echo "Decompressing archive"
  unzip -qq $downloaded_file
  echo "Starting nxt server"
  (cd nxt && java -jar start.jar >server.log 2>&1 &)&
  while ! netstat -nlp | grep 7875 ; do
    echo "waiting for server to start up"
    sleep 1
  done
  echo "Server Started"
  echo "Starting browser"
  $BROWSER $welcome_url
else
  # sha not correct
  echo "the file downloaded might not be safe to use, stopping here. (sha1 incorrect)"
  exit 1
fi



