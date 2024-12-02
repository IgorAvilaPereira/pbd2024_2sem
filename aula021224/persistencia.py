# https://www.psycopg.org/docs/module.html
# pip install psycopg2-binary 
import psycopg2
from negocio import *

# persistencia
class UsuarioDAO:
    def listar(self):
        vetUsuario = []
        conn = psycopg2.connect("dbname=confortably_numb user=postgres password=postgres host=localhost port=5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM usuario")
        records = cur.fetchall()
        for row in records:
            # print(row[1])
            # print(row[2])
            # print(row[0])
            usuario = Usuario(row[1], int(row[0]))
            vetUsuario.append(usuario)
        cur.close()
        conn.close() 
        return vetUsuario
    

class AnotacaoDAO:
    def editar(self, anotacao): 
        try:
            conn = psycopg2.connect("dbname=confortably_numb user=postgres password=postgres host=localhost port=5432")
            cur = conn.cursor()
            cur.execute("UPDATE anotacao SET titulo = %s, texto = %s where id = %s", [anotacao.titulo, anotacao.texto, anotacao.id])
            conn.commit()
            cur.close()
            conn.close() 
            return True
        except:
            return False   

    def inserir(self, anotacao, usuario_id): 
        try:
            conn = psycopg2.connect("dbname=confortably_numb user=postgres password=postgres host=localhost port=5432")
            cur = conn.cursor()
            if (usuario_id != "NULL"):
                cur.execute("INSERT INTO anotacao (titulo, texto, usuario_id) VALUES (%s, %s, %s)", [anotacao.titulo, anotacao.texto, usuario_id])
            else:
                cur.execute("INSERT INTO anotacao (titulo, texto) VALUES (%s, %s)", [anotacao.titulo, anotacao.texto])
            conn.commit()
            cur.close()
            conn.close() 
            return True
        except:
            return False   

    def excluir(self, id): 
        try:
            conn = psycopg2.connect("dbname=confortably_numb user=postgres password=postgres host=localhost port=5432")
            cur = conn.cursor()
            cur.execute("DELETE FROM anotacao WHERE id = %s", [id])
            conn.commit()
            cur.close()
            conn.close() 
            return True
        except:
            return False  

    def listar(self):
        vetAnotacao = []
        conn = psycopg2.connect("dbname=confortably_numb user=postgres password=postgres host=localhost port=5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM anotacao")
        records = cur.fetchall()
        for row in records:
            # print(row[1])
            # print(row[2])
            # print(row[0])
            anotacao = Anotacao(row[1], row[2], int(row[0]))
            vetAnotacao.append(anotacao)
        cur.close()
        conn.close() 
        return vetAnotacao
    
    def obter(self,id):
        conn = psycopg2.connect("dbname=confortably_numb user=postgres password=postgres host=localhost port=5432")
        cur = conn.cursor()
        cur.execute("SELECT * FROM anotacao where id = %s", [id])
        row = cur.fetchone()
        anotacao = Anotacao(row[1], row[2], int(row[0]))
        cur.close()
        conn.close() 
        return anotacao