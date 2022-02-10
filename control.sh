#!/bin/bash

DEFAULT_ENVFILE="$(dirname $0)/.env"
ENVFILE=${ENVFILE:-"$DEFAULT_ENVFILE"}
source $ENVFILE

WORKING_DIR=${WORKING_DIR:-$(realpath $(dirname $0))}
TEMPLATES_DIR=${TEMPLATES_DIR:-$(realpath $(dirname $0)/templates/)}
COMPOSE_FILENAME=${COMPOSE_FILENAME:-"docker-supportive-compose.yaml"}
OUTPUT_DIR=${OUTPUT_DIR:-$(realpath $(dirname $0)/configfiles)}
STELLAR_CONF=$(realpath $(dirname $0)/stellar-genesis/)
VAL_NAME_PREFIX=${VAL_NAME_PREFIX:-"stellar-validator-"}
TESTNET_NAME=${TESTNET_NAME:-"stellar_private_testnet"}
COMPOSE_FILE=${WORKING_DIR}/$COMPOSE_FILENAME


IMAGE_TAG=${IMAGE_TAG:-"latest"}

VAL_NUM=${1:-3}


source scripts/helper_functions.sh

### Source scripts under scripts directory
. $(dirname $0)/scripts/helper_functions.sh
###


USAGE="$(basename $0) is the main control script for the testnet.
Usage : $(basename $0) <action> <arguments>

Actions:
  start --val-num|-n <num of validators>
       Starts a network with <num_validators> 
  configure --val-num|-n <num of validators>
       configures a network with <num_validators> 
  stop
       Stops the running network
  clean
       Cleans up the configuration directories of the network
  status
       Prints the status of the network
        "

function help()
{
  echo "$USAGE"
}

function generate_network_configs()
{
  nvals=$1
  echo "Creating directories for $nvals validators..."
  create_dirs ${VAL_NUM}
  
  echo "Generating key pairs for the validators..."
  generate_key_pairs ${VAL_NUM}
  
  echo "Generating config files for $nvals validators..."
  generate_configs ${VAL_NUM}
  
  echo "Updating config files with the generated key pairs..."
  update_configs ${VAL_NUM}
  
  echo "Generating docker compose for supportive services (stellar-horizon, nginx history publisher, prometheus exporter, postgres instance..."
  dockercompose_supportive_services_generator ${VAL_NUM} ${OUTPUT_DIR}
    
  echo "Run supportive services..."
  start_supportive_services
  
  echo "Waiting to create databases in postgres instance"
  sleep 25
  
  echo "Configure validators DBs stellar-core new-db..."
  prepare_dbs ${VAL_NUM}

}

function start_supportive_services()
{
  nvals=$1
  
  #run supportive servives
  echo "Starting supportive services..."
  TESTNET_NAME=${TESTNET_NAME} IMAGE_TAG=${IMAGE_TAG}\
    WORKING_DIR=$WORKING_DIR \
     docker-compose -f ${COMPOSE_FILE} --env-file $ENVFILE up --build -d


}

function stop_network()
{
  echo "Stopping network..."
  
  CONFIGFILES=${OUTPUT_DIR} IMAGE_TAG=${IMAGE_TAG} \
        WORKING_DIR=$WORKING_DIR \
      docker-compose -f ${COMPOSE_FILE} --env-file $ENVFILE down
  
  echo "  stopped!"
}

function print_status()
{
  echo "Printing status of the  network..."
  CONFIGFILES=${OUTPUT_DIR} IMAGE_TAG=${IMAGE_TAG} TESTNET_NAME=$TESTNET_NAME \
      WORKING_DIR=$WORKING_DIR \
     docker-compose -f ${COMPOSE_FILE} --env-file $ENVFILE ps
  echo "  Finished!"
}

function do_cleanup()
{
  echo "Cleaning up network configuration..."
  set -x
  rm -rf ${configs}/*
  rm ${COMPOSE_FILE}
  set +x
  echo "  clean up finished!"
}


ARGS="$@"

if [ $# -lt 1 ]
then
  #echo "No args"
  help
  exit 1
fi

while [ "$1" != "" ]; do
  case $1 in
    "start" ) shift
      while [ "$1" != "" ]; do
        case $1 in 
             -n|--val-num ) shift
               VAL_NUM=$1
               ;;
        esac
        shift
      done
      start_network $VAL_NUM
      exit
      ;;
    "configure" ) shift
      while [ "$1" != "" ]; do
        case $1 in 
             -n|--val-num ) shift
               VAL_NUM=$1
               ;;
        esac
        shift
      done
      generate_network_configs $VAL_NUM
      exit
      ;;
    "stop" ) shift
      stop_network
      exit
      ;;
    "status" ) shift
      print_status
      exit
      ;;
    "clean" ) shift
      do_cleanup
      exit
      ;;
  esac
  shift
done
