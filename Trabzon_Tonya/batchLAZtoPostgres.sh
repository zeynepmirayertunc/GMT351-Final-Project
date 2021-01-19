#!/bin/bash
dirname="/home/ayca/laz/LIDAR/Trabzon"
subdirname="Tonya"
tablename="lidar"
for filename in "$dirname"/"$subdirname"/*.laz; do
  echo "Processing $filename ..."
  pdal pipeline -i "$dirname"/pipeline_batch.json \
  --readers.las.filename="$filename" \
  --writers.pgpointcloud.table="$tablename"
done
