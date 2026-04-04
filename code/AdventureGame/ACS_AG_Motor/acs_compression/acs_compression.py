"""
acs_compression.py
──────────────────
Shared string compression for ACS parsers.

Simple encoding:
  - Words stored AS-IS (with punctuation, original case)
  - Frequent words (freq≥2) in dictionary → 1-byte token ID
  - Rare words (freq=1) stored inline as literal ASCII
  - Space between words is IMPLICIT (decoder inserts space)

Byte values:
  $00-$F8  → dictionary word token ID (max 249 entries)
  $F9      → end of inline literal
  $FA      → start inline literal (raw ASCII bytes follow until $F9)
  $FB      → (reserved)
  $FC      → (reserved)
  $FD      → (reserved)
  $FE      → newline character
  $FF      → end of compressed string

Decoder logic:
  - Read byte B
  - If B <= $F8: look up word in token_dict_index[B], print it, print space
  - If B == $FA: read bytes until $F9, print them as ASCII, print space
  - If B == $FE: print newline (no space)
  - If B == $FF: stop
"""

import json
import os
import re
from collections import Counter

SCREENS_JSON = "acs_screens.json"
ACTIONS_JSON = "acs_actions.json"
SENSORS_JSON = "acs_sensors.json"

SCREEN_STRING_FIELDS = ["Description", "FlashlightOn", "FlashlightOff"]
ACTION_STRING_FIELDS = ["Description", "DescriptionActionFailed"]
SENSOR_STRING_FIELDS = ["DialogOn", "DialogOff"]

TOKEN_END        = 0xFF
TOKEN_NEWLINE    = 0xFE
TOKEN_INLINE     = 0xFA
TOKEN_INLINE_END = 0xF9
MAX_TOKEN_ID     = 0xF8  # 249 usable dictionary slots


def _collect_all_texts():
    texts = []
    for filepath, fields in [
        (SCREENS_JSON, SCREEN_STRING_FIELDS),
        (ACTIONS_JSON, ACTION_STRING_FIELDS),
        (SENSORS_JSON, SENSOR_STRING_FIELDS),
    ]:
        if not os.path.exists(filepath):
            continue
        with open(filepath, "r", encoding="utf-8") as f:
            data = json.load(f)
        for rec in data.values():
            for field in fields:
                t = rec.get(field, "")
                if t and t.strip():
                    texts.append(t)
    return texts


def build_shared_dictionary():
    """
    Build dictionary from words appearing 2+ times across all sources.
    Words stored as-is (original case, with punctuation).
    Sorted by frequency (most common → lowest ID).
    """
    texts = _collect_all_texts()
    freq = Counter()
    for text in texts:
        for word in re.findall(r'\S+', text):
            freq[word] += 1

    # Only words with freq >= 2
    frequent = {w: c for w, c in freq.items() if c >= 2}
    sorted_words = sorted(frequent.keys(), key=lambda w: -frequent[w])

    if len(sorted_words) > MAX_TOKEN_ID + 1:
        print(f"[WARNING] {len(sorted_words)} frequent words, truncating to {MAX_TOKEN_ID + 1}")
        sorted_words = sorted_words[:MAX_TOKEN_ID + 1]

    word_to_id = {word: idx for idx, word in enumerate(sorted_words)}
    id_to_word = {idx: word for idx, word in enumerate(sorted_words)}

    return word_to_id, id_to_word, freq


def compress_text(text, word_to_id):
    """Compress text into a list of byte values."""
    if not text or not text.strip():
        return [TOKEN_END]

    bytes_out = []
    lines = text.split('\n')

    for li, line in enumerate(lines):
        words = re.findall(r'\S+', line)
        for word in words:
            if word in word_to_id:
                bytes_out.append(word_to_id[word])
            else:
                # Inline literal
                bytes_out.append(TOKEN_INLINE)
                for b in word.encode('utf-8'):
                    bytes_out.append(b)
                bytes_out.append(TOKEN_INLINE_END)

        if li < len(lines) - 1:
            bytes_out.append(TOKEN_NEWLINE)

    bytes_out.append(TOKEN_END)
    return bytes_out


