

select 
  CONCAT(
    CAST(YEAR(o_date) as char), 
    RIGHT(CONCAT('0',CAST(MONTH(o_date) as char)),2)) PERIOD
  , sum(price) SUM
  from orders_20190822
group by CONCAT(
    CAST(YEAR(o_date) as char), 
    RIGHT(CONCAT('0',CAST(MONTH(o_date) as char)),2))
