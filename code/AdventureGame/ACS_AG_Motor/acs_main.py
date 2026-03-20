import json
import os
import subprocess
import sys
import tkinter as tk
from tkinter import messagebox, scrolledtext, ttk

JSON_SCREENS_FILE    = "acs_screens.json"
JSON_ACTIONS_FILE    = "acs_actions.json"
JSON_PUZZLES_FILE    = "acs_puzzles.json"
JSON_SENSORS_FILE    = "acs_sensors.json"
JSON_DASHBOARD_FILE  = "acs_dashboard.json"

SECTIONS = ["Screens", "Actions", "Sensors", "Map Actions", "Dashboard"]
ICONS    = ["🖥️",      "⚡",       "📡",       "🔀",          "📊"]

FIELD_STYLE = {
    "bg": "#2E2270", "fg": "#FFFFFF", "insertbackground": "#FFFFFF",
    "relief": "sunken", "bd": 2, "font": ("Courier New", 11),
}
LABEL_STYLE = {
    "bg": "#40318D", "fg": "#FFFFFF",
    "font": ("Courier New", 10, "bold"), "anchor": "w",
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
    ordered = sorted(screens.values(), key=lambda r: int(r.get("ID", 0)))
    names = [r.get("Name", r.get("ID", "")) for r in ordered if r.get("Name","").strip() or r.get("ID","")]
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
    canvas    = tk.Canvas(win, bg="#40318D", highlightthickness=0)
    scrollbar = ttk.Scrollbar(win, orient="vertical", command=canvas.yview)
    canvas.configure(yscrollcommand=scrollbar.set)
    scrollbar.pack(side="right", fill="y")
    canvas.pack(side="left", fill="both", expand=True)

    form        = tk.Frame(canvas, bg="#40318D", padx=28)
    form_window = canvas.create_window((0, 0), window=form, anchor="nw")

    form.bind("<Configure>",   lambda e: canvas.configure(scrollregion=canvas.bbox("all")))
    canvas.bind("<Configure>", lambda e: canvas.itemconfig(form_window, width=e.width))
    canvas.bind_all("<MouseWheel>",
                    lambda e: canvas.yview_scroll(int(-1*(e.delta/120)), "units"))
    return form


def section_lbl(parent, text):
    tk.Label(parent, text=text, font=("Courier New", 11, "bold italic"),
             bg="#40318D", fg="#FFFFFF").pack(fill="x", pady=(14, 4))


def add_field(parent, label, entries):
    tk.Label(parent, text=label, **LABEL_STYLE).pack(fill="x", pady=(4, 1))
    e = tk.Entry(parent, **FIELD_STYLE)
    e.pack(fill="x", ipady=4)
    entries[label] = e


def add_combo(parent, label, values, store_vars, store_combos):
    tk.Label(parent, text=label, **LABEL_STYLE).pack(fill="x", pady=(4, 1))
    var = tk.StringVar(value="")
    cb  = ttk.Combobox(parent, textvariable=var, values=values,
                       font=("Courier New", 11))
    cb.pack(fill="x", ipady=3)
    store_vars[label]   = var
    store_combos[label] = cb


def add_grid_combos(parent, field_list, values_fn, store_vars, store_combos):
    """Add a row of comboboxes in a grid, values populated from values_fn()."""
    values = values_fn()
    for i, field in enumerate(field_list):
        col_frame = tk.Frame(parent, bg="#40318D")
        col_frame.grid(row=0, column=i, padx=4, sticky="ew")
        parent.columnconfigure(i, weight=1)
        tk.Label(col_frame, text=field, **LABEL_STYLE).pack(fill="x", pady=(0, 2))
        var = tk.StringVar(value="")
        cb  = ttk.Combobox(col_frame, textvariable=var, values=values,
                           font=("Courier New", 10), width=9)
        cb.pack(fill="x", ipady=3)
        store_vars[field]   = var
        store_combos[field] = cb


def save_btn(parent, text, cmd):
    tk.Button(parent, text=text, font=("Courier New", 11, "bold"),
              bg="#7869C4", fg="#000000", activebackground="#A09BE0",
              activeforeground="#000000", relief="raised", bd=3,
              cursor="hand2", padx=16, pady=6, command=cmd).pack(pady=(0, 20))


def status_lbl(parent):
    lbl = tk.Label(parent, text="", font=("Courier New", 9), bg="#40318D", fg="#50e878")
    lbl.pack(pady=(0, 4))
    return lbl


def checkbox_widget(parent, text, var):
    tk.Checkbutton(parent, text=f"  {text}", variable=var,
                   font=("Courier New", 10, "bold"), bg="#40318D", fg="#A09BE0",
                   selectcolor="#2E2270", activebackground="#40318D",
                   activeforeground="#FFFFFF", cursor="hand2").pack(anchor="w", padx=28, pady=(4, 2))


def apply_combo_style():
    s = ttk.Style()
    s.theme_use("default")
    s.configure("TCombobox", fieldbackground="#2E2270", background="#2E2270",
                foreground="#FFFFFF", selectbackground="#7869C4",
                selectforeground="#FFFFFF", arrowcolor="#FFFFFF")
    s.map("TCombobox",
          fieldbackground=[("readonly", "#2E2270"), ("disabled", "#2E2270")],
          background=[("readonly", "#2E2270"), ("disabled", "#2E2270")],
          foreground=[("readonly", "#FFFFFF"), ("disabled", "#7869C4")],
          selectbackground=[("readonly", "#7869C4")],
          selectforeground=[("readonly", "#FFFFFF")])
    # Style the dropdown popup listbox
    root = s.master
    root.option_add("*TCombobox*Listbox.background", "#2E2270")
    root.option_add("*TCombobox*Listbox.foreground", "#FFFFFF")
    root.option_add("*TCombobox*Listbox.selectBackground", "#7869C4")
    root.option_add("*TCombobox*Listbox.selectForeground", "#FFFFFF")
    root.option_add("*TCombobox*Listbox.font", "{{Courier New}} 11")


# ══════════════════════════════════════════════════════════════════════════════
#  Actions window
# ══════════════════════════════════════════════════════════════════════════════

def open_actions_window():
    win = tk.Toplevel()
    win.title("Actions")
    win.geometry("420x740")
    win.configure(bg="#40318D")
    win.resizable(False, True)
    apply_combo_style()

    tk.Label(win, text="⚡  Actions Editor", font=("Courier New", 18, "bold"),
             bg="#40318D", fg="#FFFFFF", pady=16).pack()
    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x", padx=20, pady=(0, 0))

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
                            state="readonly", font=("Courier New", 11))
    load_dd.pack(fill="x", ipady=3)

    # ── New Action button ─────────────────────────────────────
    def on_new_action():
        acts = load_json(JSON_ACTIONS_FILE)
        if acts:
            max_id = max(int(rec.get("ID", 0)) for rec in acts.values())
        else:
            max_id = -1
        new_id = str(max_id + 1)
        for f in fields:
            entries[f].delete(0, tk.END)
        entries["ID"].insert(0, new_id)
        combo_vars["Sensor"].set("")
        sensor_active_var.set(False)
        combo_vars["Screen"].set("")
        cost_var.set(0)
        enemy_prob_var.set(0)
        reset_enemy_prob_var.set(0)
        death_prob_var.set(0)
        desc_text.delete("1.0", tk.END)
        desc_failed_text.delete("1.0", tk.END)
        hide_water_var.set(0)
        hide_fear_var.set(0)
        hide_flashlight_var.set(0)
        slbl.config(text=f"✔  New action (ID {new_id}) — fill in details and save", fg="#50e878")

    tk.Button(form, text="✚  New Action", font=("Courier New", 11, "bold"),
              bg="#7869C4", fg="#000000", activebackground="#A09BE0",
              activeforeground="#000000", relief="raised", bd=3,
              cursor="hand2", padx=16, pady=4, command=on_new_action).pack(fill="x", pady=(6, 0))

    # ── Identity ──────────────────────────────────────────────
    section_lbl(form, "— Identity —")
    fields = ["ID", "Name"]
    for f in fields:
        add_field(form, f, entries)

    # ── Sensor (combo from acs_sensors.json) ──────────────────
    section_lbl(form, "— Sensor —")
    add_combo(form, "Sensor", get_sensor_names(), combo_vars, combo_widgets)
    sensor_id_var = tk.StringVar(value="")
    sensor_id_row = tk.Frame(form, bg="#40318D")
    sensor_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(sensor_id_row, text="Sensor ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(sensor_id_row, textvariable=sensor_id_var,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

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
    screen_id_row = tk.Frame(form, bg="#40318D")
    screen_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(screen_id_row, text="Screen ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(screen_id_row, textvariable=action_screen_id_var,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

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
        bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
        buttonbackground="#7869C4", relief="sunken", bd=2,
        font=("Courier New", 11), justify="left",
    )
    cost_spin.pack(anchor="w", ipady=4)

    # ── Enemy Probability slider (0–255) ──────────────────────
    section_lbl(form, "— Enemy Probability —")
    enemy_prob_var = tk.IntVar(value=0)
    enemy_prob_row = tk.Frame(form, bg="#40318D")
    enemy_prob_row.pack(fill="x")
    enemy_prob_slider = tk.Scale(
        enemy_prob_row, from_=0, to=255, orient="horizontal",
        variable=enemy_prob_var, bg="#40318D", fg="#FFFFFF",
        troughcolor="#2E2270", highlightthickness=0,
        activebackground="#7869C4", font=("Courier New", 9),
        length=300, sliderlength=16,
    )
    enemy_prob_slider.pack(side="left", fill="x", expand=True)
    tk.Label(enemy_prob_row, textvariable=enemy_prob_var, width=4,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))
    reset_enemy_prob_var = tk.IntVar(value=0)
    checkbox_widget(form, "Reset Enemy Probability", reset_enemy_prob_var)

    # ── Death Probability slider (0–255) ──────────────────────
    section_lbl(form, "— Death Probability —")
    death_prob_var = tk.IntVar(value=0)
    death_prob_row = tk.Frame(form, bg="#40318D")
    death_prob_row.pack(fill="x")
    death_prob_slider = tk.Scale(
        death_prob_row, from_=0, to=255, orient="horizontal",
        variable=death_prob_var, bg="#40318D", fg="#FFFFFF",
        troughcolor="#2E2270", highlightthickness=0,
        activebackground="#7869C4", font=("Courier New", 9),
        length=300, sliderlength=16,
    )
    death_prob_slider.pack(side="left", fill="x", expand=True)
    tk.Label(death_prob_row, textvariable=death_prob_var, width=4,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

    # ── Visibility conditions ────────────────────────────────
    section_lbl(form, "— Visibility Conditions —")
    hide_water_var      = tk.IntVar(value=0)
    hide_fear_var       = tk.IntVar(value=0)
    hide_flashlight_var = tk.IntVar(value=0)
    checkbox_widget(form, "Hide on Water Level High",   hide_water_var)
    checkbox_widget(form, "Hide on Fear Level High",    hide_fear_var)
    checkbox_widget(form, "Hide with Flashlight Off",   hide_flashlight_var)

    # ── Description text area ─────────────────────────────────
    section_lbl(form, "— Description —")
    desc_text = tk.Text(
        form, bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
        relief="sunken", bd=2, font=("Courier New", 11), height=5, wrap="word",
    )
    desc_text.pack(fill="x")

    # ── Description Action Failed text area ───────────────────
    section_lbl(form, "— Description Action Failed —")
    desc_failed_text = tk.Text(
        form, bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
        relief="sunken", bd=2, font=("Courier New", 11), height=5, wrap="word",
    )
    desc_failed_text.pack(fill="x")

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7869C4", height=2).pack(fill="x", pady=(14, 8))
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
        try:
            enemy_prob_var.set(int(rec.get("EnemyProbability", 0)))
        except (ValueError, TypeError):
            enemy_prob_var.set(0)
        reset_enemy_prob_var.set(int(rec.get("ResetEnemyProbability", 0)))
        try:
            death_prob_var.set(int(rec.get("DeathProbability", 0)))
        except (ValueError, TypeError):
            death_prob_var.set(0)
        desc_text.delete("1.0", tk.END)
        desc_text.insert("1.0", rec.get("Description", ""))
        desc_failed_text.delete("1.0", tk.END)
        desc_failed_text.insert("1.0", rec.get("DescriptionActionFailed", ""))
        hide_water_var.set(int(rec.get("HideOnWaterLevelHigh", 0)))
        hide_fear_var.set(int(rec.get("HideOnFearLevelHigh", 0)))
        hide_flashlight_var.set(int(rec.get("HideWithFlashlightOff", 0)))
        slbl.config(text=f"✔  Loaded '{name}'", fg="#A09BE0")

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
        data["Cost"]              = cost_val
        data["EnemyProbability"]       = max(0, min(255, enemy_prob_var.get()))
        data["ResetEnemyProbability"]  = reset_enemy_prob_var.get()
        data["DeathProbability"]       = max(0, min(255, death_prob_var.get()))
        data["Description"] = desc_text.get("1.0", "end-1c")
        data["DescriptionActionFailed"] = desc_failed_text.get("1.0", "end-1c")
        data["HideOnWaterLevelHigh"]  = hide_water_var.get()
        data["HideOnFearLevelHigh"]   = hide_fear_var.get()
        data["HideWithFlashlightOff"] = hide_flashlight_var.get()
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
    win.configure(bg="#40318D")
    win.resizable(False, True)
    apply_combo_style()

    tk.Label(win, text="🧩  Puzzles Editor", font=("Courier New", 18, "bold"),
             bg="#40318D", fg="#FFFFFF", pady=16).pack()
    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x", padx=20, pady=(0, 0))

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
                            state="readonly", font=("Courier New", 11))
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
    screen_id_row = tk.Frame(form, bg="#40318D")
    screen_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(screen_id_row, text="Screen ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(screen_id_row, textvariable=screen_id_var,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

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
    desc_solved = tk.Text(form, bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
                          relief="sunken", bd=2, font=("Courier New", 11), height=3, wrap="word")
    desc_solved.pack(fill="x")

    tk.Label(form, text="DescriptionNotSolved", **LABEL_STYLE).pack(fill="x", pady=(8, 2))
    desc_not_solved = tk.Text(form, bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
                              relief="sunken", bd=2, font=("Courier New", 11), height=3, wrap="word")
    desc_not_solved.pack(fill="x")

    # ── Solved checkbox ───────────────────────────────────────
    section_lbl(form, "— Status —")
    solved_var = tk.BooleanVar()
    checkbox_widget(form, "Solved", solved_var)

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7869C4", height=2).pack(fill="x", pady=(14, 8))
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
        slbl.config(text=f"✔  Loaded '{name}'", fg="#A09BE0")

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
    win.configure(bg="#40318D")
    win.resizable(True, True)
    apply_combo_style()

    tk.Label(win, text="🖥️  Screens Editor", font=("Courier New", 18, "bold"),
             bg="#40318D", fg="#FFFFFF", pady=16).pack()
    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x", padx=20, pady=(0, 0))

    form = make_scrollable_form(win)

    entries       = {}
    action_vars   = {}
    action_combos = {}

    # ── Load existing screen ──────────────────────────────────
    def screen_names_by_id():
        scr = load_json(JSON_SCREENS_FILE)
        ordered = sorted(scr.values(), key=lambda r: int(r.get("ID", 0)))
        return [r.get("Name", r.get("ID", "")) for r in ordered if r.get("Name","").strip() or r.get("ID","")]

    section_lbl(form, "— Load Existing Screen —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var,
                            values=screen_names_by_id(),
                            state="readonly", font=("Courier New", 11))
    load_dd.pack(fill="x", ipady=3)

    # ── New Screen button ─────────────────────────────────────
    def on_new_screen():
        scr = load_json(JSON_SCREENS_FILE)
        if scr:
            max_id = max(int(rec.get("ID", 0)) for rec in scr.values())
        else:
            max_id = -1
        new_id = str(max_id + 1)
        # Clear all fields
        for f in list(entries.keys()):
            entries[f].delete(0, tk.END)
        entries["ID"].insert(0, new_id)
        entries["Name"].insert(0, "")
        for a, v in action_vars.items():
            v.set("")
        desc_text.delete("1.0", tk.END)
        flashlight_on_text.delete("1.0", tk.END)
        flashlight_off_text.delete("1.0", tk.END)
        ascii_text.delete("1.0", tk.END)
        screen_enemy_prob_var.set(0)
        is_secret_var.set(0)
        is_end_var.set(0)
        slbl.config(text=f"✔  New screen (ID {new_id}) — fill in details and save", fg="#50e878")

    tk.Button(form, text="✚  New Screen", font=("Courier New", 11, "bold"),
              bg="#7869C4", fg="#000000", activebackground="#A09BE0",
              activeforeground="#000000", relief="raised", bd=3,
              cursor="hand2", padx=16, pady=4, command=on_new_screen).pack(fill="x", pady=(6, 0))

    tk.Frame(form, bg="#7869C4", height=2).pack(fill="x", pady=(10, 0))

    # ── Identity ─────────────────────────────────────────────
    section_lbl(form, "— Identity —")
    add_field(form, "ID",   entries)
    add_field(form, "Name", entries)

    # ── Actions (4 total) ─────────────────────────────────────
    section_lbl(form, "— Actions in Screen —")
    act_frame1 = tk.Frame(form, bg="#40318D")
    act_frame1.pack(fill="x")
    add_grid_combos(act_frame1, ["Action1", "Action2", "Action3", "Action4"],
                    get_action_names, action_vars, action_combos)

    # ── Description ──────────────────────────────────────────
    section_lbl(form, "— Description —")
    tk.Label(form, text="Description", **LABEL_STYLE).pack(fill="x", pady=(0, 2))
    desc_text = tk.Text(form, bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
                        relief="sunken", bd=2, font=("Courier New", 11), height=4, wrap="none", width=80)
    desc_text.pack(fill="x")

    tk.Label(form, text="FlashlightOn", **LABEL_STYLE).pack(fill="x", pady=(8, 2))
    flashlight_on_text = tk.Text(form, bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
                                 relief="sunken", bd=2, font=("Courier New", 11), height=4, wrap="none", width=80)
    flashlight_on_text.pack(fill="x")

    tk.Label(form, text="FlashlightOff", **LABEL_STYLE).pack(fill="x", pady=(8, 2))
    flashlight_off_text = tk.Text(form, bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
                                  relief="sunken", bd=2, font=("Courier New", 11), height=4, wrap="none", width=80)
    flashlight_off_text.pack(fill="x")

    # ── Enemy Probability slider (0–255) ──────────────────────
    section_lbl(form, "— Enemy Probability —")
    screen_enemy_prob_var = tk.IntVar(value=0)
    screen_enemy_prob_row = tk.Frame(form, bg="#40318D")
    screen_enemy_prob_row.pack(fill="x")
    screen_enemy_prob_slider = tk.Scale(
        screen_enemy_prob_row, from_=0, to=255, orient="horizontal",
        variable=screen_enemy_prob_var, bg="#40318D", fg="#FFFFFF",
        troughcolor="#2E2270", highlightthickness=0,
        activebackground="#7869C4", font=("Courier New", 9),
        length=300, sliderlength=16,
    )
    screen_enemy_prob_slider.pack(side="left", fill="x", expand=True)
    tk.Label(screen_enemy_prob_row, textvariable=screen_enemy_prob_var, width=4,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

    # ── Screen Flags ──────────────────────────────────────────
    section_lbl(form, "— Screen Flags —")
    is_secret_var = tk.IntVar(value=0)
    is_end_var    = tk.IntVar(value=0)
    checkbox_widget(form, "IsSecretScreen", is_secret_var)
    checkbox_widget(form, "IsEndScreen",    is_end_var)

    # ── ASCII Drawing ─────────────────────────────────────────
    section_lbl(form, "— ASCII Drawing —")
    tk.Label(form, text="AsciiDrawing", **LABEL_STYLE).pack(fill="x", pady=(0, 2))
    ascii_text = tk.Text(form, bg="#2E2270", fg="#50e878", insertbackground="#50e878",
                         relief="sunken", bd=2, font=("Courier New", 11), height=7, wrap="none", width=80)
    ascii_text.pack(fill="x")

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7869C4", height=2).pack(fill="x", pady=(18, 8))
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
        try:
            screen_enemy_prob_var.set(int(rec.get("EnemyProbability", 0)))
        except (ValueError, TypeError):
            screen_enemy_prob_var.set(0)
        is_secret_var.set(int(rec.get("IsSecretScreen", 0)))
        is_end_var.set(int(rec.get("IsEndScreen", 0)))
        slbl.config(text=f"✔  Loaded '{nm}'", fg="#A09BE0")

    load_dd.bind("<<ComboboxSelected>>", on_load_screen)

    def on_save():
        data = {f: entries[f].get() for f in entries}
        for a, v in action_vars.items():
            data[a] = v.get()
        data["Description"]   = desc_text.get("1.0", "end-1c")
        data["FlashlightOn"]  = flashlight_on_text.get("1.0", "end-1c")
        data["FlashlightOff"] = flashlight_off_text.get("1.0", "end-1c")
        data["AsciiDrawing"]  = ascii_text.get("1.0", "end-1c")
        data["EnemyProbability"] = max(0, min(255, screen_enemy_prob_var.get()))
        data["IsSecretScreen"]   = is_secret_var.get()
        data["IsEndScreen"]      = is_end_var.get()
        save_to_json(JSON_SCREENS_FILE, "ID", data, slbl)
        updated = screen_names_by_id()
        load_dd["values"] = updated
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
    win.configure(bg="#352880")
    win.resizable(True, True)

    tk.Label(win, text="🗺️  Adventure Map", font=("Courier New", 16, "bold"),
             bg="#352880", fg="#FFFFFF", pady=10).pack()
    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x", padx=20, pady=(0, 6))

    # ── Toolbar ───────────────────────────────────────────────
    toolbar = tk.Frame(win, bg="#352880")
    toolbar.pack(fill="x", padx=20, pady=(0, 6))
    tk.Label(toolbar, text="Drag rooms to rearrange  •  Scroll to zoom",
             font=("Courier New", 9), bg="#352880", fg="#7869C4").pack(side="left")
    tk.Button(toolbar, text="⟳ Reset Layout", font=("Courier New", 9, "bold"),
              bg="#7869C4", fg="#000000", activebackground="#A09BE0",
              activeforeground="#000000", relief="raised", bd=2, cursor="hand2",
              command=lambda: redraw(reset=True)).pack(side="right")

    # ── Canvas ────────────────────────────────────────────────
    canvas = tk.Canvas(win, bg="#1A1452", highlightthickness=0)
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
    BOX_COLOR        = "#2E2270"
    BOX_OUTLINE      = "#7869C4"
    TEXT_COLOR       = "#FFFFFF"
    PUZ_COLOR        = "#a0c8f0"
    PUZ_SOLVED_COLOR = "#7a9070"
    ACT_COLOR        = "#e8b0e0"
    DIVIDER_COLOR    = "#7869C4"
    ARROW_COLOR      = "#A09BE0"
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
                               fill="#FFFFFF", font=("Courier New", 8, "bold"),
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
                font=("Courier New", 9, "bold"),
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
                        font=("Courier New", 8, "italic"),
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
                        font=("Courier New", 8),
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
    win.configure(bg="#40318D")
    win.resizable(True, True)
    apply_combo_style()

    tk.Label(win, text="📡  Sensors Editor", font=("Courier New", 18, "bold"),
             bg="#40318D", fg="#FFFFFF", pady=16).pack()
    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x", padx=20, pady=(0, 0))

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
                            state="readonly", font=("Courier New", 11))
    load_dd.pack(fill="x", ipady=3)

    # ── New Sensor button ─────────────────────────────────────
    def on_new_sensor():
        sens = load_json(JSON_SENSORS_FILE)
        if sens:
            max_id = max(int(rec.get("ID", 0)) for rec in sens.values())
        else:
            max_id = -1
        new_id = str(max_id + 1)
        for f in ["ID", "Name"]:
            entries[f].delete(0, tk.END)
        entries["ID"].insert(0, new_id)
        active_var.set(False)
        dialog_on_text.delete("1.0", tk.END)
        dialog_off_text.delete("1.0", tk.END)
        slbl.config(text=f"✔  New sensor (ID {new_id}) — fill in details and save", fg="#50e878")

    tk.Button(form, text="✚  New Sensor", font=("Courier New", 11, "bold"),
              bg="#7869C4", fg="#000000", activebackground="#A09BE0",
              activeforeground="#000000", relief="raised", bd=3,
              cursor="hand2", padx=16, pady=4, command=on_new_sensor).pack(fill="x", pady=(6, 0))

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
    dialog_on_text = tk.Text(form, bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
                             relief="sunken", bd=2, font=("Courier New", 11), height=4,
                             wrap="none", width=80)
    dialog_on_text.pack(fill="x")

    tk.Label(form, text="DialogOff  (sensor is inactive)", **LABEL_STYLE).pack(fill="x", pady=(8, 2))
    dialog_off_text = tk.Text(form, bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
                              relief="sunken", bd=2, font=("Courier New", 11), height=4,
                              wrap="none", width=80)
    dialog_off_text.pack(fill="x")

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7869C4", height=2).pack(fill="x", pady=(14, 8))
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
        slbl.config(text=f"✔  Loaded '{name}'", fg="#A09BE0")

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
    ("acs_parser_sensors.py",          "📡  Sensors"),
    ("acs_parser_actions.py",          "⚡  Actions"),
    ("acs_parser_screens.py",          "🖥️  Screens"),
    ("acs_parser_dashboard.py", "📊  Dashboard"),
]


