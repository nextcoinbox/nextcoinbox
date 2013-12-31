#!/bin/bash
#set -x

file_url='http://info.nxtcrypto.org/nxt-client-0.4.8.zip'
expected_sha='ec7c30a100717e60d8abe50eedb23641952847d91ff90b9b05a74ff98d8a4cf2  nxt-client-0.4.8.zip'
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
wget $file_url

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



