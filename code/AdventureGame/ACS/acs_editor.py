import json
import os
import tkinter as tk
from tkinter import messagebox, ttk

ACTION_RULES_FILE = "action_rules.json"

# ── colours ───────────────────────────────────────────────────────────────────
BG        = "#0d0804"
FG_WHITE  = "#f0e8d0"
FG_GOLD   = "#f0c040"
FG_GREEN  = "#50e878"
FG_BLUE   = "#80c8f0"
FG_ORANGE = "#e09040"
FG_DIM    = "#7a5520"
FG_RED    = "#e05050"
FONT_MONO = ("Courier New", 11)
FONT_MONO_SM = ("Courier New", 10)
FONT_BOLD = ("Georgia", 11, "bold")

JSON_OBJECTS_FILE = "acs_objects.json"
JSON_SCREENS_FILE = "acs_screens.json"
JSON_ACTIONS_FILE = "acs_actions.json"
JSON_PUZZLES_FILE = "acs_puzzles.json"
JSON_RULES_FILE   = "acs_rules.json"

SECTIONS = ["Objects", "Puzzles", "Screens", "Actions", "Rules", "Map", "Play"]
ICONS    = ["📦",      "🧩",      "🖥️",      "⚡",       "📜",    "🗺️",  "▶"]

FIELD_STYLE = {
    "bg": "#1e0f05", "fg": "#f0c040", "insertbackground": "#f0c040",
    "relief": "sunken", "bd": 2, "font": ("Courier", 11),
}
LABEL_STYLE = {
    "bg": "#2b1a0e", "fg": "#c8a060",
    "font": ("Georgia", 10, "bold"), "anchor": "w",
}

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

def get_object_names():
    return [""] + sorted(load_json(JSON_OBJECTS_FILE).keys())

def get_screen_names():
    screens = load_json(JSON_SCREENS_FILE)
    names = sorted(rec.get("Name", rid) for rid, rec in screens.items() if rec.get("Name","").strip() or rid)
    return [""] + names

def get_puzzle_names():
    puzzles = load_json(JSON_PUZZLES_FILE)
    names = sorted(rec.get("Name", rid) for rid, rec in puzzles.items() if rec.get("Name","").strip() or rid)
    return [""] + names

def get_action_names():
    actions = load_json(JSON_ACTIONS_FILE)
    names = sorted(rec.get("Name", rid) for rid, rec in actions.items() if rec.get("Name","").strip() or rid)
    return [""] + names

def make_scrollable_form(win):
    canvas    = tk.Canvas(win, bg="#2b1a0e", highlightthickness=0)
    scrollbar = ttk.Scrollbar(win, orient="vertical", command=canvas.yview)
    canvas.configure(yscrollcommand=scrollbar.set)
    scrollbar.pack(side="right", fill="y")
    canvas.pack(side="left", fill="both", expand=True)
    form        = tk.Frame(canvas, bg="#2b1a0e", padx=28)
    form_window = canvas.create_window((0, 0), window=form, anchor="nw")
    form.bind("<Configure>",   lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
    canvas.bind("<Configure>", lambda e: canvas.itemconfig(form_window, width=e.width))
    canvas.bind_all("<MouseWheel>", lambda e: canvas.yview_scroll(int(-1*(e.delta/120)), "units"))
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
    cb  = ttk.Combobox(parent, textvariable=var, values=values, font=("Courier", 11))
    cb.pack(fill="x", ipady=3)
    store_vars[label]   = var
    store_combos[label] = cb

def add_grid_combos(parent, field_list, values_fn, store_vars, store_combos):
    values = values_fn()
    for i, field in enumerate(field_list):
        col_frame = tk.Frame(parent, bg="#2b1a0e")
        col_frame.grid(row=0, column=i, padx=4, sticky="ew")
        parent.columnconfigure(i, weight=1)
        tk.Label(col_frame, text=field, **LABEL_STYLE).pack(fill="x", pady=(0, 2))
        var = tk.StringVar(value="")
        cb  = ttk.Combobox(col_frame, textvariable=var, values=values, font=("Courier", 10), width=9)
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
    s.configure("TCombobox", fieldbackground="#000000", background="#000000",
                foreground="#f0c040", selectbackground="#5c3310",
                selectforeground="#ffffff", arrowcolor="#f0c040")
    s.map("TCombobox",
          fieldbackground=[("readonly","#000000"),("disabled","#000000")],
          background=[("readonly","#000000"),("disabled","#000000")],
          foreground=[("readonly","#f0c040"),("disabled","#7a5520")],
          selectbackground=[("readonly","#5c3310")],
          selectforeground=[("readonly","#ffffff")])

# ══════════════════════════════════════════════════════════════════════════════
#  Objects window
# ══════════════════════════════════════════════════════════════════════════════

def open_objects_window():
    win = tk.Toplevel(); win.title("Objects"); win.geometry("420x640")
    win.configure(bg="#2b1a0e"); win.resizable(False, False); apply_combo_style()
    tk.Label(win, text="📦  Objects Editor", font=("Georgia",18,"bold"), bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0,10))
    load_frame = tk.Frame(win, bg="#2b1a0e", padx=28); load_frame.pack(fill="x")
    tk.Label(load_frame, text="Load Existing Object", **LABEL_STYLE).pack(fill="x", pady=(4,2))
    existing = load_json(JSON_OBJECTS_FILE)
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(load_frame, textvariable=load_var, values=list(existing.keys()),
                            state="readonly", font=("Courier",11), width=28)
    load_dd.pack(fill="x", ipady=3)
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(10,10))
    form = tk.Frame(win, bg="#2b1a0e", padx=28); form.pack(fill="x")
    fields = ["ObjectID","Name","Description"]; entries = {}
    for f in fields: add_field(form, f, entries)
    take_var = tk.BooleanVar(); vis_var = tk.BooleanVar()
    tk.Frame(win, bg="#2b1a0e", height=6).pack()
    checkbox_widget(win, "Takeable", take_var); checkbox_widget(win, "Visible", vis_var)
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(8,8))
    slbl = status_lbl(win)
    def on_load(e=None):
        nm = load_var.get(); obj = load_json(JSON_OBJECTS_FILE).get(nm)
        if not obj: return
        for f in fields: entries[f].delete(0,tk.END); entries[f].insert(0,obj.get(f,""))
        take_var.set(obj.get("Takeable",False)); vis_var.set(obj.get("Visible",False))
        slbl.config(text=f"✔  Loaded '{nm}'", fg="#c8a060")
    load_dd.bind("<<ComboboxSelected>>", on_load)
    def on_save():
        data = {f: entries[f].get() for f in fields}
        data.update({"Takeable": take_var.get(), "Visible": vis_var.get()})
        save_to_json(JSON_OBJECTS_FILE, "Name", data, slbl)
        load_dd["values"] = list(load_json(JSON_OBJECTS_FILE).keys())
    save_btn(win, "💾  Save Object", on_save)

