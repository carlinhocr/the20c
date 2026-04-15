import json
import os
import random
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
    fields = ["ID", "Name", "Alias"]
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
        toggle_var.set(0)
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
    toggle_var = tk.IntVar(value=0)
    checkbox_widget(form, "Toggle", toggle_var)

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
        toggle_var.set(int(rec.get("Toggle", 0)))
        dialog_on_text.delete("1.0", tk.END)
        dialog_on_text.insert("1.0", rec.get("DialogOn", ""))
        dialog_off_text.delete("1.0", tk.END)
        dialog_off_text.insert("1.0", rec.get("DialogOff", ""))
        slbl.config(text=f"✔  Loaded '{name}'", fg="#A09BE0")

    load_dd.bind("<<ComboboxSelected>>", on_load)

    def on_save():
        data = {f: entries[f].get() for f in ["ID", "Name"]}
        data["Active"]    = active_var.get()
        data["Toggle"]    = toggle_var.get()
        data["DialogOn"]  = dialog_on_text.get("1.0", "end-1c")
        data["DialogOff"] = dialog_off_text.get("1.0", "end-1c")
        save_to_json(JSON_SENSORS_FILE, "ID", data, slbl)
        load_dd["values"] = sensor_names_by_id()

    save_btn(form, "💾  Save Sensor", on_save)


# ══════════════════════════════════════════════════════════════════════════════
#  Run Parsers
# ══════════════════════════════════════════════════════════════════════════════

PARSER_SCRIPTS = [
    ("acs_parser_sensors.py",              "📡  Sensors"),
    ("acs_parser_actions.py",              "⚡  Actions"),
    ("acs_parser_screens.py",              "🖥️  Screens"),
    ("acs_parser_dashboard.py",            "📊  Dashboard"),
    ("acs_parser_dual_eeproms_actions.py", "⚡  Dual EEPROM Actions"),
    ("acs_parser_dual_eeproms_screens.py", "🖥️  Dual EEPROM Screens"),
]


