#
# Docker image for postgresql with additional extentions.
#

#
# Building the docker image.
#
docker build -t postgresql:with-extentions-15-4 .

#
# Running the docker image.
#
docker run -itd --rm --name postgresql-with-extentions-15-4 \
	-e POSTGRES_PASSWORD=YOUR_DB_PASSWORD \
	-v ./pgsql-db/data:/var/lib/postgresql/data \
	-v ./pgsql-db/log:/var/log/postgresql \
	postgresql:with-extentions-15-4

#
# Check that all the extentions are loaded.
#

#
# Get the container ip address.
#
docker inspect postgresql-with-extentions-15-4

#
# Run psql query.
#
docker run -it --rm postgresql:with-extentions-15-4 psql -h IPADDR_OF_CONTAINER -U postgres -c  'select * from pg_extension;'

#
# With docker-compose.
#

#
# Starting the container.
#
docker-compose up -d

#
# Checking the container logs.
#
docker-compose logs -f

