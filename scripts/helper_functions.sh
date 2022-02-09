#!/bin/bash

VAL_NAME_PREFIX_DEFAULT="validator-"
OUTPUT_DIR_DEFAULT="./validators-config/"

VALIDATORS_MAP_FILENAME="validators-map.json"

WORKING_DIR=${WORKING_DIR:-$(realpath ./)}
TEMPLATES_DIR=${TEMPLATES_DIR:-$(realpath ./templates/)}
SUPPORTIVE_COMPOSE_FILENAME=${COMPOSE_FILENAME:-"docker-supportive-compose.yml"}
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

}

function dockercompose_supportive_services_generator ()
{
	num_of_validators=$1
	configfiles_root_path=$2

	sed -e  "s#\${WORKING_DIR}#$WORKING_DIR#g" \
		${TEMPLATES_DIR}/docker-compose-testnet-template.yml  > ${WORKING_DIR}/${COMPOSE_FILENAME}

}

function create_dirs()
{
	num_of_validators=$1
	
	for (( i=0;i<${num_of_validators};i++ ))
	do
		mkdir -p configs/validator-$i
	done
	echo "Directories created"
}


function generate_configs()
{
	num_of_validators=$1
	for (( i=0;i<${num_of_validators};i++ ))
	do
		cp ./templates/stellar_template.cfg configs/validator-$i/stellar-core.cfg
	done
	echo "Config files generated"
}


function generate_key_pairs()
{
	num_of_validators=$1
	
	docker run --rm stellar/stellar-core:latest gen-seed > stellar-genesis/key_pair.txt
	
	for (( i=0;i<${num_of_validators};i++ ))
	do
		docker run --rm stellar/stellar-core:latest gen-seed > configs/validator-$i/key_pair.txt
	done
	echo "Key pairs generated"
}

function update_configs()
{
	num_of_validators=$1
	
	#Updating Genesis config file
	first_line_genesis=$(head -n 1 ./stellar-genesis/key_pair.txt)
	arrIN=(${first_line_genesis//:/ })
	secret=${arrIN[2]}			
	sed -i 's/^\(NODE_SEED=\).*/\1"'$secret' self"/' ./stellar-genesis/stellar-core.cfg
	
	#Updating stellar genesis known peers
	known_peers=()
	for (( i=0;i<${num_of_validators};i++ ))
	do
		known_peers+=("validator-$i:11635")	
	done
	
	
	
	genesis_known_peers=$(jq -n -c -M --arg s "${known_peers[*]}" '($s|split(" "))')
	sed -i 's/^\(KNOWN_PEERS=\).*/\1'${genesis_known_peers}'/' ./stellar-genesis/stellar-core.cfg
	
	#Updating Validators config file
	for (( i=0;i<${num_of_validators};i++ ))
	do
		first_line=$(head -n 1 configs/validator-$i/key_pair.txt)
		arrIN=(${first_line//:/ })
		secret=${arrIN[2]}		
		
		sed -i 's/^\(NODE_SEED=\).*/\1"'$secret' self"/' ./configs/validator-$i/stellar-core.cfg
		
		#Updating validator's known peers
		val_known_peers=("stellar-genesis:11625")
		for (( k=0;k<${num_of_validators};k++ ))
		do
			if [ $i != $k ]; then
				val_known_peers+=("validator-$k:11635")
			fi
		done
		validator_known_peers=$(jq -n -c -M --arg s "${val_known_peers[*]}" '($s|split(" "))')
		sed -i 's/^\(KNOWN_PEERS=\).*/\1'${validator_known_peers}'/' ./configs/validator-$i/stellar-core.cfg	
		
	done
	echo "Config files updated"
}

function prepare_dbs(){

	num_of_validators=$1
	
	#Prepare DBs for each validator and generate genesis history archive to be served from the history publisher
	docker run --rm --network=$TESTNET_NAME -v "$STELLAR_CONF:/etc/stellar/" stellar/stellar-core:latest new-db
	docker run --rm --network=$TESTNET_NAME -v "$STELLAR_CONF:/etc/stellar/" -v "$WORKING_DIR/deployment/history:/mnt/stellar-hist/stellar-core-archive/node_001/" stellar/stellar-core:latest new-hist local
	  
	for (( i=0;i<${num_of_validators};i++ ))
	do	
		docker run --rm --network=$TESTNET_NAME -v "$WORKING_DIR/configs/validator-$i:/etc/stellar/" stellar/stellar-core:latest new-db
	done
}