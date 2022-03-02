# Private Stellar TestNet 
<p align="center"><img src="https://assets.gadgets360cdn.com/img/crypto/stellar-og-logo.png" width="500" height="300"/></p>

This project is a set of scripts that generate all the required validators' key-pairs and configuration files to start a private Stellar network. Additionally, it generates a docker-compose file for the private Stellar Testnet that can be used to launch a testnet locally, or on a virutal private server.

## Requirements
- Docker Engine
- Docker Compose
- JQ , JSON Command line tool
- sed, File Streams Command line tool

## Testnet related operations

### Using the *control.sh* script

```
control.sh is the main control script for the testnet.
Usage : control.sh <action> <arguments>

Actions:
  start  --val-num|-n <num of validators>
       Starts a network with <num_validators> 
  configure --val-num|-n <num of validators>
       configures a network with <num_validators> 
  stop
       Stops the running network
  clean
       Cleans up the configuration directories of the network
  status
       Prints the status of the network
```
### How to deploy a private Stellar network with n number of nodes/validators
```
./control.sh configure -n <number_of_validators>
./control.sh start
```

### How to stop the network you have just deployed
```
./control.sh stop
```

### How to check the status of the network
```
./control.sh status
```

### How to clean your environment
```
./control.sh clean
```

### In case of permission problems for nginx serving the bucket of the network

If you have not changed the volume that is used by stellar-genesis to store it's history then move to /deployment/history/buckets, dive into the next dirs to find the bucket.xvdf and execute the following (basically give read permissions to the file)
```
chmod +r <bucket_name.xvdf>
```


## Contributors

- Marios Touloupos ( @mtouloup ) - PhD Candidate, University of Nicosia - Institute for the Future ( UNIC -IFF)


## Sponsors
This work is partially funded by the Stellar Development Foundation (SDF): https://www.stellar.org/foundation


## Feedback-Channel
* GitLab issues



