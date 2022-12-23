#!/bin/bash

 if [ -z $1 ]; then
    echo "Require CODE ID"
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

echo "Input token name"
read TOKEN_NAME
if [[ -z $TOKEN_NAME ]]; then
    echo "Require token name"
    exit 1
else 
   if ! [[ $TOKEN_NAME =~ ^[a-zA-Z_][a-zA-Z0-9_]+$ ]]; then
      echo "Token name only accept alphabet digit and _"
      exit 1
   fi
fi 

echo "Input token symbol"
read TOKEN_SYMBOL
if [[ -z $TOKEN_SYMBOL ]]; then
    echo "Require token symbol"
    exit 1
else 
   if ! [[ $TOKEN_SYMBOL =~ ^[a-zA-Z\-]{3,12}$ ]]; then
      echo "Token symbol accept only alphabet digit and -"
      exit 1
   fi
fi 

echo "Input Max Supply"
read MAX_SUPPLY 
if [[ -z $MAX_SUPPLY ]]; then
   MAX_SUPPLY="10000"
   echo "No max supply is set default to  : " $MAX_SUPPLY
else
   if ! [[ $MAX_SUPPLY =~ ^[0-9]+\.?[0-9]*$ ]]; then
      echo "Error : Token max supply be unsigned integer"
      exit 1
   fi
fi




echo "Input instant label if leave this 'CW721Token' will be used"
read INSTANCE_LABEL
if [[ -z $INSTANCE_LABEL ]]; then
   INSTANCE_LABEL="CW721Token"
   echo "No label set use default : " $INSTANCE_LABEL
fi

if WALLET_ADDRESS=$(wasmd keys show -a $2); then
   INSTANT_ARGS='{"name":"'
   INSTANT_ARGS+=$TOKEN_NAME
   INSTANT_ARGS+='","symbol":"'
   INSTANT_ARGS+=$TOKEN_SYMBOL
   INSTANT_ARGS+='","max_supply":"'
   INSTANT_ARGS+=$MAX_SUPPLY
   INSTANT_ARGS+='"}'

   if INIT_ARGS_JSON=$(jq -n --arg wallet $WALLET_ADDRESS "$INSTANT_ARGS"); then
      echo "About to instantiating the contract.. for CODE_ID : " $1 " WITH ADDRESS : " $WALLET_ADDRESS
      echo "Prepare Initial Json Data : "
      echo $INIT_ARGS_JSON

      # Instantiating the contract
      if wasmd tx wasm instantiate $1 "$INIT_ARGS_JSON" --from $2 $TXFLAG --label "$INSTANCE_LABEL" --no-admin; then
         echo "Success to instantiate contract with Label"
         wasmd query wasm list-contract-by-code $1 --node $NODE --output json
      else
         echo "Failed instantiate contract for CODEID : " $1 " NODE:" $NODE " CHAINID " $CHAINID
      fi
   else
      echo "InitialMsg prepare faileds"
   fi
else
   echo "Failed for extract address from wallet name : " $2
fi
