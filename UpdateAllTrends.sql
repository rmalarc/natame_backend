drop procedure UpdateAllTrends;
DELIMITER //

CREATE PROCEDURE UpdateAllTrends(initdate DATE, enddate DATE)
BEGIN
  label1: LOOP
    delete from AGGREGATES where DATE = initdate -INTERVAL 1 DAY;
    CALL UpdateAggregates(initdate);
    delete from MOVAVG where DATE = initdate -INTERVAL 1 DAY;
    CALL UpdateMovAvg(initdate);
    delete from TRENDS where DATE = initdate -INTERVAL 1 DAY;
    CALL UpdateTrends(initdate);
    delete from ALERTS where DATE = initdate -INTERVAL 1 DAY;
    CALL UpdateAlerts(initdate);
    delete from MENU where DATE = initdate -INTERVAL 1 DAY;
    CALL UpdateMenu(initdate);
    delete from HEATMAP where DATE = initdate -INTERVAL 1 DAY;
    CALL UpdateHeatMap(initdate);
    SET initdate = initdate + interval 1 day ;
    IF initdate <= enddate THEN
      ITERATE label1;
    END IF;
    LEAVE label1;
  END LOOP label1;
END//

