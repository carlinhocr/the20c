import json
import os
import tkinter as tk
from tkinter import messagebox, ttk

JSON_OBJECTS_FILE = "acs_objects.json"
JSON_SCREENS_FILE = "acs_screens.json"

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


# ── Generic JSON helpers ──────────────────────────────────────────────────────

def load_json(json_file):
    """Load and return a JSON file as a dict, or {} if it doesn't exist."""
    if os.path.exists(json_file):
        with open(json_file, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_to_json(json_file, key_field, data, status_label):
    """Save or update a record in a JSON file, keyed by key_field."""
    key = data.get(key_field, "").strip()
    if not key:
        messagebox.showwarning("Missing ID", f"Please enter a '{key_field}' before saving.")
        return

    records = load_json(json_file)
    action = "updated" if key in records else "saved"
    records[key] = data

    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(records, f, indent=4, ensure_ascii=False)

    status_label.config(text=f"✔  '{key}' {action} successfully!", fg="#50e878")


# ── Objects window ───────────────────────────────────────────────────────────

def save_object(data, status_label):
    save_to_json(JSON_OBJECTS_FILE, "Name", data, status_label)


def open_objects_window():
    win = tk.Toplevel()
    win.title("Objects")
    win.geometry("420x640")
    win.configure(bg="#2b1a0e")
    win.resizable(False, False)

    # ── Header ───────────────────────────────────────────────
    tk.Label(win, text="📦  Objects Editor", font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 10))

    # ── Load existing object section ─────────────────────────
    load_frame = tk.Frame(win, bg="#2b1a0e", padx=28)
    load_frame.pack(fill="x")

    tk.Label(load_frame, text="Load Existing Object", **LABEL_STYLE).pack(fill="x", pady=(4, 2))

    load_row = tk.Frame(load_frame, bg="#2b1a0e")
    load_row.pack(fill="x")

    existing_objects = load_json(JSON_OBJECTS_FILE)
    object_names = list(existing_objects.keys()) if existing_objects else []

    load_var = tk.StringVar(value="— select to load —")
    load_dropdown = ttk.Combobox(
        load_row, textvariable=load_var,
        values=object_names,
        state="readonly", font=("Courier", 11), width=28
    )
    load_dropdown.pack(side="left", fill="x", expand=True, ipady=3)

    # ── Form ─────────────────────────────────────────────────
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(10, 10))

    form = tk.Frame(win, bg="#2b1a0e", padx=28)
    form.pack(fill="x")

    fields = ["ObjectID", "Name", "Description"]
    entries = {}

    for field in fields:
        tk.Label(form, text=field, **LABEL_STYLE).pack(fill="x", pady=(6, 1))
        entry = tk.Entry(form, **FIELD_STYLE)
        entry.pack(fill="x", ipady=4)
        entries[field] = entry

    # Category dropdown
    tk.Label(form, text="Category", **LABEL_STYLE).pack(fill="x", pady=(12, 1))
    dropdown_var = tk.StringVar(value="Select a category")
    category_combo = ttk.Combobox(form, textvariable=dropdown_var,
                                  values=["Weapon", "Treasure", "Key Item"],
                                  state="readonly", font=("Courier", 11))
    category_combo.pack(fill="x", ipady=3)

    style = ttk.Style()
    style.theme_use("default")
    style.configure("TCombobox", fieldbackground="#1e0f05", background="#3d2005",
                    foreground="#f0c040", selectbackground="#5c3310",
                    selectforeground="#ffffff", arrowcolor="#f0c040")

    # Checkboxes
    check_var_takeable = tk.BooleanVar()
    tk.Frame(win, bg="#2b1a0e", height=6).pack()
    tk.Checkbutton(win, text="  Takeable", variable=check_var_takeable,
                   font=("Georgia", 10, "bold"), bg="#2b1a0e", fg="#c8a060",
                   selectcolor="#1e0f05", activebackground="#2b1a0e",
                   activeforeground="#f0c040", cursor="hand2").pack(anchor="w", padx=28)

    check_var_visible = tk.BooleanVar()
    tk.Frame(win, bg="#2b1a0e", height=6).pack()
    tk.Checkbutton(win, text="  Visible", variable=check_var_visible,
                   font=("Georgia", 10, "bold"), bg="#2b1a0e", fg="#c8a060",
                   selectcolor="#1e0f05", activebackground="#2b1a0e",
                   activeforeground="#f0c040", cursor="hand2").pack(anchor="w", padx=28, pady=(0, 10))

    # ── Load callback — populate all fields from selected object ──
    def on_load(event=None):
        name = load_var.get()
        objects = load_json(JSON_OBJECTS_FILE)
        if name not in objects:
            return
        obj = objects[name]

        # clear and fill text entries
        for field in fields:
            entries[field].delete(0, tk.END)
            entries[field].insert(0, obj.get(field, ""))

        # set category dropdown
        cat = obj.get("Category", "")
        if cat in ["Weapon", "Treasure", "Key Item"]:
            dropdown_var.set(cat)
        else:
            dropdown_var.set("Select a category")

        # set checkboxes
        check_var_takeable.set(obj.get("Takeable", False))
        check_var_visible.set(obj.get("Visible", False))

        status_label.config(text=f"✔  Loaded '{name}'", fg="#c8a060")

    load_dropdown.bind("<<ComboboxSelected>>", on_load)

    # ── Save section ─────────────────────────────────────────
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 10))

    status_label = tk.Label(win, text="", font=("Courier", 9),
                            bg="#2b1a0e", fg="#50e878")
    status_label.pack(pady=(0, 4))

    def on_save():
        data = {f: entries[f].get() for f in fields}
        data["Category"] = dropdown_var.get()
        data["Takeable"] = check_var_takeable.get()
        data["Visible"] = check_var_visible.get()
        save_object(data, status_label)
        # refresh the load dropdown with the new/updated name
        updated = load_json(JSON_OBJECTS_FILE)
        load_dropdown["values"] = list(updated.keys())

    tk.Button(win, text="💾  Save Object", font=("Georgia", 11, "bold"),
              bg="#3d2005", fg="#f0c040", activebackground="#5c3310",
              activeforeground="#ffffff", relief="raised", bd=3,
              cursor="hand2", padx=16, pady=6, command=on_save).pack()


