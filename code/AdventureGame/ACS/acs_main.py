import json
import os
import tkinter as tk
from tkinter import messagebox, ttk

JSON_OBJECTS_FILE = "acs_objects.json"
JSON_SCREENS_FILE = "acs_screens.json"
JSON_ACTIONS_FILE = "acs_actions.json"
JSON_PUZZLES_FILE = "acs_puzzles.json"

SECTIONS = ["Objects", "Puzzles", "Screens", "Actions", "Elements", "Map"]
ICONS    = ["📦",      "🧩",      "🖥️",      "⚡",       "🔮",        "🗺️"]

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

def get_puzzle_names():
    puzzles = load_json(JSON_PUZZLES_FILE)
    names = sorted(
        rec.get("Name", rid)
        for rid, rec in puzzles.items()
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
        take_var.set(obj.get("Takeable", False))
        vis_var.set(obj.get("Visible",   False))
        slbl.config(text=f"✔  Loaded '{nm}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        data = {f: entries[f].get() for f in fields}
        data.update({"Takeable": take_var.get(),
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
    puzzle_vars   = {}
    puzzle_combos = {}
    action_vars   = {}
    action_combos = {}

    # ── Load existing screen ──────────────────────────────────
    section_lbl(form, "— Load Existing Screen —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var,
                            values=get_screen_names()[1:],
                            state="readonly", font=("Courier", 11))
    load_dd.pack(fill="x", ipady=3)
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(10, 0))

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

    # ── Objects (2 rows of 3 = 6 total) ──────────────────────
    section_lbl(form, "— Objects in Screen —")
    obj_frame1 = tk.Frame(form, bg="#2b1a0e")
    obj_frame1.pack(fill="x")
    add_grid_combos(obj_frame1, ["Object1", "Object2", "Object3"],
                    get_object_names, object_vars, object_combos)
    obj_frame2 = tk.Frame(form, bg="#2b1a0e")
    obj_frame2.pack(fill="x", pady=(6, 0))
    add_grid_combos(obj_frame2, ["Object4", "Object5", "Object6"],
                    get_object_names, object_vars, object_combos)


    # ── Puzzles ──────────────────────────────────────────────
    section_lbl(form, "— Puzzles —")
    puz_frame = tk.Frame(form, bg="#2b1a0e")
    puz_frame.pack(fill="x")
    add_grid_combos(puz_frame, ["Puzzle1", "Puzzle2"],
                    get_puzzle_names, puzzle_vars, puzzle_combos)

    # ── Actions (2 rows of 3 = 6 total) ──────────────────────
    section_lbl(form, "— Actions in Screen —")
    act_frame1 = tk.Frame(form, bg="#2b1a0e")
    act_frame1.pack(fill="x")
    add_grid_combos(act_frame1, ["Action1", "Action2", "Action3"],
                    get_action_names, action_vars, action_combos)
    act_frame2 = tk.Frame(form, bg="#2b1a0e")
    act_frame2.pack(fill="x", pady=(6, 0))
    add_grid_combos(act_frame2, ["Action4", "Action5", "Action6"],
                    get_action_names, action_vars, action_combos)

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

    def on_load_screen(e=None):
        nm  = load_var.get()
        screens = load_json(JSON_SCREENS_FILE)
        # find record by Name field
        rec = next((r for r in screens.values() if r.get("Name","") == nm), None)
        if not rec:
            return
        for f in list(entries.keys()):
            entries[f].delete(0, tk.END)
            entries[f].insert(0, rec.get(f, ""))
        for d, v in exit_vars.items():
            v.set(rec.get(d, ""))
        for o, v in object_vars.items():
            v.set(rec.get(o, ""))
        for p, v in puzzle_vars.items():
            v.set(rec.get(p, ""))
        for a, v in action_vars.items():
            v.set(rec.get(a, ""))
        desc_text.delete("1.0", tk.END)
        desc_text.insert("1.0", rec.get("Description", ""))
        ascii_text.delete("1.0", tk.END)
        ascii_text.insert("1.0", rec.get("AsciiDrawing", ""))
        slbl.config(text=f"✔  Loaded '{nm}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load_screen)

    def on_save():
        data = {f: entries[f].get() for f in entries}
        for d, v in exit_vars.items():
            data[d] = v.get()
        for o, v in object_vars.items():
            data[o] = v.get()
        for p, v in puzzle_vars.items():
            data[p] = v.get()
        for a, v in action_vars.items():
            data[a] = v.get()
        data["Description"]  = desc_text.get("1.0", "end-1c")
        data["AsciiDrawing"] = ascii_text.get("1.0", "end-1c")
        save_to_json(JSON_SCREENS_FILE, "ID", data, slbl)
        updated = get_screen_names()[1:]
        for cb in exit_combos.values():
            cb["values"] = [""] + updated
        load_dd["values"] = updated
        for cb in puzzle_combos.values():
            cb["values"] = get_puzzle_names()
        for cb in action_combos.values():
            cb["values"] = get_action_names()

    save_btn(form, "💾  Save Screen", on_save)



# ══════════════════════════════════════════════════════════════════════════════
#  Map window
# ══════════════════════════════════════════════════════════════════════════════

def open_map_window():
    screens = load_json(JSON_SCREENS_FILE)
    if not screens:
        messagebox.showinfo("Map", "No screens found. Create some screens first.")
        return

    win = tk.Toplevel()
    win.title("🗺️  Adventure Map")
    win.geometry("900x700")
    win.configure(bg="#1a0f06")
    win.resizable(True, True)

    tk.Label(win, text="🗺️  Adventure Map", font=("Georgia", 16, "bold"),
             bg="#1a0f06", fg="#f0c040", pady=10).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 6))

    # ── Toolbar ───────────────────────────────────────────────
    toolbar = tk.Frame(win, bg="#1a0f06")
    toolbar.pack(fill="x", padx=20, pady=(0, 6))
    tk.Label(toolbar, text="Drag rooms to rearrange  •  Scroll to zoom",
             font=("Courier", 9), bg="#1a0f06", fg="#7a5520").pack(side="left")
    tk.Button(toolbar, text="⟳ Reset Layout", font=("Georgia", 9, "bold"),
              bg="#3d2005", fg="#f0c040", activebackground="#5c3310",
              activeforeground="#fff", relief="raised", bd=2, cursor="hand2",
              command=lambda: redraw(reset=True)).pack(side="right")

    # ── Canvas ────────────────────────────────────────────────
    canvas = tk.Canvas(win, bg="#0d0804", highlightthickness=0)
    hbar = ttk.Scrollbar(win, orient="horizontal", command=canvas.xview)
    vbar = ttk.Scrollbar(win, orient="vertical",   command=canvas.yview)
    canvas.configure(xscrollcommand=hbar.set, yscrollcommand=vbar.set)
    hbar.pack(side="bottom", fill="x")
    vbar.pack(side="right",  fill="y")
    canvas.pack(side="left", fill="both", expand=True)

    # ── Layout constants ──────────────────────────────────────
    BOX_W, BOX_H  = 140, 50   # base box size (header area only)
    GAP_X, GAP_Y  = 80, 80
    STEP_X = BOX_W + GAP_X
    STEP_Y = BOX_H + GAP_Y
    ORIGIN = (100, 100)
    OBJ_LINE_H = 14   # height per object/puzzle line inside the box extension

    # ── Build adjacency: name → {N,S,E,W} neighbour names ────
    name_to_rec = {}
    for rid, rec in screens.items():
        nm = rec.get("Name", rid).strip() or rid
        name_to_rec[nm] = rec

    all_names = list(name_to_rec.keys())

    # ── Load objects data for visibility lookup ───────────────
    def get_objects_data():
        return load_json(JSON_OBJECTS_FILE)

    def get_screen_object_labels(rec):
        """
        Return a list of label strings for objects in a screen record.
        Hidden objects (Visible=False) get a [H] suffix.
        """
        objects_data = get_objects_data()
        labels = []
        for slot in ["Object1", "Object2", "Object3", "Object4", "Object5", "Object6"]:
            obj_name = rec.get(slot, "").strip()
            if not obj_name:
                continue
            obj_rec = objects_data.get(obj_name, {})
            visible = obj_rec.get("Visible", True)
            if not visible:
                labels.append(f"[H] {obj_name}")
            else:
                labels.append(obj_name)
        return labels

    def get_screen_puzzle_labels(rec):
        """
        Return a list of puzzle Name strings for puzzles in a screen record.
        Looks up the puzzle Name from acs_puzzles.json using the puzzle ID stored in the screen.
        Solved puzzles get a [S] prefix.
        """
        puzzles_data = load_json(JSON_PUZZLES_FILE)
        labels = []
        for slot in ["Puzzle1", "Puzzle2"]:
            puzzle_id = rec.get(slot, "").strip()
            if not puzzle_id:
                continue
            puzzle_rec = puzzles_data.get(puzzle_id, {})
            name = puzzle_rec.get("Name", puzzle_id) or puzzle_id
            solved = puzzle_rec.get("Solved", False)
            if solved:
                labels.append(f"[S] {name}")
            else:
                labels.append(name)
        return labels

    # ── Auto-layout via BFS from first screen ─────────────────
    positions = {}   # name → [cx, cy]  (mutable so drag works)

    def auto_layout():
        positions.clear()
        start = all_names[0]
        queue = [(start, 0, 0)]
        visited = set()
        while queue:
            nm, gx, gy = queue.pop(0)
            if nm in visited:
                continue
            visited.add(nm)
            cx = ORIGIN[0] + gx * STEP_X
            cy = ORIGIN[1] + gy * STEP_Y
            positions[nm] = [cx, cy]
            rec = name_to_rec.get(nm, {})
            neighbors = {
                "North": (gx,     gy - 1),
                "South": (gx,     gy + 1),
                "West":  (gx - 1, gy    ),
                "East":  (gx + 1, gy    ),
            }
            for direction, (nx, ny) in neighbors.items():
                neighbour = rec.get(direction, "").strip()
                if neighbour and neighbour in name_to_rec and neighbour not in visited:
                    queue.append((neighbour, nx, ny))
        # any screens not reachable from first (disconnected) get placed below
        placed_y = max((p[1] for p in positions.values()), default=ORIGIN[1])
        col = 0
        for nm in all_names:
            if nm not in positions:
                positions[nm] = [ORIGIN[0] + col * STEP_X, placed_y + STEP_Y * 2]
                col += 1

    auto_layout()

    # ── Drawing ───────────────────────────────────────────────
    BOX_COLOR        = "#3d2005"
    BOX_OUTLINE      = "#f0c040"
    TEXT_COLOR       = "#f0c040"
    OBJ_COLOR        = "#90d8a0"   # visible object text
    OBJ_HIDDEN_COLOR = "#d08050"   # hidden object text (warm orange)
    PUZ_COLOR        = "#a0c8f0"   # puzzle text (light blue)
    PUZ_SOLVED_COLOR = "#7a9070"   # solved puzzle text (muted green-grey)
    DIVIDER_COLOR    = "#7a5520"
    ARROW_COLOR      = "#c8a060"
    DIR_LABELS       = {"North": "N", "South": "S", "East": "E", "West": "W"}

    ATTACH = {
        "North": (0.5,  0.0),
        "South": (0.5,  1.0),
        "East":  (1.0,  0.5),
        "West":  (0.0,  0.5),
    }

    item_map   = {}   # name → {"rect": id, "text": id, "total_h": int}

    def total_box_height(nm):
        """Compute total rendered height of a room box including object and puzzle lines."""
        rec = name_to_rec.get(nm, {})
        obj_labels = get_screen_object_labels(rec)
        puz_labels = get_screen_puzzle_labels(rec)
        extra = 0
        if obj_labels:
            extra += len(obj_labels) * OBJ_LINE_H + 6
        if puz_labels:
            extra += len(puz_labels) * OBJ_LINE_H + 6
        return BOX_H + extra

    def box_attach(nm, direction):
        cx, cy = positions[nm]
        th = total_box_height(nm)
        # cx/cy is top-center of the header; we treat cy as the vertical center of header
        top    = cy - BOX_H // 2
        bottom = top + th
        mid_y  = (top + bottom) / 2
        if direction == "North":
            return cx, top
        elif direction == "South":
            return cx, bottom
        elif direction == "East":
            return cx + BOX_W // 2, mid_y
        elif direction == "West":
            return cx - BOX_W // 2, mid_y

    def redraw(reset=False):
        if reset:
            auto_layout()
        canvas.delete("all")
        item_map.clear()

        # Draw arrows first (behind boxes)
        # ── Collect all directed edges ────────────────────────
        OPP = {"North":"South","South":"North","East":"West","West":"East"}
        # PERP gives a perpendicular unit offset direction for each axis
        # so parallel arrows don't overlap. Offset = 5px sideways.
        OFFSET = 5
        def perp_offset(direction):
            """Return (dx, dy) perpendicular offset so parallel arrows are separated."""
            if direction in ("North", "South"):
                return (OFFSET, 0)   # shift East for the "first" arrow
            else:
                return (0, OFFSET)   # shift South for the "first" arrow

        # Build set of all directed edges: (nm, neighbour, direction)
        edges = []
        for nm, rec in name_to_rec.items():
            if nm not in positions:
                continue
            for direction in DIR_LABELS:
                neighbour = rec.get(direction, "").strip()
                if neighbour and neighbour in positions:
                    edges.append((nm, neighbour, direction))

        # Determine which edges have a reverse counterpart (bidirectional)
        edge_set = {(nm, nb, d) for nm, nb, d in edges}

        drawn_labels = []  # track label positions to avoid stacking

        for nm, neighbour, direction in edges:
            opp_dir = OPP[direction]
            is_bidir = (neighbour, nm, opp_dir) in edge_set

            x1, y1 = box_attach(nm, direction)
            x2, y2 = box_attach(neighbour, opp_dir)

            if is_bidir:
                # Determine which of the two directions is "first" (canonical)
                # so each pair offsets consistently in opposite sides.
                pair = tuple(sorted([f"{nm}:{direction}", f"{neighbour}:{opp_dir}"]))
                is_first = f"{nm}:{direction}" == pair[0]
                pdx, pdy = perp_offset(direction)
                sign = 1 if is_first else -1
                ox, oy = pdx * sign, pdy * sign
                ax1, ay1 = x1 + ox, y1 + oy
                ax2, ay2 = x2 + ox, y2 + oy
            else:
                ax1, ay1 = x1, y1
                ax2, ay2 = x2, y2

            canvas.create_line(
                ax1, ay1, ax2, ay2,
                fill=ARROW_COLOR, width=2,
                arrow=tk.LAST, arrowshape=(10, 12, 4),
                tags="arrow"
            )
            # Direction label near the source end (1/3 of the way along)
            lx = ax1 + (ax2 - ax1) * 0.25
            ly = ay1 + (ay2 - ay1) * 0.25
            # Nudge label slightly off the line
            if direction in ("North", "South"):
                lx += 10
            else:
                ly -= 10
            canvas.create_text(lx, ly, text=DIR_LABELS[direction],
                               fill="#f0c040", font=("Courier", 8, "bold"),
                               tags="arrow")

        # Draw boxes on top
        for nm in all_names:
            if nm not in positions:
                continue
            cx, cy = positions[nm]
            rec = name_to_rec.get(nm, {})
            obj_labels = get_screen_object_labels(rec)
            puz_labels = get_screen_puzzle_labels(rec)

            # Compute full box height
            obj_area_h = len(obj_labels) * OBJ_LINE_H + (6 if obj_labels else 0)
            puz_area_h = len(puz_labels) * OBJ_LINE_H + (6 if puz_labels else 0)
            full_h = BOX_H + obj_area_h + puz_area_h

            x0 = cx - BOX_W // 2
            y0 = cy - BOX_H // 2
            x1 = cx + BOX_W // 2
            y1_header = cy + BOX_H // 2
            y1_full   = y0 + full_h

            # Draw full box background
            rect = canvas.create_rectangle(
                x0, y0, x1, y1_full,
                fill=BOX_COLOR, outline=BOX_OUTLINE,
                width=2, tags=("box", nm)
            )

            # Room name in header area
            display = nm if len(nm) <= 16 else nm[:15] + "…"
            txt = canvas.create_text(
                cx, cy,
                text=display,
                fill=TEXT_COLOR,
                font=("Georgia", 9, "bold"),
                width=BOX_W - 8,
                tags=("box", nm)
            )

            # Divider line between header and object area
            if obj_labels or puz_labels:
                canvas.create_line(
                    x0 + 2, y1_header,
                    x1 - 2, y1_header,
                    fill=DIVIDER_COLOR, width=1,
                    tags=("box", nm)
                )

            # Object labels
            for i, lbl in enumerate(obj_labels):
                oy = y1_header + 4 + i * OBJ_LINE_H + OBJ_LINE_H // 2
                is_hidden = lbl.startswith("[H]")
                color = OBJ_HIDDEN_COLOR if is_hidden else OBJ_COLOR
                # Truncate long names
                max_chars = 17
                display_lbl = lbl if len(lbl) <= max_chars else lbl[:max_chars - 1] + "…"
                canvas.create_text(
                    cx, oy,
                    text=display_lbl,
                    fill=color,
                    font=("Courier", 8),
                    width=BOX_W - 6,
                    tags=("box", nm)
                )

            # Puzzle section
            y1_puz_start = y1_header + obj_area_h
            if puz_labels:
                # Divider before puzzles
                canvas.create_line(
                    x0 + 2, y1_puz_start,
                    x1 - 2, y1_puz_start,
                    fill=DIVIDER_COLOR, width=1, dash=(4, 2),
                    tags=("box", nm)
                )
                for i, lbl in enumerate(puz_labels):
                    oy = y1_puz_start + 4 + i * OBJ_LINE_H + OBJ_LINE_H // 2
                    is_solved = lbl.startswith("[S]")
                    color = PUZ_SOLVED_COLOR if is_solved else PUZ_COLOR
                    max_chars = 17
                    display_lbl = lbl if len(lbl) <= max_chars else lbl[:max_chars - 1] + "…"
                    canvas.create_text(
                        cx, oy,
                        text=display_lbl,
                        fill=color,
                        font=("Courier", 8, "italic"),
                        width=BOX_W - 6,
                        tags=("box", nm)
                    )

            item_map[nm] = {"rect": rect, "text": txt, "total_h": full_h}

        canvas.configure(scrollregion=canvas.bbox("all") or (0, 0, 900, 700))

    redraw()

    # ── Drag logic ────────────────────────────────────────────
    drag_state = {"name": None, "ox": 0, "oy": 0}

    def on_press(event):
        cx = canvas.canvasx(event.x)
        cy = canvas.canvasy(event.y)
        for nm, ids in item_map.items():
            items = canvas.find_overlapping(cx-1, cy-1, cx+1, cy+1)
            if ids["rect"] in items or ids["text"] in items:
                drag_state["name"] = nm
                drag_state["ox"]   = cx
                drag_state["oy"]   = cy
                break

    def on_drag(event):
        nm = drag_state["name"]
        if not nm:
            return
        cx = canvas.canvasx(event.x)
        cy = canvas.canvasy(event.y)
        dx, dy = cx - drag_state["ox"], cy - drag_state["oy"]
        drag_state["ox"], drag_state["oy"] = cx, cy
        positions[nm][0] += dx
        positions[nm][1] += dy
        redraw()

    def on_release(event):
        drag_state["name"] = None

    # ── Zoom ─────────────────────────────────────────────────
    scale = [1.0]

    def on_zoom(event):
        factor = 1.1 if event.delta > 0 else 0.9
        cx = canvas.canvasx(event.x)
        cy = canvas.canvasy(event.y)
        canvas.scale("all", cx, cy, factor, factor)
        canvas.configure(scrollregion=canvas.bbox("all"))

    canvas.bind("<ButtonPress-1>",   on_press)
    canvas.bind("<B1-Motion>",       on_drag)
    canvas.bind("<ButtonRelease-1>", on_release)
    canvas.bind("<MouseWheel>",      on_zoom)

# ══════════════════════════════════════════════════════════════════════════════
#  Dispatch
# ══════════════════════════════════════════════════════════════════════════════

def open_window(title):
    dispatch = {
        "Objects": open_objects_window,
        "Screens": open_screens_window,
        "Actions": open_actions_window,
        "Puzzles": open_puzzles_window,
        "Map":     open_map_window,
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
    root.geometry("730x200")
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