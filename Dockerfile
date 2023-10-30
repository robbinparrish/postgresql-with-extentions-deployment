# Default docker image - latest version of postgresql.
FROM postgres:15.4
ENV DEBIAN_FRONTEND=noninteractive

# Install build tools.
RUN apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests \
	bison \
	build-essential \
	flex \
	locales \
	wget \
	tar \
	libkrb5-dev \
	cmake \
	ca-certificates

# Install postgresql development libraries.
RUN apt-get update && \
	apt-get install -y --no-install-recommends --no-install-suggests \
	postgresql-server-dev-15

# Set and configure locale.
ENV LANG=en_US.UTF-8
ENV LC_COLLATE=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

# Generate locale for postgresql.
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=en_US.UTF-8

# Create extentions and docker entrypoint directory.
RUN mkdir -p /pgsql-extentions /docker-entrypoint-initdb.d

# Install apache-age extention.
ENV APACHE_AGE_VERSION="1.4.0"
RUN wget https://github.com/apache/age/releases/download/PG15%2Fv"${APACHE_AGE_VERSION}"-rc0/apache-age-"${APACHE_AGE_VERSION}"-src.tar.gz && \
	tar -xf apache-age-"${APACHE_AGE_VERSION}"-src.tar.gz -C /pgsql-extentions/ && \
	rm -f apache-age-"${APACHE_AGE_VERSION}"-src.tar.gz && \
	cd /pgsql-extentions/apache-age-"${APACHE_AGE_VERSION}" && \
	make install && \
	cp -Rf /pgsql-extentions/apache-age-"${APACHE_AGE_VERSION}"/docker/docker-entrypoint-initdb.d/00-create-extension-age.sql \
		/docker-entrypoint-initdb.d/00-create-extension-age.sql && \
	cd / && rm -rf /pgsql-extentions/apache-age-"${APACHE_AGE_VERSION}"

# Install timescaledb extention.
ENV TIMESCALE_DB_VERSION="2.12.2"
RUN wget https://github.com/timescale/timescaledb/archive/refs/tags/"${TIMESCALE_DB_VERSION}".tar.gz && \
	tar -xf "${TIMESCALE_DB_VERSION}".tar.gz -C /pgsql-extentions/ && \
	rm -f "${TIMESCALE_DB_VERSION}".tar.gz && \
	cd /pgsql-extentions/timescaledb-"${TIMESCALE_DB_VERSION}" && \
	./bootstrap && cd ./build && make && make install && \
	echo "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;" > /docker-entrypoint-initdb.d/00-create-extension-timescaledb.sql && \
	cd / && rm -rf /pgsql-extentions/timescaledb-"${TIMESCALE_DB_VERSION}"

# Enable extententions.
CMD ["postgres", "-c", "shared_preload_libraries=age,timescaledb", "-c", "timescaledb.telemetry_level=off"]

