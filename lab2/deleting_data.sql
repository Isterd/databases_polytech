--Удалить статью и операции, выполненные в ее рамках.
DELETE FROM articles WHERE name = 'Транспортные расходы';

--Удалить в рамках транзакции самый убыточный баланс и операции
DO $$
DECLARE min_balance_id INT;

BEGIN

min_balance_id = id FROM balance WHERE amount = (SELECT MIN(amount) FROM balance);

DELETE FROM operations WHERE balance_id = min_balance_id;
DELETE FROM balance WHERE id = min_balance_id;

END $$;

COMMIT;

--то же, что и п1, но, если в удаленном балансе использовались статьи,
--операции в рамках которых больше ни где не проводились – транзакцию
--откатить.
DO $$

DECLARE min_balance_id INT;
DECLARE articles_count INT;

BEGIN

min_balance_id = id FROM balance WHERE amount = (SELECT MIN(amount) FROM balance);
articles_count = COUNT(*) FROM operations
                          WHERE article_id IN (SELECT article_id
                                               FROM operations
                                               WHERE balance_id = min_balance_id);
DELETE FROM operations WHERE balance_id = min_balance_id;
DELETE FROM balance WHERE id = min_balance_id;

IF articles_count = 1 THEN
    ROLLBACK;
END IF;

END $$;