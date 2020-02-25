
/*ДЗ
В качестве ДЗ делам прогноз ТО на 12.2017. В качестве метода прогноза - считаем сколько денег тратят группы клиентов вдень:
1. Группа часто покупающих и которые последний раз покупали не так давно. Считаем сколько денег оформленного заказа приходится на 1 день. Умножаем на 30.
2. Группа часто покупающих, но которые не покупали уже значительное время. Так же можем сделать вывод, из такой группы за след месяц сколько купят и на какой сре чек.
3. Отдельно разобрать пользователей с 1 и 2 покупками за все время
4. В итоге у вас будет прогноз ТО и вы сможете его сравнить с фактом и оценить грубо разлет по данным.
​
Как источник данных используем данные по продажам за 2 года.*/



SET @R3 := 3; /*часто покупающие*/
SET @R2 := 10; /*покупавшие не так давно*/
SET @F1 := 20; /*в течение 23 мес покупали до 20 раз*/
SET @F2 := 100; /*в течение 23 мес (100 недель) купили до 100 раз*/
/*SET @M1 := 5000000;
SET @M2 := 100000000;*/

SET @last_date := (select MAX(o_date) FROM orders_20190822 where o_date < '2017/12/01');
SET @totalСС := (select SUM(price) FROM orders_20190822 where o_date < '2017/12/01');
WITH
  users_2017_12 as (
        select distinct (user_id) from orders_20190822 where o_date >= '2017/12/01'
  )
  ,R as (
        SELECT  user_id, 
                MAX(o_date) mdate, 
                DATEDIFF(@last_date,MAX(o_date)) days 
        FROM orders_20190822 where o_date < '2017/12/01' 
        GROUP BY user_id
        )
  ,F as (
    SELECT user_id, COUNT(id_o) c FROM orders_20190822 where o_date < '2017/12/01' GROUP BY user_id )
  -- select distinct user_id FROM F
  
  ,M as (
    SELECT user_id, DATE_FORMAT(o_date,"%y%m") PERIOD, SUM(price) m FROM orders_20190822 where o_date < '2017/12/01' GROUP BY user_id, PERIOD)
  -- select PERIOD, sum(m) from M group by PERIOD
  
  ,RF as (
    SELECT 
      R.user_id
      ,R.days R
      ,F.c F
      ,CASE  WHEN R.days <= @R3 THEN 3
            WHEN  R.days <= @R2 THEN 2
      ELSE 1 END as R1,
      CASE  WHEN F.c <= @F1 THEN 1
            WHEN  F.c <= @F2 THEN 2
      ELSE 3 END as F1,
      0 as M1
      

    FROM R inner join F on R.user_id = F.user_id)
  -- select * from RF

 , USERGROUPS as (/*ВВОДИМ ГРУППИРОВКУ*/
    SELECT
      RF.user_id,
      RF.R,
      RF.F,
      CONCAT(RF.R1,RF.F1) RF,
      CASE  
            /*1. Группа часто покупающих и которые последний раз покупали не так давно.*/
            WHEN  CONCAT(RF.R1,RF.F1) IN ('33', '23'
                                          '32', '31', '22', '21') THEN 'GROUP1' 
      
            /*2. Группа часто покупающих, но которые не покупали уже значительное время.*/
            WHEN  CONCAT(RF.R1,RF.F1) IN ('13') THEN 'GROUP2' 
            
            /*3. Отдельно разобрать пользователей с 1 и 2 покупками за все время*/
            WHEN  RF.F < 3 and CONCAT(RF.R1,RF.F1) NOT IN ('31', '21') THEN 'GROUP3'

            ELSE 'OTHER' 
      END as GR
    FROM RF)
  
--   select distinct (user_id) from orders_20190822 where o_date < '2017/12/01'
  
--  select * from USERGROUPS
  
  select
  	u.GR
  	-- ,m.user_id
  	,m.PERIOD
  	,SUM(m.m)
  	,count(m.user_id)
  from M m left join USERGROUPS u on m.user_id = u.user_id
  group by u.GR, PERIOD
  
  
  /*  
  SELECT
    GR UserGroup,
    COUNT(user_id) Users_in_Group,
    SUM(M) Sum_in_Group,
    cast(100*SUM(M)/@totalСС as decimal(3,0)) Percent_of_TotalCC

  FROM USERGROUP
  GROUP BY GR*/
    
