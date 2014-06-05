drop procedure UpdateMenu;

DELIMITER //
CREATE PROCEDURE UpdateMenu(thisdate DATE)
BEGIN

INSERT INTO MENU(dis_id, disease,TR_ID, DATE,  DISPLAY_ORDER)
select dis_id, disease,TR_ID, DATE,  DISPLAY_ORDER
from (
select 0 as dis_id, '----- Trending -----' as disease,TR_ID, (thisdate-INTERVAL 1 DAY) as DATE, 0 as DISPLAY_ORDER
FROM TRACKING t
union
(SELECT dis_id,disease,d.TR_ID, (thisdate-INTERVAL 1 DAY) as DATE, DISPLAY_ORDER
FROM DISEASE d
INNER JOIN TRACKING t ON t.TR_ID = d.TR_ID
where isactive = 1
	AND SHOWALERTS=1
        AND DIS_ID in (SELECT DIS_ID FROM ALERTS WHERE DATE = (thisdate -INTERVAL 1 DAY))
)
union
select -1 as dis_id, '----- Inactive -----' as disease, TR_ID, (thisdate-INTERVAL 1 DAY) as DATE, 100 as DISPLAY_ORDER
FROM TRACKING t
union
(SELECT dis_id,disease, d.TR_ID, (thisdate-INTERVAL 1 DAY) as DATE, DISPLAY_ORDER +100 as DISPLAY_ORDER
FROM DISEASE d
INNER JOIN TRACKING t ON t.TR_ID = d.TR_ID
where isactive = 1
        AND (DIS_ID not in (SELECT distinct DIS_ID FROM ALERTS WHERE DATE = (thisdate -INTERVAL 1 DAY))
		OR SHOWALERTS=0
	)
) 
) m
order by TR_ID, DISPLAY_ORDER, DISEASE;


END
//
