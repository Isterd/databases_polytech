--Создать хранимую процедуру, выводящую все операции последнего баланса
--и прибыли по каждой.
CREATE OR REPLACE FUNCTION get_last_balance_operations_and_profit()
RETURNS TABLE(
    operation_id INT,
    article_name VARCHAR(50),
    debit NUMERIC,
    credit NUMERIC,
    profit NUMERIC
) AS $$
DECLARE last_balance_id INT;
BEGIN
    SELECT id INTO last_balance_id FROM balance ORDER BY create_date DESC LIMIT 1;
    RETURN QUERY
    SELECT o.id AS operation_id, a.name AS article_name, o.debit, o.credit, (o.debit - o.credit) AS profit
    FROM operations o
    INNER JOIN articles a ON o.article_id = a.id
    WHERE o.balance_id = last_balance_id;
END
$$ LANGUAGE plpgsql;

SELECT * FROM get_last_balance_operations_and_profit();

--Создать хранимую процедуру, имеющую два параметра «статья1» и
--«статья2». Она должна возвращать балансы, операции по «статье1» в
--которых составили прибыль большую, чем по «статье2». Если в балансе
--отсутствуют операции по одной из статей – он не рассматривается.
CREATE OR REPLACE FUNCTION get_balances_with_higher_profit(
    article1_name VARCHAR(50),
    article2_name VARCHAR(50)
)
RETURNS TABLE(
    balance_id INT,
    article1_profit NUMERIC,
    article2_profit NUMERIC
) AS $$
DECLARE
    item1_id INT;
    item2_id INT;
BEGIN
    item1_id = id FROM articles WHERE name = article1_name;
    item2_id = id FROM articles WHERE name = article2_name;
    RETURN QUERY
    SELECT b.id AS balance_id,
           SUM(CASE WHEN o.article_id = item1_id THEN (o.debit - o.credit) ELSE 0 END)
               AS article1_profit,
           SUM(CASE WHEN o.article_id = item2_id THEN (o.debit - o.credit) ELSE 0 END)
               AS article2_profit
    FROM balance b
    LEFT JOIN operations o ON b.id = o.balance_id
    WHERE o.article_id = item1_id OR o.article_id = item2_id
    GROUP BY b.id
    HAVING
        SUM(CASE WHEN o.article_id = item1_id THEN (o.debit - o.credit) ELSE 0 END) >
        SUM(CASE WHEN o.article_id = item2_id THEN (o.debit - o.credit) ELSE 0 END);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_balances_with_higher_profit('Зарплата', 'Одежда');

--Создать хранимую процедуру с входным параметром баланс и выходным
--параметром – статья, операции по которой проведены с наибольшими расходами
CREATE OR REPLACE FUNCTION find_article_with_highest_expenses_in_balance(choose_balance_id INT)
RETURNS TABLE(
    article_with_highest_expenses VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT a.name AS article_with_highest_expenses
    FROM operations o
    INNER JOIN articles a ON o.article_id = a.id
    WHERE o.balance_id = choose_balance_id
    GROUP BY a.name
    ORDER BY SUM(o.credit) DESC
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_article_with_highest_expenses_in_balance(4);