CREATE DATABASE rinha;

\connect rinha

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE OR REPLACE FUNCTION immutable_array_to_string(text[])
RETURNS text as $$
    SELECT array_to_string($1, ',');
$$ LANGUAGE sql IMMUTABLE;

CREATE TABLE pessoas  (
    id uuid DEFAULT uuid_generate_v4 () PRIMARY KEY,
    apelido VARCHAR(255) NOT NULL UNIQUE,
    nome VARCHAR(255) NOT NULL,
    nascimento VARCHAR(10) NOT NULL,
    stack VARCHAR(255)[] NULL,
    searchable_index tsvector GENERATED ALWAYS AS (
            to_tsvector('english', coalesce(apelido, '') || ' ' || coalesce(nome, '') || ' ' || coalesce(immutable_array_to_string(stack), ''))
        ) STORED
);

CREATE INDEX textsearch_idx ON pessoas USING GIN (searchable_index);