def run_parsers():
    """Run all 4 parser scripts and show a results window."""
    win = tk.Toplevel()
    win.title("Run Parsers")
    win.geometry("640x480")
    win.configure(bg="#352880")
    win.resizable(True, True)

    tk.Label(win, text="⚙  Parser Output", font=("Courier New", 14, "bold"),
             bg="#352880", fg="#FFFFFF", pady=10).pack()
    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x", padx=20)

    log = scrolledtext.ScrolledText(
        win, bg="#1A1452", fg="#50e878", font=("Courier New", 10),
        relief="sunken", bd=2, state="disabled", wrap="word"
    )
    log.pack(fill="both", expand=True, padx=16, pady=12)

    status_lbl = tk.Label(win, text="", font=("Courier New", 10, "bold"),
                          bg="#352880", fg="#FFFFFF", pady=6)
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

    tk.Button(win, text="Close", font=("Courier New", 10, "bold"),
              bg="#7869C4", fg="#000000", activebackground="#A09BE0",
              activeforeground="#000000", relief="raised", bd=3,
              cursor="hand2", padx=12, pady=4,
              command=win.destroy).pack(pady=(0, 12))


# ══════════════════════════════════════════════════════════════════════════════
#  Map Actions window
#  Shows screens as nodes; edges = actions that link screen → screen via ScreenID
# ══════════════════════════════════════════════════════════════════════════════

