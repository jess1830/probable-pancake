---------PREPARE AND PROCESS PHASE-------------------

/** STEP 1 - Creating tables that will hold the RAW data**/
-- creating the table structure, which also serves as the table to contain quarter 1 data

		CREATE TABLE bikeshare2019_q1
		(
			trip_id TEXT,
			start_time TIMESTAMP,
			end_time TIMESTAMP,
			bike_id TEXT,
			trip_duration TEXT,
			from_station_id TEXT,
			from_station_name TEXT,
			to_station_id TEXT,
			to_station_name TEXT,
			usertype TEXT,
			gender TEXT,
			birthyear INTEGER
		);

-- next, create empty tables for q2 to q4 data sets with the same structure as q1. 
		CREATE TABLE bikeshare2019_q2 AS TABLE bikeshare2019_q1 WITH NO DATA;
		CREATE TABLE bikeshare2019_q3 AS TABLE bikeshare2019_q1 WITH NO DATA;
		CREATE TABLE bikeshare2019_q4 AS TABLE bikeshare2019_q1 WITH NO DATA; 

-- notes before proceeding to step 2: 
/** since raw data files are all in CSV format, you can visually inspect the data using google sheets
or microsoft excel, you need to check first if all the tables are "congruent" or "aligned" 
with each other. Check if the column data types are consistent with the table you created, otherwise,
adjust accordingly. In our case, no adjustments are needed. **/

/** STEP 2 - Importing data into each assigned table. **/
-- no queries for this one. I used the pGadmin GUI to import each CSV file. Alot more convenient :>

/** STEP 3 - Consolidate all four (4) tables into one table. **/
-- As a reminder, see note before STEP 2 to avoid problems when consolidating data. 

-- create a new table for the consolidated data, with the same table structure: 
		CREATE TABLE bikeshare2019_combined AS TABLE bikeshare2019_q1 WITH NO DATA;

-- copy each table (quarterly data) into the newly created table. 
		INSERT INTO bikeshare2019_combined
		(
			SELECT *
			FROM bikeshare2019_q1 UNION ALL
			SELECT *
			FROM bikeshare2019_q2 UNION ALL
			SELECT *
			FROM bikeshare2019_q3 UNION ALL
			SELECT *
			FROM bikeshare2019_q4
		);

-- visually inspect newly combined table:
		SELECT
			*
		FROM
			bikeshare2019_combined

-------- DATA CLEANING / INSPECTION -------------------

/** STEP 4 - Check if all rows of each table were included in the combined table**/

SELECT 
	((SELECT COUNT (*) FROM bikeshare2019_q1)+
	(SELECT COUNT (*) FROM bikeshare2019_q2)+
	(SELECT COUNT (*) FROM bikeshare2019_q3)+
	(SELECT COUNT (*) FROM bikeshare2019_q4)) AS totalrows,
	(SELECT COUNT (*) FROM bikeshare2019_combined) AS combinedcount
	

/** STEP 5 - Check for NULL values in each column and record. Check how this might affect further analysis. **/

		SELECT
			COUNT (*) AS total_rows,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE start_time IS NULL) AS start_time,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE end_time IS NULL) AS end_time,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE bike_id IS NULL) AS bike_id,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE trip_duration IS NULL) AS trip_duration,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE from_station_id IS NULL) AS from_station_id,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE from_station_name IS NULL) AS from_station_name,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE to_station_id IS NULL) AS to_station_id,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE to_station_name IS NULL) AS to_station_name,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE usertype IS NULL) AS usertype,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE gender IS NULL) AS gender,
			(SELECT	COUNT(*) FROM bikeshare2019_combined WHERE birthyear IS NULL) AS birthyear
		FROM
			bikeshare2019_combined;
