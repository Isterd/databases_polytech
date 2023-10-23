--Удалить статью и операции, выполненные в ее рамках.
DELETE FROM articles WHERE name = 'Покупка подарков';

--Удалить в рамках транзакции самый убыточный баланс и операции
BEGIN;
WITH delete_operations
    AS (DELETE FROM operations
        WHERE balance_id
                  IN (SELECT id
                             FROM balance
                             WHERE amount IN (SELECT min(amount)
                                              FROM balance)) returning balance_id)
DELETE FROM balance WHERE id IN (SELECT * FROM delete_operations);
COMMIT;