def run_parsers():
    """Run all parser scripts and show a results window."""
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
        dash_combo_vars["StartScreen"].set("")
        dash_combo_vars["EndScreenDefault"].set("")
        dash_combo_vars["EndScreenEnemy"].set("")
        dash_combo_vars["EndScreenTimeUp"].set("")
        dash_combo_vars["EndScreenEnemyActionFailed"].set("")
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

    # ── Start Screen ──────────────────────────────────────────
    section_lbl(form, "— Start Screen —")
    dash_combo_vars    = {}
    dash_combo_widgets = {}
    add_combo(form, "StartScreen", get_screen_names(), dash_combo_vars, dash_combo_widgets)
    dash_start_id_var = tk.StringVar(value="")
    start_id_row = tk.Frame(form, bg="#40318D")
    start_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(start_id_row, text="Screen ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(start_id_row, textvariable=dash_start_id_var,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

    def refresh_start_screen_id(*_):
        name = dash_combo_vars["StartScreen"].get().strip()
        if not name:
            dash_start_id_var.set("")
            return
        scrs = load_json(JSON_SCREENS_FILE)
        for rec in scrs.values():
            if rec.get("Name", "").strip() == name:
                dash_start_id_var.set(rec.get("ID", "?"))
                return
        dash_start_id_var.set("?")

    dash_combo_vars["StartScreen"].trace_add("write", refresh_start_screen_id)

    # ── End Screen Default ─────────────────────────────────────
    section_lbl(form, "— End Screen Default —")
    add_combo(form, "EndScreenDefault", get_screen_names(), dash_combo_vars, dash_combo_widgets)
    dash_end_default_id_var = tk.StringVar(value="")
    end_default_id_row = tk.Frame(form, bg="#40318D")
    end_default_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(end_default_id_row, text="Screen ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(end_default_id_row, textvariable=dash_end_default_id_var,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

    def refresh_end_default_screen_id(*_):
        name = dash_combo_vars["EndScreenDefault"].get().strip()
        if not name:
            dash_end_default_id_var.set("")
            return
        scrs = load_json(JSON_SCREENS_FILE)
        for rec in scrs.values():
            if rec.get("Name", "").strip() == name:
                dash_end_default_id_var.set(rec.get("ID", "?"))
                return
        dash_end_default_id_var.set("?")

    dash_combo_vars["EndScreenDefault"].trace_add("write", refresh_end_default_screen_id)

    # ── End Screen Enemy ───────────────────────────────────────
    section_lbl(form, "— End Screen Enemy —")
    add_combo(form, "EndScreenEnemy", get_screen_names(), dash_combo_vars, dash_combo_widgets)
    dash_end_enemy_id_var = tk.StringVar(value="")
    end_enemy_id_row = tk.Frame(form, bg="#40318D")
    end_enemy_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(end_enemy_id_row, text="Screen ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(end_enemy_id_row, textvariable=dash_end_enemy_id_var,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

    def refresh_end_enemy_screen_id(*_):
        name = dash_combo_vars["EndScreenEnemy"].get().strip()
        if not name:
            dash_end_enemy_id_var.set("")
            return
        scrs = load_json(JSON_SCREENS_FILE)
        for rec in scrs.values():
            if rec.get("Name", "").strip() == name:
                dash_end_enemy_id_var.set(rec.get("ID", "?"))
                return
        dash_end_enemy_id_var.set("?")

    dash_combo_vars["EndScreenEnemy"].trace_add("write", refresh_end_enemy_screen_id)

    # ── End Screen Time Up ─────────────────────────────────────
    section_lbl(form, "— End Screen Time Up —")
    add_combo(form, "EndScreenTimeUp", get_screen_names(), dash_combo_vars, dash_combo_widgets)
    dash_end_timeup_id_var = tk.StringVar(value="")
    end_timeup_id_row = tk.Frame(form, bg="#40318D")
    end_timeup_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(end_timeup_id_row, text="Screen ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(end_timeup_id_row, textvariable=dash_end_timeup_id_var,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

    def refresh_end_timeup_screen_id(*_):
        name = dash_combo_vars["EndScreenTimeUp"].get().strip()
        if not name:
            dash_end_timeup_id_var.set("")
            return
        scrs = load_json(JSON_SCREENS_FILE)
        for rec in scrs.values():
            if rec.get("Name", "").strip() == name:
                dash_end_timeup_id_var.set(rec.get("ID", "?"))
                return
        dash_end_timeup_id_var.set("?")

    dash_combo_vars["EndScreenTimeUp"].trace_add("write", refresh_end_timeup_screen_id)

    # ── End Screen Enemy Action Failed ─────────────────────────
    section_lbl(form, "— End Screen Enemy Action Failed —")
    add_combo(form, "EndScreenEnemyActionFailed", get_screen_names(), dash_combo_vars, dash_combo_widgets)
    dash_end_enemy_af_id_var = tk.StringVar(value="")
    end_enemy_af_id_row = tk.Frame(form, bg="#40318D")
    end_enemy_af_id_row.pack(fill="x", pady=(2, 0))
    tk.Label(end_enemy_af_id_row, text="Screen ID:", **LABEL_STYLE).pack(side="left")
    tk.Label(end_enemy_af_id_row, textvariable=dash_end_enemy_af_id_var,
             bg="#40318D", fg="#50e878", font=("Courier New", 11)).pack(side="left", padx=(6, 0))

    def refresh_end_enemy_af_screen_id(*_):
        name = dash_combo_vars["EndScreenEnemyActionFailed"].get().strip()
        if not name:
            dash_end_enemy_af_id_var.set("")
            return
        scrs = load_json(JSON_SCREENS_FILE)
        for rec in scrs.values():
            if rec.get("Name", "").strip() == name:
                dash_end_enemy_af_id_var.set(rec.get("ID", "?"))
                return
        dash_end_enemy_af_id_var.set("?")

    dash_combo_vars["EndScreenEnemyActionFailed"].trace_add("write", refresh_end_enemy_af_screen_id)

    # ── Thresholds ────────────────────────────────────────────
    section_lbl(form, "— Thresholds —")

    # High Water Level (0-3)
    high_water_row = tk.Frame(form, bg="#40318D")
    high_water_row.pack(fill="x", pady=(4, 0))
    tk.Label(high_water_row, text="High Water Level:", **LABEL_STYLE).pack(side="left")
    high_water_var = tk.IntVar(value=5)
    high_water_spin = tk.Spinbox(
        high_water_row, from_=0, to=9, textvariable=high_water_var, width=4,
        bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
        buttonbackground="#7869C4", relief="sunken", bd=2,
        font=("Courier New", 11), justify="left",
    )
    high_water_spin.pack(side="left", padx=(8, 0), ipady=4)
    tk.Label(high_water_row, text="(0–9)", bg="#40318D", fg="#A09BE0",
             font=("Courier New", 10)).pack(side="left", padx=(6, 0))

    # High HeartRate Level (0-1)
    high_heart_row = tk.Frame(form, bg="#40318D")
    high_heart_row.pack(fill="x", pady=(4, 0))
    tk.Label(high_heart_row, text="High HeartRate Level:", **LABEL_STYLE).pack(side="left")
    high_heart_var = tk.IntVar(value=1)
    high_heart_spin = tk.Spinbox(
        high_heart_row, from_=0, to=1, textvariable=high_heart_var, width=4,
        bg="#2E2270", fg="#FFFFFF", insertbackground="#FFFFFF",
        buttonbackground="#7869C4", relief="sunken", bd=2,
        font=("Courier New", 11), justify="left",
    )
    high_heart_spin.pack(side="left", padx=(8, 0), ipady=4)
    tk.Label(high_heart_row, text="(0–1)", bg="#40318D", fg="#A09BE0",
             font=("Courier New", 10)).pack(side="left", padx=(6, 0))

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
    for i in range(10):
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
        for i in range(10):
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
        # Start Screen
        dash_combo_vars["StartScreen"].set("")
        stored_start_id = rec.get("StartScreenID", 255)
        try:
            stored_start_id = int(stored_start_id)
        except (ValueError, TypeError):
            stored_start_id = 255
        if stored_start_id != 255:
            scrs = load_json(JSON_SCREENS_FILE)
            for srec in scrs.values():
                try:
                    if int(srec.get("ID", -1)) == stored_start_id:
                        dash_combo_vars["StartScreen"].set(srec.get("Name", ""))
                        break
                except (ValueError, TypeError):
                    pass
        # End Screen Default
        dash_combo_vars["EndScreenDefault"].set("")
        stored_end_default_id = rec.get("EndScreenDefaultID", 255)
        try:
            stored_end_default_id = int(stored_end_default_id)
        except (ValueError, TypeError):
            stored_end_default_id = 255
        if stored_end_default_id != 255:
            scrs = load_json(JSON_SCREENS_FILE)
            for srec in scrs.values():
                try:
                    if int(srec.get("ID", -1)) == stored_end_default_id:
                        dash_combo_vars["EndScreenDefault"].set(srec.get("Name", ""))
                        break
                except (ValueError, TypeError):
                    pass
        # End Screen Enemy
        dash_combo_vars["EndScreenEnemy"].set("")
        stored_end_enemy_id = rec.get("EndScreenEnemyID", 255)
        try:
            stored_end_enemy_id = int(stored_end_enemy_id)
        except (ValueError, TypeError):
            stored_end_enemy_id = 255
        if stored_end_enemy_id != 255:
            scrs = load_json(JSON_SCREENS_FILE)
            for srec in scrs.values():
                try:
                    if int(srec.get("ID", -1)) == stored_end_enemy_id:
                        dash_combo_vars["EndScreenEnemy"].set(srec.get("Name", ""))
                        break
                except (ValueError, TypeError):
                    pass
        # End Screen Time Up
        dash_combo_vars["EndScreenTimeUp"].set("")
        stored_end_timeup_id = rec.get("EndScreenTimeUpID", 255)
        try:
            stored_end_timeup_id = int(stored_end_timeup_id)
        except (ValueError, TypeError):
            stored_end_timeup_id = 255
        if stored_end_timeup_id != 255:
            scrs = load_json(JSON_SCREENS_FILE)
            for srec in scrs.values():
                try:
                    if int(srec.get("ID", -1)) == stored_end_timeup_id:
                        dash_combo_vars["EndScreenTimeUp"].set(srec.get("Name", ""))
                        break
                except (ValueError, TypeError):
                    pass
        # End Screen Enemy Action Failed
        dash_combo_vars["EndScreenEnemyActionFailed"].set("")
        stored_end_enemy_af_id = rec.get("EndScreenEnemyActionFailedID", 255)
        try:
            stored_end_enemy_af_id = int(stored_end_enemy_af_id)
        except (ValueError, TypeError):
            stored_end_enemy_af_id = 255
        if stored_end_enemy_af_id != 255:
            scrs = load_json(JSON_SCREENS_FILE)
            for srec in scrs.values():
                try:
                    if int(srec.get("ID", -1)) == stored_end_enemy_af_id:
                        dash_combo_vars["EndScreenEnemyActionFailed"].set(srec.get("Name", ""))
                        break
                except (ValueError, TypeError):
                    pass
        # Thresholds
        try:
            high_water_var.set(int(rec.get("HighWaterLevel", 5)))
        except (ValueError, TypeError):
            high_water_var.set(5)
        try:
            high_heart_var.set(int(rec.get("HighHeartRateLevel", 1)))
        except (ValueError, TypeError):
            high_heart_var.set(1)
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
        for i in range(10):
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
        # Start Screen ID
        start_name = dash_combo_vars["StartScreen"].get().strip()
        start_id_num = 255
        if start_name:
            try:
                start_id_num = int(dash_start_id_var.get())
            except (ValueError, TypeError):
                start_id_num = 255
        data["StartScreenID"] = start_id_num
        # End Screen Default ID
        end_default_name = dash_combo_vars["EndScreenDefault"].get().strip()
        end_default_id_num = 255
        if end_default_name:
            try:
                end_default_id_num = int(dash_end_default_id_var.get())
            except (ValueError, TypeError):
                end_default_id_num = 255
        data["EndScreenDefaultID"] = end_default_id_num
        # End Screen Enemy ID
        end_enemy_name = dash_combo_vars["EndScreenEnemy"].get().strip()
        end_enemy_id_num = 255
        if end_enemy_name:
            try:
                end_enemy_id_num = int(dash_end_enemy_id_var.get())
            except (ValueError, TypeError):
                end_enemy_id_num = 255
        data["EndScreenEnemyID"] = end_enemy_id_num
        # End Screen Time Up ID
        end_timeup_name = dash_combo_vars["EndScreenTimeUp"].get().strip()
        end_timeup_id_num = 255
        if end_timeup_name:
            try:
                end_timeup_id_num = int(dash_end_timeup_id_var.get())
            except (ValueError, TypeError):
                end_timeup_id_num = 255
        data["EndScreenTimeUpID"] = end_timeup_id_num
        # End Screen Enemy Action Failed ID
        end_enemy_af_name = dash_combo_vars["EndScreenEnemyActionFailed"].get().strip()
        end_enemy_af_id_num = 255
        if end_enemy_af_name:
            try:
                end_enemy_af_id_num = int(dash_end_enemy_af_id_var.get())
            except (ValueError, TypeError):
                end_enemy_af_id_num = 255
        data["EndScreenEnemyActionFailedID"] = end_enemy_af_id_num
        # Thresholds
        data["HighWaterLevel"]    = max(0, min(9, high_water_var.get()))
        data["HighHeartRateLevel"] = max(0, min(1, high_heart_var.get()))
        save_to_json(JSON_DASHBOARD_FILE, "ID", data, slbl)
        load_dd["values"] = dashboard_names_by_id()
        dash_combo_widgets["StartScreen"]["values"] = get_screen_names()
        dash_combo_widgets["EndScreenDefault"]["values"] = get_screen_names()
        dash_combo_widgets["EndScreenEnemy"]["values"] = get_screen_names()
        dash_combo_widgets["EndScreenTimeUp"]["values"] = get_screen_names()
        dash_combo_widgets["EndScreenEnemyActionFailed"]["values"] = get_screen_names()

    save_btn(form, "💾  Save Dashboard", on_save)


# ══════════════════════════════════════════════════════════════════════════════
#  Play Game — full simulation engine
# ══════════════════════════════════════════════════════════════════════════════

def open_play_window():
    screens = load_json(JSON_SCREENS_FILE)
    actions = load_json(JSON_ACTIONS_FILE)
    sensors = load_json(JSON_SENSORS_FILE)
    dashboard = load_json(JSON_DASHBOARD_FILE)

    if not screens or not actions:
        messagebox.showinfo("Play", "Need at least screens and actions to play.")
        return

    # ── Lookup tables ─────────────────────────────────────────
    screen_by_id   = {str(r.get("ID","")): r for r in screens.values()}
    screen_by_name = {r.get("Name",""): r for r in screens.values()}
    action_by_name = {r.get("Name","").strip(): r for r in actions.values() if r.get("Name","").strip()}
    sensor_by_id   = {str(r.get("ID","")): r for r in sensors.values()}

    # ── Dashboard defaults ────────────────────────────────────
    dash = {}
    if dashboard:
        # Use first dashboard record
        first = list(dashboard.values())[0] if dashboard else {}
        dash = first
    D = lambda key, default: int(dash.get(key, default))

    total_sim_time      = D("TotalSimulationTime",      600)
    total_flash_time    = D("TotalFlashlightTime",       300)
    water_thresholds    = [D(f"WaterLevel{i}", 0) for i in range(10)]
    extra_sec_water     = D("ExtraSecondsWaterLevel",    5)
    extra_sec_heart     = D("ExtraSecondsHighHeartRate", 5)
    extra_sec_flash_off = D("ExtraSecondsFlashlightOff", 5)
    death_prob_water    = D("DeathProbWaterLevel",       10)
    death_prob_heart    = D("DeathProbHighHeartRate",    10)
    death_prob_flash    = D("DeathProbFlashlightOff",    50)
    enemy_prob_flash_on = D("EnemyProbFlashlightOn",     10)
    high_water_mark     = D("HighWaterLevel",             5)
    high_heart_mark     = D("HighHeartRateLevel",         1)
    end_screen_default_id = D("EndScreenDefaultID",       255)
    end_screen_enemy_id   = D("EndScreenEnemyID",         255)
    end_screen_timeup_id  = D("EndScreenTimeUpID",        255)
    end_screen_enemy_af_id = D("EndScreenEnemyActionFailedID", 255)

    # ── Game state ────────────────────────────────────────────
    state = {
        "time_elapsed":       0,
        "flash_time_used":    0,
        "flashlight_on":      False,
        "flash_can_relight":  True,
        "water_level":        0,
        "heart_rate":         0,
        "enemy_prob_accum":   0,
        "secrets_found":      set(),
        "screens_visited":    set(),
        "game_over":          False,
        "game_over_reason":   "",
        "current_screen_id":  None,
        "sensor_states":      {},  # sensor_id -> True/False
    }

    # Count total secrets
    total_secrets = sum(1 for s in screens.values() if int(s.get("IsSecretScreen", 0)))

    # Initialize sensor states from JSON
    for sid, srec in sensor_by_id.items():
        state["sensor_states"][sid] = bool(srec.get("Active", False))

    # Find startScreen (from dashboard or fallback)
    start_screen = None
    dash_start_id = D("StartScreenID", 255)
    if dash_start_id != 255:
        start_screen = screen_by_id.get(str(dash_start_id))
    if not start_screen:
        for s in screens.values():
            if s.get("Name","").strip().lower() == "startscreen":
                start_screen = s
                break
    if not start_screen:
        start_screen = screen_by_id.get("3") or list(screens.values())[0]

    state["current_screen_id"] = str(start_screen.get("ID","0"))

    # ── Window ────────────────────────────────────────────────
    win = tk.Toplevel()
    win.title("▶  Adventure — Playing")
    win.geometry("820x700")
    win.configure(bg="#000000")
    win.resizable(True, True)

    # ── Status bar ────────────────────────────────────────────
    status_frame = tk.Frame(win, bg="#1A1452", pady=4)
    status_frame.pack(fill="x")

    status_vars = {}
    for label_text in ["Time", "Water", "Heart", "Flashlight", "Secrets"]:
        sv = tk.StringVar(value="")
        tk.Label(status_frame, textvariable=sv, font=("Courier New", 9, "bold"),
                 bg="#1A1452", fg="#50e878", padx=8).pack(side="left")
        status_vars[label_text] = sv

    # ── God mode checkbox (forces random to 255 = never fail) ─
    god_mode_var = tk.IntVar(value=0)
    tk.Checkbutton(status_frame, text="🛡 God Mode", variable=god_mode_var,
                   font=("Courier New", 9, "bold"), bg="#1A1452", fg="#FF6060",
                   selectcolor="#2E2270", activebackground="#1A1452",
                   activeforeground="#FF6060", cursor="hand2").pack(side="right", padx=8)

    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x")

    # ── Main text area ────────────────────────────────────────
    text_area = scrolledtext.ScrolledText(
        win, bg="#000000", fg="#FFFFFF", font=("Courier New", 11),
        relief="flat", bd=0, wrap="word", state="disabled",
        insertbackground="#FFFFFF", padx=12, pady=8,
    )
    text_area.pack(fill="both", expand=True)

    # Configure text tags for colors
    text_area.tag_configure("title",       foreground="#FFFFFF", font=("Courier New", 13, "bold"))
    text_area.tag_configure("description", foreground="#A09BE0")
    text_area.tag_configure("ascii_art",   foreground="#7869C4", font=("Courier New", 8))
    text_area.tag_configure("sensor",      foreground="#50e878")
    text_area.tag_configure("action_msg",  foreground="#FFFFFF")
    text_area.tag_configure("warning",     foreground="#FF6060")
    text_area.tag_configure("success",     foreground="#50e878")
    text_area.tag_configure("enemy",       foreground="#FF4040", font=("Courier New", 12, "bold"))
    text_area.tag_configure("death",       foreground="#FF4040", font=("Courier New", 12, "bold"))
    text_area.tag_configure("info",        foreground="#7869C4")
    text_area.tag_configure("progress_hdr",foreground="#FFFFFF", font=("Courier New", 12, "bold"))
    text_area.tag_configure("progress",    foreground="#50e878", font=("Courier New", 11))

    tk.Frame(win, bg="#7869C4", height=2).pack(fill="x")

    # ── Action buttons frame ──────────────────────────────────
    action_frame = tk.Frame(win, bg="#1A1452", pady=8)
    action_frame.pack(fill="x")

    # ── Stats window (separate Toplevel) ──────────────────────
    stats_win = tk.Toplevel()
    stats_win.title("📈  Action Statistics")
    stats_win.geometry("520x700")
    stats_win.configure(bg="#1A1452")
    stats_win.resizable(True, True)

    # Position stats window next to game window
    win.update_idletasks()
    gx = win.winfo_x()
    gy = win.winfo_y()
    gw = win.winfo_width()
    stats_win.geometry(f"520x700+{gx + gw + 10}+{gy}")

    tk.Label(stats_win, text="📈  Action Statistics",
             font=("Courier New", 14, "bold"),
             bg="#1A1452", fg="#FFFFFF", pady=8).pack(fill="x")
    tk.Frame(stats_win, bg="#7869C4", height=2).pack(fill="x")

    stats_text = scrolledtext.ScrolledText(
        stats_win, bg="#0D0D2B", fg="#FFFFFF",
        font=("Courier New", 10), wrap="word",
        state="disabled", relief="flat", bd=0,
        insertbackground="#FFFFFF",
    )
    stats_text.pack(fill="both", expand=True, padx=4, pady=4)

    stats_text.tag_configure("header",   foreground="#FFD700", font=("Courier New", 11, "bold"))
    stats_text.tag_configure("section",  foreground="#7869C4", font=("Courier New", 10, "bold"))
    stats_text.tag_configure("label",    foreground="#A09BE0", font=("Courier New", 10))
    stats_text.tag_configure("value",    foreground="#50e878", font=("Courier New", 10, "bold"))
    stats_text.tag_configure("roll",     foreground="#FF6060", font=("Courier New", 11, "bold"))
    stats_text.tag_configure("result_ok",   foreground="#50e878", font=("Courier New", 11, "bold"))
    stats_text.tag_configure("result_fail", foreground="#FF6060", font=("Courier New", 11, "bold"))
    stats_text.tag_configure("divider",  foreground="#7869C4", font=("Courier New", 10))
    stats_text.tag_configure("dimmed",   foreground="#666688", font=("Courier New", 10))
    stats_text.tag_configure("cost",     foreground="#FFD700", font=("Courier New", 10))

    def stats_write(text, tag="label"):
        stats_text.configure(state="normal")
        stats_text.insert("end", text + "\n", tag)
        stats_text.see("end")
        stats_text.configure(state="disabled")

    def stats_clear():
        stats_text.configure(state="normal")
        stats_text.delete("1.0", "end")
        stats_text.configure(state="disabled")

    # Close stats window when game window closes
    def on_game_close():
        try:
            stats_win.destroy()
        except tk.TclError:
            pass
        win.destroy()

    win.protocol("WM_DELETE_WINDOW", on_game_close)

    # ── Helper functions ──────────────────────────────────────
    def write(text, tag="description"):
        text_area.configure(state="normal")
        text_area.insert("end", text + "\n", tag)
        text_area.see("end")
        text_area.configure(state="disabled")

    def clear_text():
        text_area.configure(state="normal")
        text_area.delete("1.0", "end")
        text_area.configure(state="disabled")

    def update_status():
        t = state["time_elapsed"]
        tmax = total_sim_time
        ft = state["flash_time_used"]
        ftmax = total_flash_time
        wl = state["water_level"]
        hr = state["heart_rate"]
        fl = "ON" if state["flashlight_on"] else "OFF"
        if not state["flash_can_relight"] and not state["flashlight_on"]:
            fl = "DEAD"
        sf = len(state["secrets_found"])
        sv = len(state["screens_visited"])

        status_vars["Time"].set(f"⏱ {t}/{tmax}s")
        water_bars = "█" * wl + "░" * (9 - wl)
        status_vars["Water"].set(f"💧 {water_bars} ({wl})")
        status_vars["Heart"].set(f"❤ {'HIGH' if hr else 'calm'}")
        status_vars["Flashlight"].set(f"🔦 {fl} ({ft}/{ftmax}s)")
        status_vars["Secrets"].set(f"🔑 {sf}/{total_secrets}")

    def update_water_level():
        t = state["time_elapsed"]
        new_level = 0
        for i, threshold in enumerate(water_thresholds):
            if t >= threshold:
                new_level = i
        old_level = state["water_level"]
        if new_level > old_level:
            state["water_level"] = new_level
            # Trigger water sensor
            water_sensor = sensor_by_id.get("0")
            if water_sensor:
                msg = water_sensor.get("DialogOn", "")
                if msg:
                    write(f"📡 [{water_sensor.get('Name','')}]: {msg}", "sensor")
            write(f"⚠ El nivel de agua subió a {new_level}!", "warning")

    def get_random():
        if god_mode_var.get():
            return 255
        return random.randint(0, 255)

    def is_high_water():
        return state["water_level"] >= high_water_mark

    def is_high_fear():
        return state["heart_rate"] >= high_heart_mark

    def clear_actions():
        for w in action_frame.winfo_children():
            w.destroy()

    # ── Draw screen ───────────────────────────────────────────
    def draw_screen(screen_rec):
        scr_id = str(screen_rec.get("ID", ""))
        scr_name = screen_rec.get("Name", "")
        state["current_screen_id"] = scr_id
        state["screens_visited"].add(scr_id)

        # Check secret
        if int(screen_rec.get("IsSecretScreen", 0)):
            if scr_id not in state["secrets_found"]:
                state["secrets_found"].add(scr_id)
                write("🔑 ¡Descubriste un secreto!", "success")

        clear_text()

        # ASCII art
        ascii_art = screen_rec.get("AsciiDrawing", "").strip()
        if ascii_art:
            write(ascii_art, "ascii_art")
            write("", "description")

        # Description
        desc = screen_rec.get("Description", "").strip()
        if desc:
            write(desc, "description")

        # Flashlight-specific description
        if state["flashlight_on"]:
            fl_desc = screen_rec.get("FlashlightOn", "").strip()
            if fl_desc:
                write("", "description")
                write(fl_desc, "description")
        else:
            fl_desc = screen_rec.get("FlashlightOff", "").strip()
            if fl_desc:
                write("", "description")
                write(fl_desc, "description")

        write("", "description")
        update_status()

    # ── Show available actions ────────────────────────────────
    def show_actions():
        clear_actions()
        scr = screen_by_id.get(state["current_screen_id"])
        if not scr or state["game_over"]:
            return

        available = []
        for slot in ["Action1", "Action2", "Action3", "Action4"]:
            aname = scr.get(slot, "").strip()
            if not aname:
                continue
            arec = action_by_name.get(aname)
            if not arec:
                continue

            # Check visibility
            hide_water = int(arec.get("HideOnWaterLevelHigh", 0))
            hide_fear  = int(arec.get("HideOnFearLevelHigh", 0))
            hide_flash = int(arec.get("HideWithFlashlightOff", 0))

            if hide_water and is_high_water():
                continue
            if hide_fear and is_high_fear():
                continue
            if hide_flash and not state["flashlight_on"]:
                continue

            available.append((aname, arec))

        if not available:
            write("No hay acciones disponibles...", "warning")
            return

        for aname, arec in available:
            display_name = arec.get("Alias", "").strip() or aname
            btn = tk.Button(
                action_frame, text=f"▶ {display_name}",
                font=("Courier New", 10, "bold"),
                bg="#7869C4", fg="#000000",
                activebackground="#A09BE0", activeforeground="#000000",
                relief="raised", bd=2, cursor="hand2", padx=10, pady=4,
                command=lambda a=aname, r=arec: execute_action(a, r)
            )
            btn.pack(side="left", padx=4, pady=2)

    # ── End game sequence ─────────────────────────────────────
    def end_game(reason, end_screen_rec=None):
        state["game_over"] = True
        state["game_over_reason"] = reason
        clear_actions()

        write("", "description")
        write("═" * 50, "death")

        if end_screen_rec:
            desc = end_screen_rec.get("Description", "").strip()
            if desc:
                write(desc, "death")
        else:
            write(reason, "death")

        write("═" * 50, "death")
        write("", "description")

        # Show progress button
        def show_progress():
            clear_actions()
            write("", "description")
            write("═══ PROGRESO DEL JUEGO ═══", "progress_hdr")
            write(f"  Tiempo Total Usado:        {state['time_elapsed']}/{total_sim_time} segundos", "progress")
            write(f"  Tiempo Linterna Usado:     {state['flash_time_used']}/{total_flash_time} segundos", "progress")
            write(f"  Secretos Encontrados:      {len(state['secrets_found'])}/{total_secrets}", "progress")
            write(f"  Nivel Final de Agua:       {state['water_level']}", "progress")
            write(f"  Nivel de HeartRate Final:  {'HIGH' if state['heart_rate'] else 'calm'}", "progress")
            write(f"  Pantallas Recorridas:      {len(state['screens_visited'])}", "progress")
            write(f"  Razón de Fin:              {reason}", "progress")
            write("═" * 40, "progress_hdr")

            btn_menu = tk.Button(
                action_frame, text="🏠 Volver al Menú",
                font=("Courier New", 10, "bold"),
                bg="#7869C4", fg="#000000",
                activebackground="#A09BE0", activeforeground="#000000",
                relief="raised", bd=2, cursor="hand2", padx=10, pady=4,
                command=win.destroy
            )
            btn_menu.pack(side="left", padx=4, pady=2)

        btn_progress = tk.Button(
            action_frame, text="📊 Ver Progreso del Juego",
            font=("Courier New", 10, "bold"),
            bg="#7869C4", fg="#000000",
            activebackground="#A09BE0", activeforeground="#000000",
            relief="raised", bd=2, cursor="hand2", padx=10, pady=4,
            command=show_progress
        )
        btn_progress.pack(side="left", padx=4, pady=2)

        btn_close = tk.Button(
            action_frame, text="🏠 Volver al Menú",
            font=("Courier New", 10, "bold"),
            bg="#7869C4", fg="#000000",
            activebackground="#A09BE0", activeforeground="#000000",
            relief="raised", bd=2, cursor="hand2", padx=10, pady=4,
            command=win.destroy
        )
        btn_close.pack(side="left", padx=4, pady=2)

        update_status()

    # ── Execute action ────────────────────────────────────────
    def execute_action(aname, arec):
        if state["game_over"]:
            return

        # ── Special: TERMINAR EL JUEGO ends the game ─────────
        if aname.upper() == "TERMINAR EL JUEGO":
            desc = arec.get("Description", "").strip()
            if desc:
                write(desc, "action_msg")
            end_game("Fin del juego")
            return

        write(f"\n{'─' * 40}", "info")
        display_name = arec.get("Alias", "").strip() or aname
        write(f"▶ {display_name}", "title")

        # Print action description
        desc = arec.get("Description", "").strip()
        if desc:
            write(desc, "action_msg")

        # ── Check if destination screen is end screen ─────────
        dst_screen_id = arec.get("ScreenID", 255)
        try:
            dst_screen_id = int(dst_screen_id)
        except (ValueError, TypeError):
            dst_screen_id = 255

        dst_screen = screen_by_id.get(str(dst_screen_id)) if dst_screen_id != 255 else None

        def is_end_screen(scr):
            if not scr:
                return False
            if int(scr.get("IsEndScreen", 0)):
                return True
            name = scr.get("Name", "").lower()
            if name.startswith("endscreen") or name.startswith("end_screen"):
                return True
            return False

        if is_end_screen(dst_screen):
            draw_screen(dst_screen)
            end_game("Muerte por acción directa")
            return

        # ── Check if action has reset enemy probability ───────
        if int(arec.get("ResetEnemyProbability", 0)):
            state["enemy_prob_accum"] = 0
            write("(Probabilidad de enemigo reseteada)", "info")

        # ── Populate stats window ──────────────────────────────
        stats_clear()
        stats_write(f"▶  {arec.get('Alias', '').strip() or aname}", "header")
        stats_write(f"{'═' * 48}", "divider")

        # -- Current game state --
        stats_write("", "label")
        stats_write("GAME STATE", "section")
        stats_write(f"  Water Level:          {state['water_level']}", "label")
        stats_write(f"  Heart Rate:           {'HIGH (1)' if state['heart_rate'] else 'calm (0)'}", "label")
        stats_write(f"  Flashlight:           {'ON' if state['flashlight_on'] else 'OFF'}", "label")
        stats_write(f"  Enemy Prob Accum:     {state['enemy_prob_accum']}  (before this action)", "label")
        stats_write(f"  God Mode:             {'ON' if god_mode_var.get() else 'OFF'}", "label")

        # ── Calculate action failure probability ───────────────
        # Formula: action_DeathProbability * (water_level * DeathProbWaterLevel + DeathProbFlashlightOff + DeathProbHighHeartRate)
        action_death_val = 0
        try:
            action_death_val = int(arec.get("DeathProbability", 0))
        except (ValueError, TypeError):
            pass

        water_modifier = state["water_level"] * death_prob_water
        flash_modifier = death_prob_flash if not state["flashlight_on"] else 0
        heart_modifier = death_prob_heart if state["heart_rate"] else 0
        modifier_sum = water_modifier + flash_modifier + heart_modifier
        fail_prob = action_death_val * modifier_sum

        stats_write("", "label")
        stats_write("ACTION FAILURE PROBABILITY", "section")
        stats_write(f"  Action DeathProbability:       {action_death_val}", "label")
        stats_write(f"  ─── Modifiers (from Dashboard) ───", "dimmed")
        stats_write(f"  Water Level ({state['water_level']}) × DeathProbWater ({death_prob_water}):  {water_modifier}", "label")
        stats_write(f"  Flashlight {'OFF' if not state['flashlight_on'] else 'ON '} → DeathProbFlash ({death_prob_flash}):      {flash_modifier}", "label")
        stats_write(f"  HeartRate  {'HIGH' if state['heart_rate'] else 'calm'} → DeathProbHeart ({death_prob_heart}):     {heart_modifier}", "label")
        stats_write(f"  ─── Calculation ───", "dimmed")
        stats_write(f"  Modifier Sum:  {water_modifier} + {flash_modifier} + {heart_modifier} = {modifier_sum}", "label")
        stats_write(f"  Fail Prob:     {action_death_val} × {modifier_sum} = {fail_prob}", "value")

        fail_roll = None
        fail_triggered = False
        if fail_prob > 0:
            fail_roll = get_random()
            write(f"  [Falla: {action_death_val} × (agua:{water_modifier} + linterna:{flash_modifier} + heart:{heart_modifier}) = {fail_prob}, dado={fail_roll}]", "info")
            stats_write(f"  Random Roll:   {fail_roll}  (range 0–255)", "roll")
            stats_write(f"  Condition:     roll ({fail_roll}) < fail_prob ({fail_prob})?", "label")
            if fail_roll < fail_prob:
                fail_triggered = True
                stats_write(f"  ★ RESULT: ACTION FAILED! ({fail_roll} < {fail_prob})", "result_fail")
            else:
                stats_write(f"  ★ RESULT: Action succeeded ({fail_roll} ≥ {fail_prob})", "result_ok")
        else:
            stats_write(f"  Fail Prob is 0 → no roll needed", "dimmed")
            stats_write(f"  ★ RESULT: Action succeeded (no risk)", "result_ok")

        if fail_triggered:
            failed_desc = arec.get("DescriptionActionFailed", "").strip()
            if failed_desc:
                write(failed_desc, "warning")
            # Find action failure death screen
            fail_end_screen = None
            if end_screen_enemy_af_id != 255:
                fail_end_screen = screen_by_id.get(str(end_screen_enemy_af_id))
            if not fail_end_screen and end_screen_default_id != 255:
                fail_end_screen = screen_by_id.get(str(end_screen_default_id))
            if not fail_end_screen:
                for scr_rec in screens.values():
                    if scr_rec.get("Name", "").strip() == "endScreenDefault":
                        fail_end_screen = scr_rec
                        break
            if fail_end_screen:
                draw_screen(fail_end_screen)
                end_game("Muerte por acción fallida", fail_end_screen)
            else:
                end_game("Muerte por acción fallida")
            return

        # ── Calculate enemy probability ───────────────────────
        # Sum: action prob + accumulated prob + flashlight on prob (dashboard)
        action_enemy_prob = 0
        try:
            action_enemy_prob = int(arec.get("EnemyProbability", 0))
        except (ValueError, TypeError):
            pass

        state["enemy_prob_accum"] += action_enemy_prob

        flashlight_enemy_bonus = enemy_prob_flash_on if state["flashlight_on"] else 0
        enemy_sum = action_enemy_prob + state["enemy_prob_accum"] + flashlight_enemy_bonus

        # Multiply by screen enemy probability
        cur_screen = screen_by_id.get(state["current_screen_id"], {})
        screen_enemy_prob = 0
        try:
            screen_enemy_prob = int(cur_screen.get("EnemyProbability", 0))
        except (ValueError, TypeError):
            pass

        total_enemy_prob = enemy_sum * screen_enemy_prob

        stats_write("", "label")
        stats_write("ENEMY APPEARANCE PROBABILITY", "section")
        stats_write(f"  Action EnemyProbability:       {action_enemy_prob}", "label")
        stats_write(f"  Accumulated Enemy Prob:        {state['enemy_prob_accum']}  (after adding action)", "label")
        stats_write(f"  Flashlight {'ON ' if state['flashlight_on'] else 'OFF'} → EnemyProbFlashOn ({enemy_prob_flash_on}):  {flashlight_enemy_bonus}", "label")
        stats_write(f"  ─── Calculation ───", "dimmed")
        stats_write(f"  Enemy Sum:     {action_enemy_prob} + {state['enemy_prob_accum']} + {flashlight_enemy_bonus} = {enemy_sum}", "label")
        stats_write(f"  Screen EnemyProb:  {screen_enemy_prob}  (screen: {cur_screen.get('Name', '?')})", "label")
        stats_write(f"  Total Enemy Prob:  {enemy_sum} × {screen_enemy_prob} = {total_enemy_prob}", "value")

        enemy_roll = None
        enemy_triggered = False
        if total_enemy_prob > 0:
            enemy_roll = get_random()
            write(f"  [Enemigo: suma={enemy_sum} × screen={screen_enemy_prob} = {total_enemy_prob}, dado={enemy_roll}]", "info")
            stats_write(f"  Random Roll:   {enemy_roll}  (range 0–255)", "roll")
            stats_write(f"  Condition:     total ({total_enemy_prob}) ≥ roll ({enemy_roll})?", "label")
            if total_enemy_prob >= enemy_roll:
                enemy_triggered = True
                stats_write(f"  ★ RESULT: ENEMY APPEARED! ({total_enemy_prob} ≥ {enemy_roll})", "result_fail")
            else:
                stats_write(f"  ★ RESULT: Safe ({total_enemy_prob} < {enemy_roll})", "result_ok")
        else:
            stats_write(f"  Total Enemy Prob is 0 → no roll needed", "dimmed")
            stats_write(f"  ★ RESULT: Safe (no risk)", "result_ok")

        if enemy_triggered:
            write("¡Algo se mueve en la oscuridad... El enemigo te encontró!", "enemy")
            # Find enemy death end screen
            enemy_end_screen = None
            if end_screen_enemy_id != 255:
                enemy_end_screen = screen_by_id.get(str(end_screen_enemy_id))
            if not enemy_end_screen:
                for scr_rec in screens.values():
                    if scr_rec.get("Name", "").strip() == "endScreenDefault":
                        enemy_end_screen = scr_rec
                        break
            if enemy_end_screen:
                draw_screen(enemy_end_screen)
                end_game("Te atrapó el enemigo", enemy_end_screen)
            else:
                end_game("Te atrapó el enemigo")
            return

        # ── Calculate time cost ───────────────────────────────
        base_cost = 0
        try:
            base_cost = int(arec.get("Cost", 0))
        except (ValueError, TypeError):
            pass

        time_cost = base_cost
        # Water level extra cost: level 0 = no extra, level N = N * extra_sec_water
        wl = state["water_level"]
        water_time_extra = wl * extra_sec_water if wl > 0 else 0
        heart_time_extra = extra_sec_heart if state["heart_rate"] else 0
        flash_time_extra = extra_sec_flash_off if not state["flashlight_on"] else 0
        if wl > 0:
            time_cost += wl * extra_sec_water
        if state["heart_rate"]:
            time_cost += extra_sec_heart
        if not state["flashlight_on"]:
            time_cost += extra_sec_flash_off

        stats_write("", "label")
        stats_write("TIME COST", "section")
        stats_write(f"  Base Cost (action):            {base_cost}s", "label")
        stats_write(f"  Water ({wl}) × ExtraWater ({extra_sec_water}):     +{water_time_extra}s", "label")
        stats_write(f"  HeartRate {'HIGH' if state['heart_rate'] else 'calm'} → ExtraHeart ({extra_sec_heart}):    +{heart_time_extra}s", "label")
        stats_write(f"  Flashlight {'OFF' if not state['flashlight_on'] else 'ON '} → ExtraFlash ({extra_sec_flash_off}):   +{flash_time_extra}s", "label")
        stats_write(f"  Total Time Cost:  {base_cost} + {water_time_extra} + {heart_time_extra} + {flash_time_extra} = {time_cost}s", "cost")
        stats_write(f"  Time After Action: {state['time_elapsed']} + {time_cost} = {state['time_elapsed'] + time_cost}/{total_sim_time}s", "cost")

        state["time_elapsed"] += time_cost

        if time_cost > 0:
            water_extra = wl * extra_sec_water if wl > 0 else 0
            write(f"  [Costo: {time_cost}s (base {base_cost}s + agua:{water_extra}s + modificadores)]", "info")

        # Check if time ran out → navigate to EndScreenSimulationTimeisUp
        if state["time_elapsed"] >= total_sim_time:
            write("⚠ ¡Se acabó el tiempo!", "warning")
            # Find the EndScreenSimulationTimeisUp screen
            time_up_screen = None
            if end_screen_timeup_id != 255:
                time_up_screen = screen_by_id.get(str(end_screen_timeup_id))
            if not time_up_screen:
                for scr_rec in screens.values():
                    if scr_rec.get("Name", "").strip() == "EndScreenSimulationTimeisUp":
                        time_up_screen = scr_rec
                        break
            if time_up_screen:
                draw_screen(time_up_screen)
                end_game("Se terminó el tiempo de simulación", time_up_screen)
            else:
                end_game("Se terminó el tiempo de simulación")
            return

        # ── Update water level based on elapsed time ──────────
        update_water_level()

        # Check if water level reached max (level 9) and time >= threshold
        if state["water_level"] >= 9 and state["time_elapsed"] >= water_thresholds[9]:
            write("⚠ ¡La caverna se llenó de agua!", "warning")
            end_game("Se llenó la caverna de agua")
            return

        # ── Calculate flashlight usage ────────────────────────
        if state["flashlight_on"]:
            state["flash_time_used"] += time_cost
            if state["flash_time_used"] >= total_flash_time:
                state["flashlight_on"] = False
                state["flash_can_relight"] = False
                write("🔦 ¡La linterna se apagó por falta de batería!", "warning")

        # ── Process sensor activation ─────────────────────────
        sensor_id = arec.get("SensorID", 255)
        try:
            sensor_id = int(sensor_id)
        except (ValueError, TypeError):
            sensor_id = 255

        if sensor_id != 255:
            sensor_rec = sensor_by_id.get(str(sensor_id))
            if sensor_rec:
                sensor_name = sensor_rec.get("Name", "")
                sid_str = str(sensor_id)
                is_toggle = int(sensor_rec.get("Toggle", 0))

                if is_toggle:
                    # Toggle: flip current state
                    current = state["sensor_states"].get(sid_str, False)
                    sensor_active = not current
                    state["sensor_states"][sid_str] = sensor_active
                else:
                    # Normal: use SensorActive from the action
                    sensor_active = arec.get("SensorActive", False)
                    if isinstance(sensor_active, str):
                        sensor_active = sensor_active.lower() in ("true", "1", "yes")
                    state["sensor_states"][sid_str] = sensor_active

                if sensor_active:
                    msg = sensor_rec.get("DialogOn", "").strip()
                    if msg:
                        write(f"📡 [{sensor_name}]: {msg}", "sensor")
                else:
                    msg = sensor_rec.get("DialogOff", "").strip()
                    if msg:
                        write(f"📡 [{sensor_name}]: {msg}", "sensor")

                # Handle specific sensors
                if sensor_name == "flashlightheart":
                    # Toggle: flip flashlight and inversely flip heart
                    # If flashlight was OFF → turn ON and set heart to 0 (calm)
                    # If flashlight was ON  → turn OFF and set heart to 1 (high)
                    if not state["flashlight_on"]:
                        if state["flash_can_relight"]:
                            state["flashlight_on"] = True
                            state["heart_rate"] = 0
                            write("🔦 La linterna se prende. Tu corazón se calma.", "sensor")
                        else:
                            write("🔦 La linterna no tiene batería, no se puede prender.", "warning")
                    else:
                        state["flashlight_on"] = False
                        state["heart_rate"] = 1
                        write("🔦 La linterna se apaga. Tu corazón se acelera.", "sensor")

                elif sensor_name == "flashlight":
                    if sensor_active and state["flash_can_relight"]:
                        state["flashlight_on"] = True
                    elif sensor_active and not state["flash_can_relight"]:
                        write("🔦 La linterna no tiene batería, no se puede prender.", "warning")
                    else:
                        state["flashlight_on"] = False

                elif sensor_name == "heart":
                    state["heart_rate"] = 1 if sensor_active else 0

                elif sensor_name == "water":
                    if sensor_active and state["water_level"] < 9:
                        state["water_level"] += 1
                        write(f"💧 Nivel de agua: {state['water_level']}", "warning")

                elif sensor_name == "gamePlaying":
                    if not sensor_active:
                        # Game ended by sensor
                        pass

        # ── Move to new screen or stay ────────────────────────
        if dst_screen and dst_screen_id != 255:
            write("", "description")
            draw_screen(dst_screen)
        else:
            update_status()

        # ── Show next actions ─────────────────────────────────
        show_actions()

    # ── Start the game ────────────────────────────────────────
    draw_screen(start_screen)
    show_actions()


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
    root.geometry("920x300")
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

    # ── Bottom buttons row ────────────────────────────────────
    tk.Frame(root, bg="#7869C4", height=1).pack(fill="x", padx=20)
    bottom_frame = tk.Frame(root, bg="#352880")
    bottom_frame.pack(pady=10)

    tk.Button(bottom_frame, text="⚙  Run Parsers", font=("Courier New", 11, "bold"),
              bg="#7869C4", fg="#000000",
              activebackground="#A09BE0", activeforeground="#000000",
              relief="raised", bd=3, cursor="hand2",
              padx=20, pady=6, command=run_parsers).pack(side="left", padx=8)

    tk.Button(bottom_frame, text="▶  PLAY GAME", font=("Courier New", 11, "bold"),
              bg="#50e878", fg="#000000",
              activebackground="#80FFA0", activeforeground="#000000",
              relief="raised", bd=3, cursor="hand2",
              padx=20, pady=6, command=open_play_window).pack(side="left", padx=8)

    root.mainloop()


if __name__ == "__main__":
    main()