#OSRM_PBF_URL=https://skoleskyss.akt.no/osrm/agder.osm.pbf


# Get timestamp of the server file
ts=$(curl -s -I $OSRM_PBF_URL | grep Last-Modified)
echo "Timestamp on server:"
echo $ts

# Sanity check result
if [ ${#ts} -le 5 ]; then
    echo "Bad timestamp on server"
    exit
fi

# Testing
#rm /tmp/timestamp.txt
#touch /tmp/has_fresh_data

if [ ! -f /tmp/timestamp.txt ]; then
    echo "File didn't exist"
    echo $ts > /tmp/timestamp.txt
else
    echo "File existed"

    oldts=$(cat /tmp/timestamp.txt)
    if [ "$oldts" = "$ts" ]; then
        echo "Running most recent map data"
    else 
        echo "Map data is stale, removing /tmp/has_fresh_data"
        rm /tmp/has_fresh_data
    fi
fi
