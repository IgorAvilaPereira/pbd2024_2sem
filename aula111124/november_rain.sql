-- export FLASK_APP=hello.py
-- flask run

DROP DATABASE IF EXISTS november_rain;

CREATE DATABASE november_rain;

\c november_rain;

CREATE TABLE usuario (
    id serial primary key,
    email varchar(255) not null,
    senha varchar(255) not null,
    unique(email)
);


CREATE TABLE cliente (
    id serial primary key,
    cpf char(11) not null,
    nome varchar(255) not null,
    usuario_id integer references usuario (id),
    unique(cpf)   
);


CREATE TABLE auditoria (
    id serial primary key,
    cliente_id integer,
    operacao varchar(100) not null,
    data_hora timestamp default current_timestamp,
    usuario_id integer references usuario (id)
);

-- retorna trigger
CREATE OR REPLACE FUNCTION auditoria_function() RETURNS trigger AS
$$
BEGIN
    IF (TG_OP != 'DELETE') THEN
        INSERT INTO auditoria (cliente_id, operacao, usuario_id) VALUES (NEW.id, TG_OP, NEW.usuario_id);
        RETURN NEW;
    ELSE
        INSERT INTO auditoria (cliente_id, operacao, usuario_id) VALUES (OLD.id, TG_OP, OLD.usuario_id);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE 'plpgsql';

-- precisa ser definido um comportamento de gatilho/disparo
CREATE TRIGGER auditoria_trigger BEFORE INSERT OR DELETE OR UPDATE ON cliente 
FOR EACH ROW EXECUTE PROCEDURE auditoria_function();

INSERT INTO usuario (email, senha) values('admin@admin.com', md5('123'));
INSERT INTO cliente (cpf, nome, usuario_id) VALUES ('11111111111', 'IGOR', 1);




