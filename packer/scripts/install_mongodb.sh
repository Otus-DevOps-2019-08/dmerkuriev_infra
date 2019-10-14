#!/bin/bash
set -e

# Install mongod
wget -qO - https://www.mongodb.org/static/pgp/server-3.2.asc | sudo apt-key add
bash -c 'echo "deb http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.2 multiverse" > /etc/apt/sources.list.d/mongodb-org-3.2.list'
apt update
apt install -y mongodb-org
systemctl start mongod
systemctl enable mongod