def emit_dictionary_asm(id_to_word, freq):
    """Generate the shared token dictionary as ASM."""
    lines = []
    lines.append("; ════════════════════════════════════════════════════════════")
    lines.append(";  ACS Shared Token Dictionary")
    lines.append(";  1-byte IDs, implicit space between words")
    lines.append(f";  $FF=end  $FE=\\n  $FA..$F9=inline literal")
    lines.append(f";  {len(id_to_word)} entries")
    lines.append("; ════════════════════════════════════════════════════════════")
    lines.append("")

    lines.append("token_dict_index:")
    for tid in range(len(id_to_word)):
        word = id_to_word[tid]
        count = freq.get(word, 0)
        lines.append(f"  .word token_{tid}  ; [{tid}] \"{word}\" (x{count})")
    lines.append("")

    for tid in range(len(id_to_word)):
        word = id_to_word[tid]
        word_asm = word.replace('"', '\\"')
        lines.append(f"token_{tid}:  ; \"{word}\"")
        w = word_asm
        while len(w) > 80:
            lines.append(f'  .ascii "{w[:80]}"')
            w = w[80:]
        if w:
            lines.append(f'  .ascii "{w}"')
        lines.append("")

    lines.append("token_dict_count:")
    lines.append(f"  .byte {len(id_to_word)}")
    lines.append("")
    return lines


def emit_compressed_field_asm(label, text, word_to_id, id_to_word):
    """Emit a compressed string field as .byte directives with correct comments."""
    lines = []
    lines.append(f"{label}:")

    compressed = compress_text(text, word_to_id)

    if len(compressed) == 1 and compressed[0] == TOKEN_END:
        lines.append(f"  .byte ${TOKEN_END:02X}  ; end (empty)")
        lines.append("")
        return lines

    # Build comment-annotated output
    i = 0
    chunk_bytes = []
    chunk_comments = []

    while i < len(compressed):
        b = compressed[i]

        if b == TOKEN_END:
            chunk_bytes.append(f"${b:02X}")
            chunk_comments.append("end")
            # Flush
            lines.append(f"  .byte {', '.join(chunk_bytes)}  ; {' | '.join(chunk_comments)}")
            chunk_bytes = []
            chunk_comments = []
            i += 1

        elif b == TOKEN_NEWLINE:
            chunk_bytes.append(f"${b:02X}")
            chunk_comments.append("\\n")
            i += 1

        elif b == TOKEN_INLINE:
            # Collect the inline literal bytes until TOKEN_INLINE_END
            literal_bytes = []
            i += 1
            while i < len(compressed) and compressed[i] != TOKEN_INLINE_END:
                literal_bytes.append(compressed[i])
                i += 1
            if i < len(compressed):
                i += 1  # skip TOKEN_INLINE_END

            # Reconstruct the word for the comment
            try:
                inline_word = bytes(literal_bytes).decode('utf-8')
            except:
                inline_word = "?"

            # Emit as: $FA, bytes..., $F9
            chunk_bytes.append(f"${TOKEN_INLINE:02X}")
            for lb in literal_bytes:
                chunk_bytes.append(f"${lb:02X}")
            chunk_bytes.append(f"${TOKEN_INLINE_END:02X}")
            chunk_comments.append(f"\"{inline_word}\"")

        elif b <= MAX_TOKEN_ID and b in id_to_word:
            chunk_bytes.append(f"${b:02X}")
            chunk_comments.append(id_to_word[b])
            i += 1

        else:
            chunk_bytes.append(f"${b:02X}")
            chunk_comments.append(f"?${b:02X}")
            i += 1

        # Flush at 12 bytes or at end
        if len(chunk_bytes) >= 12:
            lines.append(f"  .byte {', '.join(chunk_bytes)}  ; {' | '.join(chunk_comments)}")
            chunk_bytes = []
            chunk_comments = []

    if chunk_bytes:
        lines.append(f"  .byte {', '.join(chunk_bytes)}  ; {' | '.join(chunk_comments)}")

    lines.append("")
    return lines


def compute_stats(texts, word_to_id):
    total_original = sum(len(t.encode('utf-8')) for t in texts)
    total_compressed = sum(len(compress_text(t, word_to_id)) for t in texts)
    dict_bytes = sum(len(w.encode('utf-8')) for w in word_to_id.keys())
    dict_bytes += len(word_to_id) * 2  # index table .word pointers
    return total_original, total_compressed, dict_bytes


def compute_global_stats():
    word_to_id, id_to_word, freq = build_shared_dictionary()
    texts = _collect_all_texts()
    total_orig, total_comp, dict_bytes = compute_stats(texts, word_to_id)
    net = total_comp + dict_bytes
    savings = total_orig - net
    pct = (savings / total_orig * 100) if total_orig > 0 else 0
    return {
        "total_original": total_orig,
        "total_compressed": total_comp,
        "dict_bytes": dict_bytes,
        "dict_entries": len(word_to_id),
        "net": net,
        "savings": savings,
        "pct": pct,
    }
