drop procedure UpdateMovAvg;

DELIMITER //
CREATE PROCEDURE UpdateMovAvg(thisdate DATE)
BEGIN

INSERT INTO MOVAVG(DATE,COUNTY_FIPS,TAX_ID, AVG14d, STD14d)
select (thisdate - interval 1 day) as DATE, COUNTY_FIPS, TAX_ID, avg(a1.UCOUNT) as AVG14d, std(a1.UCOUNT) as STD14d
        from AGGREGATES a1
        where a1.COUNTY_FIPS is not null
                AND a1.DATE <= (thisdate - interval 2 day)
                AND a1.DATE >= (thisdate - interval 16 day)
group by COUNTY_FIPS, TAX_ID
having std(a1.UCOUNT) > 0;


INSERT INTO MOVAVG(DATE,STATE_FIPS,TAX_ID, AVG14d, STD14d)
select (thisdate - interval 1 day) as DATE, STATE_FIPS, TAX_ID, avg(a1.UCOUNT) as AVG14d, std(a1.UCOUNT) as STD14d
        from AGGREGATES a1
        where a1.STATE_FIPS is not null
                AND a1.DATE <= (thisdate - interval 2 day)
                AND a1.DATE >= (thisdate - interval 16 day)
group by STATE_FIPS, TAX_ID
having std(a1.UCOUNT) > 0;

END
//
