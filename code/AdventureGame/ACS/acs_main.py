import tkinter as tk
from tkinter import ttk

SECTIONS = ["Objects", "Puzzles", "Screens", "Actions", "Elements"]
ICONS = ["📦", "🧩", "🖥️", "⚡", "🔮"]

def open_window(title):
    win = tk.Toplevel()
    win.title(title)
    win.geometry("400x300")
    win.configure(bg="#2b1a0e")

    header = tk.Label(
        win,
        text=title,
        font=("Georgia", 18, "bold"),
        bg="#2b1a0e",
        fg="#f0c040",
        pady=20
    )
    header.pack()

    content = tk.Label(
        win,
        text=f"Adventure Construction Set\n— {title} Editor —",
        font=("Courier", 11),
        bg="#2b1a0e",
        fg="#c8a060",
        justify="center"
    )
    content.pack(expand=True)


def main():
    root = tk.Tk()
    root.title("Adventure Construction Set")
    root.geometry("520x200")
    root.configure(bg="#1a0f06")
    root.resizable(False, False)

    title_label = tk.Label(
        root,
        text="⚔  Adventure Construction Set  ⚔",
        font=("Georgia", 14, "bold"),
        bg="#1a0f06",
        fg="#f0c040",
        pady=12
    )
    title_label.pack()

    separator = tk.Frame(root, bg="#7a5520", height=2)
    separator.pack(fill="x", padx=20)

    btn_frame = tk.Frame(root, bg="#1a0f06", pady=15)
    btn_frame.pack()

    for icon, section in zip(ICONS, SECTIONS):
        btn = tk.Button(
            btn_frame,
            text=f"{icon}\n{section}",
            font=("Georgia", 10, "bold"),
            width=8,
            height=3,
            bg="#3d2005",
            fg="#f0c040",
            activebackground="#5c3310",
            activeforeground="#ffffff",
            relief="raised",
            bd=3,
            cursor="hand2",
            command=lambda s=section: open_window(s)
        )
        btn.pack(side="left", padx=8)

    root.mainloop()


if __name__ == "__main__":
    main()