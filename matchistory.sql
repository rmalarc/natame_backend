SELECT date(`dtm`) as `initial date (d0)`,`match`, count(`match`) as `matches d0`,
(
   SELECT count(`d-1`.`match`)
   FROM `tweets` as `d-1`
   WHERE (date(`d-1`.`dtm`)  = (CURDATE() -1)) and (`d-1`.`match` = `d-0`.`match`)
) as `matches d-1`,
(
   SELECT count(`d-2`.`match`)
   FROM `tweets` as `d-2`
   WHERE (date(`d-2`.`dtm`)  = (CURDATE() -2)) and (`d-2`.`match` = `d-0`.`match`)
) as `matches d-2`,
(
   SELECT count(`d-3`.`match`)
   FROM `tweets` as `d-3`
   WHERE (date(`d-3`.`dtm`)  = (CURDATE() -3)) and (`d-3`.`match` = `d-0`.`match`)
) as `matches d-3`,
(
   SELECT count(`d-4`.`match`)
   FROM `tweets` as `d-4`
   WHERE (date(`d-4`.`dtm`)  = (CURDATE() -4)) and (`d-4`.`match` = `d-0`.`match`)
) as `matches d-4`,
(
   SELECT count(`d-5`.`match`)
   FROM `tweets` as `d-5`
   WHERE (date(`d-5`.`dtm`)  = (CURDATE() -5)) and (`d-5`.`match` = `d-0`.`match`)
) as `matches d-5`


FROM `tweets` as `d-0`
WHERE date(`d-0`.`dtm`) = CURDATE()
group by `match`

