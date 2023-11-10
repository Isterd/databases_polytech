--Посчитать прибыль за заданную дату
SELECT debit - credit AS amount FROM operations WHERE create_date = '2022-01-20';

--Вывести наименования всех статей, в рамках которых не проводилось
--операций за заданный период времени.
SELECT name FROM articles WHERE id NOT IN (SELECT article_id
             FROM operations
             WHERE create_date BETWEEN date '2022-03-01' AND date '2022-03-25');

--Вывести операции и наименования статей, включая статьи, в рамках
--которых не проводились операции.
SELECT name, debit, credit, create_date FROM articles A LEFT JOIN operations O
ON A.id = O.article_id;

--Вывести число балансов, в которых учтены операции принадлежащие
--статье с заданным наименованием.
SELECT COUNT(DISTINCT b.id) AS balance_count
FROM balance b
INNER JOIN operations o ON b.id = o.balance_id
INNER JOIN articles a ON o.article_id = a.id
WHERE a.name = 'Продукты питания';
