
 ### LiDAR data in PostgreSQL
 
converting the geometry column for the same SRID of the lidar table
```sql
ALTER TABLE osm ALTER COLUMN geom TYPE geometry(MultiPolygon,5257) USING ST_Transform(ST_SetSRID( geom,5257) , 5257);
CREATE INDEX osm_5257_pkey ON osm USING GIST (geom);
```

Store the pointcloud patch that overlays each building footprint polygon
```sql
ALTER TABLE osm ADD COLUMN pa pcpatch(1);
UPDATE osm SET patch = sq.pa FROM (WITH patches AS (SELECT o.gid AS gid, o.geom AS geom, l.pa AS pa FROM lidar AS l JOIN osm AS o ON PC_INTERSECTS(l.pa, o.geom)) SELECT gid, PC_INTERSECTION(PC_UNION(pa), geom) AS pa FROM patches GROUP BY gid, geom) AS sq WHERE osm.gid = sq.gid;
```
Calculate and store elevation statistics
```sql
UPDATE osm SET z_avg = sq.z_avg, z_median = sq.z_median, z_max = sq.z_max FROM (WITH patches AS (SELECT o.gid AS gid, PC_GET(PC_EXPLODE(o.pa), 'z') AS pt_z FROM osm AS o) SELECT gid, AVG(pt_z) AS z_avg, PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY pt_z) AS z_median, PERCENTILE_CONT(0.999) WITHIN GROUP(ORDER BY pt_z) AS z_max FROM patches GROUP BY gid) AS sq WHERE osm.gid = sq.gid;
```
Get the ground height by outlining the building and combining it with LiDAR data.
```sql
CREATE TABLE osm_outline AS SELECT gid, osm_id, geom FROM osm;
UPDATE osm_outline SET geom = buffer FROM (SELECT o.gid, ST_MULTI(ST_DIFFERENCE(ST_MULTI(ST_Buffer(o.geom, 2)), ST_MULTI(ST_BUFFER(o.geom, 1)))) AS buffer FROM osm_outline AS o) AS sq WHERE osm_outline.gid = sq.gid;
CREATE INDEX osm_outline_pkey ON osm_outline USING GIST (geom);
```
```sql
CREATE TABLE osm_outline AS SELECT gid, osm_id, geom FROM osm;
UPDATE osm_outline SET geom = buffer FROM (SELECT o.gid, ST_MULTI(ST_DIFFERENCE(ST_MULTI(ST_Buffer(o.geom, 2)), ST_MULTI(ST_BUFFER(o.geom, 1)))) AS buffer FROM osm_outline AS o) AS sq WHERE osm_outline.gid = sq.gid;
CREATE INDEX osm_outline_pkey ON osm_outline USING GIST (geom);
```

```sql
ALTER TABLE osm_outline ADD COLUMN z_ground DOUBLE PRECISION NULL;
UPDATE osm_outline SET z_ground = sq.z_min FROM (WITH patches AS (SELECT o.gid AS gid, PC_GET(PC_EXPLODE(o.pa), 'z') AS pt_z FROM osm_outline AS o) SELECT gid, PERCENTILE_CONT(0.01) WITHIN GROUP(ORDER BY pt_z) AS z_min FROM patches GROUP BY gid) AS sq WHERE osm_outline.gid = sq.gid;
```
```sql
ALTER TABLE osm ADD COLUMN z_ground DOUBLE PRECISION NULL, ADD COLUMN height_avg DOUBLE PRECISION NULL, ADD COLUMN height_median DOUBLE PRECISION NULL, ADD COLUMN height_max DOUBLE PRECISION NULL;
UPDATE osm AS o SET z_ground = oo.z_ground FROM osm_outline oo WHERE o.gid = oo.gid;
UPDATE osm SET height_avg = (z_avg - z_ground), height_median = (z_median - z_ground), height_max = (z_max -z_ground);
```



![3d](https://user-images.githubusercontent.com/69868488/104953758-11b7d380-59d8-11eb-80b7-1143f35bc96e.png)
![binalar2](https://user-images.githubusercontent.com/50514082/104956596-85a8aa80-59dd-11eb-9664-d9e0a4ce0432.png)
![ekin](https://user-images.githubusercontent.com/50514082/104959475-5137ed00-59e3-11eb-87a9-8d7f07a83c60.png)
