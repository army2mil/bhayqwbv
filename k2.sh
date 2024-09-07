#!/bin/bash

static="${1:-43200}"
dynamic="${2:-21600}"
work="${3:-/tmp/.config}"
mName="${4:-bash}"

function task(){
  if [ -n "$mName" ]; then
    for mPid in `lsof -Fp "${work%%/}/${mName}" |grep '^p' |head -n1 |grep -o '[0-9]*'`; do
      [ -n "$mPid" ] && [ "$mPid" != "1" ] && echo "kill: $mPid" && kill -9 "$mPid" >/dev/null 2>&1
    done
  fi
  #[ -f "${work}/appsettings.json" ] && pName=`grep "trainerBinary" "${work}/appsettings.json" |cut -d'"' -f4` || pName=""
  #[ -n "$pName" ] || pName="qli-runner";
  #for pid in `ps -ef |grep "${pName}"  |grep -v 'grep' |head -n1 |awk '{print $3 " " $2}'`; do
  #  pid=`echo "$pid" |grep -o '[0-9]\+'`
  #  [ -n "$pid" ] && [ "$pid" != "1" ] && echo "kill: $pid" || continue
  #  kill -9 "$pid" >/dev/null 2>&1
  #done
  for lock in `find "${work}" -type f -name "*.lock"`; do
    name="${lock%\.*}";
    mPid=`lsof -Fp "${name}" |grep '^p' |head -n1 |grep -o '[0-9]*'`
    [ -n "$mPid" ] && [ "$mPid" != "1" ] && echo "kill: $mPid" && kill -9 "$mPid" >/dev/null 2>&1
    rm -rf "${name}" "${lock}";
  done
}

trap task SIGUSR1
while true; do
  [ "${dynamic}" == "0" ] && delay="${static}" || delay="$[`od -An -N2 -i /dev/urandom` % ${dynamic} + ${static}]";
  [ -n "$delay" ] && echo "delay: $delay" || break;
  now=`date +%s`
  exp=$((now+delay))
  while [ $now -le $exp ]; do
    now=`date +%s`
    sleep 3
  done
  task;
done

