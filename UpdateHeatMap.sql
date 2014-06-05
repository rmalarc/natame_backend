drop procedure UpdateHeatMap;

DELIMITER //
CREATE PROCEDURE UpdateHeatMap(thisdate DATE)
BEGIN


INSERT INTO HEATMAP( DATE, COUNTY_FIPS, Tweets7D,COUNTY_NAME_LONG,STATE_ALPHA, POPESTIMATE2011,Days, DISEASE, TweetsPM, Score,Score2)
SELECT  thisdate - interval 1 day as DATE
        ,t.COUNTY_FIPS
        ,sum(t.tcount) as Tweets7D
        ,c.COUNTY_NAME_LONG
        ,s.STATE_ALPHA
        ,POPESTIMATE2011
        ,count(DISTINCT DATE) AS Days
        ,d.DISEASE
        ,(sum(t.tcount) / max(POPESTIMATE2011)) * 1000000 AS TweetsPM
        ,ln(1+(sum(t.tcount) / max(POPESTIMATE2011) * 1000000))*count(DISTINCT DATE)/7 AS Score
        ,ln(1+(1000000*sum(t.tcount) / max(POPESTIMATE2011) )*(count(DISTINCT DATE)/7)) AS Score2
FROM `AGGREGATES` t
INNER JOIN TAXONOMY tax ON tax.TAX_ID = t.TAX_ID
        AND tax.isactive = 1
INNER JOIN DISEASE d ON d.DIS_ID = tax.DIS_ID
        AND d.isactive = 1 
	AND TR_ID = 1
INNER JOIN POP_PLACES_COUNTY c ON c.COUNTY_FIPS = t.COUNTY_FIPS
INNER JOIN POP_PLACES_STATE s ON s.STATE_FIPS = c.STATE_FIPS
WHERE t.COUNTY_FIPS IS NOT NULL
        AND DATE between (thisdate-INTERVAL 7 DAY) AND (thisdate-INTERVAL 1 DAY)
#       AND DATE BETWEEN '2013-01-05' and '2013-01-11'
GROUP BY d.DISEASE
        ,t.COUNTY_FIPS;

END
//
