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
compute stats klimodo.klimodo_Flat_Final_Output;
--compute stats vw_dat_not_mapped_stations;
--compute stats vw_klimodo_hospitalization_data_select;


--Attach!!! to a file for each patient the monitor stations only for the patients city NOT mapped by Uriel
--https://www.cloudera.com/documentation/enterprise/5-8-x/topics/impala_insert.html
--insert into table parquet_table select * from default.tab1;

--Attach!!! to a file for each patient the monitor stations only for the patients city NOT mapped by Uriel
insert into table amir.delivery_to_klimodo


select 


dat_not_mapped_stations.identity--Connect this to the select of all the hospitalization data using the hashed(hospitalizations_visit.identity)
,pat.institute_code
,pat.No_Hospitalization

--,dat_not_mapped_stations.Row_Num --this field will not be provided to the researcher
,dat_not_mapped_stations.Monitor_Station_Id
,dat_not_mapped_stations.Monitor_Station_Desc
,dat_not_mapped_stations.Station_City_Distance_km 


,dat_not_mapped_stations.Admission_Month
              
,dat_not_mapped_stations.Admission_Year	  




--,dat_not_mapped_stations.monitor_date --this field will not be provided to the researcher
--Remember that the clinical data is shifted in the lake +5 days
,dat_not_mapped_stations.no_of_days_before_admission
,dat_not_mapped_stations.monitor_time

--,pnimi.City_code as Patient_City_code   --this field will not be provided to the researcher
--,pnimi.City_desc as Patient_City_desc --this field will not be provided to the researcher


,dat_not_mapped_stations.CO
,dat_not_mapped_stations.Filter
,dat_not_mapped_stations.filter_2_half
,dat_not_mapped_stations.ITemp 
,dat_not_mapped_stations.Benzen 
,dat_not_mapped_stations.H2S
,dat_not_mapped_stations.no
,dat_not_mapped_stations.No2
,dat_not_mapped_stations.Nox
,dat_not_mapped_stations.O3
,dat_not_mapped_stations.PM10
,dat_not_mapped_stations.PREC
,dat_not_mapped_stations.RH
,dat_not_mapped_stations.SO2
,dat_not_mapped_stations.STAB
,dat_not_mapped_stations.Temp
,dat_not_mapped_stations.TOLUENE
,dat_not_mapped_stations.WD
,dat_not_mapped_stations.WS
,dat_not_mapped_stations.BP

,dat_not_mapped_stations.pm2_half
,dat_not_mapped_stations.SR
,dat_not_mapped_stations.StWd
,dat_not_mapped_stations.NO_T
,dat_not_mapped_stations.NOX_T
,dat_not_mapped_stations.NO2_T 
,dat_not_mapped_stations.shTemp
,dat_not_mapped_stations.PM1

,pat.Main_Diagnose, pat.Main_Operation, pat.diagnose_type, pat.visit_reason
,pat.age_in_months       

,pat.secondary_diagnoseoperation
,pat.secondary_diagnoseoperation_type
,pat.gender
,pat.discharge_type



from amir.vw_dat_not_mapped_stations dat_not_mapped_stations

join  amir.vw_klimodo_hospitalization_data_select pat
on pat.identity = dat_not_mapped_stations.identity
and pat.No_Hospitalization = dat_not_mapped_stations.No_Hospitalization
and pat.institute_code = dat_not_mapped_stations.institute_code

--and pat.hospitalisation_date = dat_not_mapped_stations.hospitalisation_date

--where pat.Identity like '%236869%' -- 23686901 only for testing on more than 2 admissions

--order by identity, Admission_Year, Admission_Month, no_of_days_before_admission, monitor_time asc
;