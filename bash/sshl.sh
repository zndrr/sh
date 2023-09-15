#!/bin/bash

##### Log files will look such for Global and Local respectively
# ! /var/log/ssh/jump-box/2023-09/15/14-25__zndrr__opnsense.local.log
# !   /home/zndrr/log/ssh/2023-09/15/14-25__zndrr__opnsense.local.log

# Setting variables
logHost="$(hostname -f)"
logDate="$(date +%Y-%m)/$(date +%d)"
logUser="$(whoami)"
logRoot="/var/log/ssh"
logGlobal="${logRoot}/${logHost}"
logLocal="${HOME}/log/ssh"
logTime="$(date +%H-%M)"

logStart="$(date +%s)"
logDir="${logLocal}/${logDate}"
# Checks for write perms in global directories. Local if not.
if [[ ! -w "${logRoot}" ]] || [[ ! -w "${logGlobal}" ]]; then
  printf '\n%b\n' "Global log dir issue (likely permissions). Logging locally ..."
else
  logDir="${logGlobal}/${logDate}"
fi
logFile="${logDir}/${logTime}__${logUser}"
# Creates log dirs if absent (mostly Day, but less often Month).
if [[ ! -d "${logDir}" ]]; then mkdir -p "${logDir}"; fi
printf '\n%b\n\n' "Logging started at ${logTime} hours ..."
#--- THE MEAT AND POTATOES BURIED RIGHT HERE.
ssh "$1" | tee -a "${logFile}__$1.log"
# Prints useful message on fail exception.
if [[ ! -f "${logFile}__$1.log" ]]; then
  printf '\n%b\n' "... Logging failed! Likely SSH issue ..."
else
  # Checks for a generated log. Purges if empty (eg failed login).
  if [[ -f "${logFile}__$1.log" ]]; then
    #if [[ -z $(grep '[^[:space:]]' "${logFile}__$1.log") ]]; then
    if [[ ! -s "${logFile}__$1.log" ]]; then
      printf '\n%b\n\n' "... Logging failed! Likely session issue ..."
      rm "${logFile}__$1.log"
    # Homestretch! Gives you session duration in seconds and ...
    # Prints out log dir location with cat for easy access.
    else
      logEnd="$(date +%s)";
      printf '\n%b' "... Logging finished! Duration $((logEnd-logStart)) seconds. Location:"
      printf '\n%b\n\n' "  cat ${logFile}__$1.log"
    fi
  fi
fi