def open_map_actions_window():
    from collections import defaultdict

    screens = load_json(JSON_SCREENS_FILE)
    actions = load_json(JSON_ACTIONS_FILE)
    sensors = load_json(JSON_SENSORS_FILE)

    if not screens:
        messagebox.showinfo("Map Actions", "No screens found. Create some screens first.")
        return

    # ── Lookup tables ─────────────────────────────────────────
    id_to_screen_name = { str(rec.get("ID","")): rec.get("Name", f"Screen{rid}")
                          for rid, rec in screens.items() }
    screen_name_to_id = { v: k for k, v in id_to_screen_name.items() }

    # sensor id → sensor record
    sensor_by_id = { str(rec.get("ID","")): rec for rec in sensors.values() }

    # action name → action record
    action_by_name = { rec.get("Name","").strip(): rec
                       for rec in actions.values() if rec.get("Name","").strip() }

    all_screen_names = list(id_to_screen_name.values())

    # ── Per-screen action info ────────────────────────────────
    # screen_name → [ {name, dst_name, sensor_name, sensor_active, has_link} ]
    screen_action_rows = {}
    edges = []   # (src_name, dst_name, action_name)

    for rid, srec in screens.items():
        src_name = srec.get("Name", f"Screen{rid}")
        rows = []
        for slot in ["Action1","Action2","Action3","Action4","Action5","Action6"]:
            aname = srec.get(slot, "").strip()
            if not aname:
                continue
            arec = action_by_name.get(aname, {})

            # Destination screen
            dst_id = arec.get("ScreenID", 255)
            try:
                dst_id = int(dst_id)
            except (ValueError, TypeError):
                dst_id = 255
            dst_name = id_to_screen_name.get(str(dst_id)) if dst_id != 255 else None
            if dst_name and dst_name != src_name:
                edges.append((src_name, dst_name, aname))

            # Sensor info
            sid = arec.get("SensorID", 255)
            try:
                sid = int(sid)
            except (ValueError, TypeError):
                sid = 255
            srec2 = sensor_by_id.get(str(sid)) if sid != 255 else None
            sensor_name   = srec2.get("Name", f"S{sid}") if srec2 else None
            sensor_active = arec.get("SensorActive", False)

            rows.append({
                "name":          aname,
                "dst_name":      dst_name,
                "sensor_name":   sensor_name,
                "sensor_active": sensor_active,
            })
        screen_action_rows[src_name] = rows

    # ── Window ────────────────────────────────────────────────
    win = tk.Toplevel()
    win.title("🔀  Map Actions")
    win.geometry("1100x780")
    win.configure(bg="#352880")
    win.resizable(True, True)

    tk.Label(win, text="🔀  Map Actions  —  Screens · Actions · Sensors",
             font=("Courier New", 15, "bold"), bg="#352880", fg="#FFFFFF", pady=10).pack()
    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x", padx=20, pady=(0, 4))

    # ── Toolbar ───────────────────────────────────────────────
    toolbar = tk.Frame(win, bg="#352880")
    toolbar.pack(fill="x", padx=20, pady=(0, 2))
    tk.Label(toolbar, text="Drag nodes  •  Scroll to zoom  •  Arrows = transitions",
             font=("Courier New", 9), bg="#352880", fg="#7869C4").pack(side="left")
    tk.Button(toolbar, text="⟳ Reset Layout", font=("Courier New", 9, "bold"),
              bg="#7869C4", fg="#000000", activebackground="#A09BE0",
              activeforeground="#000000", relief="raised", bd=2, cursor="hand2",
              command=lambda: redraw(reset=True)).pack(side="right")

    # ── Legend ────────────────────────────────────────────────
    legend = tk.Frame(win, bg="#352880")
    legend.pack(fill="x", padx=24, pady=(0, 3))
    for color, label in [
        ("#FFFFFF", "Screen header"),
        ("#50b8e0", "→ transition arrow"),
        ("#c8f050", "Sensor ON"),
        ("#e05050", "Sensor OFF"),
        ("#7a9070", "No sensor"),
        ("#e08040", "→ Dest. screen"),
    ]:
        tk.Label(legend, text=f"■  {label}", font=("Courier New", 8),
                 bg="#352880", fg=color).pack(side="left", padx=8)

    # ── Canvas ────────────────────────────────────────────────
    canvas = tk.Canvas(win, bg="#1A1452", highlightthickness=0)
    hbar = ttk.Scrollbar(win, orient="horizontal", command=canvas.xview)
    vbar = ttk.Scrollbar(win, orient="vertical",   command=canvas.yview)
    canvas.configure(xscrollcommand=hbar.set, yscrollcommand=vbar.set)
    hbar.pack(side="bottom", fill="x")
    vbar.pack(side="right",  fill="y")
    canvas.pack(side="left", fill="both", expand=True)

    # ── Layout / size constants ───────────────────────────────
    BOX_W      = 280   # node width
    HDR_H      = 36    # header (screen name) height
    ROW_H      = 20    # height per action row
    ROW_PAD    = 6     # padding below last row
    GAP_X      = 200
    GAP_Y      = 70
    ORIGIN     = (60, 60)

    # Colours
    C_HDR_BG   = "#2E2270"
    C_HDR_OUT  = "#7869C4"
    C_HDR_TXT  = "#FFFFFF"
    C_BODY_BG  = "#1A1452"
    C_DIV      = "#7869C4"
    C_ACT_TXT  = "#A09BE0"        # action name
    C_DST_TXT  = "#e08040"        # → destination
    C_SEN_ON   = "#c8f050"        # sensor active
    C_SEN_OFF  = "#e05050"        # sensor inactive
    C_SEN_NONE = "#7a9070"        # no sensor
    C_ARROW    = "#A09BE0"
    C_ARR_LBL  = "#e08040"

    # ── Compute total height of a node ────────────────────────
    def node_height(nm):
        rows = screen_action_rows.get(nm, [])
        return HDR_H + len(rows) * ROW_H + ROW_PAD

    # ── positions: screen_name → [left_x, top_y]  (top-left corner) ──
    positions = {}

    def auto_layout():
        positions.clear()
        cols = max(1, int(len(all_screen_names) ** 0.5 + 0.99))
        # compute row heights to space vertically
        row_heights = {}
        for i, nm in enumerate(all_screen_names):
            row = i // cols
            row_heights[row] = max(row_heights.get(row, 0), node_height(nm))

        col_x = [ORIGIN[0] + c * (BOX_W + GAP_X) for c in range(cols)]
        row_y = []
        y = ORIGIN[1]
        for r in sorted(row_heights):
            row_y.append(y)
            y += row_heights[r] + GAP_Y

        for i, nm in enumerate(all_screen_names):
            col = i % cols
            row = i // cols
            positions[nm] = [col_x[col], row_y[row] if row < len(row_y) else ORIGIN[1]]

    auto_layout()

    # item_map: screen_name → {rect_hdr, rect_body, all_ids:[...]}
    item_map = {}

    # ── Tooltip ───────────────────────────────────────────────
    tip_win = [None]

    def show_tip(event, text):
        hide_tip()
        tw = tk.Toplevel(win)
        tw.wm_overrideredirect(True)
        tw.wm_geometry(f"+{event.x_root+14}+{event.y_root+10}")
        tk.Label(tw, text=text, justify="left",
                 bg="#40318D", fg="#FFFFFF",
                 font=("Courier New", 9), relief="solid", bd=1,
                 padx=6, pady=4).pack()
        tip_win[0] = tw

    def hide_tip(event=None):
        if tip_win[0]:
            tip_win[0].destroy()
            tip_win[0] = None

    # ── Draw ──────────────────────────────────────────────────
    def redraw(reset=False):
        if reset:
            auto_layout()
        canvas.delete("all")
        item_map.clear()

        # ── Edges (drawn first, behind nodes) ────────────────
        edge_groups = defaultdict(list)
        for src, dst, aname in edges:
            edge_groups[(src, dst)].append(aname)

        for (src, dst), anames in edge_groups.items():
            if src not in positions or dst not in positions:
                continue

            # Attach from right-mid of src, to left-mid of dst
            sx0, sy0 = positions[src]
            dx0, dy0 = positions[dst]
            sh = node_height(src)
            dh = node_height(dst)

            ax1 = sx0 + BOX_W
            ay1 = sy0 + sh / 2
            ax2 = dx0
            ay2 = dy0 + dh / 2

            is_bidir = (dst, src) in edge_groups
            offset   = 0
            if is_bidir:
                offset = 8 if src < dst else -8
                ay1 += offset
                ay2 += offset

            # Curved bezier-like via control points
            cx1 = ax1 + GAP_X * 0.45
            cy1 = ay1
            cx2 = ax2 - GAP_X * 0.45
            cy2 = ay2

            # Approximate with a polyline (tk canvas has no bezier natively)
            pts = []
            steps = 12
            for t_i in range(steps + 1):
                t = t_i / steps
                mt = 1 - t
                bx = mt**3*ax1 + 3*mt**2*t*cx1 + 3*mt*t**2*cx2 + t**3*ax2
                by = mt**3*ay1 + 3*mt**2*t*cy1 + 3*mt*t**2*cy2 + t**3*ay2
                pts.extend([bx, by])

            canvas.create_line(*pts, fill=C_ARROW, width=2,
                               smooth=True,
                               arrow=tk.LAST, arrowshape=(11, 13, 4),
                               tags="edge")

            # Label at midpoint
            mx = (ax1 + ax2) / 2
            my = (ay1 + ay2) / 2 - 8
            canvas.create_text(mx, my, text=" / ".join(anames),
                               fill=C_ARR_LBL, font=("Courier New", 7, "italic"),
                               tags="edge")

        # ── Nodes ─────────────────────────────────────────────
        for nm in all_screen_names:
            if nm not in positions:
                continue
            x0, y0 = positions[nm]
            nh = node_height(nm)
            x1 = x0 + BOX_W
            y1 = y0 + nh

            all_ids = []

            # Header background
            hdr_rect = canvas.create_rectangle(
                x0, y0, x1, y0 + HDR_H,
                fill=C_HDR_BG, outline=C_HDR_OUT, width=2,
                tags=("node", nm)
            )
            all_ids.append(hdr_rect)

            # Screen name
            sid = screen_name_to_id.get(nm, "?")
            disp = nm if len(nm) <= 22 else nm[:21] + "…"
            hdr_txt = canvas.create_text(
                x0 + 8, y0 + HDR_H // 2,
                text=f"[{sid}] {disp}",
                fill=C_HDR_TXT,
                font=("Courier New", 10, "bold"),
                anchor="w", width=BOX_W - 12,
                tags=("node", nm)
            )
            all_ids.append(hdr_txt)

            # Body background
            body_rect = canvas.create_rectangle(
                x0, y0 + HDR_H, x1, y1,
                fill=C_BODY_BG, outline=C_HDR_OUT, width=1,
                tags=("node", nm)
            )
            all_ids.append(body_rect)

            # Divider under header
            canvas.create_line(x0, y0 + HDR_H, x1, y0 + HDR_H,
                               fill=C_DIV, width=1, tags=("node", nm))

            # Action rows
            rows = screen_action_rows.get(nm, [])
            for i, row in enumerate(rows):
                ry = y0 + HDR_H + i * ROW_H + ROW_H // 2

                aname      = row["name"]
                dst_name   = row["dst_name"]
                sen_name   = row["sensor_name"]
                sen_active = row["sensor_active"]

                # Bullet dot colour: green if has transition, dim otherwise
                dot_color = C_ARROW if dst_name else C_DIV
                canvas.create_oval(x0+6, ry-4, x0+14, ry+4,
                                   fill=dot_color, outline="", tags=("node",nm))

                # Action name
                act_disp = aname if len(aname) <= 16 else aname[:15]+"…"
                canvas.create_text(x0 + 20, ry,
                                   text=act_disp,
                                   fill=C_ACT_TXT,
                                   font=("Courier New", 9, "bold"),
                                   anchor="w", tags=("node", nm))

                # Destination screen tag
                if dst_name:
                    dst_disp = dst_name if len(dst_name) <= 12 else dst_name[:11]+"…"
                    canvas.create_text(x0 + 128, ry,
                                       text=f"→{dst_disp}",
                                       fill=C_DST_TXT,
                                       font=("Courier New", 8),
                                       anchor="w", tags=("node", nm))

                # Sensor badge (right side)
                if sen_name:
                    s_color = C_SEN_ON if sen_active else C_SEN_OFF
                    s_state = "ON" if sen_active else "OFF"
                    sen_disp = sen_name if len(sen_name) <= 9 else sen_name[:8]+"…"
                    canvas.create_rectangle(x1-76, ry-7, x1-2, ry+7,
                                            fill="#352880", outline=s_color,
                                            width=1, tags=("node",nm))
                    canvas.create_text(x1-40, ry,
                                       text=f"📡{sen_disp}:{s_state}",
                                       fill=s_color,
                                       font=("Courier New", 8),
                                       tags=("node", nm))
                else:
                    canvas.create_text(x1-38, ry,
                                       text="no sensor",
                                       fill=C_SEN_NONE,
                                       font=("Courier New", 8, "italic"),
                                       tags=("node", nm))

                # Row separator
                if i < len(rows) - 1:
                    canvas.create_line(x0+2, ry + ROW_H//2,
                                       x1-2, ry + ROW_H//2,
                                       fill=C_DIV, width=1,
                                       tags=("node", nm))

            item_map[nm] = {
                "rect_hdr":  hdr_rect,
                "rect_body": body_rect,
                "all_ids":   all_ids,
                "x0": x0, "y0": y0, "h": nh,
            }

        canvas.configure(scrollregion=canvas.bbox("all") or (0, 0, 1100, 780))

    redraw()

    # ── Drag (click anywhere on node) ────────────────────────
    drag = {"name": None, "ox": 0, "oy": 0}

    def on_press(event):
        hide_tip()
        cx = canvas.canvasx(event.x)
        cy = canvas.canvasy(event.y)
        for nm, info in item_map.items():
            x0, y0, h = info["x0"], info["y0"], info["h"]
            if x0 <= cx <= x0 + BOX_W and y0 <= cy <= y0 + h:
                drag.update({"name": nm, "ox": cx, "oy": cy})
                break

    def on_drag(event):
        nm = drag["name"]
        if not nm:
            return
        cx = canvas.canvasx(event.x)
        cy = canvas.canvasy(event.y)
        dx, dy = cx - drag["ox"], cy - drag["oy"]
        drag["ox"], drag["oy"] = cx, cy
        positions[nm][0] += dx
        positions[nm][1] += dy
        redraw()

    def on_release(event):
        drag["name"] = None

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
#  Dashboard window
# ══════════════════════════════════════════════════════════════════════════════

