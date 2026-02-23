import json
import os
import tkinter as tk
from tkinter import messagebox, ttk

JSON_OBJECTS_FILE = "acs_objects.json"
JSON_SCREENS_FILE = "acs_screens.json"
JSON_ACTIONS_FILE = "acs_actions.json"
JSON_PUZZLES_FILE = "acs_puzzles.json"

SECTIONS = ["Objects", "Puzzles", "Screens", "Actions", "Elements"]
ICONS    = ["📦",      "🧩",      "🖥️",      "⚡",       "🔮"]

FIELD_STYLE = {
    "bg": "#1e0f05", "fg": "#f0c040", "insertbackground": "#f0c040",
    "relief": "sunken", "bd": 2, "font": ("Courier", 11),
}
LABEL_STYLE = {
    "bg": "#2b1a0e", "fg": "#c8a060",
    "font": ("Georgia", 10, "bold"), "anchor": "w",
}


# ══════════════════════════════════════════════════════════════════════════════
#  Generic JSON helpers
# ══════════════════════════════════════════════════════════════════════════════

def load_json(json_file):
    if os.path.exists(json_file):
        with open(json_file, "r", encoding="utf-8") as f:
            return json.load(f)
    return {}


def save_to_json(json_file, key_field, data, status_label):
    key = data.get(key_field, "").strip()
    if not key:
        messagebox.showwarning("Missing ID", f"Please enter a '{key_field}' before saving.")
        return
    records = load_json(json_file)
    action  = "updated" if key in records else "saved"
    records[key] = data
    with open(json_file, "w", encoding="utf-8") as f:
        json.dump(records, f, indent=4, ensure_ascii=False)
    status_label.config(text=f"✔  '{key}' {action} successfully!", fg="#50e878")


# ══════════════════════════════════════════════════════════════════════════════
#  Shared helpers for populating dropdowns
# ══════════════════════════════════════════════════════════════════════════════

def get_object_names():
    return [""] + sorted(load_json(JSON_OBJECTS_FILE).keys())

def get_screen_names():
    screens = load_json(JSON_SCREENS_FILE)
    names = sorted(
        rec.get("Name", rid)
        for rid, rec in screens.items()
        if rec.get("Name", "").strip() or rid
    )
    return [""] + names

def get_action_names():
    actions = load_json(JSON_ACTIONS_FILE)
    names = sorted(
        rec.get("Name", rid)
        for rid, rec in actions.items()
        if rec.get("Name", "").strip() or rid
    )
    return [""] + names


# ══════════════════════════════════════════════════════════════════════════════
#  Shared UI helpers
# ══════════════════════════════════════════════════════════════════════════════

