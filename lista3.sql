--Exercício 2: Trigger de Validação
--Crie uma trigger que valide os dados inseridos em uma tabela de produtos. A trigger deve garantir que o preço do produto seja maior que zero e que a quantidade em estoque seja um número inteiro positivo. Se os dados não forem válidos, a trigger deve impedir a inserção e retornar uma mensagem de erro.
DROP DATABASE IF EXISTS lista3;

CREATE DATABASE lista3;

\c lista3;

CREATE TABLE produto (
    id serial primary key,
    descricao text,
    preco numeric(8,2),
    estoque integer
);

CREATE OR REPLACE FUNCTION func_validacao_produtos() RETURNS trigger AS 
$$
BEGIN
    IF NEW.preco <= 0 THEN
        RAISE EXCEPTION 'O preco do produto deve ser maior que zero';        
    ELSIF NEW.estoque < 0 THEN
        RAISE EXCEPTION 'A qtde em estoque do produto deve um nro inteiro';
    END IF;
    RETURN NEW;   
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trg_validacao_produtos BEFORE INSERT OR UPDATE on produto FOR EACH ROW EXECUTE FUNCTION func_validacao_produtos();

INSERT INTO produto (descricao, preco, estoque) values ('prod1', 1.99, -1);
INSERT INTO produto (descricao, preco, estoque) values ('prod1', 1.99, 0);
INSERT INTO produto (descricao, preco, estoque) values ('prod2', -1.99, 0);

--Exercício 3: Trigger de Atualização Automática
--Crie uma trigger que atualize automaticamente o campo data_atualizacao de uma tabela de pedidos sempre que um registro for atualizado. A data_atualizacao deve ser definida como a data e hora atual no momento da atualização.
CREATE TABLE pedidos (
    id serial primary key,
    data_pedido timestamp default current_timestamp,
    valor numeric(8,2),    
    data_atualizacao timestamp
);

CREATE OR REPLACE FUNCTION func_atualizacao_pedidos() RETURNS trigger AS
$$
BEGIN
--  NEW.data_atualizacao = NOW();
    NEW.data_atualizacao = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trg_atualizacao_pedidos BEFORE UPDATE on pedidos FOR EACH ROW EXECUTE FUNCTION func_atualizacao_pedidos();

INSERT INTO pedidos (valor) values (1.99);
UPDATE pedidos SET valor = 10.00 where id = 1;

--Exercício 4: Trigger de Cálculo
--Crie uma trigger que calcule automaticamente o valor total de um pedido em uma tabela de pedidos. O valor total deve ser calculado como a soma do preço dos produtos multiplicado pela quantidade de cada produto no pedido.

CREATE TABLE item (
    id serial primary key,
    produto_id integer references produto (id),
    pedido_id integer references pedidos (id),
    qtde integer 
);

CREATE OR REPLACE FUNCTION func_calculo_valor_total() RETURNS trigger AS
$$
DECLARE
    total numeric(8,2);
    registro RECORD;
BEGIN

    
    total := 0;
    FOR registro IN select produto_id, qtde, preco FROM item INNER JOIN produto ON (item.produto_id = produto.id) where pedido_id = NEW.pedido_id LOOP
        total := total + registro.preco*registro.qtde;
    END LOOP;
    
    UPDATE produto SET estoque = estoque - NEW.qtde WHERE id = NEW.produto_id;
    SELECT id, preco FROM produto where id = NEW.produto_id INTO registro;
    total := total + registro.preco*NEW.qtde;
    
    UPDATE pedidos SET valor = total where id = NEW.pedido_id;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trg_calculo_valor_total BEFORE INSERT OR UPDATE ON item 
FOR EACH ROW EXECUTE FUNCTION func_calculo_valor_total();

--Exercício 5: Trigger de Notificação
--Crie uma trigger que envie uma notificação (pode ser uma mensagem de log) sempre que um novo registro for inserido em uma tabela de usuários. A notificação deve incluir o ID do usuário e a data e hora da inserção.
CREATE TABLE usuarios (
    id serial primary key,
    cpf character(11) unique,
    nome text not null
);

