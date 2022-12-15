
#!/bin/bash
 if [ -z $1 ]; then
    echo "Require CODE ID"
    exit 1
 fi 

NETWORKNAME=$3
 if [ -z $NETWORKNAME ]; then
    echo "No Networkname set use malaga as default"
    NETWORKNAME="malaga"
 fi

 DIR="$(dirname "$(realpath "$0")")"
 CHAINCONFIGFILE="$DIR/chains/$NETWORKNAME.sh"
 if [[ -f "$CHAINCONFIGFILE" ]]; then
     source $CHAINCONFIGFILE
 else
     echo "No config file for Network : " $NETWORKNAME
     exit 1
 fi

export PATH=$PATH:$(go env GOPATH)/bin
wasmd query wasm list-contract-by-code $1 --node $NODE --output json