#!/bin/bash
 if [ -z $1 ]; then
    echo "Require Contact Name"
    exit 1
 fi 

 if [ -z $2 ]; then
    echo "Require Wallet Name"
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

 # Setting up the correct parameters
export TXFLAG="--node $NODE --chain-id $CHAINID --gas-prices $GAS_PRICE --gas auto --gas-adjustment $GAS_ADJUST -y --output json -b block"

# Storing the binary on chain
WASMPATH="../artifacts/$1.wasm"
if RES=$(wasmd tx wasm store $WASMPATH --from $2 $TXFLAG) ; then
   # Getting the code id for the stored binary
   CODE_ID=$(echo $RES | jq -r '.logs[0].events[1].attributes[0].value')

   # Printing the code id
   echo "CODE ID IS : " $CODE_ID

   CODEIDPATH="$DIR/codeids/$NETWORKNAME.txt"
   echo "$1,$CODE_ID,$(date "+%Y-%m-%d-%H:%M:%S")"| sudo tee -a $CODEIDPATH
else
   echo "Store wasm : " $1 " failed on NODE " $NODE " CHAIN : " $CHAINID 
fi