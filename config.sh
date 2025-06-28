#!/bin/bash

# PostgreSQL configuration script
# Version and paths
# PostgreSQL version
PG_VERSION="17.5"
# PostgreSQL base version
PG_VERSION_BASE="17"
# PostgreSQL source directory
SRC_DIR="/usr/local/src/postgres17-spock"
# PostgreSQL installation prefix
INSTALL_PREFIX="/usr/local/pgsql"
# PostgreSQL data directory
DATA_DIR="${INSTALL_PREFIX}/data"
# Core count
NUM_CORES=$(nproc)
# PostgreSQL binaries
PG_CTL="${INSTALL_PREFIX}/bin/pg_ctl"
# PostgreSQL data directory
PGDATA="${DATA_DIR}"
# PostgreSQL service configuration file
SERVICE_FILE="/etc/systemd/system/postgresql.service"
