#!/usr/bin/env bash

# constant
LOGFILE="daemon.log"
LOGMASTERFILE="daemon.master.log"
PIDFILE="daemon.pid"
PIDMASTERFILE="daemon.master.pid"

# variables
ACTION=$1
COMMAND=$2
INTERVAL=$3 
PID=''

if [ -z "$INTERVAL" ] ; then
  INTERVAL=1
fi


start_process() {
  if [ -z "$COMMAND" ] ; then
    echo "Usage: $0 start <command>" >&2
    exit 1
  fi
  $COMMAND &> $LOGFILE &
  PID=$!
  echo $PID > $PIDFILE
}

monitor() {
  while true 
  do
    PSLINE=$(ps $PID | wc -l)
    if [ -n "$PID" -a $PSLINE -eq 1 ]; then
      start_process
      echo restart
    fi
    echo $PSLINE
    sleep $INTERVAL 
  done;
}

stop() {
  if [ -e $PIDMASTERFILE ] ; then
    kill $(cat $PIDMASTERFILE)
    rm $PIDMASTERFILE 
    echo "master has stop"
  fi

  if [ -e $PIDFILE ] ; then
    kill $(cat $PIDFILE)
    rm $PIDFILE 
    echo "child has stop"
  fi
}

start_monitor() {
  (monitor &> $LOGMASTERFILE&  echo $! > $PIDMASTERFILE)
}


case $ACTION in
  start)
    start_process
    start_monitor
    echo "Write log in deamon.log"
    ;;
  stop)
    stop
    ;;
  *)
    echo "Usage: $0 {start <command>|stop}" >&2
    exit 1
    ;;
esac
  
exit 0