def open_dashboard_window():
    win = tk.Toplevel()
    win.title("Dashboard")
    win.geometry("500x700")
    win.configure(bg="#40318D")
    win.resizable(False, True)
    apply_combo_style()

    tk.Label(win, text="📊  Dashboard Editor", font=("Courier New", 18, "bold"),
             bg="#40318D", fg="#FFFFFF", pady=16).pack()
    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x", padx=20, pady=(0, 0))

    form = make_scrollable_form(win)

    entries = {}
    water_spins = {}

    # ── Load existing ─────────────────────────────────────────
    def dashboard_names_by_id():
        data = load_json(JSON_DASHBOARD_FILE)
        ordered = sorted(data.values(), key=lambda r: int(r.get("ID", 0)))
        return [r.get("Name", r.get("ID", "")) for r in ordered]

    section_lbl(form, "— Load Existing Dashboard —")
    load_var = tk.StringVar(value="— select to load —")
    load_dd  = ttk.Combobox(form, textvariable=load_var,
                            values=dashboard_names_by_id(),
                            state="readonly", font=("Courier New", 11))
    load_dd.pack(fill="x", ipady=3)

    # ── New Dashboard button ──────────────────────────────────
    def on_new_dashboard():
        data = load_json(JSON_DASHBOARD_FILE)
        if data:
            max_id = max(int(rec.get("ID", 0)) for rec in data.values())
        else:
            max_id = -1
        new_id = str(max_id + 1)
        for f in list(entries.keys()):
            entries[f].delete(0, tk.END)
        entries["ID"].insert(0, new_id)
        for wvar in water_spins.values():
            wvar.set(0)
        total_sim_var.set(0)
        total_flash_var.set(0)
        for evar in extra_spins.values():
            evar.set(0)
        for dvar in death_prob_sliders.values():
            dvar.set(0)
        for evar in enemy_prob_sliders.values():
            evar.set(0)
        slbl.config(text=f"✔  New dashboard (ID {new_id}) — fill in details and save", fg="#50e878")

    tk.Button(form, text="✚  New Dashboard", font=("Courier New", 11, "bold"),
              bg="#7869C4", fg="#000000", activebackground="#A09BE0",
              activeforeground="#000000", relief="raised", bd=3,
              cursor="hand2", padx=16, pady=4, command=on_new_dashboard).pack(fill="x", pady=(6, 0))

    tk.Frame(form, bg="#7869C4", height=2).pack(fill="x", pady=(10, 0))

    # ── Identity ──────────────────────────────────────────────
    section_lbl(form, "— Identity —")
    add_field(form, "ID",   entries)
    add_field(form, "Name", entries)

    # ── Total Simulation Time ─────────────────────────────────
    section_lbl(form, "— Total Simulation Time —")
    total_sim_var = tk.IntVar(value=0)
    total_sim_row = tk.Frame(form, bg="#40318D")
    total_sim_row.pack(fill="x", pady=(4, 0))
    tk.Label(total_sim_row, text="Total Simulation Time:", **LABEL_STYLE).pack(side="left")
    total_sim_spin = tk.Spinbox(
        total_sim_row, from_=0, to=1023, textvariable=total_sim_var, width=6,
        bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
        buttonbackground="#7869C4", relief="sunken", bd=2,
        font=("Courier New", 11), justify="left",
    )
    total_sim_spin.pack(side="left", padx=(8, 0), ipady=4)
    tk.Label(total_sim_row, text="seconds (max 1023)", bg="#40318D", fg="#A09BE0",
             font=("Courier New", 10)).pack(side="left", padx=(6, 0))

    # ── Total Flashlight Time ─────────────────────────────────
    section_lbl(form, "— Total Flashlight Time —")
    total_flash_var = tk.IntVar(value=0)
    total_flash_row = tk.Frame(form, bg="#40318D")
    total_flash_row.pack(fill="x", pady=(4, 0))
    tk.Label(total_flash_row, text="Total Flashlight Time:", **LABEL_STYLE).pack(side="left")
    total_flash_spin = tk.Spinbox(
        total_flash_row, from_=0, to=0, textvariable=total_flash_var, width=6,
        bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
        buttonbackground="#7869C4", relief="sunken", bd=2,
        font=("Courier New", 11), justify="left",
    )
    total_flash_spin.pack(side="left", padx=(8, 0), ipady=4)
    total_flash_max_lbl = tk.Label(total_flash_row, text="seconds (max 0)", bg="#40318D", fg="#A09BE0",
                                    font=("Courier New", 10))
    total_flash_max_lbl.pack(side="left", padx=(6, 0))

    # ── Water Levels ──────────────────────────────────────────
    water_section_lbl = tk.Label(form, text="— Water Levels (0 seconds) —",
                                 font=("Courier New", 11, "bold italic"),
                                 bg="#40318D", fg="#FFFFFF")
    water_section_lbl.pack(fill="x", pady=(14, 4))

    water_spin_widgets = []
    for i in range(4):
        label = f"WaterLevel{i}"
        row = tk.Frame(form, bg="#40318D")
        row.pack(fill="x", pady=(4, 0))
        tk.Label(row, text=f"Water Level {i}:", **LABEL_STYLE).pack(side="left")
        var = tk.IntVar(value=0)
        spin = tk.Spinbox(
            row, from_=0, to=0, textvariable=var, width=6,
            bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
            buttonbackground="#7869C4", relief="sunken", bd=2,
            font=("Courier New", 11), justify="left",
        )
        spin.pack(side="left", padx=(8, 0), ipady=4)
        tk.Label(row, text="seconds", bg="#40318D", fg="#A09BE0",
                 font=("Courier New", 10)).pack(side="left", padx=(6, 0))
        water_spins[label] = var
        water_spin_widgets.append(spin)

    # ── Extra Seconds ─────────────────────────────────────────
    section_lbl(form, "— Extra Seconds —")
    extra_spins = {}
    extra_spin_widgets = []
    extra_max_lbls = []
    for field_label, field_key in [
        ("Seconds Extra for each Water Level", "ExtraSecondsWaterLevel"),
        ("Seconds Extra for High HeartRate",   "ExtraSecondsHighHeartRate"),
        ("Seconds Extra for Flashlight Off",   "ExtraSecondsFlashlightOff"),
    ]:
        row = tk.Frame(form, bg="#40318D")
        row.pack(fill="x", pady=(4, 0))
        tk.Label(row, text=f"{field_label}:", **LABEL_STYLE).pack(side="left")
        var = tk.IntVar(value=0)
        spin = tk.Spinbox(
            row, from_=0, to=0, textvariable=var, width=6,
            bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
            buttonbackground="#7869C4", relief="sunken", bd=2,
            font=("Courier New", 11), justify="left",
        )
        spin.pack(side="left", padx=(8, 0), ipady=4)
        max_lbl = tk.Label(row, text="seconds (max 0)", bg="#40318D", fg="#A09BE0",
                           font=("Courier New", 10))
        max_lbl.pack(side="left", padx=(6, 0))
        extra_spins[field_key] = var
        extra_spin_widgets.append(spin)
        extra_max_lbls.append(max_lbl)

    def on_total_sim_changed(*_):
        try:
            max_val = int(total_sim_var.get())
            max_val = max(0, min(1023, max_val))
        except (ValueError, TypeError):
            max_val = 0
        water_section_lbl.config(text=f"— Water Levels (0–{max_val} seconds) —")
        for spin in water_spin_widgets:
            spin.config(to=max_val)
        total_flash_spin.config(to=max_val)
        total_flash_max_lbl.config(text=f"seconds (max {max_val})")
        for spin in extra_spin_widgets:
            spin.config(to=max_val)
        for lbl in extra_max_lbls:
            lbl.config(text=f"seconds (max {max_val})")

    total_sim_var.trace_add("write", on_total_sim_changed)

    # ── Death Probability on Action sliders (0–255) ─────────────────
    section_lbl(form, "— Death Probability on Action —")
    death_prob_sliders = {}
    for field_label, field_key in [
        ("For each Water Level",  "DeathProbWaterLevel"),
        ("For High HeartRate",    "DeathProbHighHeartRate"),
        ("For Flashlight Off",    "DeathProbFlashlightOff"),
    ]:
        row = tk.Frame(form, bg="#40318D")
        row.pack(fill="x", pady=(4, 0))
        tk.Label(row, text=f"{field_label}:", **LABEL_STYLE).pack(side="left")
        var = tk.IntVar(value=0)
        slider = tk.Scale(
            row, from_=0, to=255, orient="horizontal",
            variable=var, bg="#40318D", fg="#FFFFFF",
            troughcolor="#2E2270", highlightthickness=0,
            activebackground="#7869C4", font=("Courier New", 9),
            length=200, sliderlength=16,
        )
        slider.pack(side="left", fill="x", expand=True)
        tk.Label(row, textvariable=var, width=4,
                 bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))
        death_prob_sliders[field_key] = var

    # ── Enemy Probability sliders (0–255) ─────────────────────
    section_lbl(form, "— Enemy Probability —")
    enemy_prob_sliders = {}
    for field_label, field_key in [
        ("For Flashlight On", "EnemyProbFlashlightOn"),
    ]:
        row = tk.Frame(form, bg="#40318D")
        row.pack(fill="x", pady=(4, 0))
        tk.Label(row, text=f"{field_label}:", **LABEL_STYLE).pack(side="left")
        var = tk.IntVar(value=0)
        slider = tk.Scale(
            row, from_=0, to=255, orient="horizontal",
            variable=var, bg="#40318D", fg="#FFFFFF",
            troughcolor="#2E2270", highlightthickness=0,
            activebackground="#7869C4", font=("Courier New", 9),
            length=200, sliderlength=16,
        )
        slider.pack(side="left", fill="x", expand=True)
        tk.Label(row, textvariable=var, width=4,
                 bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))
        enemy_prob_sliders[field_key] = var

    # ── Save ──────────────────────────────────────────────────
    tk.Frame(form, bg="#7869C4", height=2).pack(fill="x", pady=(14, 8))
    slbl = status_lbl(form)

    def on_load(e=None):
        name = load_var.get()
        data = load_json(JSON_DASHBOARD_FILE)
        rec = next((r for r in data.values() if r.get("Name", "") == name), None)
        if not rec:
            return
        for f in list(entries.keys()):
            entries[f].delete(0, tk.END)
            entries[f].insert(0, rec.get(f, ""))
        try:
            total_sim_var.set(int(rec.get("TotalSimulationTime", 0)))
        except (ValueError, TypeError):
            total_sim_var.set(0)
        try:
            total_flash_var.set(int(rec.get("TotalFlashlightTime", 0)))
        except (ValueError, TypeError):
            total_flash_var.set(0)
        for i in range(4):
            label = f"WaterLevel{i}"
            try:
                water_spins[label].set(int(rec.get(label, 0)))
            except (ValueError, TypeError):
                water_spins[label].set(0)
        for field_key in extra_spins:
            try:
                extra_spins[field_key].set(int(rec.get(field_key, 0)))
            except (ValueError, TypeError):
                extra_spins[field_key].set(0)
        for field_key in death_prob_sliders:
            try:
                death_prob_sliders[field_key].set(int(rec.get(field_key, 0)))
            except (ValueError, TypeError):
                death_prob_sliders[field_key].set(0)
        for field_key in enemy_prob_sliders:
            try:
                enemy_prob_sliders[field_key].set(int(rec.get(field_key, 0)))
            except (ValueError, TypeError):
                enemy_prob_sliders[field_key].set(0)
        slbl.config(text=f"✔  Loaded '{name}'", fg="#A09BE0")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        data = {f: entries[f].get() for f in entries}
        try:
            tsim = int(total_sim_var.get())
            tsim = max(0, min(1023, tsim))
        except (ValueError, TypeError):
            tsim = 0
        data["TotalSimulationTime"] = tsim
        try:
            tflash = int(total_flash_var.get())
            tflash = max(0, min(tsim, tflash))
        except (ValueError, TypeError):
            tflash = 0
        data["TotalFlashlightTime"] = tflash
        for i in range(4):
            label = f"WaterLevel{i}"
            try:
                val = int(water_spins[label].get())
                val = max(0, min(tsim, val))
            except (ValueError, TypeError):
                val = 0
            data[label] = val
        for field_key, var in extra_spins.items():
            try:
                val = int(var.get())
                val = max(0, min(tsim, val))
            except (ValueError, TypeError):
                val = 0
            data[field_key] = val
        for field_key, var in death_prob_sliders.items():
            data[field_key] = max(0, min(255, var.get()))
        for field_key, var in enemy_prob_sliders.items():
            data[field_key] = max(0, min(255, var.get()))
        save_to_json(JSON_DASHBOARD_FILE, "ID", data, slbl)
        load_dd["values"] = dashboard_names_by_id()

    save_btn(form, "💾  Save Dashboard", on_save)


