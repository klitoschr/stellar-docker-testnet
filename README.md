
# Private Stellar TestNet 


## Requirements
- Docker Engine should be installed and running.
- Docker Compose
- jq , JSON Command line tool
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

## Contributors

- Marios Touloupos ( @mtouloup ) - UBRI Fellow Researcher / PhD Candidate, University of Nicosia - Institute for the Future ( UNIC -IFF)

# Research Team
* Marios Touloupou (@mtouloup) [ touloupos.m@unic.ac.cy ]
* Klitos Christodoulou [ christodoulou.kl@unic.ac.cy ]
* Elias Iosif [ iosif.e@unic.ac.cy ]

## Acknowledgements
This work is funded by the Ripple’s Impact Fund, an advised fund of Silicon Valley Community Foundation (Grant id: 2018–188546).
Link: [University Blockchain Research Initiative](https://ubri.ripple.com)

## About IFF

IFF is an interdisciplinary research centre, aimed at advancing emerging technologies, contributing to their effective application and evaluating their impact. The general mission at IFF is to educate leaders, develop knowledge and build communities to help society prepare for a future shaped by transformative technologies. The institution has been engaged with the community since 2013 offering the World’s First Massive Open Online Course (MOOC) on blockchain and cryptocurrency for free, supporting the community and bridging the educational gap on blockchains and digital currencies.
