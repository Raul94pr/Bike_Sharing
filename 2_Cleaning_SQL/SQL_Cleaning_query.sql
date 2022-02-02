/* Create Single Table with 2021 data*/
SELECT *
INTO Temp_Table
FROM(
SELECT * 
FROM [202101_tripdata]
UNION ALL 
SELECT *  FROM  [202102_tripdata]
UNION ALL 
SELECT *  FROM  [202103_tripdata]
UNION ALL 
SELECT *  FROM  [202104_tripdata]
UNION ALL 
SELECT *  FROM  [202105_tripdata]
UNION ALL 
SELECT *  FROM  [202106_tripdata]
UNION ALL 
SELECT *  FROM  [202107_tripdata]
UNION ALL 
SELECT *  FROM  [202108_tripdata]
UNION ALL 
SELECT *  FROM  [202109_tripdata]
UNION ALL 
SELECT *  FROM  [202110_tripdata]
UNION ALL 
SELECT *  FROM  [202111_tripdata]
UNION ALL 
SELECT *  FROM  [202112_tripdata]
) alias;

/*Correct Format */
ALTER TABLE Temp_Table  ALTER COLUMN ride_id VARCHAR
ALTER TABLE Temp_Table  ALTER COLUMN rideable_type VARCHAR
ALTER TABLE Temp_Table  ALTER COLUMN started_at DATETIME
ALTER TABLE Temp_Table  ALTER COLUMN ended_at DATETIME
ALTER TABLE Temp_Table  ALTER COLUMN start_station_name VARCHAR
ALTER TABLE Temp_Table  ALTER COLUMN start_station_id VARCHAR
ALTER TABLE Temp_Table  ALTER COLUMN end_station_name VARCHAR
ALTER TABLE Temp_Table  ALTER COLUMN end_station_id VARCHAR
ALTER TABLE Temp_Table  ALTER COLUMN start_lat FLOAT
ALTER TABLE Temp_Table  ALTER COLUMN start_lng FLOAT
ALTER TABLE Temp_Table  ALTER COLUMN end_lat FLOAT
ALTER TABLE Temp_Table  ALTER COLUMN end_lng FLOAT
ALTER TABLE Temp_Table  ALTER COLUMN member_casual VARCHAR;


/*Correction Duplicated Data */
	/*--no duplicated ride_id data*/

/*Correction Incomplete Data */

UPDATE Temp_Table
SET Temp_Table.start_station_name = Stations_2017.name
FROM Temp_Table,Stations_2017
WHERE Temp_Table.start_station_name IS NULL OR Temp_Table.start_station_name = ''
AND Temp_Table.start_lat = Round(Stations_2017.latitude,2) AND Temp_Table.start_lng = Round(Stations_2017.longitude,2);

UPDATE Temp_Table
SET Temp_Table.end_station_name = Stations_2017.name
FROM Temp_Table,Stations_2017
WHERE Temp_Table.end_station_name IS NULL OR Temp_Table.end_station_name = ''
AND Temp_Table.end_lat = Round(Stations_2017.latitude,2) AND Temp_Table.end_lng = Round(Stations_2017.longitude,2);

DELETE FROM Temp_Table
WHERE start_station_id IS NULL OR end_station_id IS NULL 
OR start_station_id ='' OR end_station_id =''

	/*Total missing start station_names : 690789 | Corrected:690781 */
	/*Total missing end station_names : 739149 | Corrected: 739132*/

/*Correction Incorrect Data */
	DELETE FROM Temp_Table
	WHERE DATEDIFF(s,started_at,ended_at) < 0;
	/*147 Rows Deleted*/

/*Correction Inconsistent Data */
UPDATE Temp_Table
SET start_lat = ROUND(start_lat,2),
	start_lng = ROUND(start_lng,2),
	end_lat = ROUND(end_lat,2),
	end_lng = ROUND(end_lng,2);

UPDATE Temp_Table
SET start_station_name = TRIM(start_station_name),
	end_station_name = TRIM(end_station_name)

/*Correction Outdated Data*/
DELETE FROM Temp_Table 
WHERE  started_at < '2021-01-01' OR ended_at > '2022-01-01'
	/*75 Rows Deleted*/

/* Final Query for import */
 SELECT ride_id, rideable_type, 
 CONVERT(varchar,started_at,20) AS ride_start, 
 CONVERT(varchar,ended_at,20) AS ride_end,
 start_station_name,
 start_lat,
 start_lng,
 end_station_name,
 end_lat,
 end_lng,
 member_casual AS Membership
 FROM Temp_Table;
