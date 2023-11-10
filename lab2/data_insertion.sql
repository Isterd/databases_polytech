--Добавить новую статью
INSERT INTO articles(name)
VALUES ('Покупка книг');

--Добавить операцию в рамках статьи из п1
INSERT INTO operations(article_id, debit, credit, create_date)
VALUES (11, 0, 1000, '2022-05-20');

--Сформировать баланс. Если сумма прибыли меньше некоторой суммы –
--транзакцию откатить.
DO $$
DECLARE new_balance_id INT;
DECLARE profit_amount DECIMAL;

BEGIN

new_balance_id = max(id) + 1 FROM balance;
profit_amount = SUM(debit) - SUM(credit) FROM operations WHERE balance_id IS NULL;

IF profit_amount >= 0 THEN
    INSERT INTO balance (id, create_date, debit, credit, amount)
    VALUES (new_balance_id, CURRENT_DATE, (SELECT SUM(debit) FROM operations WHERE balance_id IS NULL),
            (SELECT SUM(credit) FROM operations WHERE balance_id IS NULL), profit_amount);
    UPDATE operations SET balance_id = new_balance_id WHERE balance_id IS NULL;
ELSE
    ROLLBACK;
END IF;
END $$;

COMMIT;