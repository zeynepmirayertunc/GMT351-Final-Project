#!/bin/bash
dirname="/home/miray/project/laz/LIDAR/ARRA-CA_GoldenGate_2010"
subdirname="san francisco"
tablename="lidar"
for filename in "$dirname"/"$subdirname"/*.laz; do
  echo "Processing $filename ..."
  pdal pipeline -i "$dirname"/pipeline_batch.json \
  --readers.las.filename="$filename" \
  --writers.pgpointcloud.table="$tablename"
done
