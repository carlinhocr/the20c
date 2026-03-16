import json
import os
import subprocess
import sys
import tkinter as tk
from tkinter import messagebox, scrolledtext, ttk

JSON_SCREENS_FILE  = "acs_screens.json"
JSON_ACTIONS_FILE  = "acs_actions.json"
JSON_PUZZLES_FILE  = "acs_puzzles.json"
JSON_SENSORS_FILE  = "acs_sensors.json"

SECTIONS = ["Puzzles", "Screens", "Actions", "Sensors", "Map"]
ICONS    = ["🧩",      "🖥️",      "⚡",       "📡",       "🗺️"]

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

def get_sensor_names():
    sensors = load_json(JSON_SENSORS_FILE)
    ordered = sorted(sensors.values(), key=lambda r: int(r.get("ID", 0)))
    return [""] + [r.get("Name", r.get("ID", "")) for r in ordered]


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
    s.configure("TCombobox", fieldbackground="#000000", background="#000000",
                foreground="#f0c040", selectbackground="#5c3310",
                selectforeground="#ffffff", arrowcolor="#f0c040")
    s.map("TCombobox",
          fieldbackground=[("readonly", "#000000"), ("disabled", "#000000")],
          background=[("readonly", "#000000"), ("disabled", "#000000")],
          foreground=[("readonly", "#f0c040"), ("disabled", "#7a5520")],
          selectbackground=[("readonly", "#5c3310")],
          selectforeground=[("readonly", "#ffffff")])


# ══════════════════════════════════════════════════════════════════════════════
#  Actions window
# ══════════════════════════════════════════════════════════════════════════════

