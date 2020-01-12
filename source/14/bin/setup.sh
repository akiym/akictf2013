#!/bin/bash

if [ -a ../q14-session ]; then
    rm -rf ../q14-session
fi
mkdir ../q14-session

if [ -a db/production.db ]; then
    rm db/production.db
fi

bin/appperl vendor/bin/carton exec -- bin/appperl script/setup-session.pl

chown ctfq14:ctfq14 ../q14-session
chown -R ctfq14:ctfq14 db
