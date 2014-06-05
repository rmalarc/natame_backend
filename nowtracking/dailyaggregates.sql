UPDATE `tweets` as `t`
SET `FEATURE_ID`=(
        select `p`.`FEATURE_ID`
        from `POP_PLACES` as `p`
        where COUNTY_NAME = COUNTY
                and `state` = `STATE_ALPHA`
                and `PRIM_LAT_DEC` is not null
                and `PRIM_LONG_DEC` is not null
        limit 1 )
where `t`.`feature_id` is null
      AND county is not null
      AND ISJUNK = 0
        and (DELETEME <>1 or deleteme is null)
      AND dt >= curdate() - interval 1 day
;



update tweets set DELETEME = 1 where FEATURE_ID is null and dt < curdate() and DELETEME <> 1;


#delete from AGGREGATES where date = curdate() - interval 1 day;
#delete from ALERTS where date = curdate() - interval 1 day;
#delete from TRENDS where date = curdate() - interval 1 day;
#delete from MENU where date = curdate() - interval 1 day;
#delete from MOVAVG where date = curdate() - interval 1 day;

select curtime() as 'UpdateAggregates:';
CALL UpdateAggregates(CURDATE());
select curtime() as 'UpdateMovAvg:';
CALL UpdateMovAvg(CURDATE());
select curtime() as 'UpdateTrends:';
CALL UpdateTrends(CURDATE());
select curtime() as 'UpdateAlerts:';
CALL UpdateAlerts(CURDATE());
select curtime() as 'UpdateMenu:';
CALL UpdateMenu(CURDATE());
select curtime() as 'UpdateHeatMap:';
CALL UpdateHeatMap(CURDATE());
select curtime() as 'Done: ';
select concat('DONE: ',curtime()) as a6;


insert into tweets_old (`tid`, `dtm`, `dt`, `match`, `ISJUNK`, `TISJUNK`, `pISJUNK`, `text`, `lang`, `name`, `screen_name`, `profile_image_url`, `full_name`, `city`, `state`, `county`, `latitude`, `longitude`, `location`, `FEATURE_ID`, `TAX_ID`, `DELETEME`)
	 select `tid`, `dtm`, `dt`, `match`, `ISJUNK`, `TISJUNK`, `pISJUNK`, `text`, `lang`, `name`, `screen_name`, `profile_image_url`, `full_name`, `city`, `state`, `county`, `latitude`, `longitude`, `location`, `FEATURE_ID`, `TAX_ID`, `DELETEME` 
	from tweets 
	where (isjunk = 1 and tisjunk is null and dt <= (curdate() - interval 1 day))
	OR (DELETEME = 1 and dt <= (curdate() - interval 1 day) )
	OR (dt < (curdate() - interval 14 day) AND tisjunk is null)
	OR (dt <= (curdate() - interval 2 day) AND feature_id is null)
	;



delete from tweets where 
	(isjunk = 1 and tisjunk is null and dt <= (curdate() - interval 1 day))
	OR (DELETEME = 1 and dt <= (curdate() - interval 1 day) )
	OR (dt < curdate() - interval 14 day AND tisjunk is null)
	OR (dt <= curdate() - interval 2 day AND feature_id is null)
	;


EXIT



insert into `AGGREGATES` (`DATE`,`STATE_FIPS`,`TAX_ID`,`TCOUNT`,`UCOUNT`)
SELECT `dt`, `STATE_FIPS`,`TAX_ID`, count(`match`), count(distinct(`screen_name`))
FROM `tweets` as `t`
inner join `POP_PLACES` `p` on `p`.`FEATURE_ID` = `t`.`FEATURE_ID`
WHERE `dt` = CURDATE() -INTERVAL 1 DAY AND ISJUNK = 0
group by `p`.`STATE_FIPS`, `TAX_ID`;


insert into `AGGREGATES` (`DATE`,`COUNTY_FIPS`,`TAX_ID`,`TCOUNT`,`UCOUNT`)
SELECT `dt`, `COUNTY_FIPS`,`TAX_ID`, count(`match`), count(distinct(`screen_name`))
FROM `tweets` as `t`
inner join `POP_PLACES` `p` on `p`.`FEATURE_ID` = `t`.`FEATURE_ID`
WHERE `dt` = CURDATE() - INTERVAL 1 DAY AND ISJUNK =0
group by `p`.`COUNTY_FIPS`, `TAX_ID`;


INSERT INTO `TRENDS`(`DATE`, `COUNTY_FIPS`, `DIS_ID`, `NORMAVG`, `tweets`, `tot_days`) 
SELECT `DATE`, `county_FIPS`,`dis_ID`, `normavg`, `tweets`,`tot_days`
FROM `DailyTrendsbyCounty`;


INSERT INTO ALERTS( DATE, STATE_ALPHA, DISEASE, DIS_ID, COUNTY_NAME_LONG, LATITUDE, LONGITUDE, COUNTY_FIPS , STATE_FIPS)
SELECT distinct curdate() as DATE, STATE_ALPHA, DISEASE, DIS_ID, COUNTY_NAME_LONG, LATITUDE, LONGITUDE, COUNTY_FIPS , STATE_FIPS
FROM (
SELECT state_alpha, disease, d.DIS_ID, county_name_long, latitude, longitude, t.county_fips, c.state_fips
FROM `TRENDS` t
inner join DISEASE d on d.dis_id = t.dis_id and d.isactive =1
inner join POP_PLACES_COUNTY c on c.county_fips = t.county_fips
inner join POP_PLACES_STATE s on s.state_fips = c.state_fips
where date >= curdate()- INTERVAL 14 DAY
group by t.county_fips, t.dis_id
having sum(normavg)/14 >=0.5 and count(normavg) > 1
UNION
SELECT state_alpha, disease, d.DIS_ID, county_name_long, latitude, longitude, t.county_fips, c.state_fips
FROM `TRENDS` t
inner join DISEASE d on d.dis_id = t.dis_id and d.isactive =1
inner join POP_PLACES_COUNTY c on c.county_fips = t.county_fips
inner join POP_PLACES_STATE s on s.state_fips = c.state_fips
where date >= curdate()- INTERVAL 1 DAY
group by t.county_fips, t.dis_id
having avg(normavg) >=1.5 and count(normavg) > 1
) t;


