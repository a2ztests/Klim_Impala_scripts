--How to handle join memory problems: 
--https://www.cloudera.com/documentation/enterprise/5-10-x/topics/impala_perf_joins.html

--Gathering statistics for all the tables is straightforward, one COMPUTE STATS statement per table:
compute stats amir.delivery_to_klimodo;
compute stats amir.dim_city;
compute stats amir.hosp_chronic_diagnosis;
compute stats amir.hosp_financier;
compute stats amir.hosp_ward_main_dgop;
compute stats amir.hosp_ward_secondary_dgop;
compute stats amir.hospitalizations_visit;
compute stats amir.hospitalizations_visit_test_raw;
compute stats amir.klimodo_city_to_monitor_station_partial_map;
compute stats amir.klimodo_monitor_station_city_distances;
compute stats amir.klimodo_monitor_stations;
compute stats amir.klimodo_monitor_stations_data;
--compute stats vw_dat_not_mapped_stations;
--compute stats vw_klimodo_hospitalization_data_select;

--Replace !!! in a file for each patient the monitor stations only for the patients city mapped by Uriel
--https://www.cloudera.com/documentation/enterprise/5-8-x/topics/impala_insert.html
--insert overwrite table parquet_table select * from default.tab1

--Replace !!! in a file for each patient the monitor stations only for the patients city mapped by Uriel
insert overwrite table amir.delivery_to_klimodo

select 
pat.identity  --Connect this to the select of all the hospitalization data using the hashed(hospitalizations_visit.identity)
,pat.institute_code
,pat.No_Hospitalization

,mapping.Monitor_Station_Id
, mapping.Monitor_Station_Desc
, dis.monitor_station_city_distance as Station_City_Distance_km

--the 3 following fields will not be provided to the researcher - they are  for tests
/*
,cast( 
         concat(
           substr(pat.hospitalisation_date,1,4),'-', substr(pat.hospitalisation_date, 6,2),'-', substr(pat.hospitalisation_date,9,2)
               ) 
        as timestamp
    ) -interval 5 days as hosp_date_calc
,concat(
                      substr(pat.hospitalisation_date,1,4),'-', substr(pat.hospitalisation_date, 6,2),'-', substr(pat.hospitalisation_date,9,2)
       )  as hosp_date

,concat(
                      substr(dat.monitor_date,2,4),'-', substr(dat.monitor_date, 7,2),'-', substr(dat.monitor_date,10,2)
       )  as monitor_date
*/
,month(cast( 
               concat(
                      substr(pat.hospitalisation_date,1,4),'-', substr(pat.hospitalisation_date, 6,2),'-', substr(pat.hospitalisation_date,9,2)
           ) as timestamp
      ) -interval 5 days
      ) as Admission_Month
              
,year(cast( 
               concat(
                      substr(pat.hospitalisation_date,1,4),'-', substr(pat.hospitalisation_date, 6,2),'-', substr(pat.hospitalisation_date,9,2)
                      ) as timestamp
           ) -interval 5 days
    ) as Admission_Year

,datediff( 
          cast( 
               concat(
                      substr(pat.hospitalisation_date,1,4),'-', substr(pat.hospitalisation_date, 6,2),'-', substr(pat.hospitalisation_date,9,2)
                      ) as timestamp
              ) -interval 5 days,

			 
          cast( 
               concat(
                       substr(dat.monitor_date,2,4),'-', substr(dat.monitor_date, 7,2),'-', substr(dat.monitor_date,10,2)
                      ) as timestamp
              ) 
         )  no_of_days_before_admission
         
,substr(dat.monitor_time,13,5) monitor_time 
--,pat.City_code as Patient_City_code --this field will not be provided to the researcher
--,dim_city.City_desc as Patient_City_desc --this field will not be provided to the researcher

,dat.CO, dat.Filter, dat.filter_2_half, dat.ITemp, dat.Benzen, dat.H2S, dat.No, dat.No2, dat.Nox, dat.O3, dat.PM10, dat.PREC, dat.RH, dat.SO2, dat.STAB, dat.Temp, dat.TOLUENE, dat.WD, dat.WS, dat.BP, dat.pm2_half, dat.SR, dat.StWd, dat.NO_T, dat.NOX_T, dat.NO2_T, dat.shTemp, dat.PM1

,pat.Main_Diagnose, pat.Main_Operation, pat.diagnose_type, pat.visit_reason
,pat.age_in_months       

,pat.secondary_diagnoseoperation
,pat.secondary_diagnoseoperation_type
,pat.gender
,pat.discharge_type



from amir.vw_Klimodo_hospitalization_data_select pat
--amir.hospitalizations_visit pat

join amir.klimodo_city_to_monitor_station_partial_map mapping 
on pat.city_code = cast(mapping.city_code as string)

join amir.klimodo_monitor_station_city_distances dis
on dis.monitor_station_id =mapping.monitor_station_id
and dis.city_code = mapping.city_code --only for the patients city mapped by Uriel

join amir.klimodo_monitor_stations_data dat
on dat.monitor_station_id = dis.monitor_station_id

--https://www.cloudera.com/documentation/enterprise/5-8-x/topics/impala_operators.html#between
where 
--Remember that pat.Admission_Date in the reservoir was shifted 5 days into the future
--and that we give 7 data days of the relevant stations prior to the admission date
cast( 
               concat(
                       substr(dat.monitor_date,2,4),'-', substr(dat.monitor_date, 7,2),'-', substr(dat.monitor_date,10,2)
                      ) as timestamp
    ) 

between

cast( 
         concat(
                substr(pat.hospitalisation_date,1,4),'-', substr(pat.hospitalisation_date, 6,2),'-', substr(pat.hospitalisation_date,9,2)
                ) as timestamp
    ) -interval 12 days
and 
     cast( 
         concat(
           substr(pat.hospitalisation_date,1,4),'-', substr(pat.hospitalisation_date, 6,2),'-', substr(pat.hospitalisation_date,9,2)
               ) as timestamp
         ) -interval 5 days	

--and pat.city_code='255' --this is for testing that non mapped city codes do not enter the result of this query
--and pat.Identity = '23730287' --only for testing on more than 2 admissions

--order by identity, Admission_Year, Admission_Month, no_of_days_before_admission, monitor_time asc