# ── Screens window ───────────────────────────────────────────────────────────

def save_screen(data, status_label):
    save_to_json(JSON_SCREENS_FILE, "ID", data, status_label)


def open_screens_window():
    win = tk.Toplevel()
    win.title("Screens")
    win.geometry("500x700")
    win.configure(bg="#2b1a0e")
    win.resizable(False, True)

    tk.Label(win, text="🖥️  Screens Editor", font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 0))

    # ── Scrollable canvas ────────────────────────────────────
    canvas = tk.Canvas(win, bg="#2b1a0e", highlightthickness=0)
    scrollbar = ttk.Scrollbar(win, orient="vertical", command=canvas.yview)
    canvas.configure(yscrollcommand=scrollbar.set)
    scrollbar.pack(side="right", fill="y")
    canvas.pack(side="left", fill="both", expand=True)

    form = tk.Frame(canvas, bg="#2b1a0e", padx=28)
    form_window = canvas.create_window((0, 0), window=form, anchor="nw")

    def on_frame_configure(e):
        canvas.configure(scrollregion=canvas.bbox("all"))

    def on_canvas_configure(e):
        canvas.itemconfig(form_window, width=e.width)

    form.bind("<Configure>", on_frame_configure)
    canvas.bind("<Configure>", on_canvas_configure)

    def on_mousewheel(e):
        canvas.yview_scroll(int(-1 * (e.delta / 120)), "units")
    canvas.bind_all("<MouseWheel>", on_mousewheel)

    entries = {}
    exit_vars = {}      # StringVar for each exit combobox
    exit_combos = {}    # the Combobox widgets for the exits
    object_vars = {}    # StringVar for each object combobox
    object_combos = {}  # the Combobox widgets for the objects

    def get_object_names():
        """Return sorted list of object Names from acs_objects.json, blank entry first."""
        objects = load_json(JSON_OBJECTS_FILE)
        names = sorted(objects.keys())
        return [""] + names

    def get_screen_names():
        """Return sorted list of screen Names from the JSON file, blank entry first."""
        screens = load_json(JSON_SCREENS_FILE)
        names = sorted(
            rec.get("Name", rec_id)
            for rec_id, rec in screens.items()
            if rec.get("Name", "").strip() or rec_id
        )
        return [""] + names

    def section_label(text):
        tk.Label(form, text=text, font=("Georgia", 11, "bold italic"),
                 bg="#2b1a0e", fg="#f0c040").pack(fill="x", pady=(14, 4))

    def add_entry(field):
        tk.Label(form, text=field, **LABEL_STYLE).pack(fill="x", pady=(4, 1))
        e = tk.Entry(form, **FIELD_STYLE)
        e.pack(fill="x", ipady=4)
        entries[field] = e

    def add_grid_entries(parent_frame, field_list, columns):
        for i, field in enumerate(field_list):
            col = i % columns
            col_frame = tk.Frame(parent_frame, bg="#2b1a0e")
            col_frame.grid(row=i // columns, column=col, padx=4, sticky="ew")
            parent_frame.columnconfigure(col, weight=1)
            tk.Label(col_frame, text=field, **LABEL_STYLE).pack(fill="x", pady=(0, 2))
            e = tk.Entry(col_frame, **FIELD_STYLE)
            e.pack(fill="x", ipady=4)
            entries[field] = e

    # ── Identity ─────────────────────────────────────────────
    section_label("— Identity —")
    add_entry("ID")
    add_entry("Name")

    # ── Exits (comboboxes pre-filled with screen names) ───────
    section_label("— Exits (Screen Names) —")
    exits_frame = tk.Frame(form, bg="#2b1a0e")
    exits_frame.pack(fill="x")

    screen_names = get_screen_names()
    for i, direction in enumerate(["North", "South", "East", "West"]):
        col_frame = tk.Frame(exits_frame, bg="#2b1a0e")
        col_frame.grid(row=0, column=i, padx=4, sticky="ew")
        exits_frame.columnconfigure(i, weight=1)
        tk.Label(col_frame, text=direction, **LABEL_STYLE).pack(fill="x", pady=(0, 2))
        var = tk.StringVar(value="")
        cb = ttk.Combobox(col_frame, textvariable=var, values=screen_names,
                          font=("Courier", 10), width=9)
        cb.pack(fill="x", ipady=3)
        exit_vars[direction] = var
        exit_combos[direction] = cb

    # ── Objects ──────────────────────────────────────────────
    section_label("— Objects in Screen —")
    obj_frame = tk.Frame(form, bg="#2b1a0e")
    obj_frame.pack(fill="x")

    object_names = get_object_names()
    for i, obj_field in enumerate(["Object1", "Object2", "Object3"]):
        col_frame = tk.Frame(obj_frame, bg="#2b1a0e")
        col_frame.grid(row=0, column=i, padx=4, sticky="ew")
        obj_frame.columnconfigure(i, weight=1)
        tk.Label(col_frame, text=obj_field, **LABEL_STYLE).pack(fill="x", pady=(0, 2))
        var = tk.StringVar(value="")
        cb = ttk.Combobox(col_frame, textvariable=var, values=object_names,
                          font=("Courier", 10), width=9)
        cb.pack(fill="x", ipady=3)
        object_vars[obj_field] = var
        object_combos[obj_field] = cb

    # ── Puzzles ──────────────────────────────────────────────
    section_label("— Puzzles —")
    puz_frame = tk.Frame(form, bg="#2b1a0e")
    puz_frame.pack(fill="x")
    add_grid_entries(puz_frame, ["Puzzle1", "Puzzle2"], 2)

    # ── Description ──────────────────────────────────────────
    section_label("— Description —")
    tk.Label(form, text="Description", **LABEL_STYLE).pack(fill="x", pady=(0, 2))
    desc_text = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                        relief="sunken", bd=2, font=("Courier", 11), height=4, wrap="word")
    desc_text.pack(fill="x")

    # ── ASCII Drawing ─────────────────────────────────────────
    section_label("— ASCII Drawing —")
    tk.Label(form, text="AsciiDrawing", **LABEL_STYLE).pack(fill="x", pady=(0, 2))
    ascii_text = tk.Text(form, bg="#1e0f05", fg="#50e878", insertbackground="#50e878",
                         relief="sunken", bd=2, font=("Courier New", 11), height=7, wrap="none")
    ascii_text.pack(fill="x")

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(18, 8))

    status_label = tk.Label(form, text="", font=("Courier", 9),
                            bg="#2b1a0e", fg="#50e878")
    status_label.pack(pady=(0, 4))

    def on_save():
        data = {f: entries[f].get() for f in entries}
        # collect exit combobox values
        for direction, var in exit_vars.items():
            data[direction] = var.get()
        # collect object combobox values
        for obj_field, var in object_vars.items():
            data[obj_field] = var.get()
        data["Description"] = desc_text.get("1.0", "end-1c")
        data["AsciiDrawing"] = ascii_text.get("1.0", "end-1c")
        save_screen(data, status_label)
        # refresh exit dropdowns so the new screen name appears
        updated_screen_names = get_screen_names()
        for cb in exit_combos.values():
            cb["values"] = updated_screen_names

    tk.Button(form, text="💾  Save Screen", font=("Georgia", 11, "bold"),
              bg="#3d2005", fg="#f0c040", activebackground="#5c3310",
              activeforeground="#ffffff", relief="raised", bd=3,
              cursor="hand2", padx=16, pady=6, command=on_save).pack(pady=(0, 20))


