#!/bin/sh
echo default path: $PATH
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games
echo sphinx-build: `which sphinx-build`
exec ./run-gp.pl --publish
