#!/bin/bash

VAL_NAME_PREFIX_DEFAULT="validator-"
OUTPUT_DIR_DEFAULT="./validators-config/"

IPS_FILENAME="ips_fixed.lst"
VALIDATORS_MAP_FILENAME="validators-map.json"

WORKING_DIR=${WORKING_DIR:-$(realpath ./)}
TEMPLATES_DIR=${TEMPLATES_DIR:-$(realpath ./templates/)}
COMPOSE_FILENAME=${COMPOSE_FILENAME:-"docker-compose.yml"}
VAL_NAME_PREFIX=${VAL_NAME_PREFIX:-VAL_NAME_PREFIX_DEFAULT}
OUTPUT_DIR=${OUTPUT_DIR:-${OUTPUT_DIR_DEFAULT}}

function validator_service()
{
	valnum=$1
        val_deploy_path=${OUTPUT_DIR}/${VAL_NAME_PREFIX}${valnum}
	sed -e "s/\${VAL_ID}/$valnum/g" \
            -e "s/\${VAL_NAME_PREFIX}/${VAL_NAME_PREFIX}/g" \
            -e "s#\${LOCAL_BESU_DEPLOY_PATH}#$val_deploy_path#g" \
            -e "s#\${WORKING_DIR}#$WORKING_DIR#g" \
		${TEMPLATES_DIR}/validator-template.yml | sed -e $'s/\\\\n/\\\n    /g'

}

function dockercompose_testnet_generator ()
{
	num_of_validators=$1
	configfiles_root_path=$2

	sed -e  "s#\${WORKING_DIR}#$WORKING_DIR#g" \
		${TEMPLATES_DIR}/docker-compose-testnet-template.yml  > ${WORKING_DIR}/${COMPOSE_FILENAME}
<<comment
	for (( i=0;i<${num_of_validators};i++ ))
	do
		echo "$(validator_service $i)" >> ${WORKING_DIR}/${COMPOSE_FILENAME}
	done
comment
}



