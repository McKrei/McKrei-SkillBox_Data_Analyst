-- Задание 1
-- Каждая строка таблицы orderdetails описывает, сколько единиц товара с соответствующим артикулом было заказано в рамках конкретного заказа. 
-- Например, запись в таблице выше следует понимать так: в рамках заказа № 10100 было куплено 22 единицы товара S18_4409 по цене 75.46 каждая. Другими словами, общая стоимость купленных S18_4409 в заказе 10100 составила 1660.12.
-- Напишите запрос, который выберет из таблицы orderdetails топ-10 строк с максимальной общей стоимостью конкретного товара в рамках заказа. Для каждой строки выведите номер заказа, артикул товара и общую стоимость товара в заказе. 

SELECT orderNumber, productCode, quantityOrdered * priceEach as amounth
FROM orderdetails
ORDER BY amounth DESC
LIMIT 10;

-- Задание 2
-- В предыдущем задании вы нашли пары «номер заказа, артикул товара», для которых суммарная стоимость конкретного товара в рамках заказа была максимальной. Однако в рамках одного заказа могут быть заказаны разные товары. 
-- Пример в таблице выше показывает, что заказ 10100, кроме S18_4909, включал ещё три товарные единицы. Итого стоимость всего заказа: 
-- 49 × 35.29 + 22 × 75.46 + 50 × 55.09 + 30 × 136 = 10223.83.
-- Напишите запрос, который вернёт только те заказы, итоговая стоимость которых превышает 59 000 долларов. Результирующая таблица должна выглядеть так:

SELECT orderNumber, sum(quantityOrdered * priceEach) as total
FROM orderdetails
GROUP BY orderNumber
HAVING total > 59000
ORDER BY total DESC;

-- Задание 3
-- В предыдущем задании вы выбрали номера заказов, итоговая сумма которых превышала 59 000 долларов. Ваше текущее задание — узнать дату, когда эти заказы были сделаны, и статусы, в которых они находятся.
-- Напишите запрос, который вернёт вот такую таблицу:

SELECT t1.orderNumber,
		orderDate,
		status,
		sum(quantityOrdered * priceEach) as total
FROM orderdetails as t1
INNER JOIN orders as t2
ON t1.orderNumber = t2.orderNumber
GROUP BY orderNumber
HAVING total > 59000
ORDER BY total DESC;

-- Задание 4
-- Теперь вы знаете, столько стоили самые дорогие заказы, когда они были сделаны и в каком статусе находятся. Пришло время узнать, кто их сделал. 
-- Напишите запрос, в результате которого получится такая таблица:

SELECT contactFirstName,
		contactLastName,
		country,
		t1.orderNumber,
		orderDate,
		status,
		sum(quantityOrdered * priceEach) as total
FROM orderdetails as t1
INNER JOIN orders as t2
ON t1.orderNumber = t2.orderNumber
INNER JOIN customers as t3
ON t2.customerNumber = t3.customerNumber
GROUP BY orderNumber
HAVING total > 59000
ORDER BY total DESC

-- Задание 5
-- В заданиях с первого по четвёртое вы исследовали самые дорогие заказы, когда и кем они были сделаны. Вы начали от таблицы orderdetails и двигались к таблице customers через таблицу orders.
-- Теперь пойдите в другом направлении и составьте запрос, который выведет топ-10 названий (productName) товаров, на которые было потрачено больше всего денег.  
-- Другими словами, найдите 10 моделей, которые принесли максимальную выручку за всю историю наблюдений, содержащуюся в базе данных.

SELECT productName, sum(quantityOrdered * priceEach) as total
FROM products t1
INNER JOIN orderdetails t2
ON t1.productCode = t2.productCode
GROUP BY productName
ORDER BY total DESC
LIMIT 10

-- Задание 6
-- В уроках модуля мы рассмотрели три вида оператора JOIN — INNER, LEFT и RIGHT. Однако в языке SQL определён ещё один вид соединения таблиц — FULL JOIN. 
-- Эти таблицы и связь между ними отражают следующий факт: сотрудники магазина обслуживают клиентов. Один сотрудник может обслужить нескольких клиентов, но могут быть сотрудники, которые не обслуживали ни одного клиента. И наоборот, могут быть клиенты, которых никто не обслуживал. 
-- Видите, справа есть значения NULL — это значит, что соответствующий сотрудник не обслужил ни одного клиента.
-- Теперь значения NULL появились слева, потому что существуют клиенты, которых пока ещё не обслуживали. 
-- Так вот, FULL JOIN — это ситуация, в которой значения NULL могут быть как справа, так и слева. То есть FULL JOIN собирает в одной результирующей таблице вообще всех:
-- Сотрудников, которые обслуживали клиентов.
-- Клиентов, которые были обслужены сотрудниками.
-- Сотрудников, которые никого ещё не обслуживали.
-- Клиентов, которых никто пока не обслужил.

SELECT firstName, lastName, contactFirstName, contactLastName
FROM employees as t1
LEFT JOIN customers as t2
ON t1.employeeNumber = t2.salesRepEmployeeNumber 
UNION 
SELECT firstName, lastName, contactFirstName, contactLastName
FROM employees as t1
RIGHT JOIN customers as t2
ON t1.employeeNumber = t2.salesRepEmployeeNumber 

-- Видите, таблица связана сама с собой? Автосвязь соединяет первичный ключ таблицы employeeNumber с её внешним ключом reportsTo и реализует отношение «подчинённый → начальник». 
-- Так, если какой-либо сотрудник напрямую подчиняется сотруднику 1002, то поле reportsTo у него будет установлено в 1002.

SELECT t1.firstName, t1.lastName, t1.jobTitle, t2.firstName as subFirstName, t2.lastName as subLastName
FROM employees as t1
LEFT JOIN employees as t2
ON t1.employeeNumber = t2.reportsTo
