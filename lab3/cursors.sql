-- Входными параметрами процедуры задается интервал времени, множество
-- анализируемых статей и тип потоков для анализа (расход, приход, прибыль). Результатом работы процедуры
-- должна явится выборка, содержащая идентификаторы статей и
-- процент финансов, принадлежащих этой статье согласно анализируемому типу потоков.
-- Предлагается следующий алгоритм реализации. Согласно переданных в процедуру
-- параметров рассчитываем сумму финансовых потоков заданного типа согласно балансам,
-- вошедшим в заданный интервал. Далее, организуем курсор по статьям, идентификаторы
-- которых переданы в процедуру. В теле курсора для каждой статьи рассчитываем процент
-- финансов от общего и выбираем его.
CREATE OR REPLACE FUNCTION calculate_financial_percentages(
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    article_ids INT[],
    flow_type VARCHAR
)
RETURNS TABLE(
    item_id INT,
    financial_percentage NUMERIC
) AS $$
DECLARE
    total_amount NUMERIC;
BEGIN
    -- Рассчитываем сумму финансовых потоков заданного типа согласно балансам, вошедшим в заданный интервал
    SELECT
        CASE
            WHEN flow_type = 'debit' THEN SUM(debit)
            WHEN flow_type = 'credit' THEN SUM(credit)
            WHEN flow_type = 'amount' THEN SUM(debit - credit)
            ELSE 0
        END
    INTO total_amount
    FROM operations
    WHERE create_date BETWEEN start_date AND end_date;

    -- Организуем курсор по статьям
    FOR item_id IN SELECT id FROM articles WHERE id = ANY (article_ids)
    LOOP
        BEGIN
        -- Рассчитываем процент финансов от общего для каждой статьи
        financial_percentage := (SELECT
                                    (CASE
                                        WHEN flow_type = 'debit' THEN SUM(debit)
                                        WHEN flow_type = 'credit' THEN SUM(credit)
                                        WHEN flow_type = 'amount' THEN SUM(debit - credit)
                                        ELSE 0
                                    END) / total_amount * 100
                                FROM operations AS o
                                WHERE o.article_id = item_id
                                  AND o.create_date
                                      BETWEEN start_date AND end_date);
        -- Возвращаем идентификатор статьи и рассчитанный процент
        RETURN NEXT;
        END;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM calculate_financial_percentages('2022-01-01', '2022-03-01',ARRAY[1, 2, 3], 'credit');