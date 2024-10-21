-- exe 1
CREATE or REPLACE function listar_alunos() returns 
    TABLE (id_aluno integer, nome_aluno varchar(100), data_nascimento_aluno date) AS
$$
BEGIN
    RETURN QUERY (SELECT id, nome, data_nascimento from alunos);
END;
$$ LANGUAGE 'plpgsql';

SELECT * from listar_alunos();

INSERT INTO professores (nome, especialidade) values ('igor', 'troca');

INSERT INTO cursos(nome, descricao, professor_id) values ('pbd', 'programação em banco de dados', 1);

-- exe 2
DROP FUNCTION listar_curso();
create or replace function listar_curso() returns table (id_curso integer, nome_curso varchar(100)) AS
$$
BEGIN
    RETURN query (Select id, nome from cursos);
end;
$$ LANGUAGE 'plpgsql';

select * from listar_curso();

begin;
delete from cursos where id = 2;
delete from professores where id = 2;
COMmit;

select * from professores;

-- exe 5
CREATE OR REPLACE procedure atualizar_especialidade_por_professor(id_professor integer, nova_especialidade varchar(100)) AS 
$$
BEGIN
    if exists(Select * from professores where id = id_professor) THEN
        UPDATE professores SET especialidade = nova_especialidade where id = id_professor;
    END if;
end;
$$ LANGUAGE 'plpgsql';

call atualizar_especialidade_por_professor(32, 'bd');

select * from professores;

-- insert into cursos(nome,)
select * from cursos;

CREATE OR REPLACE FUNCTION 
deletar_curso(curso_id_aux INT)
RETURNS VOID AS $$
BEGIN
    DELETE FROM matriculas WHERE curso_id = curso_id_aux;
    DELETE FROM cursos WHERE id = curso_id_aux;
END;
$$ LANGUAGE plpgsql;  

CREATE OR REPLACE PROCEDURE 
deletar_curso_fred(curso_id_aux INT) AS 
$$
BEGIN
    BEGIN
        DELETE FROM matriculas WHERE curso_id = curso_id_aux;
        DELETE FROM cursos WHERE id = curso_id_aux;
    EXCEPTION 
        WHEN OTHERS THEN RAISE EXCEPTION 'OPA';
    END;
END;
$$ LANGUAGE 'plpgsql';  

call deletar_curso_fred(1);

-- exe8
CREATE OR REPLACE FUNCTION alunos_curso (curso_id_aux INT)  
RETURNS TABLE(curso_nome VARCHAR, total_alunos BIGINT) AS
$$
BEGIN
    RETURN QUERY
    SELECT c.nome, COUNT(m.aluno_id)
    FROM cursos c
    LEFT JOIN matriculas m ON c.id = m.curso_id
    WHERE c.id = curso_id_aux
    GROUP BY c.nome;
END;
$$ LANGUAGE plpgsql;

-- exe 7
create or replace function listar_alunos_por_curso(id_curso_aux integer) returns void AS
$$
DECLARE
    registro record;
BEGIN
    for registro in select alunos.nome from matriculas inner join alunos on (matriculas.aluno_id = alunos.id) where curso_id = id_curso_aux LOOP
        raise notice 'Aluno: %', registro.nome;
    end LOOP;
end;
$$ LANGUAGE 'plpgsql';

create or replace function listar_cursos_de_professor(INTEGER) RETURNS table (curso_nome varchar(100)) AS
$$
BEGIN
    RETURN query (select cursos.nome from cursos inner join professores on (cursos.professor_id = professores.id) where professores.id = $1);
end;
$$ LANGUAGE 'plpgsql';

create or replace FUNCTION media() returns numeric(4,1) AS
$$
declare
    media numeric(5,2);
BEGIN
    select cast(avg(extract(year from age(data_nascimento))) as numeric(4,1)) from alunos into media;
    return media;
end;
$$ LANGUAGE 'plpgsql';

SELECT media();

select listar_alunos_por_curso(3);

select * from cursos;
select * from professores;

INSERT into alunos (nome, data_nascimento) VALUES('annie', '2003-04-16');
INSERT INTO matriculas(curso_id, aluno_id, data_matricula) VALUES(3, 1, NOW());
SELECT * from matriculas;
SELECT * FROM alunos_curso(3);


select deletar_curso(1);


select * from professores;

select * from listar_cursos_de_professor(1);


create or replace FUNCTION listar_curso3(integer) returns table (curso_id integer, curso_nome varchar(100), qtde integer) as
$$
begin
    return query (SELECT cursos.id, cursos.nome, count(*)::integer from 
    cursos inner join matriculas on (cursos.id = matriculas.curso_id) 
    group BY cursos.id, cursos.nome HAVING count(*) >= $1 ORDER BY cursos.nome);
end;
$$ language 'plpgsql';


select * from listar_curso3(1);
