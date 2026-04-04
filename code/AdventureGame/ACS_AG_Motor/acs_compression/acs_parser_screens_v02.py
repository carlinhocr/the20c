import json
import os
import sys
import re

JSON_FILE    = "acs_screens.json"
PUZZLES_FILE = "acs_puzzles.json"
ACTIONS_FILE = "acs_actions.json"
ASM_FILE     = "acs_screens.asm"

# Fields that contain compressible text strings
STRING_FIELDS = ["Description", "FlashlightOn", "FlashlightOff"]


def load_name_to_id(filepath, id_field="ID", name_field="Name"):
    """Load a JSON file and return a dict { name -> id }."""
    if not os.path.exists(filepath):
        print(f"[ERROR] '{filepath}' not found.")
        sys.exit(1)
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)
    mapping = {}
    for entry in data.values():
        name = entry.get(name_field, "").strip()
        eid  = entry.get(id_field,   "").strip()
        if name and eid:
            mapping[name] = int(eid)
    return mapping


def resolve(name, mapping, label, optional=False):
    """Resolve a name to its numeric ID. If optional and empty, return 255 (no ref)."""
    name = name.strip()
    if not name:
        if optional:
            return 255
        return 255   # empty slot → 0xFF sentinel
    if name not in mapping:
        print(f"[ERROR] '{name}' not found in {label}. Available: {list(mapping.keys())}")
        sys.exit(1)
    return mapping[name]


def ascii_lines(text):
    """
    Split text on real newline characters and return a list of .ascii directive strings.
    Newlines are emitted as .byte $0A between segments so the newline character
    is preserved in the assembled output without being inside a quoted string.
    """
    segments = text.split("\n")
    out = []
    for si, seg in enumerate(segments):
        while len(seg) > 80:
            out.append(f'  .ascii "{seg[:80]}"')
            seg = seg[80:]
        if seg:
            out.append(f'  .ascii "{seg}"')
        # Emit a .byte $0A for the newline between segments (not after the last one)
        if si < len(segments) - 1:
            out.append(f'  .byte $0A  ; \\n')
    return out


# ═══════════════════════════════════════════════════════════════
#  String compression: word+trailing-whitespace tokenization
# ═══════════════════════════════════════════════════════════════

def tokenize_text(text):
    """
    Split text into tokens where each token is a word followed by whatever
    whitespace comes after it (space, newline, or nothing if it's the last word).
    
    Example: "Hola mundo\\nTest" → ["Hola ", "mundo\\n", "Test"]
    
    We use a regex that captures: (non-whitespace+)(whitespace*)
    Each match becomes one token = word + trailing_whitespace.
    """
    # Match one or more non-whitespace chars, followed by zero or more whitespace chars
    tokens = re.findall(r'\S+\s*', text)
    return tokens


def build_token_dictionary(screens):
    """
    Pass 1: Scan all string fields across all screens, tokenize them,
    and build a global dictionary of unique tokens.
    
    Returns:
        token_to_id: dict { token_string -> integer_id }
        id_to_token: dict { integer_id -> token_string }
    """
    unique_tokens = {}  # token_string -> first-seen order
    
    for key, scr in screens.items():
        for field in STRING_FIELDS:
            text = scr.get(field, "")
            if not text or not text.strip():
                continue
            tokens = tokenize_text(text)
            for tok in tokens:
                if tok not in unique_tokens:
                    unique_tokens[tok] = len(unique_tokens)
    
    token_to_id = unique_tokens
    id_to_token = {v: k for k, v in unique_tokens.items()}
    return token_to_id, id_to_token


