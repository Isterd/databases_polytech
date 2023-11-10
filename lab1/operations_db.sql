CREATE TABLE balance (
    id serial primary key,
    create_date timestamp(3),
    debit numeric(18, 2),
    credit numeric(18, 2),
    amount numeric(18, 2)
);

CREATE TABLE articles (
    id serial primary key,
    name varchar(50)
);

CREATE TABLE operations (
    id serial primary key,
    article_id integer references articles(id) ON DELETE CASCADE,
    debit numeric(18, 2),
    credit numeric(18, 2),
    create_date timestamp(3),
    balance_id integer references balance(id)
);