# ══════════════════════════════════════════════════════════════════════════════
#  Dispatch
# ══════════════════════════════════════════════════════════════════════════════

def open_window(title):
    dispatch = {
        "Screens":           open_screens_window,
        "Actions":           open_actions_window,
        "Puzzles":           open_puzzles_window,
        "Sensors":           open_sensors_window,
        "Map":               open_map_window,
        "Map Actions":       open_map_actions_window,
        "Dashboard":  open_dashboard_window,
    }
    if title in dispatch:
        dispatch[title]()
        return

    win = tk.Toplevel()
    win.title(title)
    win.geometry("400x300")
    win.configure(bg="#40318D")
    tk.Label(win, text=title, font=("Courier New", 18, "bold"),
             bg="#40318D", fg="#FFFFFF", pady=20).pack()
    tk.Label(win, text=f"Adventure Construction Set\n— {title} Editor —",
             font=("Courier New", 11), bg="#40318D", fg="#A09BE0",
             justify="center").pack(expand=True)


# ══════════════════════════════════════════════════════════════════════════════
#  Main window
# ══════════════════════════════════════════════════════════════════════════════

def main():
    root = tk.Tk()
    root.title("Adventure Construction Set")
    root.geometry("920x260")
    root.configure(bg="#352880")
    root.resizable(False, False)

    tk.Label(root, text="⚔  Adventure Construction Set  ⚔",
             font=("Courier New", 14, "bold"), bg="#352880", fg="#FFFFFF", pady=12).pack()
    tk.Frame(root, bg="#7869C4", height=2).pack(fill="x", padx=20)

    btn_frame = tk.Frame(root, bg="#352880", pady=15)
    btn_frame.pack()

    for icon, section in zip(ICONS, SECTIONS):
        tk.Button(btn_frame, text=f"{icon}\n{section}", font=("Courier New", 10, "bold"),
                  width=8, height=3, bg="#7869C4", fg="#000000",
                  activebackground="#7869C4", activeforeground="#ffffff",
                  relief="raised", bd=3, cursor="hand2",
                  command=lambda s=section: open_window(s)).pack(side="left", padx=8)

    # ── Run Parsers button ────────────────────────────────────
    tk.Frame(root, bg="#7869C4", height=1).pack(fill="x", padx=20)
    tk.Button(root, text="⚙  Run Parsers", font=("Courier New", 11, "bold"),
              bg="#7869C4", fg="#000000",
              activebackground="#A09BE0", activeforeground="#000000",
              relief="raised", bd=3, cursor="hand2",
              padx=20, pady=6, command=run_parsers).pack(pady=10)

    root.mainloop()


if __name__ == "__main__":
    main()