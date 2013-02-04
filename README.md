# Blackhole

## Overview
**blackhole**, UDP Nonblock Log Aggregator Server  
## Requirements
- >= Ruby 1.9.0
- MongoDB

## Install
    $ gem install blackhole
    

## Start
    Usage: Blackhole [options]
    == Blackhole ==

    Starting Blackhole
    =================================================================================
    Options:
            --pidfile PATH               DO YOU WANT ME TO WRITE A PIDFILE SOMEWHERE FOR U?
            --logfile PATH               I'LL POOP OUT LOGS HERE FOR U
        -v, --verbosity LEVEL            HOW MUCH POOP DO U WANT IN UR LOGS? [LEVEL=0:errors,1:some,2:lots of poop]
        -K, --kill                       SHUT DOWN Blackhole
        -H, --host HOST                  Blackhole will be place this Network Interface
        -P, --port PORT                  Blackhole pull log from this hole
            --mongodb DATABASE           STORE LOGS IN THIS DB
            --mongohost HOSTPORT         STORE LOGS IN THIS MONGO [eg, localhost or localhost:27017]
        -h, --help                       WANNA LEARN MORE?

## Feed Log
    $ gem install remote_syslog
    $ remote_syslog -d [blackhole_host] -p [blackhole_port] [logfile_path]

## ToDo
- delete old log automatically ( by config?)
- make it as a gem blackhole
