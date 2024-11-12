# https://flask.palletsprojects.com/en/stable/quickstart/#a-minimal-application
# pip install flask
from flask import Flask
# https://www.psycopg.org/docs/module.html
# pip install psycopg2-binary 
import psycopg2

app = Flask(__name__)

@app.route("/")
def hello_world():
    conn = psycopg2.connect("dbname=november_rain user=postgres password=postgres host=localhost port=5432")
    cur = conn.cursor()
    cur.execute("SELECT * FROM cliente")
    records = cur.fetchall()
    html = "<table border='1'>"
    for row in records:
        html = html + "<tr><td>"+str(row[0])+"</td><td>"+row[1]+"</td><td>"+row[2]+"</td><td>"+str(row[3])+"</td><tr>"
    cur.close()
    conn.close()    
    html = html + "</table>"
    return html

# para rodar nas maquinas do ifrs
# export FLASK_APP=hello.py
# flask run

# para rodas nas maquinas de voces
# flask --app hello run