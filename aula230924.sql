-- Procedure para verificar se um participante é maior de idade:
CREATE OR REPLACE PROCEDURE verificar_maioridade_participante(id_aux integer) AS 
$$
DECLARE
    idade integer; 
BEGIN
    SELECT EXTRACT(YEAR FROM AGE(data_nascimento)) INTO idade
    FROM participante where id = id_aux;
    IF idade >= 18 THEN
        RAISE NOTICE 'PARTICIPANTE MAIOR DE IDADE';
    ELSE
        RAISE NOTICE 'PARTICIPANTE MENOR DE IDADE';
    END IF;
END; 
$$ LANGUAGE 'plpgsql';

-- CALL verificar_maioridade_participante(1);

-- Procedure para atualizar o nome de um evento com tratamento de exceção:
CREATE OR REPLACE PROCEDURE atualizar_nome_evento_com_excecao(evento_id_aux integer, novo_nome character varying(150)) AS $$
-- DECLARE
BEGIN
    BEGIN
        IF (evento_id_aux > 0) THEN
            IF EXISTS(SELECT * FROM evento where id = evento_id_aux) THEN
                UPDATE evento SET nome = novo_nome where id = evento_id_aux;
                RAISE NOTICE 'EVENTO ATUALIZADO COM SUCESSO';
            ELSE
                RAISE NOTICE 'EVENTO INEXISTENTE';
            END IF;
        ELSE
            RAISE NOTICE 'PK DE EVENTO NAO PODE SER NEGATIVA';
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'ERRO NA ATUALIZACAO DO EVENTO';
    END;
END;
$$ LANGUAGE 'plpgsql';

--amigo_secreto=# CALL atualizar_nome_evento_com_excecao(-1, 'evento atualizado');
--NOTICE:  PK DE EVENTO NAO PODE SER NEGATIVA
--CALL
--amigo_secreto=# CALL atualizar_nome_evento_com_excecao(300, 'evento atualizado');
--NOTICE:  EVENTO INEXISTENTE
--CALL
--

-- Function para verificar se um desejo está dentro de um valor limite:
CREATE OR REPLACE FUNCTION verifica_limite(desejo_id_aux integer, valor_limite money) RETURNS BOOLEAN AS 
$$
DECLARE
    valor_desejo money;
BEGIN
    IF EXISTS(SELECT * FROM desejo where id = desejo_id_aux) THEN    
        SELECT valor_medio INTO valor_desejo FROM desejo where id = desejo_id_aux;
        RAISE NOTICE '% <= %', valor_desejo, valor_limite;        
        IF CAST(valor_desejo AS NUMERIC(10,2)) <= CAST(valor_limite AS NUMERIC(10,2)) THEN
            RETURN TRUE;
        ELSE
            RETURN FALSE;
        END IF;
   ELSE
        RAISE NOTICE 'DESEJO INEXISTENTE';
        RETURN FALSE; 
   END IF;   
END;
$$ LANGUAGE 'plpgsql';

-- Procedure para listar todos os participantes com idade acima de um valor específico: 
CREATE OR REPLACE PROCEDURE listar_participantes_maiores_de(idade_limite integer) AS
$$
DECLARE
    rec RECORD;
--  rec tablename%ROWTYPE;
BEGIN
    FOR rec IN SELECT * FROM participante where EXTRACT(YEAR FROM AGE(data_nascimento)) >= idade_limite LOOP
        RAISE NOTICE '%: %', rec.nome, rec.data_nascimento;    
    END LOOP;    
END;
$$ LANGUAGE 'plpgsql';

--amigo_secreto=# call listar_participantes_maiores_de(40);
--NOTICE:  RAFAEL BETITO: 1980-10-02
--NOTICE:  MARCIO TORRES: 1970-11-01
--NOTICE:  TIAGO TELECKEN: 1900-01-02
--CALL
--amigo_secreto=# call listar_participantes_maiores_de(37);
--NOTICE:  IGOR PEREIRA: 1987-01-20
--NOTICE:  RAFAEL BETITO: 1980-10-02
--NOTICE:  MARCIO TORRES: 1970-11-01
--NOTICE:  TIAGO TELECKEN: 1900-01-02
--CALL
--amigo_secreto=# 
--

