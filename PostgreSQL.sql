-- При решении применялась СУБД PostgreSQL
-- Создание таблиц производилось средствами среды pgAdmin


-- Первое задание:
WITH RECURSIVE get_schedule AS
(
	SELECT 
		1 AS Iteration,
		NOW() AS CurrentDate    
	UNION 
	SELECT 
		Iteration + 1 AS Iteration, 
		CurrentDate + (FLOOR(random()*(7-2+1))+2)*interval '1 day' AS CurrentDate 
	FROM get_schedule
	WHERE Iteration < 100
)
SELECT to_char(get_schedule.CurrentDate, 'DD.MM.YYYY') date FROM get_schedule;


-- Заполнение таблиц тестовыми данными для 2-ого задания:
-- INSERT INTO employee VALUES  (1, 'Иван'),
-- 								(2, 'Анастасия'),
-- 								(3, 'Дарья'),
-- 								(4, 'Василий'),
-- 								(5, 'Александр')			
-- INSERT INTO sales VALUES (1, 1, 254),
-- 							(2, 3, 874),
-- 							(3, 1, 201),
-- 							(4, 4, 780),
-- 							(5, 2, 502)

-- Второе задание
-- Примечание: итоговый результат сортируется по сумме продаж
SELECT
	id,
	name,
	sales_c,
	DENSE_RANK() OVER(ORDER BY sales_c DESC) AS sales_rank_c,
	sales_s,
	DENSE_RANK() OVER(ORDER BY sales_s DESC) AS sales_rank_s
FROM
(
	SELECT
		employee.id,
		employee.name,
		COUNT(*) sales_c,
		SUM(sales.price) sales_s
	FROM employee, sales
	WHERE sales.employee_id = employee.id
	GROUP BY
		employee.id,
		employee.name,
		sales.employee_id,
		sales.employee_id
) AS foo
ORDER BY sales_rank_s


-- Заполнение тестовыми данными таблицы transfers для 3-его задания:
-- INSERT INTO transfers VALUES (1, 2, 500, '23.02.2023'),
-- 								(2, 3, 300, '01.03.2023'),
-- 								(3, 1, 200, '05.03.2023'),
-- 								(1, 3, 400, '05.04.2023')
							
-- Третье задание:
-- Получение списка уникальных аккаунтов, отсортированных по возрастанию:
WITH acc_list AS
(
	SELECT
		transfers.from AS acc
	FROM transfers
	UNION
	SELECT
		transfers.to AS acc
	FROM transfers
	ORDER BY acc
),

-- Получение предварительного результата (без конвертации дат и с неправильными балансами):
no_preproc_dates AS
(
	SELECT
		acc,
		dt_from,
		LEAD(dt_to, 1, '01.01.3000') OVER (PARTITION BY acc ORDER BY dt_from) AS dt_to,
		balance
	FROM
	(
		SELECT
			transfers.from AS acc,
			transfers.tdate AS dt_from,
			transfers.tdate AS dt_to,
			-transfers.amount AS balance
		FROM transfers
		WHERE transfers.from IN 
			(SELECT * FROM acc_list)
		UNION
		SELECT
			transfers.to AS acc,
			transfers.tdate AS dt_from,
			transfers.tdate AS dt_to,
			transfers.amount AS balance
		FROM transfers
		WHERE transfers.to IN 
			(SELECT * FROM acc_list)
	) AS foo
),

-- Расчёт правильного баланса:
get_balance AS
(
	SELECT
		acc,
		dt_from,
		dt_to,
		COALESCE(SUM(balance) OVER (PARTITION BY acc ORDER BY dt_from ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 0) AS balance
	FROM no_preproc_dates
),

-- Финальная конвертация дат:
get_converted_dates AS
(
	SELECT
		acc,
		to_char(dt_from, 'DD.MM.YYYY') as dt_from,
		to_char(dt_to, 'DD.MM.YYYY') as dt_to,
		balance
	from get_balance
)

-- Получение финального результата:
SELECT * from get_converted_dates