def open_actions_window():
    win = tk.Toplevel()
    win.title("Actions")
    win.geometry("420x740")
    win.configure(bg="#2b1a0e")
    win.resizable(False, True)
    apply_combo_style()

    tk.Label(win, text="⚡  Actions Editor", font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 0))

    form = make_scrollable_form(win)

    entries = {}
    combo_vars    = {}
    combo_widgets = {}

    # ── Load existing ─────────────────────────────────────────
    def action_names_by_id():
        actions = load_json(JSON_ACTIONS_FILE)
        ordered = sorted(actions.values(), key=lambda r: int(r.get("ID", 0)))
        return [r.get("Name", r.get("ID", "")) for r in ordered]

    section_lbl(form, "— Load Existing Action —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var,
                            values=action_names_by_id(),
                            state="readonly", font=("Courier", 11))
    load_dd.pack(fill="x", ipady=3)

    # ── Identity ──────────────────────────────────────────────
    section_lbl(form, "— Identity —")
    fields = ["ID", "Name"]
    for f in fields:
        add_field(form, f, entries)

    # ── Sensor (combo from acs_sensors.json) ──────────────────
    section_lbl(form, "— Sensor —")
    add_combo(form, "Sensor", get_sensor_names(), combo_vars, combo_widgets)
    sensor_id_var = tk.StringVar(value="")
    sensor_id_row = tk.Frame(form, bg="#2b1a0e")
    sensor_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(sensor_id_row, text="Sensor ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(sensor_id_row, textvariable=sensor_id_var,
             bg="#2b1a0e", fg="#50e878", font=("Courier", 11)).pack(side="left", padx=(6, 0))

    def refresh_sensor_id(*_):
        name = combo_vars["Sensor"].get().strip()
        if not name:
            sensor_id_var.set("")
            return
        sensors = load_json(JSON_SENSORS_FILE)
        for rec in sensors.values():
            if rec.get("Name", "").strip() == name:
                sensor_id_var.set(rec.get("ID", "?"))
                return
        sensor_id_var.set("?")

    combo_vars["Sensor"].trace_add("write", refresh_sensor_id)

    sensor_active_var = tk.BooleanVar(value=False)
    checkbox_widget(form, "Set Sensor Active (On)", sensor_active_var)

    # ── Screen (combo from acs_screens.json) ──────────────────
    section_lbl(form, "— Screen —")
    add_combo(form, "Screen", get_screen_names(), combo_vars, combo_widgets)
    action_screen_id_var = tk.StringVar(value="")
    screen_id_row = tk.Frame(form, bg="#2b1a0e")
    screen_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(screen_id_row, text="Screen ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(screen_id_row, textvariable=action_screen_id_var,
             bg="#2b1a0e", fg="#50e878", font=("Courier", 11)).pack(side="left", padx=(6, 0))

    def refresh_action_screen_id(*_):
        name = combo_vars["Screen"].get().strip()
        if not name:
            action_screen_id_var.set("")
            return
        screens = load_json(JSON_SCREENS_FILE)
        for rec in screens.values():
            if rec.get("Name", "").strip() == name:
                action_screen_id_var.set(rec.get("ID", "?"))
                return
        action_screen_id_var.set("?")

    combo_vars["Screen"].trace_add("write", refresh_action_screen_id)

    # ── Cost field (numeric 0–256) ────────────────────────────
    section_lbl(form, "— Cost —")
    cost_var = tk.IntVar(value=0)
    cost_spin = tk.Spinbox(
        form, from_=0, to=256, textvariable=cost_var, width=6,
        bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
        buttonbackground="#3d2005", relief="sunken", bd=2,
        font=("Courier", 11), justify="left",
    )
    cost_spin.pack(anchor="w", ipady=4)

    # ── Description text area ─────────────────────────────────
    section_lbl(form, "— Description —")
    desc_text = tk.Text(
        form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
        relief="sunken", bd=2, font=("Courier", 11), height=5, wrap="word",
    )
    desc_text.pack(fill="x")

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(14, 8))
    slbl = status_lbl(form)

    def on_load(e=None):
        name = load_var.get()
        actions = load_json(JSON_ACTIONS_FILE)
        rec = next((r for r in actions.values() if r.get("Name", "") == name), None)
        if not rec:
            return
        for f in fields:
            entries[f].delete(0, tk.END)
            entries[f].insert(0, rec.get(f, ""))
        combo_vars["Sensor"].set("")
        stored_sid = rec.get("SensorID", 255)
        try:
            stored_sid = int(stored_sid)
        except (ValueError, TypeError):
            stored_sid = 255
        if stored_sid != 255:
            sensors = load_json(JSON_SENSORS_FILE)
            for srec in sensors.values():
                try:
                    if int(srec.get("ID", -1)) == stored_sid:
                        combo_vars["Sensor"].set(srec.get("Name", ""))
                        break
                except (ValueError, TypeError):
                    pass
        sensor_active_var.set(rec.get("SensorActive", False))
        combo_vars["Screen"].set("")
        stored_scr_id = rec.get("ScreenID", 255)
        try:
            stored_scr_id = int(stored_scr_id)
        except (ValueError, TypeError):
            stored_scr_id = 255
        if stored_scr_id != 255:
            screens = load_json(JSON_SCREENS_FILE)
            for srec in screens.values():
                try:
                    if int(srec.get("ID", -1)) == stored_scr_id:
                        combo_vars["Screen"].set(srec.get("Name", ""))
                        break
                except (ValueError, TypeError):
                    pass
        try:
            cost_var.set(int(rec.get("Cost", 0)))
        except (ValueError, TypeError):
            cost_var.set(0)
        desc_text.delete("1.0", tk.END)
        desc_text.insert("1.0", rec.get("Description", ""))
        slbl.config(text=f"✔  Loaded '{name}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        data = {f: entries[f].get() for f in fields}
        sensor_name = combo_vars["Sensor"].get().strip()
        sensor_id_num = 255
        if sensor_name:
            try:
                sensor_id_num = int(sensor_id_var.get())
            except (ValueError, TypeError):
                sensor_id_num = 255
        data["SensorID"]     = sensor_id_num
        data["SensorActive"] = sensor_active_var.get()
        screen_name = combo_vars["Screen"].get().strip()
        screen_id_num = 255
        if screen_name:
            try:
                screen_id_num = int(action_screen_id_var.get())
            except (ValueError, TypeError):
                screen_id_num = 255
        data["ScreenID"] = screen_id_num
        try:
            cost_val = int(cost_var.get())
            cost_val = max(0, min(256, cost_val))
        except (ValueError, TypeError):
            cost_val = 0
        data["Cost"]        = cost_val
        data["Description"] = desc_text.get("1.0", "end-1c")
        save_to_json(JSON_ACTIONS_FILE, "ID", data, slbl)
        load_dd["values"] = action_names_by_id()
        combo_widgets["Sensor"]["values"] = get_sensor_names()
        combo_widgets["Screen"]["values"] = get_screen_names()

    save_btn(form, "💾  Save Action", on_save)


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
    def puzzle_names_by_id():
        puzzles = load_json(JSON_PUZZLES_FILE)
        ordered = sorted(puzzles.values(), key=lambda r: int(r.get("ID", 0)))
        return [r.get("Name", r.get("ID", "")) for r in ordered]

    section_lbl(form, "— Load Existing Puzzle —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var,
                            values=puzzle_names_by_id(),
                            state="readonly", font=("Courier", 11))
    load_dd.pack(fill="x", ipady=3)

    # ── Identity ──────────────────────────────────────────────
    section_lbl(form, "— Identity —")
    for f in ["ID", "Name"]:
        add_field(form, f, entries)

    # ── Action (combo from acs_actions.json) ──────────────────
    section_lbl(form, "— Action —")
    add_combo(form, "Action", get_action_names(), combo_vars, combo_widgets)

    # ── Screen (combo from acs_screens.json) ──────────────────
    section_lbl(form, "— Screen —")
    add_combo(form, "Screen", get_screen_names(), combo_vars, combo_widgets)
    screen_id_var = tk.StringVar(value="")
    screen_id_row = tk.Frame(form, bg="#2b1a0e")
    screen_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(screen_id_row, text="Screen ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(screen_id_row, textvariable=screen_id_var,
             bg="#2b1a0e", fg="#50e878", font=("Courier", 11)).pack(side="left", padx=(6, 0))

    def refresh_screen_id(*_):
        name = combo_vars["Screen"].get().strip()
        if not name:
            screen_id_var.set("")
            return
        screens = load_json(JSON_SCREENS_FILE)
        for rec in screens.values():
            if rec.get("Name", "").strip() == name:
                screen_id_var.set(rec.get("ID", "?"))
                return
        screen_id_var.set("?")

    combo_vars["Screen"].trace_add("write", refresh_screen_id)

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
        name = load_var.get()
        puzzles = load_json(JSON_PUZZLES_FILE)
        rec = next((r for r in puzzles.values() if r.get("Name", "") == name), None)
        if not rec:
            return
        for f in ["ID", "Name"]:
            entries[f].delete(0, tk.END)
            entries[f].insert(0, rec.get(f, ""))
        combo_vars["Action"].set(rec.get("Action", ""))
        combo_vars["Screen"].set(rec.get("Screen", ""))
        desc_solved.delete("1.0", tk.END)
        desc_solved.insert("1.0", rec.get("DescriptionSolved", ""))
        desc_not_solved.delete("1.0", tk.END)
        desc_not_solved.insert("1.0", rec.get("DescriptionNotSolved", ""))
        solved_var.set(rec.get("Solved", False))
        slbl.config(text=f"✔  Loaded '{name}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        data = {f: entries[f].get() for f in entries}
        data["Action"]               = combo_vars["Action"].get()
        data["Screen"]               = combo_vars["Screen"].get()
        data["ScreenID"]             = screen_id_var.get()
        data["DescriptionSolved"]    = desc_solved.get("1.0", "end-1c")
        data["DescriptionNotSolved"] = desc_not_solved.get("1.0", "end-1c")
        data["Solved"]               = solved_var.get()
        save_to_json(JSON_PUZZLES_FILE, "ID", data, slbl)
        load_dd["values"] = puzzle_names_by_id()
        # refresh action combo in case new actions were added
        combo_widgets["Action"]["values"]  = get_action_names()
        combo_widgets["Screen"]["values"]  = get_screen_names()

    save_btn(form, "💾  Save Puzzle", on_save)


# ══════════════════════════════════════════════════════════════════════════════
#  Screens window
# ══════════════════════════════════════════════════════════════════════════════

def open_screens_window():
    win = tk.Toplevel()
    win.title("Screens")
    win.geometry("740x700")
    win.configure(bg="#2b1a0e")
    win.resizable(True, True)
    apply_combo_style()

    tk.Label(win, text="🖥️  Screens Editor", font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 0))

    form = make_scrollable_form(win)

    entries       = {}
    exit_vars     = {}
    exit_combos   = {}
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
                        relief="sunken", bd=2, font=("Courier", 11), height=4, wrap="none", width=80)
    desc_text.pack(fill="x")

    tk.Label(form, text="FlashlightOn", **LABEL_STYLE).pack(fill="x", pady=(8, 2))
    flashlight_on_text = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                                 relief="sunken", bd=2, font=("Courier", 11), height=4, wrap="none", width=80)
    flashlight_on_text.pack(fill="x")

    tk.Label(form, text="FlashlightOff", **LABEL_STYLE).pack(fill="x", pady=(8, 2))
    flashlight_off_text = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                                  relief="sunken", bd=2, font=("Courier", 11), height=4, wrap="none", width=80)
    flashlight_off_text.pack(fill="x")

    # ── ASCII Drawing ─────────────────────────────────────────
    section_lbl(form, "— ASCII Drawing —")
    tk.Label(form, text="AsciiDrawing", **LABEL_STYLE).pack(fill="x", pady=(0, 2))
    ascii_text = tk.Text(form, bg="#1e0f05", fg="#50e878", insertbackground="#50e878",
                         relief="sunken", bd=2, font=("Courier New", 11), height=7, wrap="none", width=80)
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
        for p, v in puzzle_vars.items():
            v.set(rec.get(p, ""))
        for a, v in action_vars.items():
            v.set(rec.get(a, ""))
        desc_text.delete("1.0", tk.END)
        desc_text.insert("1.0", rec.get("Description", ""))
        flashlight_on_text.delete("1.0", tk.END)
        flashlight_on_text.insert("1.0", rec.get("FlashlightOn", ""))
        flashlight_off_text.delete("1.0", tk.END)
        flashlight_off_text.insert("1.0", rec.get("FlashlightOff", ""))
        ascii_text.delete("1.0", tk.END)
        ascii_text.insert("1.0", rec.get("AsciiDrawing", ""))
        slbl.config(text=f"✔  Loaded '{nm}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load_screen)

    def on_save():
        data = {f: entries[f].get() for f in entries}
        for d, v in exit_vars.items():
            data[d] = v.get()
        for p, v in puzzle_vars.items():
            data[p] = v.get()
        for a, v in action_vars.items():
            data[a] = v.get()
        data["Description"]   = desc_text.get("1.0", "end-1c")
        data["FlashlightOn"]  = flashlight_on_text.get("1.0", "end-1c")
        data["FlashlightOff"] = flashlight_off_text.get("1.0", "end-1c")
        data["AsciiDrawing"]  = ascii_text.get("1.0", "end-1c")
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

    def get_screen_action_labels(rec):
        """Return a list of action Name strings for actions assigned to a screen record."""
        actions_data = load_json(JSON_ACTIONS_FILE)
        labels = []
        for slot in ["Action1", "Action2", "Action3", "Action4", "Action5", "Action6"]:
            act_name = rec.get(slot, "").strip()
            if not act_name:
                continue
            # Look up display name from actions file (fall back to the stored name itself)
            act_rec = actions_data.get(act_name, {})
            name = act_rec.get("Name", act_name) or act_name
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
    PUZ_COLOR        = "#a0c8f0"
    PUZ_SOLVED_COLOR = "#7a9070"
    ACT_COLOR        = "#e8b0e0"
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
        """Compute total rendered height of a room box including puzzle and action lines."""
        rec = name_to_rec.get(nm, {})
        puz_labels = get_screen_puzzle_labels(rec)
        act_labels = get_screen_action_labels(rec)
        extra = 0
        if puz_labels:
            extra += len(puz_labels) * OBJ_LINE_H + 6
        if act_labels:
            extra += len(act_labels) * OBJ_LINE_H + 6
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
            puz_labels = get_screen_puzzle_labels(rec)
            act_labels = get_screen_action_labels(rec)

            # Compute full box height
            puz_area_h = len(puz_labels) * OBJ_LINE_H + (6 if puz_labels else 0)
            act_area_h = len(act_labels) * OBJ_LINE_H + (6 if act_labels else 0)
            full_h = BOX_H + puz_area_h + act_area_h

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

            # Divider line between header and content area
            if puz_labels or act_labels:
                canvas.create_line(
                    x0 + 2, y1_header,
                    x1 - 2, y1_header,
                    fill=DIVIDER_COLOR, width=1,
                    tags=("box", nm)
                )

            # Puzzle section
            y1_puz_start = y1_header
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

            # Action section
            y1_act_start = y1_header + puz_area_h
            if act_labels:
                # Divider before actions (dotted)
                canvas.create_line(
                    x0 + 2, y1_act_start,
                    x1 - 2, y1_act_start,
                    fill=DIVIDER_COLOR, width=1, dash=(2, 3),
                    tags=("box", nm)
                )
                for i, lbl in enumerate(act_labels):
                    oy = y1_act_start + 4 + i * OBJ_LINE_H + OBJ_LINE_H // 2
                    max_chars = 17
                    display_lbl = lbl if len(lbl) <= max_chars else lbl[:max_chars - 1] + "…"
                    canvas.create_text(
                        cx, oy,
                        text=display_lbl,
                        fill=ACT_COLOR,
                        font=("Courier", 8),
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
#  Sensors window
# ══════════════════════════════════════════════════════════════════════════════

def open_sensors_window():
    win = tk.Toplevel()
    win.title("Sensors")
    win.geometry("740x660")
    win.configure(bg="#2b1a0e")
    win.resizable(True, True)
    apply_combo_style()

    tk.Label(win, text="📡  Sensors Editor", font=("Georgia", 18, "bold"),
             bg="#2b1a0e", fg="#f0c040", pady=16).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20, pady=(0, 0))

    form = make_scrollable_form(win)

    entries = {}

    # ── Load existing ─────────────────────────────────────────
    def sensor_names_by_id():
        sensors = load_json(JSON_SENSORS_FILE)
        ordered = sorted(sensors.values(), key=lambda r: int(r.get("ID", 0)))
        return [r.get("Name", r.get("ID", "")) for r in ordered]

    section_lbl(form, "— Load Existing Sensor —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var,
                            values=sensor_names_by_id(),
                            state="readonly", font=("Courier", 11))
    load_dd.pack(fill="x", ipady=3)

    # ── Identity ──────────────────────────────────────────────
    section_lbl(form, "— Identity —")
    for f in ["ID", "Name"]:
        add_field(form, f, entries)

    # ── State ─────────────────────────────────────────────────
    section_lbl(form, "— State —")
    active_var = tk.BooleanVar(value=False)
    checkbox_widget(form, "Active (On)", active_var)

    # ── Dialogs ───────────────────────────────────────────────
    section_lbl(form, "— Dialogs —")
    tk.Label(form, text="DialogOn  (sensor is active)", **LABEL_STYLE).pack(fill="x", pady=(0, 2))
    dialog_on_text = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                             relief="sunken", bd=2, font=("Courier", 11), height=4,
                             wrap="none", width=80)
    dialog_on_text.pack(fill="x")

    tk.Label(form, text="DialogOff  (sensor is inactive)", **LABEL_STYLE).pack(fill="x", pady=(8, 2))
    dialog_off_text = tk.Text(form, bg="#1e0f05", fg="#f0c040", insertbackground="#f0c040",
                              relief="sunken", bd=2, font=("Courier", 11), height=4,
                              wrap="none", width=80)
    dialog_off_text.pack(fill="x")

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7a5520", height=2).pack(fill="x", pady=(14, 8))
    slbl = status_lbl(form)

    def on_load(e=None):
        name = load_var.get()
        sensors = load_json(JSON_SENSORS_FILE)
        rec = next((r for r in sensors.values() if r.get("Name", "") == name), None)
        if not rec:
            return
        for f in ["ID", "Name"]:
            entries[f].delete(0, tk.END)
            entries[f].insert(0, rec.get(f, ""))
        active_var.set(rec.get("Active", False))
        dialog_on_text.delete("1.0", tk.END)
        dialog_on_text.insert("1.0", rec.get("DialogOn", ""))
        dialog_off_text.delete("1.0", tk.END)
        dialog_off_text.insert("1.0", rec.get("DialogOff", ""))
        slbl.config(text=f"✔  Loaded '{name}'", fg="#c8a060")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        data = {f: entries[f].get() for f in ["ID", "Name"]}
        data["Active"]    = active_var.get()
        data["DialogOn"]  = dialog_on_text.get("1.0", "end-1c")
        data["DialogOff"] = dialog_off_text.get("1.0", "end-1c")
        save_to_json(JSON_SENSORS_FILE, "ID", data, slbl)
        load_dd["values"] = sensor_names_by_id()

    save_btn(form, "💾  Save Sensor", on_save)