-- OFF-TOPIC:
CREATE OR REPLACE FUNCTION listar_participantes_maiores_de2(idade_limite integer) RETURNS TABLE (nome_aux character varying(100), data_nascimento_aux date) AS 
$$
BEGIN
    RETURN QUERY SELECT nome as nome_aux, data_nascimento as data_nascimento_aux FROM participante where EXTRACT(YEAR FROM AGE(data_nascimento)) >= idade_limite;  
END;
$$ LANGUAGE 'plpgsql';

--amigo_secreto=# select listar_participantes_maiores_de2(40);
-- listar_participantes_maiores_de2 
--------------------------
-- ("RAFAEL BETITO",1980-10-02)
-- ("MARCIO TORRES",1970-11-01)
-- ("TIAGO TELECKEN",1900-01-02)
--(3 rows)
--
--amigo_secreto=# select * from listar_participantes_maiores_de2(40);
--    nome_aux    | data_nascimento_aux 
--------+---------------------
-- RAFAEL BETITO  | 1980-10-02
-- MARCIO TORRES  | 1970-11-01
-- TIAGO TELECKEN | 1900-01-02
--(3 rows)
--
--amigo_secreto=# 

-- Function para verificar se um participante tem desejos cadastrados:
CREATE OR REPLACE FUNCTION verifica_participante_desejos(participante_id_aux integer) RETURNS BOOLEAN AS
$$
BEGIN
    IF EXISTS(SELECT * FROM desejo where participante_id = participante_id_aux) THEN
        
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE 'plpgsql';

--amigo_secreto=# SELECT verifica_participante_desejos(1);
-- verifica_participante_desejos 
-----------------------------
-- t
--(1 row)

--amigo_secreto=# SELECT verifica_participante_desejos(300);
-- verifica_participante_desejos 
-----------------------------
-- f
--(1 row)

--amigo_secreto=# DELETE FROM desejo;
--DELETE 1
--amigo_secreto=# SELECT verifica_participante_desejos(1);
-- verifica_participante_desejos 
-----------------------------
-- f
--(1 row)

--Procedure para listar todos os eventos criados após uma data específica:
-- ALTER TABLE evento ADD COLUMN data_hora TIMESTAMP;
-- UPDATE evento SET data_hora = '2024-09-30 18:00:00' ;

CREATE OR REPLACE PROCEDURE listar_eventos_pos_data(data_aux date) AS $$
DECLARE
    rec RECORD;
--  rec tablename%ROWTYPE;
BEGIN
    FOR rec IN SELECT * FROM evento where cast(data_hora as date) > data_aux LOOP
        RAISE NOTICE '%:%', rec.id, rec.data_hora;
    END LOOP;
END;
$$ LANGUAGE 'plpgsql';

-- amigo_secreto=# call listar_eventos_pos_data(CAST(NOW() AS DATE));

--Function para calcular a diferença de idade entre dois participantes:
CREATE OR REPLACE FUNCTION diferenca(participante_id_aux1 integer, participante_id_aux2 integer) RETURNS integer AS
$$
DECLARE
    idade_aux1 integer := 0;
    idade_aux2 integer := 0;
BEGIN
    IF EXISTS(SELECT * FROM participante where id = participante_id_aux1) AND EXISTS(SELECT * FROM participante where id = participante_id_aux2) THEN
--      participante 1
        SELECT EXTRACT(YEAR FROM AGE(data_nascimento)) INTO idade_aux1 FROM participante where id = participante_id_aux1;
--      participante 2
        SELECT EXTRACT(YEAR FROM AGE(data_nascimento)) INTO idade_aux2 FROM participante where id = participante_id_aux2;
--      retorna o valor absoluto da diferenca
        RETURN abs(idade_aux2 - idade_aux1);
   ELSE
