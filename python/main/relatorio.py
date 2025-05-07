import tkinter as tk
from tkinter import ttk

class App:
    def __init__(self, master):
        master.title("Relatórios")
        master.configure(bg="#f0f0f0")

        # Botão Voltar no canto superior esquerdo
        voltar_btn = tk.Button(
            master, text="← Voltar", font=("Helvetica", 12, "bold"),
            bg="#ff6666", fg="white", relief="raised", padx=10, pady=5
        )
        voltar_btn.pack(anchor='nw', padx=10, pady=10)

        # Criando apenas uma aba (Aba 1)
        self.abas = ttk.Notebook(master)
        self.frame_aba1 = ttk.Frame(self.abas)

        self.abas.add(self.frame_aba1, text="Aba 1")
        self.abas.pack(expand=1, fill="both", padx=10, pady=10)

        # Label
        self.label1 = ttk.Label(self.frame_aba1, text="Relatórios", font=("Helvetica", 16, "bold"))
        self.label1.pack(pady=10)

        # Frame para as Treeviews
        tree_frame = tk.Frame(self.frame_aba1)
        tree_frame.pack(padx=10, pady=5, fill=tk.BOTH, expand=True)

        style = ttk.Style()
        style.configure("Treeview", font=("Helvetica", 11), rowheight=25)
        style.configure("Treeview.Heading", font=("Helvetica", 12, "bold"))

        # Treeview 1
        self.treeview1 = ttk.Treeview(tree_frame, height=5)
        self.treeview1.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5)
        self.treeview1.heading("#0", text="Tempo de vida")
        self.treeview1.insert("", "end",)

        # Treeview 2
        self.treeview2 = ttk.Treeview(tree_frame, height=5)
        self.treeview2.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5)
        self.treeview2.heading("#0", text="Tempo de contagem")
        self.treeview2.insert("", "end", )

        # Treeview 3
        self.treeview3 = ttk.Treeview(tree_frame, height=5)
        self.treeview3.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5)
        self.treeview3.heading("#0", text="Colisões")
        self.treeview3.insert("", "end",)

        # Botão Mostrar Dados
        mostrar_btn = tk.Button(
            self.frame_aba1, text="Mostrar Dados", font=("Helvetica", 13, "bold"),
            bg="#4CAF50", fg="white", relief="raised", padx=20, pady=10
        )
        mostrar_btn.pack(pady=20)

# Inicialização da janela principal
root = tk.Tk()
root.geometry("1000x500")  # Tamanho ajustado
app = App(root)
root.mainloop()
