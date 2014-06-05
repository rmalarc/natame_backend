drop procedure UpdateAlerts;

DELIMITER //
CREATE PROCEDURE UpdateAlerts(thisdate DATE)
BEGIN


INSERT INTO ALERTS( DATE, STATE_ALPHA, DISEASE, DIS_ID, COUNTY_NAME_LONG, LATITUDE, LONGITUDE, COUNTY_FIPS , STATE_FIPS)
SELECT distinct (thisdate -INTERVAL 1 DAY) as DATE, STATE_ALPHA, DISEASE, DIS_ID, COUNTY_NAME_LONG, LATITUDE, LONGITUDE, COUNTY_FIPS , STATE_FIPS
FROM (
SELECT state_alpha, disease, d.DIS_ID, county_name_long, latitude, longitude, t.county_fips, c.state_fips
FROM `TRENDS` t
inner join DISEASE d on d.dis_id = t.dis_id and d.isactive =1 and d.SHOWALERTS = 1
inner join POP_PLACES_COUNTY c on c.county_fips = t.county_fips
inner join POP_PLACES_STATE s on s.state_fips = c.state_fips
where date <= (thisdate-INTERVAL 1 DAY) and date >= (thisdate- INTERVAL 15 DAY)
group by t.county_fips, t.dis_id
having sum(normavg)/14 >=0.5 and count(normavg) > 1
UNION
SELECT state_alpha, disease, d.DIS_ID, county_name_long, latitude, longitude, t.county_fips, c.state_fips
FROM `TRENDS` t
inner join DISEASE d on d.dis_id = t.dis_id and d.isactive =1 and d.showalerts=1
inner join POP_PLACES_COUNTY c on c.county_fips = t.county_fips
inner join POP_PLACES_STATE s on s.state_fips = c.state_fips
where date <= (thisdate-INTERVAL 1 DAY) and date >= (thisdate- INTERVAL 2 DAY)
group by t.county_fips, t.dis_id
having avg(normavg) >=1 and count(normavg) > 1
) t;



END
//
