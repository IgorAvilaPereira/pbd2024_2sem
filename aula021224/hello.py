from flask import Flask
from flask import request
from flask import render_template
from flask import abort, redirect, url_for
from persistencia import *

# lsof -i :5000
# kill -9 47927
app = Flask(__name__)

@app.route("/")
def home():
    anotacaoDAO = AnotacaoDAO()
    return render_template('home.html', vetAnotacao=anotacaoDAO.listar())

@app.route("/tela_adicionar")
def tela_adicionar():
    vetUsuario = UsuarioDAO().listar()
    return render_template('tela_adicionar.html', vetUsuario = vetUsuario)

@app.route("/tela_editar/<int:id>", methods=['GET'])
def tela_editar(id):
    return render_template('tela_editar.html', anotacao = AnotacaoDAO().obter(id))

@app.route("/excluir/<int:id>", methods=['GET'])
def excluir(id):
    resultado = AnotacaoDAO().excluir(id)
    if (resultado is True):
        return redirect(url_for('home'))
    else:
        return render_template('mensagem.html', mensagem="deu xabum!")

@app.route("/editar", methods=['POST'])
def editar():
    titulo = request.form['titulo']
    texto = request.form['texto']
    id = int(request.form['id'])
    anotacao = Anotacao(titulo=titulo, texto=texto, id=id)
    anotacaoDAO = AnotacaoDAO()
    resultado = anotacaoDAO.editar(anotacao)
    return redirect(url_for('home'))

@app.route("/adicionar", methods=['POST'])
def adicionar():
    titulo = request.form['titulo']
    texto = request.form['texto']
    usuario_id = request.form['usuario_id']
       
    anotacao = Anotacao(titulo=titulo, texto=texto)
    anotacaoDAO = AnotacaoDAO()
    resultado = anotacaoDAO.inserir(anotacao, usuario_id)
    if (resultado is True):
        return redirect(url_for('home'))
    else:
        return render_template('mensagem.html', mensagem="deu xabum!")

# para rodar nas maquinas do ifrs
# export FLASK_APP=hello.py
# flask run

# para rodas nas maquinas de voces
# flask --app hello run
# flask --app hello run --debug