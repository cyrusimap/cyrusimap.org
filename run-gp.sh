#!/bin/sh

set -e

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

basedir=/tmp/JENKINS_BUILD_DIR/
target=$basedir/cyrusimap.github.io
imapsource25=$basedir/cyrus-imapd-2.5
imapsource30=$basedir/cyrus-imapd-3.0
imapsource=$basedir/cyrus-imapd
saslsource=$basedir/cyrus-sasl

# pull the target
mkdir -p $basedir
if [ -d "$target" ]; then
    git -C $target pull
else
    git clone -q https://github.com/cyrusimap/cyrusimap.github.io.git $target
fi

# make sure we have the source trees
test -d $saslsource || git clone -q https://github.com/cyrusimap/cyrus-sasl.git $saslsource
test -d $imapsource || git clone -q https://github.com/cyrusimap/cyrus-imapd.git $imapsource
test -d $imapsource25 || git clone -q https://github.com/cyrusimap/cyrus-imapd.git $imapsource25
test -d $imapsource30 || git clone -q https://github.com/cyrusimap/cyrus-imapd.git $imapsource30

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
