import tkinter as tk
from tkinter import ttk
import json
import os
from datetime import datetime

ARQUIVO_DADOS = "nave_eventos.json"

# Função para inicializar os dados
def inicializar_dados():
    if not os.path.exists(ARQUIVO_DADOS):
        with open(ARQUIVO_DADOS, "w") as f:
            json.dump({
                "tempo_de_vida_total": 0.0,
                "tempo_de_contagem_total": 0.0,
                "colisoes": 0,
                "eventos": []
            }, f, indent=4)

# Evento atual
_evento_atual = {
    "inicio": None,
    "fim": None,
    "tempo_de_contagem": 0,
    "colisoes": 0
}

def iniciar_nave():
    global _evento_atual
    _evento_atual = {
        "inicio": datetime.now().isoformat(),
        "fim": None,
        "tempo_de_contagem": 0,
        "colisoes": 0
    }

def registrar_colisao():
    global _evento_atual
    _evento_atual["colisoes"] += 1

def atualizar_tempo_contagem(segundos):
    global _evento_atual
    _evento_atual["tempo_de_contagem"] += segundos

def finalizar_nave():
    global _evento_atual
    _evento_atual["fim"] = datetime.now().isoformat()
    inicio = datetime.fromisoformat(_evento_atual["inicio"])
    fim = datetime.fromisoformat(_evento_atual["fim"])
    tempo_de_vida = (fim - inicio).total_seconds()
    _evento_atual["tempo_de_vida"] = tempo_de_vida

    with open(ARQUIVO_DADOS, "r") as f:
        dados = json.load(f)

    dados["tempo_de_vida_total"] += tempo_de_vida
    dados["tempo_de_contagem_total"] += _evento_atual["tempo_de_contagem"]
    dados["colisoes"] += _evento_atual["colisoes"]
    dados["eventos"].append(_evento_atual)

    with open(ARQUIVO_DADOS, "w") as f:
        json.dump(dados, f, indent=4)

    _evento_atual = {
        "inicio": None,
        "fim": None,
        "tempo_de_contagem": 0,
        "colisoes": 0
    }

def obter_dados():
    with open(ARQUIVO_DADOS, "r") as f:
        return json.load(f)

# Interface gráfica
class App:
    def __init__(self, master):
        master.title("Relatórios")
        master.configure(bg="#f0f0f0")

        voltar_btn = tk.Button(
            master, text="← Voltar", font=("Helvetica", 12, "bold"),
            bg="#ff6666", fg="white", relief="raised", padx=10, pady=5
        )
        voltar_btn.pack(anchor='nw', padx=10, pady=10)

        self.abas = ttk.Notebook(master)
        self.frame_aba1 = ttk.Frame(self.abas)

        self.abas.add(self.frame_aba1, text="Aba 1")
        self.abas.pack(expand=1, fill="both", padx=10, pady=10)

        self.label1 = ttk.Label(self.frame_aba1, text="Relatórios", font=("Helvetica", 16, "bold"))
        self.label1.pack(pady=10)

        tree_frame = tk.Frame(self.frame_aba1)
        tree_frame.pack(padx=10, pady=5, fill=tk.BOTH, expand=True)

        style = ttk.Style()
        style.configure("Treeview", font=("Helvetica", 11), rowheight=25)
        style.configure("Treeview.Heading", font=("Helvetica", 12, "bold"))

        self.treeview1 = ttk.Treeview(tree_frame, height=5)
        self.treeview1.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5)
        self.treeview1.heading("#0", text="Tempo de vida")

        self.treeview2 = ttk.Treeview(tree_frame, height=5)
        self.treeview2.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5)
        self.treeview2.heading("#0", text="Tempo de contagem")

        self.treeview3 = ttk.Treeview(tree_frame, height=5)
        self.treeview3.pack(side=tk.LEFT, fill=tk.BOTH, expand=True, padx=5)
        self.treeview3.heading("#0", text="Colisões")

        self.mostrar_btn = tk.Button(
            self.frame_aba1, text="Mostrar Dados", font=("Helvetica", 13, "bold"),
            bg="#4CAF50", fg="white", relief="raised", padx=20, pady=10,
            command=self.mostrar_dados
        )
        self.mostrar_btn.pack(pady=20)

    def mostrar_dados(self):
        dados = obter_dados()

        self.treeview1.delete(*self.treeview1.get_children())
        self.treeview2.delete(*self.treeview2.get_children())
        self.treeview3.delete(*self.treeview3.get_children())

        self.treeview1.insert("", "end", text=f"Tempo de vida total: {dados['tempo_de_vida_total']:.2f} s")
        self.treeview2.insert("", "end", text=f"Tempo de contagem total: {dados['tempo_de_contagem_total']:.2f} s")
        self.treeview3.insert("", "end", text=f"Total de colisões: {dados['colisoes']}")

# Inicialização
inicializar_dados()
root = tk.Tk()
root.geometry("1000x500")
app = App(root)
root.mainloop()
