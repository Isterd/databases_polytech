-- Создать триггер, который не позволяет создать баланс с нулевым приходом
-- и расходом или незаданной датой.
CREATE OR REPLACE FUNCTION CheckBalance()
RETURNS TRIGGER
AS $BODY$
BEGIN
    IF NEW.debit = 0 OR NEW.credit = 0 OR NEW.create_date IS NULL THEN
        RAISE EXCEPTION 'Cannot create balance with zero debit or credit or null create date';
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER check_balance_trigger
BEFORE INSERT ON balance
FOR EACH ROW
EXECUTE FUNCTION CheckBalance();

-- Создать триггер, который не позволяет изменить операцию, которая учтена
-- в балансе
CREATE OR REPLACE FUNCTION CheckOperation()
RETURNS TRIGGER
AS $BODY$
BEGIN
    IF EXISTS (SELECT 1 FROM balance WHERE OLD.balance_id = id) THEN
        RAISE EXCEPTION 'Cannot modify operation that is included in a balance';
    END IF;
    RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER check_operation_trigger
BEFORE UPDATE ON operations
FOR EACH ROW
EXECUTE FUNCTION CheckOperation();

-- Создать триггер, который при удалении операции, если она учтена в балансе
-- – откатывает транзакцию.
CREATE OR REPLACE FUNCTION CheckDeleteOperation()
RETURNS TRIGGER
AS $BODY$
BEGIN
    IF EXISTS (SELECT 1 FROM balance WHERE OLD.balance_id = id) THEN
        RAISE EXCEPTION 'Operation is included in a balance, transaction rollback';
    END IF;
    RETURN OLD;
END;
$BODY$
LANGUAGE plpgsql;

CREATE TRIGGER check_delete_operation_trigger
BEFORE DELETE ON operations
FOR EACH ROW
EXECUTE FUNCTION CheckDeleteOperation();