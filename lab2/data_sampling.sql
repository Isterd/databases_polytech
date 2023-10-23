--Посчитать прибыль за заданную дату
SELECT amount FROM balance WHERE create_date = '2022-05-20';

--Вывести наименования всех статей, в рамках которых не проводилось
--операций за заданный период времени.
SELECT name FROM articles WHERE id IN (SELECT article_id
             FROM operations
             WHERE create_date NOT BETWEEN '2022-05-07' AND '2022-06-25');

--Вывести операции и наименования статей, включая статьи, в рамках
--которых не проводились операции.
SELECT name, debit, credit, create_date FROM articles A INNER JOIN operations O
ON A.id = O.article_id;

--Вывести число балансов, в которых учтены операции принадлежащие
--статье с заданным наименованием.
SELECT COUNT(*) FROM balance B INNER JOIN operations O
ON B.debit = O.debit AND B.credit = O.credit AND B.create_date = O.create_date
INNER JOIN articles A ON O.article_id = A.id WHERE A.name = 'Покупка топлива';

