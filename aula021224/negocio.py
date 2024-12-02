# negocio
class Usuario:
    def __init__(self, email, id = 0):
        self.email = email
        self.id = id


class Anotacao:
    def __init__(self, titulo, texto, id = 0):
        self.titulo = titulo
        self.texto = texto
        self.id = id