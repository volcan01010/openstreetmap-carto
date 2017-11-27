#! /bin/bash

# Run the export

# Default settings export globe to data/output.mbtiles
X_MIN="${MBTILES_X_MIN:--180}"
Y_MIN="${MBTILES_Y_MIN:--85.05112877980659}"
X_MAX="${MBTILES_X_MAX:-180}"
Y_MAX="${MBTILES_Y_MAX:-85.05112877980659}"
MIN_ZOOM="${MBTILES_MIN_ZOOM:-1}"
MAX_ZOOM="${MBTILES_MAX_ZOOM:-6}"
OUTFILE="${MBTILES_FILE:-/openstreetmap-carto/data/output.mbtiles}"

echo "Exporting to ${OUTFILE}"


# Show kosmtik version (should be 0.0.16)
# Changes may be necessary as this bug is addressed:
# https://github.com/kosmtik/kosmtik/issues/118
echo "Getting Kosmtik version:"
npm list -g kosmtik

# Switch directory and extract files
cd /usr/lib/node_modules/kosmtik

rm -f "${OUTFILE}"

node index.js export /openstreetmap-carto/project.mml \
       --format=mbtiles \
       --output="${OUTFILE}" \
       --minZoom=${MIN_ZOOM} --maxZoom=${MAX_ZOOM}
       #--bbox=${X_MIN},${Y_MIN},${X_MAX},${Y_MAX}

# Make file writeable (deletable) by any users
chmod a+w "${OUTFILE}"

exit 0
