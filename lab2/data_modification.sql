--Увеличить сумму расхода операций, выполненных в рамках статьи, заданной по наименованию, на заданную величину.
--Расход и прибыль сформированных на основании модифицируемых операций балансов должны быть пересчитаны.
UPDATE operations SET credit = credit + 1000
                  WHERE article_id IN (SELECT id
                                       FROM articles
                                       WHERE name = 'Оплата медицинских услуг');
UPDATE balance
        SET credit = credit + 1000,
            amount = debit - credit - 1000
        WHERE id IN (SELECT balance_id
                     FROM operations
                     WHERE article_id IN (SELECT id
                                          FROM articles
                                          WHERE name = 'Оплата медицинских услуг'));

--В рамках транзакции поменять заданную статью во всех операциях на другую и удалить ее.
BEGIN;

UPDATE operations SET article_id = 6
WHERE article_id IN (SELECT id FROM articles
                               WHERE name = 'Покупка топлива');

DELETE FROM articles WHERE name = 'Покупка топлива';

COMMIT;