# *GMT351-Final-Project* 
  
 ### Project Description: 
> The purpose of this project is finding buildings' height by using LiDAR data

### About

This project has been prepared by Hacettepe University Geomatics Engineering students for the GMT351 course final project.

### What we use: 
- [Docker](https://www.docker.com/)  <p align="left"> <a href="https://www.docker.com/" target="_blank"> <img src="https://miro.medium.com/max/336/1*glD7bNJG3SlO0_xNmSGPcQ.png" alt="docker" width="25" height="25"/> 
  
- [Pdal](https://pdal.io/)
- [pgPointCloud](https://github.com/pgpointcloud/pointcloud)

 ### Database management system  we use:
 - PostgreSQL  <p align="left"> <a href="https://www.postgresql.org" target="_blank"> <img src="https://upload.wikimedia.org/wikipedia/commons/2/29/Postgresql_elephant.svg" alt="PostgreSql" width="25" height="25"/> 
  
 ### LiDAR data in PostgreSQL
 
> SELECT Count(*), Sum(PC_NumPoints(pa)) FROM lidar;
>CREATE INDEX lidar_env_pkey ON lidar USING GIST(PC_EnvelopeGeometry(pa));
>ALTER TABLE osm ALTER COLUMN geom TYPE geometry(MultiPolygon,5257) USING ST_Transform(ST_SetSRID( geom,5257) , 5257);
>CREATE INDEX osm_5257_pkey ON osm USING GIST (geom);
>ALTER TABLE osm ADD COLUMN pa pcpatch(1);
 
![3d](https://user-images.githubusercontent.com/69868488/104953758-11b7d380-59d8-11eb-80b7-1143f35bc96e.png)
![binalar2](https://user-images.githubusercontent.com/50514082/104956596-85a8aa80-59dd-11eb-9664-d9e0a4ce0432.png)
![ekin](https://user-images.githubusercontent.com/50514082/104959475-5137ed00-59e3-11eb-87a9-8d7f07a83c60.png)
