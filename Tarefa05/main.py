from tkinter import ttk
from tkinter import *

import sqlite3


class ChildDog:
    # Conecta ao banco
    db_name = 'database.db'

    def __init__(self, window):
        # Initializations 
        self.wind = window
        self.wind.title('Gestao de Criancas Cachorros')

        # Creating a Frame Container 
        frame = LabelFrame(self.wind, text='Cadastrar crianca e seu cachorro')
        frame.grid(row=0, column=0, columnspan=3, pady=20)

        # Child Input
        Label(frame, text='Crianca: ').grid(row=1, column=0)
        self.child_name = Entry(frame)
        self.child_name.focus()
        self.child_name.grid(row=1, column=1)

        # Dog Input
        Label(frame, text='Cachorro: ').grid(row=2, column=0)
        self.dog_name = Entry(frame)
        self.dog_name.grid(row=2, column=1)

        # Button Add Product
        ttk.Button(frame, text='Salvar', command=self.add_child_dog).grid(row=3, columnspan=2, sticky=W + E)

        # Table
        self.tree = ttk.Treeview(height=10, columns=2)
        self.tree.grid(row=4, column=0, columnspan=2)
        self.tree.heading('#0', text='crianca', anchor=CENTER)
        self.tree.heading('#1', text='cachorro', anchor=CENTER)

        # Filling the Rows
        self.get_child_dogs()

    # Funcao para executar as querys no banco
    def run_query(self, query):
        with sqlite3.connect(self.db_name) as conn:
            cursor = conn.cursor()
            result = cursor.execute(query)
            conn.commit()
        return result

    # Get Dados do banco
    def get_child_dogs(self):
        # cleaning Table
        records = self.tree.get_children()
        for element in records:
            self.tree.delete(element)
        # query
        query = 'SELECT * FROM child ORDER BY name DESC'
        db_rows_child = self.run_query(query)

        query = 'SELECT * FROM dog ORDER BY name DESC'
        db_rows_dog = self.run_query(query)
        # filling data
        for child, dog in zip(db_rows_child, db_rows_dog):
            self.tree.insert('', 0, text=child[1], values=dog[1])

    def add_child_dog(self):
        query = 'INSERT INTO child VALUES(NULL,"' + self.child_name.get() + '")'
        self.run_query(query)
        query = 'INSERT INTO dog VALUES(NULL,"' + self.dog_name.get() + '")'
        self.run_query(query)
        self.get_child_dogs()


if __name__ == '__main__':
    window = Tk()
    application = ChildDog(window)
    window.mainloop()
