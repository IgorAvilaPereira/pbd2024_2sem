DROP DATABASE IF EXISTS amigo_secreto;

CREATE DATABASE amigo_secreto;

\c amigo_secreto;

CREATE TABLE evento (
    id serial primary key,
    nome character varying(150) not null,
    data_hora_criacao timestamp default current_timestamp
);

INSERT INTO evento (nome) VALUES
('AMIGO SECRETO - PBD');

CREATE TABLE participante (
    id serial primary key,
    nome character varying(100) not null,
    data_nascimento date
);
INSERT INTO participante (nome, data_nascimento) VALUES
('IGOR PEREIRA', '1987-01-20'),
('RAFAEL BETITO', '1980-10-02'),
('MARCIO TORRES', '1970-11-01'),
('TIAGO TELECKEN', '1900-01-02'); 

CREATE TABLE evento_participante (
    id serial primary key,
    evento_id integer references evento (id),
    participante_id integer references participante (id),
    amigo_id integer references participante (id),
    unique (evento_id, amigo_id),
    unique (evento_id, participante_id),
    unique (participante_id, amigo_id)
);
INSERT INTO evento_participante (evento_id, participante_id) VALUES
(1,1),
(1,2),
(1,3),
(1,4);

CREATE TABLE desejo (
    id serial primary key,
    descricao text,
    valor_medio money default 0.0,
    participante_id integer references participante (id)
);
INSERT INTO desejo (descricao, participante_id) VALUES
('MEIAS DIVERTIDAS', 1);

CREATE OR REPLACE FUNCTION adiciona_desejo(descricao_aux text, participante_id_aux integer, valor_medio_aux money) RETURNS boolean AS
$$
BEGIN
   IF (cast(valor_medio_aux as numeric(8,2)) <= 50.000) THEN
    INSERT INTO desejo (descricao, participante_id, valor_medio) VALUES
    (descricao_aux, participante_id_aux, valor_medio_aux);
        RETURN TRUE;
   ELSE
        RAISE NOTICE 'N rola desejos extremamente caros!';
        RETURN FALSE;
   END IF;
END;
$$ LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION excluir_evento(integer) returns boolean as
$$
begin
    IF EXISTS(SELECT * FROM evento where id = $1) THEN
        DELETE FROM evento_participante where evento_id = $1;
        DELETE FROM evento where id = $1;
        RETURN TRUE;
    ELSE
        RAISE NOTICE 'Evento inexistente';
        RETURN FALSE;
    END IF;    
end;
$$ language 'plpgsql';










