source ./config.sh

set -euo pipefail

install_dependencies() {
    echo "Installing dependencies..."
    sudo apt update
    sudo apt install -y make build-essential libssl-dev zlib1g-dev libreadline-dev \
        libxml2-dev libxslt-dev libkrb5-dev flex bison libxml2-utils xsltproc \
        ccache pkg-config git libjansson-dev
}

# /usr/local/src/
prepare_source_dir() {
    echo "Preparing source directory..."
    sudo mkdir -p "$SRC_DIR"
    sudo chown "$(whoami)" "$SRC_DIR"
    cd "$SRC_DIR"
}

download_postgres() {
    echo "Downloading PostgreSQL ${PG_VERSION}..."
    if [ ! -f "postgresql-${PG_VERSION}.tar.gz" ]; then
        echo "Descargando PostgreSQL ${PG_VERSION}..."
        wget "https://ftp.postgresql.org/pub/source/v${PG_VERSION}/postgresql-${PG_VERSION}.tar.gz"
    fi
}

extract_sources() {
    echo "Extracting PostgreSQL sources..."
    tar -xvzf "postgresql-${PG_VERSION}.tar.gz"
}

clone_spock() {
    echo "Cloning Spock repository..."
    if [ ! -d "spock" ]; then
        echo "Clonando Spock..."
        git clone https://github.com/pgEdge/spock
    fi
}

apply_patches() {
    echo "Applying Spock patches to PostreSQL source code ..."
    cd "${SRC_DIR}/postgresql-${PG_VERSION}"
    for patch in ../spock/patches/pg${PG_VERSION_BASE}-*.diff; do
        echo "Aplicando $(basename "$patch")"
        patch -p1 < "$patch"
    done
}

configure_postgres() {
    echo "Configuring source code for PostgreSQL ${PG_VERSION}..."
    ./configure --prefix="$INSTALL_PREFIX" \
                --with-readline --with-zlib --with-icu --with-openssl --with-libxml
}

build_and_install_postgres() {
    echo "Compiling PostgreSQL..."
    make -j"$NUM_CORES"
    sudo make install
}
configure_path() {
    echo "Adding ${INSTALL_PREFIX}/bin to the system PATH variable..."
    sudo tee /etc/profile.d/pgsql.sh >/dev/null <<EOF
#!/bin/sh
export PATH=${INSTALL_PREFIX}/bin:\$PATH
EOF
    sudo chmod +x /etc/profile.d/pgsql.sh
    source /etc/profile.d/pgsql.sh
}

create_postgres_user() {
    echo "Creating postgres user if necessary..."
    if ! id postgres >/dev/null 2>&1; then
        echo "Creating postgres user..."
        sudo adduser --system --home /var/lib/postgresql --group --shell /bin/bash postgres
    fi
}

# configurar directorio de datos de postgres
setup_data_dir() {
    echo "Creating data directory..."
    sudo mkdir -p "$DATA_DIR"
    sudo chown postgres:postgres "$DATA_DIR"
}

# inicializar el clúster
init_db_cluster() {
    echo "Database Initialization..."
    sudo -u postgres "${INSTALL_PREFIX}/bin/initdb" -D "$DATA_DIR"
}

install_spock() {
    echo "Compiling and Installing Spock..."
    cd "${SRC_DIR}/spock"
    cp compat${PG_VERSION_BASE}/* .
    env PATH="${INSTALL_PREFIX}/bin:$PATH" make -j"$NUM_CORES"
    sudo env PATH="${INSTALL_PREFIX}/bin:$PATH" make install
}

# configre postgresql.conf file for Spock
# erase file lines and adds to the bottom
configure_spock() {
    echo "🛠️ Configuring postgresql.conf for Spock..."
    CONF_FILE="${DATA_DIR}/postgresql.conf"
    sudo sed -i "/^#*shared_preload_libraries *=/d" "$CONF_FILE"
    sudo sed -i "/^#*track_commit_timestamp *=/d" "$CONF_FILE"
    sudo sed -i "/^#*wal_level *=/d" "$CONF_FILE"
    sudo sed -i "/^#*max_worker_processes *=/d" "$CONF_FILE"
    sudo sed -i "/^#*max_replication_slots *=/d" "$CONF_FILE"
    sudo sed -i "/^#*max_wal_senders *=/d" "$CONF_FILE"
    {
        echo ""
        echo "# Spock basic Configuration"
        echo "shared_preload_libraries = 'spock'"
        echo "track_commit_timestamp = on"
        echo "wal_level = 'logical'"
        echo "max_worker_processes = 10  # one per database needed on provider node"
        echo ""
        echo "max_replication_slots = 10  # one per node needed on provider node"
        echo "max_wal_senders = 10        # one per node needed on provider node"
    } | sudo tee -a "$CONF_FILE" >/dev/null
}

# resumen
show_summary() {
    echo "✅ PostgreSQL ${PG_VERSION} and Spock are compiled and installed successfully."
    echo "🔧 PostgreSQL installed at: $INSTALL_PREFIX"
    echo "📁 Data at: $DATA_DIR"
}

main() {
    install_dependencies
    prepare_source_dir
    download_postgres
    extract_sources
    clone_spock
    apply_patches
    configure_postgres
    build_and_install_postgres
    configure_path
    create_postgres_user
    setup_data_dir
    init_db_cluster
    install_spock
    configure_spock
    show_summary
}

main