import json
import os
import tkinter as tk
from tkinter import messagebox, ttk

JSON_FILE = "acs_objects.json"


def save_object(data, status_label):
    """Save or update an object in acs_objects.json, keyed by Name."""
    name = data.get("Name", "").strip()
    if not name:
        messagebox.showwarning("Missing Name", "Please enter a Name before saving.")
        return

    # Load existing data or start fresh
    print(os.getcwd())
    if os.path.exists(JSON_FILE):
        with open(JSON_FILE, "r", encoding="utf-8") as f:
            objects = json.load(f)
    else:
        objects = {}

    action = "updated" if name in objects else "saved"
    objects[name] = data

    with open(JSON_FILE, "w", encoding="utf-8") as f:
        json.dump(objects, f, indent=4, ensure_ascii=False)

    status_label.config(
        text=f"✔  Object '{name}' {action} successfully!",
        fg="#50e878",
    )

SECTIONS = ["Objects", "Puzzles", "Screens", "Actions", "Elements"]
ICONS = ["📦", "🧩", "🖥️", "⚡", "🔮"]

FIELD_STYLE = {
    "bg": "#1e0f05",
    "fg": "#f0c040",
    "insertbackground": "#f0c040",
    "relief": "sunken",
    "bd": 2,
    "font": ("Courier", 11),
}

LABEL_STYLE = {
    "bg": "#2b1a0e",
    "fg": "#c8a060",
    "font": ("Georgia", 10, "bold"),
    "anchor": "w",
}


def open_objects_window():
    win = tk.Toplevel()
    win.title("Objects")
    win.geometry("420x520")
    win.configure(bg="#2b1a0e")
    win.resizable(False, False)

    # ── Header ──────────────────────────────────────────────
    tk.Label(
        win,
        text="📦  Objects Editor",
        font=("Georgia", 18, "bold"),
        bg="#2b1a0e",
        fg="#f0c040",
        pady=16,
    ).pack()

    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 14))

    # ── Form frame ──────────────────────────────────────────
    form = tk.Frame(win, bg="#2b1a0e", padx=28)
    form.pack(fill="x")

    fields = ["Name", "Email", "Phone", "Address"]
    entries = {}

    for field in fields:
        tk.Label(form, text=field, **LABEL_STYLE).pack(fill="x", pady=(6, 1))
        entry = tk.Entry(form, **FIELD_STYLE)
        entry.pack(fill="x", ipady=4)
        entries[field] = entry

    # ── Dropdown ────────────────────────────────────────────
    tk.Label(form, text="Category", **LABEL_STYLE).pack(fill="x", pady=(12, 1))

    dropdown_var = tk.StringVar(value="Select a category")
    dropdown = ttk.Combobox(
        form,
        textvariable=dropdown_var,
        values=["Weapon", "Treasure", "Key Item"],
        state="readonly",
        font=("Courier", 11),
    )
    dropdown.pack(fill="x", ipady=3)

    # Style the combobox to match the theme
    style = ttk.Style()
    style.theme_use("default")
    style.configure(
        "TCombobox",
        fieldbackground="#1e0f05",
        background="#3d2005",
        foreground="#f0c040",
        selectbackground="#5c3310",
        selectforeground="#ffffff",
        arrowcolor="#f0c040",
    )

    # ── Checkbox ────────────────────────────────────────────
    check_var = tk.BooleanVar()
    tk.Frame(win, bg="#2b1a0e", height=10).pack()  # spacer

    checkbox = tk.Checkbutton(
        win,
        text="  Mark as Quest Item",
        variable=check_var,
        font=("Georgia", 10, "bold"),
        bg="#2b1a0e",
        fg="#c8a060",
        selectcolor="#1e0f05",
        activebackground="#2b1a0e",
        activeforeground="#f0c040",
        cursor="hand2",
    )
    checkbox.pack(anchor="w", padx=28, pady=(4, 14))

    # ── Save button ─────────────────────────────────────────
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 14))

    status_label = tk.Label(
        win,
        text="",
        font=("Courier", 9),
        bg="#2b1a0e",
        fg="#50e878",
    )
    status_label.pack(pady=(0, 4))

    def on_save():
        data = {f: entries[f].get() for f in fields}
        data["Category"] = dropdown_var.get()
        data["Quest Item"] = check_var.get()
        save_object(data, status_label)

    tk.Button(
        win,
        text="💾  Save Object",
        font=("Georgia", 11, "bold"),
        bg="#3d2005",
        fg="#f0c040",
        activebackground="#5c3310",
        activeforeground="#ffffff",
        relief="raised",
        bd=3,
        cursor="hand2",
        padx=16,
        pady=6,
        command=on_save,
    ).pack()


def open_window(title):
    if title == "Objects":
        open_objects_window()
        return

    win = tk.Toplevel()
    win.title(title)
    win.geometry("400x300")
    win.configure(bg="#2b1a0e")

    tk.Label(
        win,
        text=title,
        font=("Georgia", 18, "bold"),
        bg="#2b1a0e",
        fg="#f0c040",
        pady=20,
    ).pack()

    tk.Label(
        win,
        text=f"Adventure Construction Set\n— {title} Editor —",
        font=("Courier", 11),
        bg="#2b1a0e",
        fg="#c8a060",
        justify="center",
    ).pack(expand=True)


def main():
    root = tk.Tk()
    root.title("Adventure Construction Set")
    root.geometry("520x200")
    root.configure(bg="#1a0f06")
    root.resizable(False, False)

    tk.Label(
        root,
        text="⚔  Adventure Construction Set  ⚔",
        font=("Georgia", 14, "bold"),
        bg="#1a0f06",
        fg="#f0c040",
        pady=12,
    ).pack()

    tk.Frame(root, bg="#7a5520", height=2).pack(fill="x", padx=20)

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
            command=lambda s=section: open_window(s),
        )
        btn.pack(side="left", padx=8)

    root.mainloop()


if __name__ == "__main__":
    main()