-- only columns "gender" and "birthyear" have NULL values. 
-- inspecting further:
		SELECT
			COUNT (*),
			(SELECT
				COUNT(*)
			 FROM bikeshare2019_combined
			 WHERE
			 	birthyear IS NULL OR gender IS NULL) AS either_null,
			(SELECT
				COUNT(*)
			 FROM bikeshare2019_combined
			 WHERE
			 	birthyear IS NULL AND gender IS NULL) AS both_null
		FROM
			bikeshare2019_combined; -- record results
			
-- STEP 5a - Inspecting birthyear column further: 

		SELECT
			(2022 - birthyear) AS age,
			birthyear,
			COUNT(trip_id)
		FROM
			bikeshare2019_combined
		GROUP BY
			(2022 - birthyear),birthyear
		HAVING
			(2022 - birthyear) IS NOT NULL
		ORDER BY
			age DESC;
			--COUNT(trip_id) DESC;
			
		SELECT
			COUNT(*)
		FROM
			bikeshare2019_combined
		WHERE
			(2022 - birthyear) > 95;
			
/** STEP 6 - Check for duplicates from trip_id, since this should not have any: **/
		
		SELECT
			COUNT (DISTINCT trip_id) AS  distinct_values,
			COUNT (trip_id) AS current_values
		FROM
			bikeshare2019_combined;
		
		-- results of the above query should be equal
					
/** STEP 7 - Check for duplicates from station names, the distinct values of the names and the id's should be equal **/
		SELECT
			COUNT (DISTINCT to_station_id) AS  to_sta_id,
			COUNT (DISTINCT to_station_name) AS  to_sta_name,
			COUNT (DISTINCT from_station_id) AS from_sta_id,
			COUNT (DISTINCT from_station_name) AS from_sta_name
		FROM
			bikeshare2019_combined;
			
	-- report if there is any discrepancy and identify reason/s for such.
	-- also identify if this affects analysis significantly.
	/** since there is difference in the distinct values of the station names vs station ids, we can inspect further
	to check the reason/s for this**/
		-- to stations
		SELECT
			DISTINCT to_station_name,
			CAST (to_station_id AS integer) AS to_sta_id
		FROM
			bikeshare2019_combined
		ORDER BY
			to_sta_id
		-- from stations
		SELECT
			DISTINCT from_station_name,
			CAST (from_station_id AS integer) AS from_sta_id
		FROM
			bikeshare2019_combined
		ORDER BY
			from_sta_id
			
	-- Export both results to spreadsheet inorder to create a new consolidated table for better results,
	-- Later in the analysis, we can refer to this "Station table" using JOIN. 

/** STEP 8 - Trip duration **/
/** This is where it gets quite tricky. Since we are analyzing data about transport, it would be safe
to declare that trip duration is one of the important variables in this dataset, thus we need to inspect
carefuly.
	- while importing the dataset from the CSV, we notice that the trip_duration column has inconsistent data
	format / data types, which is why we imported it as "text" data type just so PostGreSQL would accept it,
	thinking we would use CAST function later on to make use of it. 
	- TO CHECK consistency, we use the "to_number" function to "CAST" the trip_duration into a usable data type
	numeric. We then compare this to a computed version of the trip duration by obtaining the difference between
	end time and start time. Both should yield the same results in seconds. The query below does this. **/
	
			SELECT
				trip_id,
				(to_number(trip_duration, '999G999G999D99')) - (EXTRACT(EPOCH FROM(end_time - start_time))) AS diff,
				from_station_name,
				to_station_name,
				start_time, 
				end_time,
				trip_duration,
				to_number(trip_duration, '999G999G999D99') AS dur1,
				EXTRACT(EPOCH FROM(end_time - start_time)) AS dur2
			FROM
				bikeshare2019_combined
			WHERE
				(to_number(trip_duration, '999G999G999D99')) != (EXTRACT(EPOCH FROM(end_time - start_time)))
			ORDER BY
				--(to_number(trip_duration, '999G999G999D99')) - (EXTRACT(EPOCH FROM(end_time - start_time)))
				(EXTRACT(EPOCH FROM(end_time - start_time)));