# ══════════════════════════════════════════════════════════════════════════════
#  Actions window
# ══════════════════════════════════════════════════════════════════════════════

def open_actions_window():
    win = tk.Toplevel(); win.title("Actions"); win.geometry("420x520")
    win.configure(bg="#2b1a0e"); win.resizable(False,False); apply_combo_style()
    tk.Label(win, text="⚡  Actions Editor", font=("Georgia",18,"bold"), bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0,14))
    load_frame = tk.Frame(win, bg="#2b1a0e", padx=28); load_frame.pack(fill="x")
    tk.Label(load_frame, text="Load Existing Action", **LABEL_STYLE).pack(fill="x", pady=(4,2))
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(load_frame, textvariable=load_var,
                            values=list(load_json(JSON_ACTIONS_FILE).keys()),
                            state="readonly", font=("Courier",11), width=28)
    load_dd.pack(fill="x", ipady=3)
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(10,10))
    form = tk.Frame(win, bg="#2b1a0e", padx=28); form.pack(fill="x")
    fields = ["ID","Name","Sensor"]; entries = {}
    for f in fields: add_field(form, f, entries)
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(14,8))
    slbl = status_lbl(win)
    def on_load(e=None):
        key = load_var.get(); rec = load_json(JSON_ACTIONS_FILE).get(key)
        if not rec: return
        for f in fields: entries[f].delete(0,tk.END); entries[f].insert(0,rec.get(f,""))
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
    win = tk.Toplevel(); win.title("Puzzles"); win.geometry("460x660")
    win.configure(bg="#2b1a0e"); win.resizable(False,True); apply_combo_style()
    tk.Label(win, text="🧩  Puzzles Editor", font=("Georgia",18,"bold"), bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0,0))
    form = make_scrollable_form(win)
    entries = {}; combo_vars = {}; combo_widgets = {}
    section_lbl(form, "— Load Existing Puzzle —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var, values=list(load_json(JSON_PUZZLES_FILE).keys()),
                            state="readonly", font=("Courier",11))
    load_dd.pack(fill="x", ipady=3)
    section_lbl(form, "— Identity —")
    for f in ["ID","Name"]: add_field(form, f, entries)
    section_lbl(form, "— Action —")
    add_combo(form, "Action", get_action_names(), combo_vars, combo_widgets)
    section_lbl(form, "— Objects —")
    obj_frame = tk.Frame(form, bg="#2b1a0e"); obj_frame.pack(fill="x")
    add_grid_combos(obj_frame, ["Object1","Object2"], get_object_names, combo_vars, combo_widgets)
    section_lbl(form, "— Descriptions —")
    tk.Label(form, text="DescriptionSolved", **LABEL_STYLE).pack(fill="x", pady=(0,2))
    desc_solved = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                          relief="sunken", bd=2, font=("Courier",11), height=3, wrap="word")
    desc_solved.pack(fill="x")
    tk.Label(form, text="DescriptionNotSolved", **LABEL_STYLE).pack(fill="x", pady=(8,2))
    desc_not_solved = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                              relief="sunken", bd=2, font=("Courier",11), height=3, wrap="word")
    desc_not_solved.pack(fill="x")
    section_lbl(form, "— Status —")
    solved_var = tk.BooleanVar(); checkbox_widget(form, "Solved", solved_var)
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(14,8))
    slbl = status_lbl(form)
    def on_load(e=None):
        key = load_var.get(); rec = load_json(JSON_PUZZLES_FILE).get(key)
        if not rec: return
        for f in ["ID","Name"]: entries[f].delete(0,tk.END); entries[f].insert(0,rec.get(f,""))
        combo_vars["Action"].set(rec.get("Action",""))
        combo_vars["Object1"].set(rec.get("Object1",""))
        combo_vars["Object2"].set(rec.get("Object2",""))
        desc_solved.delete("1.0",tk.END); desc_solved.insert("1.0",rec.get("DescriptionSolved",""))
        desc_not_solved.delete("1.0",tk.END); desc_not_solved.insert("1.0",rec.get("DescriptionNotSolved",""))
        solved_var.set(rec.get("Solved",False))
        slbl.config(text=f"✔  Loaded '{key}'", fg="#c8a060")
    load_dd.bind("<<ComboboxSelected>>", on_load)
    def on_save():
        data = {f: entries[f].get() for f in entries}
        data["Action"] = combo_vars["Action"].get()
        data["Object1"] = combo_vars["Object1"].get()
        data["Object2"] = combo_vars["Object2"].get()
        data["DescriptionSolved"] = desc_solved.get("1.0","end-1c")
        data["DescriptionNotSolved"] = desc_not_solved.get("1.0","end-1c")
        data["Solved"] = solved_var.get()
        save_to_json(JSON_PUZZLES_FILE, "ID", data, slbl)
        load_dd["values"] = list(load_json(JSON_PUZZLES_FILE).keys())
        combo_widgets["Action"]["values"]  = get_action_names()
        combo_widgets["Object1"]["values"] = get_object_names()
        combo_widgets["Object2"]["values"] = get_object_names()
    save_btn(form, "💾  Save Puzzle", on_save)

# ══════════════════════════════════════════════════════════════════════════════
#  Screens window
# ══════════════════════════════════════════════════════════════════════════════

