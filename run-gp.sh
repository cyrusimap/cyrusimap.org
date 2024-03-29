#!/bin/sh

set -e

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

basedir=/tmp/CYRUS_DOCS_BUILD_DIR/
target=$basedir/cyrusimap.github.io
imapsource25=$basedir/cyrus-imapd-2.5
imapsource30=$basedir/cyrus-imapd-3.0
imapsource32=$basedir/cyrus-imapd-3.2
imapsource34=$basedir/cyrus-imapd-3.4
imapsource36=$basedir/cyrus-imapd-3.6
imapsource38=$basedir/cyrus-imapd-3.8
imapsource310=$basedir/cyrus-imapd-3.10
imapsource=$basedir/cyrus-imapd
saslsource=$basedir/cyrus-sasl

# pull the target
mkdir -p $basedir
if [ -d "$target" ]; then
    git -C $target pull
else
    git clone git@github.com:cyrusimap/cyrusimap.github.io.git $target
    git -C $target config --add user.name cyrusdocgen
    git -C $target config --add user.email cyrusdocgen@users.noreply.github.com
fi

# make sure we have the source trees
test -d $saslsource || git clone https://github.com/cyrusimap/cyrus-sasl.git $saslsource
test -d $imapsource || git clone https://github.com/cyrusimap/cyrus-imapd.git $imapsource
test -d $imapsource25 || git clone https://github.com/cyrusimap/cyrus-imapd.git $imapsource25
test -d $imapsource30 || git clone https://github.com/cyrusimap/cyrus-imapd.git $imapsource30
test -d $imapsource32 || git clone https://github.com/cyrusimap/cyrus-imapd.git $imapsource32
test -d $imapsource34 || git clone https://github.com/cyrusimap/cyrus-imapd.git $imapsource34
test -d $imapsource36 || git clone https://github.com/cyrusimap/cyrus-imapd.git $imapsource36
test -d $imapsource38 || git clone https://github.com/cyrusimap/cyrus-imapd.git $imapsource38
test -d $imapsource310 || git clone https://github.com/cyrusimap/cyrus-imapd.git $imapsource310


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
rsync -av $imapsource30/docsrc/build/html/ $target/3.0

# add the 3.2 docs
cd $imapsource32
git fetch
git checkout -q origin/cyrus-imapd-3.2
cd docsrc
make html
rsync -av $imapsource32/docsrc/build/html/ $target/3.2

# add the 3.4 docs
cd $imapsource34
git fetch
git checkout -q origin/cyrus-imapd-3.4
cd docsrc
make html
rsync -av $imapsource34/docsrc/build/html/ $target/3.4

# add the 3.6 docs
cd $imapsource36
git fetch
git checkout -q origin/cyrus-imapd-3.6
cd docsrc
make html
rsync -av $imapsource36/docsrc/build/html/ $target/3.6

# add the 3.8 docs
cd $imapsource38
git fetch
git checkout -q origin/cyrus-imapd-3.8
cd docsrc
make html
rsync -av $imapsource38/docsrc/build/html/ $target
rsync -av $imapsource38/docsrc/build/html/ $target/stable
rsync -av $imapsource38/docsrc/build/html/ $target/3.8

# add the 3.10 docs
cd $imapsource310
git fetch
git checkout -q origin/cyrus-imapd-3.10
cd docsrc
make html
rsync -av $imapsource310/docsrc/build/html/ $target/3.10

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
git commit -m "automatic commit" || true ## FIXME
git push
