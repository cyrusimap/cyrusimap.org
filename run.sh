#!/bin/sh

set -e

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

# set up a clean target
rm -rf /root/docs/target
rsync -av /root/docs/original/ /root/docs/target

# add the stable docs
cd /root/docs/cyrus-imapd-2.5/
git fetch
git checkout -q origin/cyrus-imapd-2.5
cd docsrc
make html
rsync -av /root/docs/cyrus-imapd-2.5/docsrc/build/html/ /root/docs/target
rsync -av /root/docs/cyrus-imapd-2.5/docsrc/build/html/ /root/docs/target/stable

# add the developent docs
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
