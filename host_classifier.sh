#!/bin/bash
# -----------------------------------------------------------------------------
#        File: parser.sh
# Description: Parse inventory file for OS and environment types.
#      Inputs: Structured inventory file with hostnames xxxxxyzxxxnnn.domain.tld
#              x = any alpha/numeric character (any length after z)
#              y = environment [ p | d | * ]
#              z = OS type [ l | w | * ]
#              n = any numeric character (any length)
#              Example: usoh4pltst01.domain.tld
#      Author: R.Paxton
#        Date: 2019.05.13
# -----------------------------------------------------------------------------

typeset -i THosts=0 LHosts=0 WHosts=0 OHosts=0 PEnv=0 DEnv=0 OEnv=0

## Matching example
C1=$(printf '\033[38;5;034m')
C2=$(printf '\033[38;5;196m')
C0=$(printf '\033[0;00m')

## Check for inventory file
if [[ $# -lt 1 ]]; then
  echo -e "\n  ${C2}ERROR[1]:${C0} Must supply inventory file name to parse."
  exit 1
elif [[ ! -r $1 ]]; then
  echo -e "\n  ${C2}ERROR[2]:${C0} Unable to read '$1'."
  exit 2
fi

while [[ $# -gt 0 ]]; do
  inFile="$1"

  while read LINE; do
    ## Ensure all are lowercase
    LINE=$(tr '[:upper:]' '[:lower:]' <<< "$LINE")
  
    ## Check if LINE is proper hostname.
    _PRE=${LINE:0:5}
    if [[ $_PRE == 'usoh4' ]]; then
  
      ## Extract environment type
      _ENV=${LINE:5:1}
      ## Extract OS type
      _OS=${LINE:6:1}
      ## Count total number of hosts
      ((THosts++))
    
      ## Count Environments
      case $_ENV in
        p) # Production
          ((PEnv++))
          ;;
        d) # Development
          ((DEnv++))
          ;;
        *) # Other
          ((OEnv++))
      esac
    
      ## Count OS Types
      case $_OS in
        l) # Linux hosts
          ((LHosts++))
          ;;
        w) # Windows hosts
          ((WHosts++))
          ;;
        *) # Other hosts
          ((OHosts++))
      esac
  
    fi
  
  done < "$inFile"

  ## Adjust line length +2 past filename. ;)
  pad=$(printf '%0.1s' "="{1..80})
  padlength=${#1}
  LINE=$(printf '%*.*s\n' 0 $((padlength + 9 )) "$pad")

  ## Display file info
  cat <<EOF
$LINE
File = $1
EOF

  ## Get next argument
  shift

done

## Check if any hosts were parsed.
if [[ $THosts -lt 1 ]]; then
  echo -e "\n  ${C2}ERROR[3]:${C0} No structured hostnames were found in supplied inventory file(s)."
  exit 3
fi

## Display results
cat <<EOF
$LINE
OS Windows = ${C1}$WHosts${C0}
OS Linux   = ${C1}$LHosts${C0}
OS Other   = ${C1}$OHosts${C0}
Environment Production  = ${C1}$PEnv${C0}
Environment Development = ${C1}$DEnv${C0}
Envrionment Other       = ${C1}$OEnv${C0}
EOF

exit 0