def make_scrollable_form(win):
    """Return a scrollable Frame inside win for use as a form."""
    canvas    = tk.Canvas(win, bg="#2b1a0e", highlightthickness=0)
    scrollbar = ttk.Scrollbar(win, orient="vertical", command=canvas.yview)
    canvas.configure(yscrollcommand=scrollbar.set)
    scrollbar.pack(side="right", fill="y")
    canvas.pack(side="left", fill="both", expand=True)

    form        = tk.Frame(canvas, bg="#2b1a0e", padx=28)
    form_window = canvas.create_window((0, 0), window=form, anchor="nw")

    form.bind("<Configure>",   lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
    canvas.bind("<Configure>", lambda e: canvas.itemconfig(form_window, width=e.width))
    canvas.bind_all("<MouseWheel>",
                    lambda e: canvas.yview_scroll(int(-1*(e.delta/120)), "units"))
    return form


def section_lbl(parent, text):
    tk.Label(parent, text=text, font=("Georgia", 11, "bold italic"),
             bg="#2b1a0e", fg="#f0c040").pack(fill="x", pady=(14, 4))


def add_field(parent, label, entries):
    tk.Label(parent, text=label, **LABEL_STYLE).pack(fill="x", pady=(4, 1))
    e = tk.Entry(parent, **FIELD_STYLE)
    e.pack(fill="x", ipady=4)
    entries[label] = e


def add_combo(parent, label, values, store_vars, store_combos):
    tk.Label(parent, text=label, **LABEL_STYLE).pack(fill="x", pady=(4, 1))
    var = tk.StringVar(value="")
    cb  = ttk.Combobox(parent, textvariable=var, values=values,
                       font=("Courier", 11))
    cb.pack(fill="x", ipady=3)
    store_vars[label]   = var
    store_combos[label] = cb


def add_grid_combos(parent, field_list, values_fn, store_vars, store_combos):
    """Add a row of comboboxes in a grid, values populated from values_fn()."""
    values = values_fn()
    for i, field in enumerate(field_list):
        col_frame = tk.Frame(parent, bg="#2b1a0e")
        col_frame.grid(row=0, column=i, padx=4, sticky="ew")
        parent.columnconfigure(i, weight=1)
        tk.Label(col_frame, text=field, **LABEL_STYLE).pack(fill="x", pady=(0, 2))
        var = tk.StringVar(value="")
        cb  = ttk.Combobox(col_frame, textvariable=var, values=values,
                           font=("Courier", 10), width=9)
        cb.pack(fill="x", ipady=3)
        store_vars[field]   = var
        store_combos[field] = cb


def save_btn(parent, text, cmd):
    tk.Button(parent, text=text, font=("Georgia", 11, "bold"),
              bg="#3d2005", fg="#f0c040", activebackground="#5c3310",
              activeforeground="#ffffff", relief="raised", bd=3,
              cursor="hand2", padx=16, pady=6, command=cmd).pack(pady=(0, 20))


def status_lbl(parent):
    lbl = tk.Label(parent, text="", font=("Courier", 9), bg="#2b1a0e", fg="#50e878")
    lbl.pack(pady=(0, 4))
    return lbl


def checkbox_widget(parent, text, var):
    tk.Checkbutton(parent, text=f"  {text}", variable=var,
                   font=("Georgia", 10, "bold"), bg="#2b1a0e", fg="#c8a060",
                   selectcolor="#1e0f05", activebackground="#2b1a0e",
                   activeforeground="#f0c040", cursor="hand2").pack(anchor="w", padx=28, pady=(4, 2))


def apply_combo_style():
    s = ttk.Style()
    s.theme_use("default")
    s.configure("TCombobox", fieldbackground="#1e0f05", background="#3d2005",
                foreground="#f0c040", selectbackground="#5c3310",
                selectforeground="#ffffff", arrowcolor="#f0c040")


# ══════════════════════════════════════════════════════════════════════════════
#  Objects window
# ══════════════════════════════════════════════════════════════════════════════

def open_objects_window():
    win = tk.Toplevel()
    win.title("Objects")
    win.geometry("420x640")
    win.configure(bg="#2b1a0e")
    win.resizable(False, False)
    apply_combo_style()

    tk.Label(win, text="📦  Objects Editor", font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 10))

    # ── Load existing ─────────────────────────────────────────
    load_frame = tk.Frame(win, bg="#2b1a0e", padx=28)
    load_frame.pack(fill="x")
    tk.Label(load_frame, text="Load Existing Object", **LABEL_STYLE).pack(fill="x", pady=(4, 2))
    existing = load_json(JSON_OBJECTS_FILE)
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(load_frame, textvariable=load_var,
                            values=list(existing.keys()),
                            state="readonly", font=("Courier", 11), width=28)
    load_dd.pack(fill="x", ipady=3)

    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(10, 10))

    form    = tk.Frame(win, bg="#2b1a0e", padx=28)
    form.pack(fill="x")
    fields  = ["ObjectID", "Name", "Description"]
    entries = {}
    for f in fields:
        add_field(form, f, entries)

    tk.Label(form, text="Category", **LABEL_STYLE).pack(fill="x", pady=(12, 1))
    cat_var = tk.StringVar(value="Select a category")
    cat_cb  = ttk.Combobox(form, textvariable=cat_var,
                           values=["Weapon", "Treasure", "Key Item"],
                           state="readonly", font=("Courier", 11))
    cat_cb.pack(fill="x", ipady=3)

    take_var = tk.BooleanVar()
    vis_var  = tk.BooleanVar()
    tk.Frame(win, bg="#2b1a0e", height=6).pack()
    checkbox_widget(win, "Takeable", take_var)
    checkbox_widget(win, "Visible",  vis_var)

    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(8, 8))
    slbl = status_lbl(win)

    def on_load(e=None):
        nm  = load_var.get()
        obj = load_json(JSON_OBJECTS_FILE).get(nm)
        if not obj:
            return
        for f in fields:
            entries[f].delete(0, tk.END)
            entries[f].insert(0, obj.get(f, ""))
        cat = obj.get("Category", "")
        cat_var.set(cat if cat in ["Weapon","Treasure","Key Item"] else "Select a category")
        take_var.set(obj.get("Takeable", False))
        vis_var.set(obj.get("Visible",   False))
        slbl.config(text=f"✔  Loaded '{nm}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        data = {f: entries[f].get() for f in fields}
        data.update({"Category": cat_var.get(),
                     "Takeable": take_var.get(),
                     "Visible":  vis_var.get()})
        save_to_json(JSON_OBJECTS_FILE, "Name", data, slbl)
        load_dd["values"] = list(load_json(JSON_OBJECTS_FILE).keys())

    save_btn(win, "💾  Save Object", on_save)


# ══════════════════════════════════════════════════════════════════════════════
#  Actions window
# ══════════════════════════════════════════════════════════════════════════════

def open_actions_window():
    win = tk.Toplevel()
    win.title("Actions")
    win.geometry("420x520")
    win.configure(bg="#2b1a0e")
    win.resizable(False, False)
    apply_combo_style()

    tk.Label(win, text="⚡  Actions Editor", font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 14))

    # ── Load existing ─────────────────────────────────────────
    load_frame = tk.Frame(win, bg="#2b1a0e", padx=28)
    load_frame.pack(fill="x")
    tk.Label(load_frame, text="Load Existing Action", **LABEL_STYLE).pack(fill="x", pady=(4, 2))
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(load_frame, textvariable=load_var,
                            values=list(load_json(JSON_ACTIONS_FILE).keys()),
                            state="readonly", font=("Courier", 11), width=28)
    load_dd.pack(fill="x", ipady=3)

    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(10, 10))

    form    = tk.Frame(win, bg="#2b1a0e", padx=28)
    form.pack(fill="x")
    fields  = ["ID", "Name", "Sensor"]
    entries = {}
    for f in fields:
        add_field(form, f, entries)

    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(14, 8))
    slbl = status_lbl(win)

    def on_load(e=None):
        key = load_var.get()
        rec = load_json(JSON_ACTIONS_FILE).get(key)
        if not rec:
            return
        for f in fields:
            entries[f].delete(0, tk.END)
            entries[f].insert(0, rec.get(f, ""))
        slbl.config(text=f"✔  Loaded '{key}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        data = {f: entries[f].get() for f in fields}
        save_to_json(JSON_ACTIONS_FILE, "ID", data, slbl)
        load_dd["values"] = list(load_json(JSON_ACTIONS_FILE).keys())

    save_btn(win, "💾  Save Action", on_save)


# ══════════════════════════════════════════════════════════════════════════════
#  Puzzles window
# ══════════════════════════════════════════════════════════════════════════════

def open_puzzles_window():
    win = tk.Toplevel()
    win.title("Puzzles")
    win.geometry("460x660")
    win.configure(bg="#2b1a0e")
    win.resizable(False, True)
    apply_combo_style()

    tk.Label(win, text="🧩  Puzzles Editor", font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 0))

    form = make_scrollable_form(win)

    entries       = {}
    combo_vars    = {}
    combo_widgets = {}

    # ── Load existing ─────────────────────────────────────────
    section_lbl(form, "— Load Existing Puzzle —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var,
                            values=list(load_json(JSON_PUZZLES_FILE).keys()),
                            state="readonly", font=("Courier", 11))
    load_dd.pack(fill="x", ipady=3)

    # ── Identity ──────────────────────────────────────────────
    section_lbl(form, "— Identity —")
    for f in ["ID", "Name"]:
        add_field(form, f, entries)

    # ── Action (combo from acs_actions.json) ──────────────────
    section_lbl(form, "— Action —")
    add_combo(form, "Action", get_action_names(), combo_vars, combo_widgets)

    # ── Objects (combo from acs_objects.json) ─────────────────
    section_lbl(form, "— Objects —")
    obj_frame = tk.Frame(form, bg="#2b1a0e")
    obj_frame.pack(fill="x")
    add_grid_combos(obj_frame, ["Object1", "Object2"],
                    get_object_names, combo_vars, combo_widgets)

    # ── Descriptions ──────────────────────────────────────────
    section_lbl(form, "— Descriptions —")
    tk.Label(form, text="DescriptionSolved", **LABEL_STYLE).pack(fill="x", pady=(0, 2))
    desc_solved = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                          relief="sunken", bd=2, font=("Courier", 11), height=3, wrap="word")
    desc_solved.pack(fill="x")

    tk.Label(form, text="DescriptionNotSolved", **LABEL_STYLE).pack(fill="x", pady=(8, 2))
    desc_not_solved = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                              relief="sunken", bd=2, font=("Courier", 11), height=3, wrap="word")
    desc_not_solved.pack(fill="x")

    # ── Solved checkbox ───────────────────────────────────────
    section_lbl(form, "— Status —")
    solved_var = tk.BooleanVar()
    checkbox_widget(form, "Solved", solved_var)

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(14, 8))
    slbl = status_lbl(form)

    def on_load(e=None):
        key = load_var.get()
        rec = load_json(JSON_PUZZLES_FILE).get(key)
        if not rec:
            return
        for f in ["ID", "Name"]:
            entries[f].delete(0, tk.END)
            entries[f].insert(0, rec.get(f, ""))
        combo_vars["Action"].set(rec.get("Action", ""))
        combo_vars["Object1"].set(rec.get("Object1", ""))
        combo_vars["Object2"].set(rec.get("Object2", ""))
        desc_solved.delete("1.0", tk.END)
        desc_solved.insert("1.0", rec.get("DescriptionSolved", ""))
        desc_not_solved.delete("1.0", tk.END)
        desc_not_solved.insert("1.0", rec.get("DescriptionNotSolved", ""))
        solved_var.set(rec.get("Solved", False))
        slbl.config(text=f"✔  Loaded '{key}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        data = {f: entries[f].get() for f in entries}
        data["Action"]               = combo_vars["Action"].get()
        data["Object1"]              = combo_vars["Object1"].get()
        data["Object2"]              = combo_vars["Object2"].get()
        data["DescriptionSolved"]    = desc_solved.get("1.0", "end-1c")
        data["DescriptionNotSolved"] = desc_not_solved.get("1.0", "end-1c")
        data["Solved"]               = solved_var.get()
        save_to_json(JSON_PUZZLES_FILE, "ID", data, slbl)
        load_dd["values"] = list(load_json(JSON_PUZZLES_FILE).keys())
        # refresh action combo in case new actions were added
        combo_widgets["Action"]["values"] = get_action_names()
        combo_widgets["Object1"]["values"] = get_object_names()
        combo_widgets["Object2"]["values"] = get_object_names()

    save_btn(form, "💾  Save Puzzle", on_save)


# ══════════════════════════════════════════════════════════════════════════════
#  Screens window
# ══════════════════════════════════════════════════════════════════════════════

def open_screens_window():
    win = tk.Toplevel()
    win.title("Screens")
    win.geometry("500x700")
    win.configure(bg="#2b1a0e")
    win.resizable(False, True)
    apply_combo_style()

    tk.Label(win, text="🖥️  Screens Editor", font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 0))

    form = make_scrollable_form(win)

    entries       = {}
    exit_vars     = {}
    exit_combos   = {}
    object_vars   = {}
    object_combos = {}

    # ── Identity ─────────────────────────────────────────────
    section_lbl(form, "— Identity —")
    add_field(form, "ID",   entries)
    add_field(form, "Name", entries)

    # ── Exits ────────────────────────────────────────────────
    section_lbl(form, "— Exits (Screen Names) —")
    exits_frame = tk.Frame(form, bg="#2b1a0e")
    exits_frame.pack(fill="x")
    add_grid_combos(exits_frame, ["North", "South", "East", "West"],
                    get_screen_names, exit_vars, exit_combos)

    # ── Objects ──────────────────────────────────────────────
    section_lbl(form, "— Objects in Screen —")
    obj_frame = tk.Frame(form, bg="#2b1a0e")
    obj_frame.pack(fill="x")
    add_grid_combos(obj_frame, ["Object1", "Object2", "Object3"],
                    get_object_names, object_vars, object_combos)

    # ── Puzzles ──────────────────────────────────────────────
    section_lbl(form, "— Puzzles —")
    puz_frame = tk.Frame(form, bg="#2b1a0e")
    puz_frame.pack(fill="x")
    puz_entries = {}
    for i, pf in enumerate(["Puzzle1", "Puzzle2"]):
        col = tk.Frame(puz_frame, bg="#2b1a0e")
        col.grid(row=0, column=i, padx=4, sticky="ew")
        puz_frame.columnconfigure(i, weight=1)
        tk.Label(col, text=pf, **LABEL_STYLE).pack(fill="x", pady=(0, 2))
        e = tk.Entry(col, **FIELD_STYLE)
        e.pack(fill="x", ipady=4)
        puz_entries[pf] = e

    # ── Description ──────────────────────────────────────────
    section_lbl(form, "— Description —")
    tk.Label(form, text="Description", **LABEL_STYLE).pack(fill="x", pady=(0, 2))
    desc_text = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                        relief="sunken", bd=2, font=("Courier", 11), height=4, wrap="word")
    desc_text.pack(fill="x")

    # ── ASCII Drawing ─────────────────────────────────────────
    section_lbl(form, "— ASCII Drawing —")
    tk.Label(form, text="AsciiDrawing", **LABEL_STYLE).pack(fill="x", pady=(0, 2))
    ascii_text = tk.Text(form, bg="#1e0f05", fg="#50e878", insertbackground="#50e878",
                         relief="sunken", bd=2, font=("Courier New", 11), height=7, wrap="none")
    ascii_text.pack(fill="x")

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(18, 8))
    slbl = status_lbl(form)

    def on_save():
        data = {f: entries[f].get() for f in entries}
        for d, v in exit_vars.items():
            data[d] = v.get()
        for o, v in object_vars.items():
            data[o] = v.get()
        for p, e in puz_entries.items():
            data[p] = e.get()
        data["Description"]  = desc_text.get("1.0", "end-1c")
        data["AsciiDrawing"] = ascii_text.get("1.0", "end-1c")
        save_to_json(JSON_SCREENS_FILE, "ID", data, slbl)
        updated = get_screen_names()
        for cb in exit_combos.values():
            cb["values"] = updated

    save_btn(form, "💾  Save Screen", on_save)


# ══════════════════════════════════════════════════════════════════════════════
#  Dispatch
# ══════════════════════════════════════════════════════════════════════════════

def open_window(title):
    dispatch = {
        "Objects": open_objects_window,
        "Screens": open_screens_window,
        "Actions": open_actions_window,
        "Puzzles": open_puzzles_window,
    }
    if title in dispatch:
        dispatch[title]()
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


# ══════════════════════════════════════════════════════════════════════════════
#  Main window
# ══════════════════════════════════════════════════════════════════════════════

def main():
    root = tk.Tk()
    root.title("Adventure Construction Set")
    root.geometry("620x200")
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