--      retorna 0 + uma mensagem de erro no caso de algum dos participantes nao existir
        RAISE NOTICE 'ALGUM (OU ambos) PARTICIPANTE(S) NAO EXISTE(M)';
   END IF;
   RETURN 0;
END;
$$ LANGUAGE 'plpgsql';

-- amigo_secreto=# SELECT diferenca(2,1);

-- Function para listar todos os participantes de um evento:
CREATE OR REPLACE FUNCTION listar_participantes_de_um_evento(evento_id_aux integer) RETURNS TABLE (nome_aux character varying(100), data_nascimento_aux date) AS 
$$
BEGIN
    RETURN QUERY SELECT nome as nome_aux, data_nascimento as data_nascimento_aux FROM participante inner join evento_participante on participante.id = evento_participante.participante_id where evento_participante.evento_id = evento_id_aux;  
END;
$$ LANGUAGE 'plpgsql';

-- amigo_secreto=# select * from listar_participantes_de_um_evento(1);

-- Function para listar todos os desejos de um participante:
--INSERT INTO desejo (descricao, valor_medio, participante_id) values
--('meias', 1.99, 1), ('camiseta', 10, 2);

CREATE OR REPLACE FUNCTION listar_desejos_participante(participante_id_aux integer) RETURNS TABLE (descricao_aux text, valor_medio_aux money) AS 
$$
BEGIN
    RETURN QUERY SELECT descricao as descricao_aux, valor_medio as valor_medio_aux from participante inner join desejo on (participante.id = desejo.participante_id) where participante.id = participante_id_aux;
END;
$$ LANGUAGE 'plpgsql';

--amigo_secreto=# select * from listar_desejos_participante(1);
-- descricao_aux | valor_medio_aux 
---------------+-----------------
-- meias         |         R$ 1,99
--(1 row)

--amigo_secreto=# select * from listar_desejos_participante(2);
-- descricao_aux | valor_medio_aux 
---------------+-----------------
-- camiseta      |        R$ 10,00
--(1 row)

--amigo_secreto=# select * from listar_desejos_participante(2) where valor_medio_aux >= cast(11.00 as money);

-- Function para listar todos os eventos de um participante:
CREATE OR REPLACE FUNCTION listar_eventos_de_um_participante(participante_id_aux integer) RETURNS TABLE (id_aux integer, nome_aux character varying(150), data_hora timestamp) AS 
$$
BEGIN
    RETURN QUERY SELECT evento.id as id_aux, evento.nome as nome_aux, evento.data_hora as data_hora_aux FROM evento inner join evento_participante on evento.id = evento_participante.evento_id where evento_participante.participante_id = participante_id_aux;  
END;
$$ LANGUAGE 'plpgsql';

--amigo_secreto=# select * from listar_eventos_de_um_participante(1);
-- id_aux |     nome_aux      |      data_hora      
--------+-------------------+---------------------
--      1 | evento atualizado | 2024-09-30 18:00:00
--(1 row)

--amigo_secreto=# select * from listar_eventos_de_um_participante(2);
-- id_aux |     nome_aux      |      data_hora      
--------+-------------------+---------------------
--      1 | evento atualizado | 2024-09-30 18:00:00

-- Function para verificar se um participante está em um evento:
CREATE OR REPLACE FUNCTION verificar_participacao(participante_id_aux integer, evento_id_aux integer) RETURNS boolean AS
$$
BEGIN
    IF EXISTS(SELECT * FROM evento_participante where participante_id = participante_id_aux and evento_id = evento_id_aux) THEN
        RETURN TRUE;
    END IF;
    RETURN FALSE;
END;
$$ LANGUAGE 'plpgsql';

--amigo_secreto=# SELECT verificar_participacao(1,1);
-- verificar_participacao 
----------------------
-- t
--(1 row)

--amigo_secreto=# SELECT verificar_participacao(1,30);
-- verificar_participacao 
------------------
-- f
--(1 row)

--amigo_secreto=# 


