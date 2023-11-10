--Увеличить сумму расхода операций, выполненных в рамках статьи, заданной по наименованию, на заданную величину.
--Расход и прибыль сформированных на основании модифицируемых операций балансов должны быть пересчитаны.
DO $$
DECLARE increase_in_flow INTEGER;
DECLARE article_name VARCHAR;

BEGIN

increase_in_flow = 1000;
article_name = 'Медицинские расходы';

UPDATE operations SET credit = credit + increase_in_flow
                  WHERE article_id IN (SELECT id
                                       FROM articles
                                       WHERE name = article_name);
UPDATE balance
        SET credit = credit + increase_in_flow,
            amount = debit - credit - increase_in_flow
        WHERE id IN (SELECT balance_id
                     FROM operations
                     WHERE article_id IN (SELECT id
                                          FROM articles
                                          WHERE name = article_name));
END $$;

--В рамках транзакции поменять заданную статью во всех операциях на другую и удалить ее.
START TRANSACTION;

DO $$
DECLARE old_article_id INT;
DECLARE new_article_id INT;

BEGIN
SELECT old_article_id = id FROM articles WHERE name = 'Одежда';
SELECT new_article_id = id FROM articles WHERE name = 'Развлечения';

UPDATE operations SET article_id = new_article_id WHERE article_id = old_article_id;
DELETE FROM articles WHERE id = old_article_id;
END $$;

COMMIT;