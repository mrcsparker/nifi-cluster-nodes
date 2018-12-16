#!/bin/bash

# Setup the GID and UID to be the same as the docker container for shared mounts
groupadd -g 1000 nifi || groupmod -n nifi `getent group 1000 | cut -d: -f1` \
     && useradd --shell /bin/bash -u 1000 -g 1000 -m nifi 

# Setup all the mount points so the data is persisted if the container restarts
mkdir -p /opt/nifi/content_repository
mkdir -p /opt/nifi/fileflow_repository
mkdir -p /opt/nifi/provenance_repository
mkdir -p /opt/nifi/database_repository

# Copy over the configuration files
cp -rp /tmp/nifi/conf /opt/nifi/

# Make the files readable by the nifi user, these were created with 
# the right gid/uid in user_data
chown -R nifi.nifi /opt/nifi

# Now join the ECS cluster and have a workload provisioned
# ECS is configured to dinstinctively place 1 container per EC2 instances in ECS
# ecs start

