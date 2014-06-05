DROP PROCEDURE UpdateTrends;
DELIMITER //
CREATE PROCEDURE UpdateTrends(thisdate DATE)
BEGIN

INSERT INTO TRENDS(DATE, COUNTY_FIPS, DIS_ID, NORMAVG, tweets, tot_days)
SELECT DATE, county_FIPS,dis_ID, normavg, tweets,tot_days
FROM (
	select (thisdate -INTERVAL 1 DAY) AS DATE,tc.COUNTY_FIPS AS COUNTY_FIPS,d.DIS_ID AS DIS_ID,avg(tc.normalized) AS NORMAVG,sum(tc.tweets) AS tweets,sum(tc.tot_days) AS tot_days 
	from ((TAXONOMY t 
		join (
			select a.TAX_ID AS TAX_ID,a.COUNTY_FIPS AS COUNTY_FIPS,((a.UCOUNT - tc.avg) / tc.std) AS normalized,(tc.sum + a.UCOUNT) AS tweets,(tc.samples + 1) AS tot_days 
			from (AGGREGATES a 
				join (
					#TaxbyCounty14d AS 
					select a1.COUNTY_FIPS AS COUNTY_FIPS,t1.TAX_ID AS TAX_ID,avg(a1.UCOUNT) AS avg,std(a1.UCOUNT) AS std,sum(a1.UCOUNT) AS sum
							,count(a1.UCOUNT) AS samples 
					from (AGGREGATES a1 
						join TAXONOMY t1 on((t1.TAX_ID = a1.TAX_ID))) 
					where ((a1.DATE <= (thisdate - interval 2 day)) and (a1.DATE >= (thisdate - interval 16 day)) and t1.ISACTIVE 
						and (a1.COUNTY_FIPS is not null)) 
					group by a1.COUNTY_FIPS,t1.TAX_ID 
				) tc on(((tc.COUNTY_FIPS = a.COUNTY_FIPS) and (tc.TAX_ID = a.TAX_ID)))) 
			where ((a.DATE = (thisdate - interval 1 day)) and (tc.std > 0))
		)tc on((tc.TAX_ID = t.TAX_ID))) 
		join DISEASE d on((d.DIS_ID = t.DIS_ID))) 
	group by tc.COUNTY_FIPS,d.DIS_ID
	) AS DailyTrendsbyCounty;

INSERT INTO TRENDS(DATE, STATE_FIPS, DIS_ID, NORMAVG, tweets, tot_days)
SELECT DATE, STATE_FIPS,dis_ID, normavg, tweets,tot_days
FROM (
	select (thisdate -INTERVAL 1 DAY) AS DATE,tc.STATE_FIPS AS STATE_FIPS,d.DIS_ID AS DIS_ID,avg(tc.normalized) AS NORMAVG,sum(tc.tweets) AS tweets,sum(tc.tot_days) AS tot_days 
	from ((TAXONOMY t 
		join (
			select a.TAX_ID AS TAX_ID,a.STATE_FIPS AS STATE_FIPS,((a.UCOUNT - tc.avg) / tc.std) AS normalized,(tc.sum + a.UCOUNT) AS tweets,(tc.samples + 1) AS tot_days 
			from (AGGREGATES a 
				join (
					#TaxbyCounty14d AS 
					select a1.STATE_FIPS AS STATE_FIPS,t1.TAX_ID AS TAX_ID,avg(a1.UCOUNT) AS avg,std(a1.UCOUNT) AS std,sum(a1.UCOUNT) AS sum,count(a1.UCOUNT) AS samples 
					from (AGGREGATES a1 
						join TAXONOMY t1 on((t1.TAX_ID = a1.TAX_ID))) 
					where ((a1.DATE <= (thisdate - interval 2 day)) and (a1.DATE >= (thisdate - interval 16 day)) and t1.ISACTIVE and (a1.STATE_FIPS is not null)) group by a1.STATE_FIPS,t1.TAX_ID 
				) tc on(((tc.STATE_FIPS = a.STATE_FIPS) and (tc.TAX_ID = a.TAX_ID)))) 
			where ((a.DATE = (thisdate - interval 1 day)) and (tc.std > 0))
		)tc on((tc.TAX_ID = t.TAX_ID))) 
		join DISEASE d on((d.DIS_ID = t.DIS_ID))) 
	group by tc.STATE_FIPS,d.DIS_ID
	) AS DailyTrendsbyState;


END //
