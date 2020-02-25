
with 
  FIRST_ORDER_DATE as (
    SELECT 
      user_id, 
      MIN(o_date) mdate,
      CONCAT(CAST(YEAR(o_date) as char),RIGHT(CONCAT('0',CAST(MONTH(o_date) as char)),2)) COHORT_PERIOD
    FROM orders_20190822 GROUP BY user_id ),
  USERS_DATA as (
    SELECT 
        user_id, 
        SUM(price) PRICE
      FROM orders_20190822 
      GROUP BY user_id)


select 
    FOD.COHORT_PERIOD COHORT
    /*,ROW_NUMBER() OVER(PARTITION BY FOD.COHORT_PERIOD ORDER BY FOD.COHORT_PERIOD)*/
    ,CONCAT(CAST(YEAR(O.o_date) as char),RIGHT(CONCAT('0',CAST(MONTH(O.o_date) as char)),2)) ORDER_PERIOD
    ,sum(O.price) SUM
  from orders_20190822 O left join FIRST_ORDER_DATE FOD on O.user_id = FOD.user_id
group by 
    COHORT,
    ORDER_PERIOD
  order by COHORT, ORDER_PERIOD