CREATE OR REPLACE FUNCTION func_notificacao_usuarios() RETURNS trigger AS
$$
BEGIN
    RAISE NOTICE 'NOVO USUARIO ADICIONADO %', CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trg_notificacao_usuarios AFTER INSERT ON usuarios FOR EACH ROW EXECUTE FUNCTION func_notificacao_usuarios();

INSERT INTO usuarios (nome) values ('ANA CLARA');

--Cronograma
--25/11 - lista de exercício
--02/12 - revisão pré atividade
--09/12 - atividade avaliada
--16/12 - dia de ajustes

--Exercício 6: Trigger de Restrição
--Crie uma trigger que impeça a exclusão de registros em uma tabela de funcionários se o funcionário estiver associado a algum projeto em uma tabela de projetos. A trigger deve retornar uma mensagem de erro informando que a exclusão não é permitida.


CREATE TABLE projetos (
    id serial primary key,
    nome text not null
);
INSERT INTO projetos (nome) values ('xurras by annie');

CREATE TABLE funcionarios (
    id serial primary key,
    cpf character(11) unique,
    nome text not null,
    projeto_id integer references projetos (id)
);
INSERT INTO funcionarios (nome, projeto_id) values ('erick', 1);
INSERT INTO funcionarios (nome, projeto_id) values ('adriana', 1);

CREATE OR REPLACE FUNCTION func_restricao_exclusao() RETURNS trigger AS 
$$
BEGIN
    IF (EXISTS(SELECT * FROM funcionarios WHERE id = OLD.id AND projeto_id IS NOT NULL)) THEN
        RAISE NOTICE 'NÃO É PERMITIDO EXCLUIR FUNCIONARIOS ATRELADOS A PROJETOS';
        RETURN NULL;
    END IF;    
    RETURN OLD;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trg_restricao_excluscao BEFORE DELETE ON funcionarios FOR EACH ROW EXECUTE FUNCTION func_restricao_exclusao();


--Exercício 7: Trigger de Backup
--Crie uma trigger que faça um backup de um registro (USUARIO) antes de ele ser atualizado ou excluído em uma tabela de inventário. O backup deve ser armazenado em uma tabela de histórico de inventário.
CREATE TABLE log (
    id serial primary key,
    texto text not null
);

CREATE OR REPLACE FUNCTION func_backup() RETURNS trigger AS
$$
BEGIN   
    INSERT INTO log (texto) VALUES (TG_OP||':'|| TG_TABLE_NAME||':'||OLD.id::text);
    RETURN OLD;
END;
$$ LANGUAGE 'plpgsql'; 

CREATE TRIGGER trg_backup BEFORE UPDATE OR DELETE ON usuarios FOR EACH ROW EXECUTE FUNCTION func_backup();


--Exercício 8: Trigger de Sincronização
--Crie uma trigger que sincronize os dados entre duas tabelas. Por exemplo, sempre que um registro for inserido ou atualizado em uma tabela de produtos, a trigger deve garantir que a tabela de estoque seja atualizada com as informações correspondentes.
CREATE OR REPLACE FUNCTION func_sincronizacao() RETURNS trigger AS
$$
BEGIN
    IF TG_OP = 'DELETE' THEN
        DELETE FROM funcionarios WHERE cpf = OLD.cpf;
        RETURN OLD;        
    ELSIF TG_OP = 'INSERT' THEN
        INSERT INTO funcionarios (nome, cpf) VALUES (NEW.nome, NEW.cpf);
    ELSIF TG_OP = 'UPDATE' THEN
        UPDATE funcionarios SET nome = NEW.nome where cpf = NEW.cpf;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER trg_sincronizacao AFTER INSERT OR UPDATE OR DELETE ON usuarios FOR EACH ROW EXECUTE FUNCTION func_sincronizacao();



