UPDATE `tweets` SET STATE = '' WHERE STATE IS NULL;

update tweets
set ISJUNK = 1 
where text like '%vaccin%' or text like '%epidemic%' or text like '%FDA%' or text like '%flu shot%' 
	or text like '%tetanus shot%' or text like '%flu game%'
	or text like '%meningitis shot%'
#	or text like '%http://%'
	or name = 'tweet3po'
      AND TAX_ID is null
      AND dt >= curdate() - interval 1 day
      AND ISJUNK = 0
;



UPDATE `tweets` 
SET `city`= 'Hempstead'
where `city` = 'Long Island'
	and `state` = 'NY' 
	and `feature_id` is null
	and (latitude = 0 or longitude = 0)
      AND dt >= curdate() - interval 1 day
      AND ISJUNK = 0
;


UPDATE `tweets` 
SET `city`= 'New York'
where `city` = 'NYC'
	and `state` = 'NY' 
	and `feature_id` is null
      AND dt >= curdate() - interval 1 day
      AND ISJUNK = 0
;


UPDATE `tweets` as `t` 
SET `FEATURE_ID`=(
	select `p`.`FEATURE_ID` 
	from `POP_PLACES` as `p` 
	where `city` = `FEATURE_NAME` 
		and `state` = `STATE_ALPHA` 
		and `PRIM_LAT_DEC` is not null 
		and `PRIM_LONG_DEC` is not null 
	limit 1 )
where `t`.`feature_id` is null 
      AND ISJUNK = 0
	and (DELETEME <>1 or deleteme is null)
      AND dt >= curdate() - interval 1 day
;



UPDATE `tweets` as `t` 
SET `TAX_ID`=(
	select `TAX`.`TAX_ID` 
	from `TAXONOMY` as `TAX` 
	where `TERM` = `MATCH` 
	 )
where `t`.`TAX_ID` is null
      AND dt >= curdate() - interval 1 day
      AND ISJUNK = 0
;