def emit_token_dictionary_asm(id_to_token):
    """
    Generate ASM for the token dictionary table.
    
    Layout:
      token_dict_index:
        .word token_0    ; pointer to token 0
        .word token_1    ; pointer to token 1
        ...
      
      token_0:
        .ascii "word "
        .ascii "e"       ; end sentinel
      token_1:
        .ascii "otro\\n"
        .ascii "e"
        ...
      
      token_dict_count:
        .byte N
    """
    lines = []
    lines.append("; ════════════════════════════════════════════════════════════")
    lines.append(";  Token Dictionary — compressed string tokens")
    lines.append("; ════════════════════════════════════════════════════════════")
    lines.append("")
    
    # Index table: array of .word pointers to each token's data
    lines.append("token_dict_index:")
    for tid in sorted(id_to_token.keys()):
        tok_repr = id_to_token[tid].replace('\n', '\\n')
        lines.append(f"  .word token_{tid}  ; [{tid}] \"{tok_repr}\"")
    lines.append("")
    
    # Token data: each token as .ascii with $00 sentinel byte
    # Newlines are emitted as .byte $0A outside the .ascii string
    for tid in sorted(id_to_token.keys()):
        tok = id_to_token[tid]
        tok_repr = tok.replace('\n', '\\n')
        
        lines.append(f"token_{tid}:  ; \"{tok_repr}\"")
        
        # Split the token into text parts and newlines
        # so newlines become .byte $0A and text stays in .ascii
        parts = tok.split('\n')
        for pi, part in enumerate(parts):
            if part:
                part_asm = part.replace('"', '\\"')
                lines.append(f'  .ascii "{part_asm}"')
            # If not the last part, there was a \n here
            if pi < len(parts) - 1:
                lines.append(f'  .byte $0A  ; \\n')
        
        lines.append(f'  .byte $00  ; end-of-token sentinel')
        lines.append("")
    
    lines.append("token_dict_count:")
    lines.append(f"  .byte {len(id_to_token)}")
    lines.append("")
    
    return lines


def emit_compressed_field(label_prefix, field_suffix, text, token_to_id):
    """
    Emit the compressed version of a string field.
    
    The compressed field is a sequence of .word entries, each being the
    address (label) of the token in the dictionary. Terminated with
    .word 0xFFFF as end sentinel.
    
    label: {label_prefix}_{field_suffix}_compressed
    """
    lines = []
    compressed_label = f"{label_prefix}_{field_suffix}_compressed"
    
    lines.append(f"{compressed_label}:")
    
    if not text or not text.strip():
        # Empty string → just the sentinel
        lines.append(f"  .word $FFFF  ; end sentinel (empty)")
    else:
        tokens = tokenize_text(text)
        for tok in tokens:
            tid = token_to_id[tok]
            tok_repr = tok.replace('\n', '\\n')
            lines.append(f"  .word token_{tid}  ; \"{tok_repr}\"")
        lines.append(f"  .word $FFFF  ; end sentinel")
    
    lines.append("")
    return lines


