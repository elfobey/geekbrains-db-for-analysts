/*
Идея - научиться работать с парами товаров.
Т.е. в заказах часто одновлеменнно встречаются товар1 и товар2. Надо найти на каждую такую существующую группу товаров общий ТО, кот. они делают, сколько делает в этих группах каждый из товаров и еще найти сколько каждый из этих товаров делает не в этих группа.
К примеру: Товар1 и Товар2. Группа Т1 и Т2 вместе (когда встречается в заказах одновремнно) генерит столько-то. Товар Т1, когда в заказах идет вместе с Т2, генерит столько-то. Аналогично для Т2. Т1 в заказах, где нет Т2, генерит столько-то. Т2 в заказах, где нет Т1, генерит столько-то.
Подобным образом надо разобрать все группы. И в итоге мы будем понимать как ведет себя товар один как таковой и как во всех возможных (в которых он стречался) группах. Подумайте, как бы вы подошли к решению такой задачи.
Исходник баскета: https://drive.google.com/open?id=1Mny5vMvBMCanejc9AEA8y4SVwvgWGd0S
*/

set @prod1 := 94674;
set @prod2 := 98886; -- важно, чтобы ID у prod1 был меньше ID у prod2
set @ORDERS_LIMIT := 2000; -- всео их 302449 уникальных, последний ORDER_ID = 576484. Данный лимит нужен для PAIRS ниже

/*в данном CTE соберутся все возможные сочетания пар заказов*/
with PAIRS as (
	select 
		 b1.`BASKET_ID` b1
		,b1.`ORDER_ID` o1
		,b1.`PRODUCT_ID` prod1
		,b1.`QUANTITY` q1
		,b1.`PRICE` price1
		,b2.`BASKET_ID` b2
		,b2.`ORDER_ID` o2
		,b2.`PRODUCT_ID` prod2
		,b2.`QUANTITY` q2
		,b2.`PRICE` price2
	from basket_20190922 b1 inner join basket_20190922 b2 on b1.`PRODUCT_ID`< b2.`PRODUCT_ID`
	and b1.`ORDER_ID` = b2.`ORDER_ID`
	and b1.`ORDER_ID` <= @ORDERS_LIMIT
	LIMIT 0, 10000 -- на всякий случай ограничиваем, поскольку множество очень большое
 )
 
 /*в искомом множестве пар найдем товарооборот по условию задачи*/
 select 1 as N, 'together' as T, SUM(q1*price1 + q2*price2) from PAIRS where prod1 = @prod1 and prod2 = @prod2
 union
 select 2, concat('p1(',cast(@prod1 as char),') where p2 (',cast(@prod2 as char),') exists'), SUM(q1*price1) from PAIRS where prod1 = @prod1 and prod2 = @prod2
 union
 select 3, concat('p2(',cast(@prod2 as char),') where p1 (',cast(@prod1 as char),') exists'), SUM(q2*price2) from PAIRS where prod1 = @prod1 and prod2 = @prod2
 union
 select 4, concat('p1(',cast(@prod1 as char),') where p2 (',cast(@prod2 as char),') absent'), SUM(q1*price1) from PAIRS where prod1 = @prod1 and prod2 != @prod2
 union
 select 5, concat('p2(',cast(@prod2 as char),') where p1 (',cast(@prod1 as char),') absent'), SUM(q2*price2) from PAIRS where prod1 != @prod1 and prod2 = @prod2