def open_screens_window():
    win = tk.Toplevel(); win.title("Screens"); win.geometry("500x700")
    win.configure(bg="#2b1a0e"); win.resizable(False,True); apply_combo_style()
    tk.Label(win, text="🖥️  Screens Editor", font=("Georgia",18,"bold"), bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0,0))
    form = make_scrollable_form(win)
    entries = {}; exit_vars = {}; exit_combos = {}
    object_vars = {}; object_combos = {}; puzzle_vars = {}; puzzle_combos = {}
    action_vars = {}; action_combos = {}
    section_lbl(form, "— Load Existing Screen —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var, values=get_screen_names()[1:],
                            state="readonly", font=("Courier",11))
    load_dd.pack(fill="x", ipady=3)
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(10,0))
    section_lbl(form, "— Identity —")
    add_field(form, "ID", entries); add_field(form, "Name", entries)
    section_lbl(form, "— Exits (Screen Names) —")
    exits_frame = tk.Frame(form, bg="#2b1a0e"); exits_frame.pack(fill="x")
    add_grid_combos(exits_frame, ["North","South","East","West"], get_screen_names, exit_vars, exit_combos)
    section_lbl(form, "— Objects in Screen —")
    obj_frame1 = tk.Frame(form, bg="#2b1a0e"); obj_frame1.pack(fill="x")
    add_grid_combos(obj_frame1, ["Object1","Object2","Object3"], get_object_names, object_vars, object_combos)
    obj_frame2 = tk.Frame(form, bg="#2b1a0e"); obj_frame2.pack(fill="x", pady=(6,0))
    add_grid_combos(obj_frame2, ["Object4","Object5","Object6"], get_object_names, object_vars, object_combos)
    section_lbl(form, "— Puzzles —")
    puz_frame = tk.Frame(form, bg="#2b1a0e"); puz_frame.pack(fill="x")
    add_grid_combos(puz_frame, ["Puzzle1","Puzzle2"], get_puzzle_names, puzzle_vars, puzzle_combos)
    section_lbl(form, "— Actions in Screen —")
    act_frame1 = tk.Frame(form, bg="#2b1a0e"); act_frame1.pack(fill="x")
    add_grid_combos(act_frame1, ["Action1","Action2","Action3"], get_action_names, action_vars, action_combos)
    act_frame2 = tk.Frame(form, bg="#2b1a0e"); act_frame2.pack(fill="x", pady=(6,0))
    add_grid_combos(act_frame2, ["Action4","Action5","Action6"], get_action_names, action_vars, action_combos)
    section_lbl(form, "— Description —")
    tk.Label(form, text="Description", **LABEL_STYLE).pack(fill="x", pady=(0,2))
    desc_text = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                        relief="sunken", bd=2, font=("Courier",11), height=4, wrap="word")
    desc_text.pack(fill="x")
    section_lbl(form, "— ASCII Drawing —")
    tk.Label(form, text="AsciiDrawing", **LABEL_STYLE).pack(fill="x", pady=(0,2))
    ascii_text = tk.Text(form, bg="#1e0f05", fg="#50e878", insertbackground="#50e878",
                         relief="sunken", bd=2, font=("Courier New",11), height=7, wrap="none")
    ascii_text.pack(fill="x")
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(18,8))
    slbl = status_lbl(form)
    def on_load_screen(e=None):
        nm = load_var.get(); screens = load_json(JSON_SCREENS_FILE)
        rec = next((r for r in screens.values() if r.get("Name","") == nm), None)
        if not rec: return
        for f in list(entries.keys()): entries[f].delete(0,tk.END); entries[f].insert(0,rec.get(f,""))
        for d,v in exit_vars.items(): v.set(rec.get(d,""))
        for o,v in object_vars.items(): v.set(rec.get(o,""))
        for p,v in puzzle_vars.items(): v.set(rec.get(p,""))
        for a,v in action_vars.items(): v.set(rec.get(a,""))
        desc_text.delete("1.0",tk.END); desc_text.insert("1.0",rec.get("Description",""))
        ascii_text.delete("1.0",tk.END); ascii_text.insert("1.0",rec.get("AsciiDrawing",""))
        slbl.config(text=f"✔  Loaded '{nm}'", fg="#c8a060")
    load_dd.bind("<<ComboboxSelected>>", on_load_screen)
    def on_save():
        data = {f: entries[f].get() for f in entries}
        for d,v in exit_vars.items(): data[d] = v.get()
        for o,v in object_vars.items(): data[o] = v.get()
        for p,v in puzzle_vars.items(): data[p] = v.get()
        for a,v in action_vars.items(): data[a] = v.get()
        data["Description"] = desc_text.get("1.0","end-1c")
        data["AsciiDrawing"] = ascii_text.get("1.0","end-1c")
        save_to_json(JSON_SCREENS_FILE, "ID", data, slbl)
        updated = get_screen_names()[1:]
        for cb in exit_combos.values(): cb["values"] = [""] + updated
        load_dd["values"] = updated
        for cb in puzzle_combos.values(): cb["values"] = get_puzzle_names()
        for cb in action_combos.values(): cb["values"] = get_action_names()
    save_btn(form, "💾  Save Screen", on_save)

# ══════════════════════════════════════════════════════════════════════════════
#  Rules window
#
#  acs_rules.json schema:
#  {
#    "<rule_id>": {
#      "ID": "<rule_id>",
#      "PuzzleName": "<puzzle_name>",   ← trigger: fires when this puzzle is solved
#      "Effects": [
#        { "Type": "set_puzzle_solved",  "PuzzleName": "<name>", "Value": true },
#        { "Type": "set_object_visible", "ObjectName": "<name>", "Value": true|false }
#      ]
#    }
#  }
# ══════════════════════════════════════════════════════════════════════════════

EFFECT_TYPES = ["set_puzzle_solved", "set_object_visible"]
MAX_EFFECTS  = 8

