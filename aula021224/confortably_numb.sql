DROP DATABASE IF EXISTS confortably_numb;

CREATE DATABASE confortably_numb;

\c confortably_numb;

CREATE TABLE usuario (
    id serial primary key,
    email text not null
);
INSERT INTO usuario (email) VALUES ('fritzen@riogrande.ifrs.edu.br');


CREATE TABLE anotacao (
    id serial primary key,
    titulo text,
    texto text not null
);
ALTER TABLE anotacao ADD COLUMN usuario_id integer references usuario (id);

CREATE TABLE lixeira (
    id serial primary key,
    anotacao_id integer,
    anotacao_titulo text,
    anotacao_texto text
);

CREATE OR REPLACE function verifica_anotacao() RETURNS trigger AS
$$
BEGIN
    IF NEW.titulo IS NOT NULL AND NEW.titulo != '' THEN
        IF NEW.texto IS NOT NULL AND NEW.texto != '' THEN
            RETURN NEW;
        END IF;
    END IF;
    RAISE EXCEPTION 'Deu xabum!!';
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER verifica_anotaca_trigger BEFORE INSERT OR UPDATE ON anotacao 
FOR EACH ROW EXECUTE PROCEDURE verifica_anotacao();

CREATE OR REPLACE FUNCTION enviar_lixeira() RETURNS trigger AS
$$
BEGIN
    INSERT INTO lixeira (anotacao_id, anotacao_titulo, anotacao_texto) values (OLD.id, OLD.titulo, OLD.texto);
    RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER lixeira_trigger BEFORE DELETE ON anotacao 
FOR EACH ROW EXECUTE PROCEDURE enviar_lixeira();

INSERT INTO anotacao (titulo, texto) values ('gunter the king', 'gunter the king in house party');

INSERT INTO anotacao (titulo, texto) values ('TESTE', NULL);