# ══════════════════════════════════════════════════════════════════════════════
#  Run Parsers
# ══════════════════════════════════════════════════════════════════════════════

PARSER_SCRIPTS = [
    ("acs_parser_sensors.py",  "📡  Sensors"),
    ("acs_parser_actions.py",  "⚡  Actions"),
    ("acs_parser_puzzles.py",  "🧩  Puzzles"),
    ("acs_parser_screens.py",  "🖥️  Screens"),
]


def run_parsers():
    """Run all 4 parser scripts and show a results window."""
    win = tk.Toplevel()
    win.title("Run Parsers")
    win.geometry("640x480")
    win.configure(bg="#1a0f06")
    win.resizable(True, True)

    tk.Label(win, text="⚙  Parser Output", font=("Georgia", 14, "bold"),
             bg="#1a0f06", fg="#f0c040", pady=10).pack()
    tk.Frame(win, bg="#7a5520", height=2).pack(fill="x", padx=20)

    log = scrolledtext.ScrolledText(
        win, bg="#0d0603", fg="#50e878", font=("Courier", 10),
        relief="sunken", bd=2, state="disabled", wrap="word"
    )
    log.pack(fill="both", expand=True, padx=16, pady=12)

    status_lbl = tk.Label(win, text="", font=("Courier", 10, "bold"),
                          bg="#1a0f06", fg="#f0c040", pady=6)
    status_lbl.pack()

    def append(text, tag=None):
        log.configure(state="normal")
        log.insert("end", text)
        log.see("end")
        log.configure(state="disabled")

    base_dir = os.path.dirname(os.path.abspath(__file__))
    errors   = []

    for script_name, label in PARSER_SCRIPTS:
        script_path = os.path.join(base_dir, script_name)
        append(f"\n{'─'*50}\n▶  Running {label} parser…\n{'─'*50}\n")
        win.update()

        if not os.path.exists(script_path):
            msg = f"[ERROR] '{script_name}' not found next to acs_main.py\n"
            append(msg)
            errors.append(label)
            continue

        try:
            result = subprocess.run(
                [sys.executable, script_path],
                capture_output=True, text=True,
                cwd=base_dir, timeout=30
            )
            if result.stdout:
                append(result.stdout)
            if result.stderr:
                append(f"[STDERR]\n{result.stderr}")
            if result.returncode != 0:
                errors.append(label)
        except subprocess.TimeoutExpired:
            append(f"[ERROR] {label} parser timed out.\n")
            errors.append(label)
        except Exception as exc:
            append(f"[ERROR] {exc}\n")
            errors.append(label)

    append(f"\n{'═'*50}\n")
    if errors:
        status_lbl.config(
            text=f"⚠  Finished with errors in: {', '.join(errors)}",
            fg="#ff6060"
        )
        append(f"⚠  Completed — errors in: {', '.join(errors)}\n")
    else:
        status_lbl.config(text="✔  All parsers completed successfully!", fg="#50e878")
        append("✔  All parsers completed successfully!\n")

    tk.Button(win, text="Close", font=("Georgia", 10, "bold"),
              bg="#3d2005", fg="#f0c040", activebackground="#5c3310",
              activeforeground="#ffffff", relief="raised", bd=3,
              cursor="hand2", padx=12, pady=4,
              command=win.destroy).pack(pady=(0, 12))


# ══════════════════════════════════════════════════════════════════════════════
#  Dispatch
# ══════════════════════════════════════════════════════════════════════════════

def open_window(title):
    dispatch = {
        "Screens": open_screens_window,
        "Actions": open_actions_window,
        "Puzzles": open_puzzles_window,
        "Sensors": open_sensors_window,
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
    root.geometry("610x260")
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

    # ── Run Parsers button ────────────────────────────────────
    tk.Frame(root, bg="#7a5520", height=1).pack(fill="x", padx=20)
    tk.Button(root, text="⚙  Run Parsers", font=("Georgia", 11, "bold"),
              bg="#0d2b0d", fg="#50e878",
              activebackground="#1a4d1a", activeforeground="#ffffff",
              relief="raised", bd=3, cursor="hand2",
              padx=20, pady=6, command=run_parsers).pack(pady=10)

    root.mainloop()


if __name__ == "__main__":
    main()