def open_rules_window():
    win = tk.Toplevel(); win.title("Rules"); win.geometry("520x740")
    win.configure(bg="#2b1a0e"); win.resizable(False, True); apply_combo_style()

    tk.Label(win, text="📜  Rules Editor", font=("Georgia",18,"bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Label(win, text="Define what happens when a puzzle is solved",
             font=("Courier",9), bg="#2b1a0e", fg="#7a5520").pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(6,0))

    form = make_scrollable_form(win)

    # ── Load existing ─────────────────────────────────────────
    section_lbl(form, "— Load Existing Rule —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var,
                            values=list(load_json(JSON_RULES_FILE).keys()),
                            state="readonly", font=("Courier",11))
    load_dd.pack(fill="x", ipady=3)

    # ── Identity ──────────────────────────────────────────────
    section_lbl(form, "— Identity —")
    entries = {}
    add_field(form, "ID", entries)

    # ── Trigger puzzle ────────────────────────────────────────
    section_lbl(form, "— Trigger: When this puzzle is solved —")
    trigger_var   = tk.StringVar(value="")
    trigger_combo = ttk.Combobox(form, textvariable=trigger_var,
                                 values=get_puzzle_names(), font=("Courier",11))
    trigger_combo.pack(fill="x", ipady=3)

    # ── Effects ───────────────────────────────────────────────
    section_lbl(form, "— Effects (up to 8) —")
    tk.Label(form, text="Each effect runs when the trigger puzzle is solved.",
             font=("Courier",9), bg="#2b1a0e", fg="#7a5520").pack(anchor="w")

    effect_rows       = []
    effects_container = tk.Frame(form, bg="#2b1a0e")
    effects_container.pack(fill="x", pady=(6,0))

    def make_effect_row(parent, index):
        row_frame = tk.Frame(parent, bg="#1e0f05", relief="sunken", bd=1)
        row_frame.pack(fill="x", pady=3)
        tk.Label(row_frame, text=f"Effect {index+1}", font=("Georgia",9,"bold italic"),
                 bg="#1e0f05", fg="#f0c040").pack(anchor="w", padx=6, pady=(4,2))

        # Type
        type_frame = tk.Frame(row_frame, bg="#1e0f05"); type_frame.pack(fill="x", padx=6, pady=2)
        tk.Label(type_frame, text="Type", bg="#1e0f05", fg="#c8a060",
                 font=("Georgia",9,"bold")).pack(side="left", padx=(0,6))
        type_var = tk.StringVar(value="")
        type_cb  = ttk.Combobox(type_frame, textvariable=type_var, values=EFFECT_TYPES,
                                font=("Courier",10), width=22, state="readonly")
        type_cb.pack(side="left", fill="x", expand=True)

        # Target
        target_frame = tk.Frame(row_frame, bg="#1e0f05"); target_frame.pack(fill="x", padx=6, pady=2)
        tk.Label(target_frame, text="Target", bg="#1e0f05", fg="#c8a060",
                 font=("Georgia",9,"bold")).pack(side="left", padx=(0,6))
        target_var = tk.StringVar(value="")
        target_cb  = ttk.Combobox(target_frame, textvariable=target_var, values=[],
                                  font=("Courier",10), width=22)
        target_cb.pack(side="left", fill="x", expand=True)

        # Value
        val_frame = tk.Frame(row_frame, bg="#1e0f05"); val_frame.pack(fill="x", padx=6, pady=(2,6))
        tk.Label(val_frame, text="Value", bg="#1e0f05", fg="#c8a060",
                 font=("Georgia",9,"bold")).pack(side="left", padx=(0,6))
        val_var = tk.BooleanVar(value=True)
        tk.Checkbutton(val_frame, text="  True", variable=val_var,
                       font=("Courier",10), bg="#1e0f05", fg="#f0c040",
                       selectcolor="#3d2005", activebackground="#1e0f05",
                       activeforeground="#f0c040").pack(side="left")

        def on_type_change(e=None):
            t = type_var.get()
            if t == "set_puzzle_solved":
                target_cb["values"] = get_puzzle_names()
            elif t == "set_object_visible":
                target_cb["values"] = get_object_names()
            else:
                target_cb["values"] = []
        type_cb.bind("<<ComboboxSelected>>", on_type_change)

        return {"frame": row_frame, "type_var": type_var, "target_var": target_var,
                "val_var": val_var, "target_cb": target_cb}

    for i in range(MAX_EFFECTS):
        effect_rows.append(make_effect_row(effects_container, i))

    # ── Save / Load ───────────────────────────────────────────
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(14,8))
    slbl = status_lbl(form)

    def clear_effects():
        for row in effect_rows:
            row["type_var"].set(""); row["target_var"].set("")
            row["val_var"].set(True); row["target_cb"]["values"] = []

    def on_load(e=None):
        key = load_var.get(); rec = load_json(JSON_RULES_FILE).get(key)
        if not rec: return
        entries["ID"].delete(0,tk.END); entries["ID"].insert(0,rec.get("ID",""))
        trigger_var.set(rec.get("PuzzleName",""))
        clear_effects()
        for i, eff in enumerate(rec.get("Effects",[])[:MAX_EFFECTS]):
            row = effect_rows[i]; t = eff.get("Type","")
            row["type_var"].set(t)
            if t == "set_puzzle_solved":
                row["target_cb"]["values"] = get_puzzle_names()
                row["target_var"].set(eff.get("PuzzleName",""))
            elif t == "set_object_visible":
                row["target_cb"]["values"] = get_object_names()
                row["target_var"].set(eff.get("ObjectName",""))
            row["val_var"].set(eff.get("Value",True))
        slbl.config(text=f"✔  Loaded '{key}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        rule_id = entries["ID"].get().strip()
        if not rule_id:
            messagebox.showwarning("Missing ID","Please enter an ID before saving."); return
        puzzle_trigger = trigger_var.get().strip()
        if not puzzle_trigger:
            messagebox.showwarning("Missing Trigger","Please select a trigger puzzle."); return

        effects = []
        for row in effect_rows:
            t = row["type_var"].get().strip(); target = row["target_var"].get().strip()
            if not t or not target: continue
            eff = {"Type": t, "Value": row["val_var"].get()}
            if t == "set_puzzle_solved":   eff["PuzzleName"] = target
            elif t == "set_object_visible": eff["ObjectName"] = target
            effects.append(eff)

        rule  = {"ID": rule_id, "PuzzleName": puzzle_trigger, "Effects": effects}
        rules = load_json(JSON_RULES_FILE)
        action = "updated" if rule_id in rules else "saved"
        rules[rule_id] = rule
        with open(JSON_RULES_FILE,"w",encoding="utf-8") as f:
            json.dump(rules, f, indent=4, ensure_ascii=False)
        slbl.config(text=f"✔  Rule '{rule_id}' {action}!", fg="#50e878")
        load_dd["values"] = list(load_json(JSON_RULES_FILE).keys())
        trigger_combo["values"] = get_puzzle_names()

    save_btn(form, "💾  Save Rule", on_save)

# ══════════════════════════════════════════════════════════════════════════════
#  Map window
# ══════════════════════════════════════════════════════════════════════════════

def open_map_window():
    screens = load_json(JSON_SCREENS_FILE)
    if not screens:
        messagebox.showinfo("Map","No screens found. Create some screens first."); return
    win = tk.Toplevel(); win.title("🗺️  Adventure Map"); win.geometry("900x700")
    win.configure(bg="#1a0f06"); win.resizable(True,True)
    tk.Label(win, text="🗺️  Adventure Map", font=("Georgia",16,"bold"),
             bg="#1a0f06", fg="#f0c040", pady=10).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0,6))
    toolbar = tk.Frame(win, bg="#1a0f06"); toolbar.pack(fill="x", padx=20, pady=(0,6))
    tk.Label(toolbar, text="Drag rooms to rearrange  •  Scroll to zoom",
             font=("Courier",9), bg="#1a0f06", fg="#7a5520").pack(side="left")
    tk.Button(toolbar, text="⟳ Reset Layout", font=("Georgia",9,"bold"),
              bg="#3d2005", fg="#f0c040", activebackground="#5c3310", activeforeground="#fff",
              relief="raised", bd=2, cursor="hand2",
              command=lambda: redraw(reset=True)).pack(side="right")
    canvas = tk.Canvas(win, bg="#0d0804", highlightthickness=0)
    hbar = ttk.Scrollbar(win, orient="horizontal", command=canvas.xview)
    vbar = ttk.Scrollbar(win, orient="vertical",   command=canvas.yview)
    canvas.configure(xscrollcommand=hbar.set, yscrollcommand=vbar.set)
    hbar.pack(side="bottom", fill="x"); vbar.pack(side="right", fill="y")
    canvas.pack(side="left", fill="both", expand=True)
    BOX_W,BOX_H = 140,50; GAP_X,GAP_Y = 80,80
    STEP_X = BOX_W+GAP_X; STEP_Y = BOX_H+GAP_Y; ORIGIN = (100,100); OBJ_LINE_H = 14
    name_to_rec = {}
    for rid,rec in screens.items():
        nm = rec.get("Name",rid).strip() or rid
        name_to_rec[nm] = rec
    all_names = list(name_to_rec.keys())
    def get_screen_object_labels(rec):
        objects_data = load_json(JSON_OBJECTS_FILE); labels = []
        for slot in ["Object1","Object2","Object3","Object4","Object5","Object6"]:
            obj_name = rec.get(slot,"").strip()
            if not obj_name: continue
            obj_rec = objects_data.get(obj_name,{})
            visible = obj_rec.get("Visible",True)
            labels.append(f"[H] {obj_name}" if not visible else obj_name)
        return labels
    def get_screen_puzzle_labels(rec):
        puzzles_data = load_json(JSON_PUZZLES_FILE); labels = []
        for slot in ["Puzzle1","Puzzle2"]:
            pid = rec.get(slot,"").strip()
            if not pid: continue
            pr = puzzles_data.get(pid,{}); name = pr.get("Name",pid) or pid
            labels.append(f"[S] {name}" if pr.get("Solved",False) else name)
        return labels
    def get_screen_action_labels(rec):
        actions_data = load_json(JSON_ACTIONS_FILE); labels = []
        for slot in ["Action1","Action2","Action3","Action4","Action5","Action6"]:
            act_name = rec.get(slot,"").strip()
            if not act_name: continue
            act_rec = actions_data.get(act_name,{})
            labels.append(act_rec.get("Name",act_name) or act_name)
        return labels
    positions = {}
    def auto_layout():
        positions.clear(); start = all_names[0]
        queue = [(start,0,0)]; visited = set()
        while queue:
            nm,gx,gy = queue.pop(0)
            if nm in visited: continue
            visited.add(nm)
            positions[nm] = [ORIGIN[0]+gx*STEP_X, ORIGIN[1]+gy*STEP_Y]
            rec = name_to_rec.get(nm,{})
            for direction,(nx,ny) in {"North":(gx,gy-1),"South":(gx,gy+1),"West":(gx-1,gy),"East":(gx+1,gy)}.items():
                nb = rec.get(direction,"").strip()
                if nb and nb in name_to_rec and nb not in visited:
                    queue.append((nb,nx,ny))
        placed_y = max((p[1] for p in positions.values()),default=ORIGIN[1]); col=0
        for nm in all_names:
            if nm not in positions:
                positions[nm] = [ORIGIN[0]+col*STEP_X, placed_y+STEP_Y*2]; col+=1
    auto_layout()
    BOX_COLOR="#3d2005"; BOX_OUTLINE="#f0c040"; TEXT_COLOR="#f0c040"
    OBJ_COLOR="#90d8a0"; OBJ_HIDDEN_COLOR="#d08050"
    PUZ_COLOR="#a0c8f0"; PUZ_SOLVED_COLOR="#7a9070"
    ACT_COLOR="#e8b0e0"; DIVIDER_COLOR="#7a5520"; ARROW_COLOR="#c8a060"
    DIR_LABELS={"North":"N","South":"S","East":"E","West":"W"}
    item_map={}
    def total_box_height(nm):
        rec=name_to_rec.get(nm,{})
        obj_l=get_screen_object_labels(rec); puz_l=get_screen_puzzle_labels(rec); act_l=get_screen_action_labels(rec)
        extra=0
        if obj_l: extra+=len(obj_l)*OBJ_LINE_H+6
        if puz_l: extra+=len(puz_l)*OBJ_LINE_H+6
        if act_l: extra+=len(act_l)*OBJ_LINE_H+6
        return BOX_H+extra
    def box_attach(nm,direction):
        cx,cy=positions[nm]; th=total_box_height(nm)
        top=cy-BOX_H//2; bottom=top+th; mid_y=(top+bottom)/2
        if direction=="North": return cx,top
        elif direction=="South": return cx,bottom
        elif direction=="East": return cx+BOX_W//2,mid_y
        elif direction=="West": return cx-BOX_W//2,mid_y
    def redraw(reset=False):
        if reset: auto_layout()
        canvas.delete("all"); item_map.clear()
        OPP={"North":"South","South":"North","East":"West","West":"East"}; OFFSET=5
        def perp_offset(d): return (OFFSET,0) if d in ("North","South") else (0,OFFSET)
        edges=[]
        for nm,rec in name_to_rec.items():
            if nm not in positions: continue
            for d in DIR_LABELS:
                nb=rec.get(d,"").strip()
                if nb and nb in positions: edges.append((nm,nb,d))
        edge_set={(nm,nb,d) for nm,nb,d in edges}
        for nm,nb,d in edges:
            od=OPP[d]; is_bidir=(nb,nm,od) in edge_set
            x1,y1=box_attach(nm,d); x2,y2=box_attach(nb,od)
            if is_bidir:
                pair=tuple(sorted([f"{nm}:{d}",f"{nb}:{od}"])); is_first=f"{nm}:{d}"==pair[0]
                pdx,pdy=perp_offset(d); sign=1 if is_first else -1
                ax1,ay1=x1+pdx*sign,y1+pdy*sign; ax2,ay2=x2+pdx*sign,y2+pdy*sign
            else: ax1,ay1,ax2,ay2=x1,y1,x2,y2
            canvas.create_line(ax1,ay1,ax2,ay2,fill=ARROW_COLOR,width=2,
                               arrow=tk.LAST,arrowshape=(10,12,4),tags="arrow")
            lx=ax1+(ax2-ax1)*0.25; ly=ay1+(ay2-ay1)*0.25
            if d in ("North","South"): lx+=10
            else: ly-=10
            canvas.create_text(lx,ly,text=DIR_LABELS[d],fill="#f0c040",
                               font=("Courier",8,"bold"),tags="arrow")
        for nm in all_names:
            if nm not in positions: continue
            cx,cy=positions[nm]; rec=name_to_rec.get(nm,{})
            obj_l=get_screen_object_labels(rec); puz_l=get_screen_puzzle_labels(rec); act_l=get_screen_action_labels(rec)
            oa=len(obj_l)*OBJ_LINE_H+(6 if obj_l else 0)
            pa=len(puz_l)*OBJ_LINE_H+(6 if puz_l else 0)
            aa=len(act_l)*OBJ_LINE_H+(6 if act_l else 0)
            full_h=BOX_H+oa+pa+aa
            x0=cx-BOX_W//2; y0=cy-BOX_H//2; x1=cx+BOX_W//2
            y1h=cy+BOX_H//2; y1f=y0+full_h
            rect=canvas.create_rectangle(x0,y0,x1,y1f,fill=BOX_COLOR,outline=BOX_OUTLINE,width=2,tags=("box",nm))
            disp=nm if len(nm)<=16 else nm[:15]+"…"
            txt=canvas.create_text(cx,cy,text=disp,fill=TEXT_COLOR,font=("Georgia",9,"bold"),width=BOX_W-8,tags=("box",nm))
            if obj_l or puz_l or act_l:
                canvas.create_line(x0+2,y1h,x1-2,y1h,fill=DIVIDER_COLOR,width=1,tags=("box",nm))
            for i,lbl in enumerate(obj_l):
                oy=y1h+4+i*OBJ_LINE_H+OBJ_LINE_H//2
                color=OBJ_HIDDEN_COLOR if lbl.startswith("[H]") else OBJ_COLOR
                dl=lbl if len(lbl)<=17 else lbl[:16]+"…"
                canvas.create_text(cx,oy,text=dl,fill=color,font=("Courier",8),width=BOX_W-6,tags=("box",nm))
            yps=y1h+oa
            if puz_l:
                canvas.create_line(x0+2,yps,x1-2,yps,fill=DIVIDER_COLOR,width=1,dash=(4,2),tags=("box",nm))
                for i,lbl in enumerate(puz_l):
                    oy=yps+4+i*OBJ_LINE_H+OBJ_LINE_H//2
                    color=PUZ_SOLVED_COLOR if lbl.startswith("[S]") else PUZ_COLOR
                    dl=lbl if len(lbl)<=17 else lbl[:16]+"…"
                    canvas.create_text(cx,oy,text=dl,fill=color,font=("Courier",8,"italic"),width=BOX_W-6,tags=("box",nm))
            yas=y1h+oa+pa
            if act_l:
                canvas.create_line(x0+2,yas,x1-2,yas,fill=DIVIDER_COLOR,width=1,dash=(2,3),tags=("box",nm))
                for i,lbl in enumerate(act_l):
                    oy=yas+4+i*OBJ_LINE_H+OBJ_LINE_H//2
                    dl=lbl if len(lbl)<=17 else lbl[:16]+"…"
                    canvas.create_text(cx,oy,text=dl,fill=ACT_COLOR,font=("Courier",8),width=BOX_W-6,tags=("box",nm))
            item_map[nm]={"rect":rect,"text":txt,"total_h":full_h}
        canvas.configure(scrollregion=canvas.bbox("all") or (0,0,900,700))
    redraw()
    drag_state={"name":None,"ox":0,"oy":0}
    def on_press(event):
        cx=canvas.canvasx(event.x); cy=canvas.canvasy(event.y)
        for nm,ids in item_map.items():
            items=canvas.find_overlapping(cx-1,cy-1,cx+1,cy+1)
            if ids["rect"] in items or ids["text"] in items:
                drag_state.update({"name":nm,"ox":cx,"oy":cy}); break
    def on_drag(event):
        nm=drag_state["name"]
        if not nm: return
        cx=canvas.canvasx(event.x); cy=canvas.canvasy(event.y)
        dx,dy=cx-drag_state["ox"],cy-drag_state["oy"]
        drag_state["ox"],drag_state["oy"]=cx,cy
        positions[nm][0]+=dx; positions[nm][1]+=dy; redraw()
    def on_release(event): drag_state["name"]=None
    def on_zoom(event):
        factor=1.1 if event.delta>0 else 0.9
        cx=canvas.canvasx(event.x); cy=canvas.canvasy(event.y)
        canvas.scale("all",cx,cy,factor,factor); canvas.configure(scrollregion=canvas.bbox("all"))
    canvas.bind("<ButtonPress-1>",on_press); canvas.bind("<B1-Motion>",on_drag)
    canvas.bind("<ButtonRelease-1>",on_release); canvas.bind("<MouseWheel>",on_zoom)

