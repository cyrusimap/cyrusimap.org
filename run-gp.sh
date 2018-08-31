#!/bin/sh

set -e

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

target=/home/ellie/fastmail/cyrusimap.github.io
imapsource25=/home/ellie/fastmail/build/cyrus-imapd-2.5
imapsource30=/home/ellie/fastmail/build/cyrus-imapd-3.0
imapsource=/home/ellie/fastmail/build/cyrus-imapd
saslsource=/home/ellie/fastmail/build/cyrus-sasl

# set up a clean target
#rm -rf /root/docs/target
#rsync -av /root/docs/original/ /root/docs/target

# add files from this repo
# XXX there's probably a better way to achieve this
#cp -p /root/docs/robots.txt /root/docs/target/
#cp -p /root/docs/sitemapindex.xml /root/docs/target/

# add the 2.5 docs
cd $imapsource25
git fetch
git checkout -q origin/cyrus-imapd-2.5
cd docsrc
make html
rsync -av $imapsource25/docsrc/build/html/ $target/2.5

# add the 3.0 docs
cd $imapsource30
git fetch
git checkout -q origin/cyrus-imapd-3.0
cd docsrc
make html
rsync -av $imapsource30/docsrc/build/html/ $target
rsync -av $imapsource30/docsrc/build/html/ $target/stable
rsync -av $imapsource30/docsrc/build/html/ $target/3.0

# add the development docs
cd $imapsource
git fetch
git checkout -q origin/master
cd docsrc
make html
rsync -av $imapsource/docsrc/build/html/ $target/dev

# add sasl
cd $saslsource
git fetch
git checkout -q origin/master
cd docsrc
make html
rsync -av $saslsource/docsrc/build/html/ $target/sasl

# copy the new docs to the website
cd $target
git add --all
git commit -m "automatic commit"
git push
