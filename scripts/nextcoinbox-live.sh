#!/bin/bash
#set -x

file_url='http://download.nxtcrypto.org/nxt-client-0.5.6e.zip'
expected_sha='680490992bc853bcfb988683f7c4de2d41e44636f4911a95544fd44f2d663762	nxt-client-0.5.6e.zip'
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

if  echo $expected_sha | sha256sum -c ; then
  # check is fine, we can continue
  echo "file validity checked"
  echo "Decompressing archive"
  unzip -qq $downloaded_file
  cd nxt
  wget https://github.com/nextcoinbox/nextcoinbox/raw/staging/files/blocks.nxt.gz
  gunzip blocks.nxt.gz
  wget https://github.com/nextcoinbox/nextcoinbox/raw/staging/files/transactions.nxt.gz
  gunzip transactions.nxt.gz
  wget https://github.com/nextcoinbox/nextcoinbox/raw/staging/files/web.xml.gz
  gunzip web.xml.gz
  mv web.xml webapps/root/WEB-INF/
  cd ..
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
  echo "the file downloaded might not be safe to use, stopping here. (sha incorrect)"
  exit 1
fi



