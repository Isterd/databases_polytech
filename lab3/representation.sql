--Создать представление, отображающее все статьи и суммы приход/расход
--неучтенных операций
CREATE VIEW UnaccountedOperations AS
SELECT a.id AS id,
       a.name AS name,
       SUM(o.debit) AS total_income,
       SUM(o.credit) AS total_expenses
FROM articles AS a
LEFT JOIN operations o ON a.id = o.article_id
WHERE o.balance_id IS NULL
GROUP BY a.id, a.name;

SELECT * FROM UnaccountedOperations;

--Создать представление, отображающее все балансы и число операций, на
--основании которых они были сформированы
CREATE VIEW BalanceOperations AS
SELECT b.id AS balance_id,
       b.create_date AS balance_date,
       COUNT(o.id) AS operation_count
FROM balance b
LEFT JOIN operations o ON b.id = o.balance_id
GROUP BY b.id, b.create_date;

SELECT * FROM BalanceOperations;
