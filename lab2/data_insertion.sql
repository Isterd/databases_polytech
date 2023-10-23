--Добавить новую статью
INSERT INTO articles(name)
VALUES ('Развлечения');

--Добавить операцию в рамках статьи из п1
INSERT INTO operations(article_id, debit, credit, create_date, balance_id)
VALUES (11, 13000, 8000, '2022-04-30', 13);

--Сформировать баланс. Если сумма прибыли меньше некоторой суммы –
--транзакцию откатить.
BEGIN;
INSERT INTO balance(id, create_date, debit, credit, amount)
VALUES (13, '2022-04-30', 13000, 8000, 5000);
rollback;