# ══════════════════════════════════════════════════════════════════════════════
#  Dispatch
# ══════════════════════════════════════════════════════════════════════════════

def open_play_window():
    # ── load all data ──────────────────────────────────────────
    screens  = load_json(JSON_SCREENS_FILE)
    objects  = load_json(JSON_OBJECTS_FILE)
    puzzles  = load_json(JSON_PUZZLES_FILE)
    actions  = load_json(JSON_ACTIONS_FILE)
    rules    = load_json(JSON_RULES_FILE)

    if not screens:
        messagebox.showerror("Play", "No screens found. Create some screens first.")
        return

    # ── game state ────────────────────────────────────────────
    # puzzle_solved: { puzzle_name -> bool }  (all start False)
    puzzle_solved = { rec["Name"]: False for rec in puzzles.values() if rec.get("Name") }

    # object_visible: { object_name -> bool }  (from JSON Visible flag)
    object_visible = { name: bool(rec.get("Visible", False)) for name, rec in objects.items() }

    # current_screen_id starts at "0"
    state = {"screen_id": "0", "pending": None}  # pending: "action" | "object" | None
    state["selected_action"] = None

    # ── init action_rules.json with "mirar" rule if not present ──
    action_rules = load_json(ACTION_RULES_FILE)
    if "mirar" not in action_rules:
        action_rules["mirar"] = {
            "Action":   "mirar",
            "Behavior": "print_object_description"
        }
        with open(ACTION_RULES_FILE, "w", encoding="utf-8") as f:
            json.dump(action_rules, f, indent=4, ensure_ascii=False)

    # ── window ────────────────────────────────────────────────
    win = tk.Toplevel()
    win.title("▶  Play Adventure")
    win.geometry("700x820")
    win.configure(bg=BG)
    win.resizable(True, True)

    tk.Label(win, text="⚔  Adventure  ⚔", font=("Georgia", 16, "bold"),
             bg=BG, fg=FG_GOLD, pady=10).pack()
    tk.Frame(win, bg="#3d2005", height=2).pack(fill="x", padx=20)

    # ── scrollable output area ────────────────────────────────
    out_frame = tk.Frame(win, bg=BG)
    out_frame.pack(fill="both", expand=True, padx=14, pady=(8, 0))

    out_text = tk.Text(
        out_frame,
        bg=BG, fg=FG_WHITE,
        font=FONT_MONO,
        wrap="word",
        state="disabled",
        relief="flat",
        bd=0,
        cursor="arrow",
        spacing1=2, spacing3=2,
    )
    out_scroll = ttk.Scrollbar(out_frame, orient="vertical", command=out_text.yview)
    out_text.configure(yscrollcommand=out_scroll.set)
    out_scroll.pack(side="right", fill="y")
    out_text.pack(side="left", fill="both", expand=True)

    # colour tags
    out_text.tag_configure("gold",   foreground=FG_GOLD)
    out_text.tag_configure("green",  foreground=FG_GREEN)
    out_text.tag_configure("blue",   foreground=FG_BLUE)
    out_text.tag_configure("orange", foreground=FG_ORANGE)
    out_text.tag_configure("dim",    foreground=FG_DIM)
    out_text.tag_configure("red",    foreground=FG_RED)
    out_text.tag_configure("white",  foreground=FG_WHITE)
    out_text.tag_configure("ascii",  foreground=FG_GREEN,
                           font=("Courier New", 10))
    out_text.tag_configure("bold",   foreground=FG_GOLD,
                           font=("Georgia", 11, "bold"))

    # ── button row ────────────────────────────────────────────
    btn_frame = tk.Frame(win, bg=BG, pady=6)
    btn_frame.pack(fill="x", padx=14)

    # Dynamic action/object buttons (rebuilt each turn)
    choice_frame = tk.Frame(win, bg=BG, pady=4)
    choice_frame.pack(fill="x", padx=14)

    tk.Frame(win, bg="#3d2005", height=2).pack(fill="x", padx=20, pady=(4, 0))
    status_bar = tk.Label(win, text="", font=("Courier New", 9),
                          bg="#1a0f06", fg=FG_DIM, anchor="w", padx=8)
    status_bar.pack(fill="x", side="bottom")

    def set_status(msg):
        status_bar.config(text=msg)

    # ── output helpers ────────────────────────────────────────
    def println(text="", tag="white"):
        out_text.config(state="normal")
        out_text.insert(tk.END, text + "\n", tag)
        out_text.config(state="disabled")
        out_text.see(tk.END)

    def print_divider(char="─", color="dim"):
        println(char * 54, color)

    def clear_choices():
        for w in choice_frame.winfo_children():
            w.destroy()

    # ── apply acs_rules effects ───────────────────────────────
    def apply_rules_for_puzzle(puzzle_name):
        for rule in rules.values():
            if rule.get("PuzzleName") == puzzle_name:
                for eff in rule.get("Effects", []):
                    t = eff.get("Type")
                    if t == "set_puzzle_solved":
                        pn = eff.get("PuzzleName")
                        if pn in puzzle_solved:
                            puzzle_solved[pn] = eff.get("Value", True)
                            println(f"  ✔ Puzzle '{pn}' marcado como resuelto.", "green")
                    elif t == "set_object_visible":
                        on = eff.get("ObjectName")
                        if on in object_visible:
                            object_visible[on] = eff.get("Value", True)
                            v = "visible" if eff.get("Value", True) else "oculto"
                            println(f"  ✔ Objeto '{on}' ahora es {v}.", "green")

    # ── get screen record ─────────────────────────────────────
    def current_screen():
        return screens.get(state["screen_id"], {})

    def screen_actions(rec):
        """Return list of action names assigned to this screen (non-empty)."""
        result = []
        for slot in ["Action1","Action2","Action3","Action4","Action5","Action6"]:
            a = rec.get(slot, "").strip()
            if a:
                result.append(a)
        return result

    def screen_visible_objects(rec):
        """Return list of object names in screen that are currently visible."""
        result = []
        for slot in ["Object1","Object2","Object3","Object4","Object5","Object6"]:
            o = rec.get(slot, "").strip()
            if o and object_visible.get(o, False):
                result.append(o)
        return result

    def screen_puzzles(rec):
        """Return list of puzzle Names (strings) assigned to this screen."""
        result = []
        for slot in ["Puzzle1", "Puzzle2"]:
            pname = rec.get(slot, "").strip()
            if pname:
                result.append(pname)
        return result

    # ── render current screen ─────────────────────────────────
    def render_screen():
        clear_choices()
        rec = current_screen()

        print_divider("═", "gold")
        println(f"  📍 {rec.get('Name', '???')}", "gold")
        print_divider("═", "gold")

        # ASCII art
        ascii_art = rec.get("AsciiDrawing", "").strip()
        if ascii_art:
            println()
            for line in ascii_art.split("\n"):
                println(line, "ascii")
            println()

        # Description
        println(rec.get("Description", ""), "white")
        println()

        # Puzzle descriptions
        puz_names = screen_puzzles(rec)
        if puz_names:
            print_divider()
            for pname in puz_names:
                solved = puzzle_solved.get(pname, False)
                # find puzzle record by Name
                puz_rec = next((p for p in puzzles.values() if p.get("Name") == pname), None)
                if puz_rec:
                    desc = puz_rec.get("DescriptionSolved" if solved else "DescriptionNotSolved", "")
                    tag  = "green" if solved else "orange"
                    prefix = "✔" if solved else "•"
                    println(f"  {prefix} {desc}", tag)
            println()

        # Actions
        print_divider()
        println("  ¿Qué hacés?", "blue")
        act_names = screen_actions(rec)
        letters = "abcdefghijklmnopqrstuvwxyz"
        for i, aname in enumerate(act_names):
            println(f"    {letters[i]})  {aname}", "gold")
        println()

        set_status(f"Pantalla: {rec.get('Name','')}  |  Elegí una acción")

        # Render action buttons
        for i, aname in enumerate(act_names):
            lbl = f"{letters[i]}) {aname}"
            tk.Button(
                choice_frame, text=lbl,
                font=FONT_MONO_SM, width=12,
                bg="#3d2005", fg=FG_GOLD,
                activebackground="#5c3310", activeforeground="#ffffff",
                relief="raised", bd=2, cursor="hand2",
                command=lambda a=aname: on_action_selected(a)
            ).pack(side="left", padx=4)

    # ── action selected ───────────────────────────────────────
    def on_action_selected(action_name):
        state["selected_action"] = action_name
        println(f"> {action_name}", "blue")
        println()

        rec = current_screen()
        vis_objs = screen_visible_objects(rec)

        if not vis_objs:
            println("  No hay objetos visibles aquí.", "dim")
            println()
            render_screen()
            return

        # Show visible objects
        print_divider()
        println("  Objetos disponibles:", "blue")
        letters = "abcdefghijklmnopqrstuvwxyz"
        for i, oname in enumerate(vis_objs):
            println(f"    {letters[i]})  {oname}", "white")
        println()
        set_status(f"Acción: {action_name}  |  Elegí un objeto")

        clear_choices()
        for i, oname in enumerate(vis_objs):
            lbl = f"{letters[i]}) {oname}"
            tk.Button(
                choice_frame, text=lbl,
                font=FONT_MONO_SM, width=14,
                bg="#1e3a1e", fg=FG_GREEN,
                activebackground="#2a5a2a", activeforeground="#ffffff",
                relief="raised", bd=2, cursor="hand2",
                command=lambda o=oname: on_object_selected(o)
            ).pack(side="left", padx=4)

    # ── object selected ───────────────────────────────────────
    def on_object_selected(object_name):
        action_name = state["selected_action"]
        println(f"> {object_name}", "green")
        println()

        # Load action_rules to check behavior
        action_rules = load_json(ACTION_RULES_FILE)
        rule = action_rules.get(action_name)

        if rule and rule.get("Behavior") == "print_object_description":
            # mirar — describe the object
            obj_rec = objects.get(object_name, {})
            desc    = obj_rec.get("Description", "(sin descripción)")
            println(f"mirar  {object_name}", "blue")
            println(f"  {desc}", "white")
            println()

        else:
            # For now any other action: no rule defined yet
            println(f"  (No hay regla definida para '{action_name}' con '{object_name}')", "dim")
            println()

        print_divider()
        println()

        # Re-render the screen for the next turn
        render_screen()

    # ── restart / new game ────────────────────────────────────
    def restart():
        out_text.config(state="normal")
        out_text.delete("1.0", tk.END)
        out_text.config(state="disabled")
        state["screen_id"] = "0"
        state["selected_action"] = None
        for k in puzzle_solved: puzzle_solved[k] = False
        for k in object_visible:
            object_visible[k] = bool(objects[k].get("Visible", False))
        render_screen()

    tk.Button(btn_frame, text="⟳  Nueva partida", font=("Georgia", 10, "bold"),
              bg="#3d2005", fg=FG_GOLD, activebackground="#5c3310",
              activeforeground="#ffffff", relief="raised", bd=2,
              cursor="hand2", command=restart).pack(side="left", padx=4)

    # ── start ─────────────────────────────────────────────────
    render_screen()
