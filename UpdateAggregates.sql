drop procedure UpdateAggregates;

DELIMITER //
CREATE PROCEDURE UpdateAggregates(thisdate DATE)
BEGIN

insert into AGGREGATES (DATE,STATE_FIPS,TAX_ID,TCOUNT,UCOUNT)
SELECT date(dtm), STATE_FIPS,t.TAX_ID, count(`match`), count(distinct(screen_name)) 
FROM tweets as t
inner join POP_PLACES `p` on `p`.FEATURE_ID = `t`.FEATURE_ID
INNER JOIN TAXONOMY `tx` on tx.TAX_ID = t.TAX_ID
WHERE date(dtm) = thisdate -INTERVAL 1 DAY 
	AND ISJUNK = 0
	AND PISJUNK <BAYES_P
group by `p`.STATE_FIPS, TAX_ID;


insert into AGGREGATES (DATE,COUNTY_FIPS,TAX_ID,TCOUNT,UCOUNT)
SELECT date(dtm), COUNTY_FIPS,t.TAX_ID, count(`match`), count(distinct(screen_name))
FROM tweets as `t`
inner join POP_PLACES p on `p`.FEATURE_ID = `t`.FEATURE_ID
INNER JOIN TAXONOMY `tx` on tx.TAX_ID = t.TAX_ID
WHERE date(dtm) = thisdate -INTERVAL 1 DAY  
	AND ISJUNK = 0
	AND PISJUNK <BAYES_P
group by `p`.COUNTY_FIPS, TAX_ID;

END
//
