import tkinter as tk 
from tkinter import ttk

class App:
    def __init__(self, master):
        self.abas = ttk.Notebook(master)
        self.frame_aba1 = ttk.Frame(self.abas)
        self.frame_aba2 = ttk.Frame(self.abas)
        self.frame_aba3 = ttk.Frame(self.abas)

        self.abas.add(self.frame_aba1, text="Aba 1")
        self.abas.add(self.frame_aba2, text="Aba 2")
        self.abas.add(self.frame_aba3, text="Aba 3")
        self.abas.pack(expand=1, fill="both")

        #  Frame superior para os botões
        top_button_frame = tk.Frame(self.frame_aba1)
        top_button_frame.pack(fill=tk.X, padx=5, pady=5)

        #  Botão "Voltar" (esquerda)
        self.voltar_button = ttk.Button(top_button_frame, text="Voltar", command=self.voltar)
        self.voltar_button.pack(side=tk.LEFT)

        #  Botão "Mostrar Dados" (direita)
        self.mostrar_dados_button = ttk.Button(top_button_frame, text="Mostrar Dados", command=self.mostrar_dados)
        self.mostrar_dados_button.pack(side=tk.TOP)

        #  Label
        self.label1 = ttk.Label(self.frame_aba1, text="Relatórios")
        self.label1.pack(pady=10)

        #  Frame para as treeviews
        tree_frame = tk.Frame(self.frame_aba1)
        tree_frame.pack(padx=10, pady=10, fill=tk.BOTH, expand=True)

        #  Treeview 1 - Relatório de Vendas
        self.treeview1 = ttk.Treeview(tree_frame)
        self.treeview1.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.treeview1.insert("", "end", text="Tempo de vida")

        #  Treeview 2 - Produtos
        self.treeview2 = ttk.Treeview(tree_frame)
        self.treeview2.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.treeview2.insert("", "end", text="Tempo de contagem")

        #  Treeview 3 - Clientes
        self.treeview3 = ttk.Treeview(tree_frame)
        self.treeview3.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        self.treeview3.insert("", "end", text="Colisões")

    #  Função para o botão Voltar
    def voltar(self):
        print("Você clicou em Voltar.")

    #  Função para o botão Mostrar Dados
    def mostrar_dados(self):
        print("Exibindo dados...")

#  Rodar a aplicação
root = tk.Tk()
root.geometry("1000x400")
app = App(root)
root.mainloop()
