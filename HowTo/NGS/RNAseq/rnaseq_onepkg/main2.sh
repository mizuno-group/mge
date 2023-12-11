#!/bin/bash

# description
# main runner for docker-compose

source ./.env
cp ./config.txt ${BSRC}/config.txt
cp ./.env ${BSRC}/.env
docker-compose build
docker-compose up -d
docker-compose exec ngs /main.sh
rm -rf ${BSRC}/config.txt ${BSRC}/.env
docker-compose down --rmi all

# history
# 220905 start writing