def to_asm(screens, action_ids):
    # ── Build token dictionary from all string fields ─────────
    token_to_id, id_to_token = build_token_dictionary(screens)
    
    lines = []
    lines.append("; ============================================================")
    lines.append(";  ACS Screens — auto-generated by acs_screens_to_asm.py")
    lines.append("; ============================================================")
    lines.append("")

    # ── Token dictionary first (so labels are available) ──────
    lines.extend(emit_token_dictionary_asm(id_to_token))

    # ── Screen index table (pointer to the start of each screen record) ──────
    lines.append("screens_index:")
    for index, (key, scr) in enumerate(screens.items()):
        scr_id = scr.get("ID", str(index)).strip()
        name   = scr.get("Name", key)
        lines.append(f"  .word screen_pointers_{scr_id}  ; {name}")
    lines.append(f"screens_index_record_length:")
    lines.append(f"  .byte 2  ; each screens_index entry is 1 .word (2 bytes)")
    lines.append("")

    # ── Pointer table ────────────────────────────────────────
    lines.append("screens_pointers:")
    offset = 0
    screen_0_action1_byte        = None
    screen_0_description_byte    = None
    screen_0_ascii_byte          = None
    screen_0_flashlight_on_byte  = None
    screen_0_flashlight_off_byte = None
    screen_0_enemy_prob_byte     = None
    screen_0_is_secret_byte      = None
    screen_0_is_end_byte         = None
    screen_0_desc_compressed_byte = None
    screen_0_flon_compressed_byte = None
    screen_0_floff_compressed_byte = None
    screen_0_record_length       = None
    screen_0_name                = None
    for index, (key, scr) in enumerate(screens.items()):
        scr_id = scr.get("ID", str(index)).strip()
        label  = f"screen_{scr_id}"
        name   = scr.get("Name", key)

        start_offset  = offset

        lines.append(f"screen_pointers_{scr_id}:")
        lines.append(f"  .word {label}_id                          ; {name} id                          [{offset},{offset+1}]") ; offset += 2
        lines.append(f"  .word {label}_name                        ; {name} name                        [{offset},{offset+1}]") ; offset += 2
        lines.append(f"  .word {label}_action1                     ; {name} action1                     [{offset},{offset+1}]") ; _act1 = offset ; offset += 2
        lines.append(f"  .word {label}_action2                     ; {name} action2                     [{offset},{offset+1}]") ; offset += 2
        lines.append(f"  .word {label}_action3                     ; {name} action3                     [{offset},{offset+1}]") ; offset += 2
        lines.append(f"  .word {label}_action4                     ; {name} action4                     [{offset},{offset+1}]") ; offset += 2
        lines.append(f"  .word {label}_description                 ; {name} description                 [{offset},{offset+1}]") ; _desc = offset ; offset += 2
        lines.append(f"  .word {label}_ascii                       ; {name} ascii                       [{offset},{offset+1}]") ; _asc  = offset ; offset += 2
        lines.append(f"  .word {label}_flashlight_on               ; {name} flashlight_on               [{offset},{offset+1}]") ; _flon = offset ; offset += 2
        lines.append(f"  .word {label}_flashlight_off              ; {name} flashlight_off              [{offset},{offset+1}]") ; _floff = offset ; offset += 2
        lines.append(f"  .word {label}_enemy_probability           ; {name} enemy_probability           [{offset},{offset+1}]") ; _enm = offset ; offset += 2
        lines.append(f"  .word {label}_is_secret_screen            ; {name} is_secret_screen            [{offset},{offset+1}]") ; _sec = offset ; offset += 2
        lines.append(f"  .word {label}_is_end_screen               ; {name} is_end_screen               [{offset},{offset+1}]") ; _end = offset ; offset += 2
        # New compressed fields
        lines.append(f"  .word {label}_description_compressed      ; {name} description_compressed      [{offset},{offset+1}]") ; _desc_c = offset ; offset += 2
        lines.append(f"  .word {label}_flashlight_on_compressed    ; {name} flashlight_on_compressed    [{offset},{offset+1}]") ; _flon_c = offset ; offset += 2
        lines.append(f"  .word {label}_flashlight_off_compressed   ; {name} flashlight_off_compressed   [{offset},{offset+1}]") ; _floff_c = offset ; offset += 2

        if index == 0:
            screen_0_action1_byte        = _act1
            screen_0_description_byte    = _desc
            screen_0_ascii_byte          = _asc
            screen_0_flashlight_on_byte  = _flon
            screen_0_flashlight_off_byte = _floff
            screen_0_enemy_prob_byte     = _enm
            screen_0_is_secret_byte      = _sec
            screen_0_is_end_byte         = _end
            screen_0_desc_compressed_byte  = _desc_c
            screen_0_flon_compressed_byte  = _flon_c
            screen_0_floff_compressed_byte = _floff_c
            screen_0_record_length       = offset - start_offset
            screen_0_name                = name

    # ── Extra fields for screen 0, placed after all screen entries ────────────
    lines.append(f"screen_action_offset:")
    lines.append(f"  .byte {screen_0_action1_byte}  ; (byte of screen_0_action1 in screens_pointers)")
    lines.append(f"screen_description_offset:")
    lines.append(f"  .byte {screen_0_description_byte}  ; (byte of screen_0_description in screens_pointers)")
    lines.append(f"screen_ascii_offset:")
    lines.append(f"  .byte {screen_0_ascii_byte}  ; (byte of screen_0_ascii in screens_pointers)")
    lines.append(f"screen_flashlight_on_offset:")
    lines.append(f"  .byte {screen_0_flashlight_on_byte}  ; (byte of screen_0_flashlight_on in screens_pointers)")
    lines.append(f"screen_flashlight_off_offset:")
    lines.append(f"  .byte {screen_0_flashlight_off_byte}  ; (byte of screen_0_flashlight_off in screens_pointers)")
    lines.append(f"screen_enemy_probability_offset:")
    lines.append(f"  .byte {screen_0_enemy_prob_byte}  ; (byte of screen_0_enemy_probability in screens_pointers)")
    lines.append(f"screen_is_secret_screen_offset:")
    lines.append(f"  .byte {screen_0_is_secret_byte}  ; (byte of screen_0_is_secret_screen in screens_pointers)")
    lines.append(f"screen_is_end_screen_offset:")
    lines.append(f"  .byte {screen_0_is_end_byte}  ; (byte of screen_0_is_end_screen in screens_pointers)")
    # New compressed field offsets
    lines.append(f"screen_description_compressed_offset:")
    lines.append(f"  .byte {screen_0_desc_compressed_byte}  ; (byte of screen_0_description_compressed in screens_pointers)")
    lines.append(f"screen_flashlight_on_compressed_offset:")
    lines.append(f"  .byte {screen_0_flon_compressed_byte}  ; (byte of screen_0_flashlight_on_compressed in screens_pointers)")
    lines.append(f"screen_flashlight_off_compressed_offset:")
    lines.append(f"  .byte {screen_0_floff_compressed_byte}  ; (byte of screen_0_flashlight_off_compressed in screens_pointers)")
    lines.append(f"screen_record_length:")
    lines.append(f"  .byte {screen_0_record_length}  ; (total .word bytes per screen record)")
    lines.append("")

    for index, (key, scr) in enumerate(screens.items()):
        scr_id    = scr.get("ID",          str(index)).strip()
        label     = f"screen_{scr_id}"
        name_str  = scr.get("Name",        "").replace('"', '\\"')
        desc_str  = scr.get("Description", "").replace('"', '\\"')
        ascii_str = scr.get("AsciiDrawing","").replace('"', '\\"')

        # Raw texts (unescaped) for tokenization
        desc_raw  = scr.get("Description", "")
        flon_raw  = scr.get("FlashlightOn", "")
        floff_raw = scr.get("FlashlightOff", "")

        # actions → numeric IDs (255 = empty slot)
        act_ids = [
            resolve(scr.get(f"Action{i}", ""), action_ids, ACTIONS_FILE, optional=True)
            for i in range(1, 5)
        ]

        lines.append(f"; ── Screen {scr_id}: {scr.get('Name', key)} ──────────────────────────")

        # ID
        lines.append(f"{label}_id:")
        lines.append(f"  .byte {scr_id}")
        lines.append("")

        # Name
        lines.append(f"{label}_name:")
        lines.extend(ascii_lines(name_str))
        lines.append('  .byte $00  ; end-of-string sentinel')
        lines.append("")

        # Actions → numeric IDs
        for i, aid in enumerate(act_ids, 1):
            act_name = scr.get(f"Action{i}", "") or "none"
            lines.append(f"{label}_action{i}:")
            lines.append(f"  .byte {aid}  ; {act_name}")
            lines.append("")

        # Description (original)
        lines.append(f"{label}_description:")
        lines.extend(ascii_lines(desc_str))
        lines.append('  .byte $00  ; end-of-string sentinel')
        lines.append("")

        # Description (compressed)
        lines.extend(emit_compressed_field(label, "description", desc_raw, token_to_id))

        # AsciiDrawing (no compression — binary art, not prose)
        lines.append(f"{label}_ascii:")
        lines.extend(ascii_lines(ascii_str))
        lines.append('  .byte $00  ; end-of-string sentinel')
        lines.append("")

        # FlashlightOn (original)
        flashlight_on_str  = scr.get("FlashlightOn",  "").replace('"', '\\"')
        lines.append(f"{label}_flashlight_on:")
        lines.extend(ascii_lines(flashlight_on_str))
        lines.append('  .byte $00  ; end-of-string sentinel')
        lines.append("")

        # FlashlightOn (compressed)
        lines.extend(emit_compressed_field(label, "flashlight_on", flon_raw, token_to_id))

        # FlashlightOff (original)
        flashlight_off_str = scr.get("FlashlightOff", "").replace('"', '\\"')
        lines.append(f"{label}_flashlight_off:")
        lines.extend(ascii_lines(flashlight_off_str))
        lines.append('  .byte $00  ; end-of-string sentinel')
        lines.append("")

        # FlashlightOff (compressed)
        lines.extend(emit_compressed_field(label, "flashlight_off", floff_raw, token_to_id))

        # Enemy Probability
        try:
            enemy_prob_val = int(scr.get("EnemyProbability", 0))
            enemy_prob_val = max(0, min(255, enemy_prob_val))
        except (ValueError, TypeError):
            enemy_prob_val = 0
        lines.append(f"{label}_enemy_probability:")
        lines.append(f"  .byte {enemy_prob_val}")
        lines.append("")

        # IsSecretScreen
        try:
            is_secret_val = int(scr.get("IsSecretScreen", 0))
            is_secret_val = 1 if is_secret_val else 0
        except (ValueError, TypeError):
            is_secret_val = 0
        lines.append(f"{label}_is_secret_screen:")
        lines.append(f"  .byte {is_secret_val}  ; {'yes' if is_secret_val else 'no'}")
        lines.append("")

        # IsEndScreen
        try:
            is_end_val = int(scr.get("IsEndScreen", 0))
            is_end_val = 1 if is_end_val else 0
        except (ValueError, TypeError):
            is_end_val = 0
        lines.append(f"{label}_is_end_screen:")
        lines.append(f"  .byte {is_end_val}  ; {'yes' if is_end_val else 'no'}")
        lines.append("")

    # ── Screen count constant ─────────────────────────────────
    lines.append("; ── Total screen count ──────────────────────────────────────")
    lines.append("screen_count:")
    lines.append(f"  .byte {len(screens)}")
    lines.append("")

    # ── Secret screens count ──────────────────────────────────
    secret_count = 0
    for scr in screens.values():
        try:
            if int(scr.get("IsSecretScreen", 0)):
                secret_count += 1
        except (ValueError, TypeError):
            pass
    lines.append("; ── Total secret screens count ──────────────────────────────")
    lines.append("screens_with_secrets:")
    lines.append(f"  .byte {secret_count}")
    lines.append("")

    # ── Compression stats ─────────────────────────────────────
    lines.append("; ── Compression stats ─────────────────────────────────────")
    lines.append(f";  Unique tokens in dictionary: {len(id_to_token)}")
    
    # Calculate rough byte savings
    total_original_bytes = 0
    total_compressed_bytes = 0
    for key, scr in screens.items():
        for field in STRING_FIELDS:
            text = scr.get(field, "")
            if text and text.strip():
                total_original_bytes += len(text.encode('utf-8'))
                tokens = tokenize_text(text)
                total_compressed_bytes += len(tokens) * 2 + 2  # 2 bytes per token ref + 2 for sentinel
    
    dict_overhead = sum(len(tok.encode('utf-8')) + 1 for tok in token_to_id.keys())  # +1 for "e" sentinel each
    dict_overhead += len(token_to_id) * 2  # index table .word pointers
    
    lines.append(f";  Original string bytes (Description+Flashlight fields): {total_original_bytes}")
    lines.append(f";  Compressed token refs bytes: {total_compressed_bytes}")
    lines.append(f";  Dictionary overhead bytes: {dict_overhead}")
    lines.append(f";  Net with dictionary: {total_compressed_bytes + dict_overhead} vs {total_original_bytes} original")
    
    savings = total_original_bytes - (total_compressed_bytes + dict_overhead)
    if total_original_bytes > 0:
        pct = (savings / total_original_bytes) * 100
        lines.append(f";  Savings: {savings} bytes ({pct:.1f}%)")
    lines.append("")

    return "\n".join(lines)


def main():
    # ── Load lookup tables ────────────────────────────────────
    action_ids = load_name_to_id(ACTIONS_FILE, id_field="ID", name_field="Name")

    # ── Load screens ──────────────────────────────────────────
    if not os.path.exists(JSON_FILE):
        print(f"[ERROR] '{JSON_FILE}' not found. Run the ACS editor first.")
        return

    with open(JSON_FILE, "r", encoding="utf-8") as f:
        screens = json.load(f)

    if not screens:
        print("[WARNING] No screens found in the JSON file.")
        return

    screens = dict(sorted(screens.items(), key=lambda item: int(item[1].get("ID", 0))))

    asm = to_asm(screens, action_ids)

    with open(ASM_FILE, "w", encoding="utf-8") as f:
        f.write(asm)

    print(f"[OK] Generated '{ASM_FILE}' with {len(screens)} screen(s).")
    print(f"[OK] Token dictionary: {len(build_token_dictionary(screens)[0])} unique tokens")
    print("-" * 50)
    print(asm)


if __name__ == "__main__":
    main()