def open_window(title):
    dispatch = {
        "Objects": open_objects_window,
        "Screens": open_screens_window,
        "Actions": open_actions_window,
        "Puzzles": open_puzzles_window,
        "Rules":   open_rules_window,
        "Map":     open_map_window,
        "Play":    open_play_window,
    }
    if title in dispatch:
        dispatch[title](); return
    win=tk.Toplevel(); win.title(title); win.geometry("400x300"); win.configure(bg="#2b1a0e")
    tk.Label(win,text=title,font=("Georgia",18,"bold"),bg="#2b1a0e",fg="#f0c040",pady=20).pack()
    tk.Label(win,text=f"Adventure Construction Set\n— {title} Editor —",
             font=("Courier",11),bg="#2b1a0e",fg="#c8a060",justify="center").pack(expand=True)

# ══════════════════════════════════════════════════════════════════════════════
#  Main window
# ══════════════════════════════════════════════════════════════════════════════

def main():
    root=tk.Tk(); root.title("Adventure Construction Set")
    root.geometry("850x200"); root.configure(bg="#1a0f06"); root.resizable(False,False)
    tk.Label(root,text="⚔  Adventure Construction Set  ⚔",
             font=("Georgia",14,"bold"),bg="#1a0f06",fg="#f0c040",pady=12).pack()
    tk.Frame(root,bg="#7a5520",height=2).pack(fill="x",padx=20)
    btn_frame=tk.Frame(root,bg="#1a0f06",pady=15); btn_frame.pack()
    for icon,section in zip(ICONS,SECTIONS):
        tk.Button(btn_frame,text=f"{icon}\n{section}",font=("Georgia",10,"bold"),
                  width=8,height=3,bg="#3d2005",fg="#f0c040",
                  activebackground="#5c3310",activeforeground="#ffffff",
                  relief="raised",bd=3,cursor="hand2",
                  command=lambda s=section: open_window(s)).pack(side="left",padx=8)
    root.mainloop()

if __name__ == "__main__":
    main()


# ══════════════════════════════════════════════════════════════════════════════
#  Play window  — Demo game engine
# ══════════════════════════════════════════════════════════════════════════════
#
#  action_rules.json  (created/updated by this window):
#  {
#    "mirar": {
#      "Action": "mirar",
#      "Behavior": "print_object_description"
#    }
#  }