# ── Generic fallback window ──────────────────────────────────────────────────

def open_window(title):
    if title == "Objects":
        open_objects_window()
        return
    if title == "Screens":
        open_screens_window()
        return

    win = tk.Toplevel()
    win.title(title)
    win.geometry("400x300")
    win.configure(bg="#2b1a0e")

    tk.Label(win, text=title, font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=20).pack()
    tk.Label(win, text=f"Adventure Construction Set\n— {title} Editor —",
             font=("Courier", 11), bg="#2b1a0e", fg="#c8a060",
             justify="center").pack(expand=True)


# ── Main window ──────────────────────────────────────────────────────────────

def main():
    root = tk.Tk()
    root.title("Adventure Construction Set")
    root.geometry("520x200")
    root.configure(bg="#1a0f06")
    root.resizable(False, False)

    tk.Label(root, text="⚔  Adventure Construction Set  ⚔",
             font=("Georgia", 14, "bold"), bg="#1a0f06", fg="#f0c040", pady=12).pack()
    tk.Frame(root, bg="#7a5520", height=2).pack(fill="x", padx=20)

    btn_frame = tk.Frame(root, bg="#1a0f06", pady=15)
    btn_frame.pack()

    for icon, section in zip(ICONS, SECTIONS):
        tk.Button(btn_frame, text=f"{icon}\n{section}", font=("Georgia", 10, "bold"),
                  width=8, height=3, bg="#3d2005", fg="#f0c040",
                  activebackground="#5c3310", activeforeground="#ffffff",
                  relief="raised", bd=3, cursor="hand2",
                  command=lambda s=section: open_window(s)).pack(side="left", padx=8)

    root.mainloop()


if __name__ == "__main__":
    main()