/** the result will yield negative (-) values for the time duration in seconds which points to the original
trip_duration column having incorrect / inconsistent data. Other results also yield approximately a 1 hr (3600 second)
difference, therefore we can remove the entries where the values are negative and proceed with using the
"computed" trip duration for analysis. This was also verified using MS EXCEL and an online time difference
calculator. **/

-- delete rows with negative trip duration, as recommended. 

			DELETE FROM bikeshare2019_combined
			WHERE 
			(EXTRACT(EPOCH FROM(end_time - start_time))) < -1;
			
-----------Additional Cleaning----------------

/** Add 1 - Removing maintenance trips, station id = 671 **/

			DELETE FROM bikeshare2019_combined
			WHERE to_station_id = '671';
			

------------------ANALYZE PHASE---------------------------------------------

/** Obtain distribution of total no. of trips between customer and subscriber usertypes then export to excel **/
	SELECT
		usertype,
		COUNT(*) AS no_of_trips
	FROM
		bikeshare2019_combined
	GROUP BY
		usertype

/** Obtain metrics **/

--MAX trip duration
	SELECT
		usertype,
		MAX (EXTRACT(EPOCH FROM(end_time - start_time)) ) AS max_trip_dur
	FROM
		bikeshare2019_combined
	GROUP BY
		usertype;
		
--MIN trip duration
	SELECT
		usertype,
		MIN (EXTRACT(EPOCH FROM(end_time - start_time)) ) AS min_trip_dur
	FROM
		bikeshare2019_combined
	GROUP BY
		usertype;

-- Obtain trips with trip_duration greater than 1 day and analyze separately. Export to excel

	SELECT *, (EXTRACT(EPOCH FROM(end_time - start_time))) AS dur1
	FROM
		bikeshare2019_combined
	WHERE
		(EXTRACT(EPOCH FROM(end_time - start_time))) > 86400
	ORDER BY
		dur1 DESC;
		
/** MEDIAN will be used instead of average for trip duration due to existence of outliers. Median will result in more accurate
picture of what the average "trip_duration" is. **/
		
	SELECT 
 		usertype,
		EXTRACT(isodow from start_time) AS day_week,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (EXTRACT(EPOCH FROM(end_time - start_time)))) AS median
  	FROM bikeshare2019_combined
	WHERE (EXTRACT(EPOCH FROM(end_time - start_time))) < 86400
	GROUP BY
		usertype,
		EXTRACT(isodow from start_time);
	
/** Average No. of Riders per day of week / month **/

-- Weekly

		SELECT 
			start_time::timestamp::date,
			usertype,
			COUNT(*) AS no_trips
		FROM
			bikeshare2019_combined
		GROUP BY
			start_time::timestamp::date, usertype
		ORDER BY
			start_time::timestamp::date;

/** the results from the query above can be used for monthly and daily analysis of no. of trips**/
		
SELECT * FROM bikeshare2019_combined LIMIT 10;

/** ROUTES **/

-- Identify no. of trips per route to take out top 10 routes per usertype

SELECT
	CONCAT(from_station_id,'_',to_station_id) AS route,
	usertype,
	COUNT(*) AS no_of_trips,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (EXTRACT(EPOCH FROM(end_time - start_time)))) AS trip_dur
FROM
	bikeshare2019_combined
GROUP BY
	CONCAT(from_station_id,'_',to_station_id),
	usertype
ORDER BY
	no_of_trips DESC

/**AGE**/

-- COMPUTING FOR AGE MEDIAN

SELECT
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY (2022-birthyear)) AS ave_age,
	usertype
FROM
	bikeshare2019_combined
GROUP BY
	usertype;
	
-- AGE DISTRIBUTION

SELECT
	usertype,
	(2022 - birthyear) AS age,
	birthyear,
	COUNT(trip_id) AS no_of_trips
FROM
	bikeshare2019_combined
GROUP BY
	(2022 - birthyear),birthyear,usertype
HAVING
	(2022 - birthyear) IS NOT NULL
ORDER BY
	age;
	
	
	

