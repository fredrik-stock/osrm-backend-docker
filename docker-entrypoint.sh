#!/bin/bash

# Defaults
OSRM_DATA_PATH=${OSRM_DATA_PATH:="/osrm-data"}
OSRM_DATA_LABEL=${OSRM_DATA_LABEL:="data"}
OSRM_GRAPH_PROFILE=${OSRM_GRAPH_PROFILE:="car"}
OSRM_GRAPH_PROFILE_URL=${OSRM_GRAPH_PROFILE_URL:=""}
OSRM_PBF_URL=${OSRM_PBF_URL:="http://download.geofabrik.de/asia/maldives-latest.osm.pbf"}
OSRM_MAX_TABLE_SIZE=${OSRM_MAX_TABLE_SIZE:="8000"}
OSRM_EXTRA_PARAMS=${OSRM_EXTRA_PARAMS:=""}
OSRM_USE_MLD=${OSRM_EXTRA_PARAMS:=""}


_sig() {
  kill -TERM $child 2>/dev/null
}
trap _sig SIGKILL SIGTERM SIGHUP SIGINT EXIT

# Set all-is-well token at start
# Will be removed if map data is updated server-side
touch /tmp/has_fresh_data

# Retrieve the PBF file
curl -L $OSRM_PBF_URL --create-dirs -o $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osm.pbf



# Set the graph profile path
OSRM_GRAPH_PROFILE_PATH="/osrm-profiles/$OSRM_GRAPH_PROFILE.lua"

# If the URL to a custom profile is provided override the default profile
if [ ! -z "$OSRM_GRAPH_PROFILE_URL" ]; then
    # Set the custom graph profile path
    OSRM_GRAPH_PROFILE_PATH="/osrm-profiles/custom-profile.lua"
    # Retrieve the custom graph profile
    curl -L $OSRM_GRAPH_PROFILE_URL --create-dirs -o $OSRM_GRAPH_PROFILE_PATH
fi

printenv | grep "OSRM" >> /etc/environment

# Build the graph
osrm-extract $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osm.pbf -p $OSRM_GRAPH_PROFILE_PATH

# Use MLD
if [ ! -z "$OSRM_USE_MLD" ]; then
    osrm-partition $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osrm
    osrm-customize $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osrm
    OSRM_EXTRA_PARAMS="${OSRM_EXTRA_PARAMS} --algorithm=MLD"
else
    osrm-contract $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osrm
fi


# Start serving requests
osrm-routed $OSRM_DATA_PATH/$OSRM_DATA_LABEL.osrm --max-table-size $OSRM_MAX_TABLE_SIZE $OSRM_EXTRA_PARAMS &
child=$!

cron
wait "$child"
