#!/bin/sh

set -e

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

# set up a clean target
rm -rf /root/docs/target
rsync -av /root/docs/original/ /root/docs/target

# add files from this repo
# XXX there's probably a better way to achieve this
cp -p /root/docs/robots.txt /root/docs/target/
cp -p /root/docs/sitemapindex.xml /root/docs/target/

# add the 2.5 docs
cd /root/docs/cyrus-imapd-2.5/
git fetch
git checkout -q origin/cyrus-imapd-2.5
cd docsrc
make html
rsync -av /root/docs/cyrus-imapd-2.5/docsrc/build/html/ /root/docs/target/2.5

# add the 3.0 docs
cd /root/docs/cyrus-imapd-3.0/
git fetch
git checkout -q origin/cyrus-imapd-3.0
cd docsrc
make html
rsync -av /root/docs/cyrus-imapd-3.0/docsrc/build/html/ /root/docs/target
rsync -av /root/docs/cyrus-imapd-3.0/docsrc/build/html/ /root/docs/target/stable
rsync -av /root/docs/cyrus-imapd-3.0/docsrc/build/html/ /root/docs/target/3.0

# add the 3.2 docs
cd /root/docs/cyrus-imapd-3.2/
git fetch
git checkout -q origin/cyrus-imapd-3.2
cd docsrc
make html
rsync -av /root/docs/cyrus-imapd-3.2/docsrc/build/html/ /root/docs/target/3.2

# add the development docs
cd /root/docs/cyrus-imapd/
git fetch
git checkout -q origin/master
cd docsrc
make html
rsync -av /root/docs/cyrus-imapd/docsrc/build/html/ /root/docs/target/dev

# add sasl
cd /root/docs/cyrus-sasl/
git fetch
git checkout -q origin/master
cd docsrc
make html
rsync -av /root/docs/cyrus-sasl/docsrc/build/html/ /root/docs/target/sasl

# copy the new docs to the website
rsync -av --delete /root/docs/target/ /var/www/html
