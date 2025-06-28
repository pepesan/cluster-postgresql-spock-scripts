# Postgresql Database installation and configuration with Spock support
In this guide, we will walk through the steps to install and configure PostgreSQL with Spock support.
## What is Spock?
Spock is a PostgreSQL extension that provides support for multi master replication and high availability. It allows for the creation of a highly available PostgreSQL cluster
with multiple nodes that can handle read and write operations simultaneously.
## Prerequisites
- A server with Ubuntu 24.04 installed
- Root or sudo access to the server
- Internet access to download packages and tgz files
## Installation Steps
- [One Node](https://blog.cursosdedesarrollo.com/posts/post-014/)
- [Two Nodes](https://blog.cursosdedesarrollo.com/posts/post-015/)
# For people in a hurry
sudo apt install -y git
git clone https://github.com/pepesan/cluster-postgresql-spock-scripts
cd cluster-postgresql-spock-scripts
sudo chmod +x *.sh
./install-postgresql_spock.sh
./setup_postgres_service.sh
## References
- [Lenam Blog is the original source for the scripts](https://len4m.github.io/)
