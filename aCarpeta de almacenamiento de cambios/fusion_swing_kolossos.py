#!/usr/bin/env python3
"""KOLOSSOS v2.0 — LA FUSION DEL SWING (la pieza 13-15 que faltaba).

Reporte del owner con la v1.9: "la animacion de los ataques el usa la
animacion swing es la animacion que faltaba que fusionaras con la
animacion de caminar y correr". El M1 basico del GMod es el gesture
ACT_MELEE_ATTACK_SWING_GESTURE (Lua l.2638) — NO el GrabPunch.

FORENSE (compara_swing_kolossos.py, sobre los SMD originales del owner):
  swing.smd    (23f): brazos reales — RightLowerArm 137.5, RightUpperArm
                      84.6, LeftUpperArm 77.8, LeftLowerArm 55.2 grados.
  swingdelta   (23f): el addlayer del torso (UpperTorso 83.9, Head 68.3).
  swingsub.smd (23f): EL SWING COMPLETO — brazos IDENTICOS a swing.smd
                      (0.0 grados de diff) + torso/cabeza/ojos con el
                      delta YA APLICADO. Es la fuente perfecta.

LA FUSION (misma receta que las 12 del pack v1.5, fusion_smd_kolossos.py):
  *_swing = piernas+Root+LowerTorso de la locomocion (walk/run/idle)
          + brazos+UpperTorso+Head+ojos de swingsub
  Timeline = los 23 frames del swing (one-shot); las piernas de la loco
  con wrap (i % len(loco)). El QC declara fps 60 -> 0.383s de barrido.

Salida: modelo_v153_completo/ (autocontenido: mesh + physics + 56 SMD
originales + 12 fusionadas del grab + 3 nuevas del swing + kolossos.qc
v1.5.3 = v1.5.2 + las 3 sequences). El owner compila con Crowbar
(misma $modelname "Noodles\\OM\\Kolossos.mdl", drop-in).
"""
import os, json, shutil

SRC_BASE = "/tmp/my-project/download/kolossos_v18/modelo_v151_completo"
SRC      = os.path.join(SRC_BASE, "kolossos_anims")
OUT_BASE = "/home/z/my-project/work/kolossos_v20_modelo/modelo_v153_completo"
OUT      = os.path.join(OUT_BASE, "kolossos_anims")
QC_IN    = os.path.join(SRC_BASE, "kolossos.qc")
QC_OUT   = os.path.join(OUT_BASE, "kolossos.qc")

# brazos (weights_swing del QC) + el torso/cabeza/ojos del swing completo
# (weights_swingdeltatosequence: UpperTorso/Head/eyes peso 1 — el addlayer
# que el GMod ponia ENCIMA del gesture; swingsub lo trae ya aplicado)
SWING_BONES = {
    "RightUpperArm", "RightLowerArm", "RightHand",
    "LeftUpperArm", "LeftLowerArm", "LeftHand",
    "LeftPinky1", "LeftPinky2",
    "LeftMiddleFinger1", "LeftMiddleFinger2",
    "LeftPointyFinger1", "LeftPointyFinger2",
    "LeftThumb1", "LeftThumb2",
    "UpperTorso", "Head", "RightEye", "LeftEye",
}
LOCO = ["idle", "walk", "run"]
SWING_SRC = "swingsub"   # el swing COMPLETO (brazos de swing.smd + torso del delta)

def parse_smd(path):
    nodes_lines, bones, frames = [], {}, []
    mode = None
    cur = None
    with open(path, "r", errors="replace") as f:
        for line in f:
            raw = line.rstrip("\n").rstrip("\r")
            t = raw.strip()
            if t == "nodes": mode = "nodes"; continue
            if mode == "nodes":
                if t == "end": mode = None; continue
                nodes_lines.append(raw)
                parts = t.split(None, 2)
                if len(parts) >= 3 and parts[0].lstrip("-").isdigit():
                    bones[int(parts[0])] = parts[1].strip('"')
                continue
            if t == "skeleton": mode = "skel"; continue
            if mode == "skel":
                if t == "end": break
                if t.startswith("time"):
                    cur = {}; frames.append(cur); continue
                parts = t.split()
                if len(parts) == 7 and cur is not None:
                    try:
                        cur[int(parts[0])] = tuple(float(x) for x in parts[1:7])
                    except ValueError:
                        pass
    return nodes_lines, bones, frames

def write_smd(path, nodes_lines, frames):
    with open(path, "w", newline="\n") as f:
        f.write("version 1\n")
        f.write("nodes\n")
        for l in nodes_lines:
            f.write(l + "\n")
        f.write("end\n")
        f.write("skeleton\n")
        for i, fr in enumerate(frames):
            f.write("time %d\n" % i)
            for bid, tr in fr.items():
                f.write("  %d %.6f %.6f %.6f %.6f %.6f %.6f\n"
                        % (bid, tr[0], tr[1], tr[2], tr[3], tr[4], tr[5]))
        f.write("end\n")

report = {"fuente": {}, "salidas": {}, "validacion": {}, "notas": []}

src_nodes, src_bones = None, None
src = {}
for name in LOCO + [SWING_SRC]:
    nl, bones, frames = parse_smd(os.path.join(SRC, name + ".smd"))
    assert len(frames) > 0, "SMD sin frames: %s" % name
    src[name] = frames
    report["fuente"][name] = len(frames)
    if src_nodes is None:
        src_nodes, src_bones = nl, bones
    else:
        assert nl == src_nodes, "nodes distinto en %s" % name
        assert bones == src_bones, "huesos distintos en %s" % name

swing_ids = {bid for bid, nm in src_bones.items() if nm in SWING_BONES}
body_ids  = set(src_bones.keys()) - swing_ids
report["notas"].append("rig: %d huesos | swing-set: %d | cuerpo: %d"
                       % (len(src_bones), len(swing_ids), len(body_ids)))
assert len(swing_ids) == len(SWING_BONES), (
    "mismatch: SWING_BONES declara %d, el rig trae %d"
    % (len(SWING_BONES), len(swing_ids)))

def frame_from(loco_fr, swing_fr):
    out = {}
    for bid in src_bones.keys():
        out[bid] = swing_fr[bid] if bid in swing_ids else loco_fr[bid]
    return out

# --- generar las 3 (one-shot: timeline del swing, piernas con wrap) ----------
os.makedirs(OUT, exist_ok=True)
swing = src[SWING_SRC]
for l in LOCO:
    loco = src[l]
    frames = [frame_from(loco[i % len(loco)], swing[i]) for i in range(len(swing))]
    write_smd(os.path.join(OUT, "%s_swing.smd" % l), src_nodes, frames)
    report["salidas"]["%s_swing" % l] = len(frames)

# --- validacion: re-parse y diff exacto contra las fuentes -------------------
all_ok = True
for l in LOCO:
    out_name = "%s_swing" % l
    _, _, frames = parse_smd(os.path.join(OUT, out_name + ".smd"))
    loco = src[l]
    worst_swing, worst_body, gaps = 0.0, 0.0, 0
    for i, fr in enumerate(frames):
        if len(fr) != len(src_bones): gaps += 1
        lf = loco[i % len(loco)]
        sf = swing[i]
        for bid, tr in fr.items():
            ref = sf[bid] if bid in swing_ids else lf[bid]
            d = max(abs(tr[k] - ref[k]) for k in range(6))
            if bid in swing_ids: worst_swing = max(worst_swing, d)
            else:                worst_body  = max(worst_body, d)
    ok = (gaps == 0 and worst_body == 0.0 and worst_swing == 0.0)
    all_ok &= ok
    report["validacion"][out_name] = {
        "frames": len(frames), "huecos": gaps,
        "desv_cuerpo": worst_body, "desv_swing": worst_swing, "OK": ok}

# --- copiar TODO el pack v1.5.2 (autocontenido) ------------------------------
copiados = 0
for fn in sorted(os.listdir(SRC)):
    dst = os.path.join(OUT, fn)
    if fn.endswith(".smd") and not os.path.exists(dst):
        shutil.copy2(os.path.join(SRC, fn), dst)
        copiados += 1
for root_extra in ["Kolossos.smd", "kolossos_physics.smd"]:
    shutil.copy2(os.path.join(SRC_BASE, root_extra), os.path.join(OUT_BASE, root_extra))
report["notas"].append("anim SMD copiados del pack v1.5.2: %d" % copiados)

# --- QC v1.5.3 = v1.5.2 + las 3 sequences ------------------------------------
with open(QC_IN, "r", errors="replace") as f:
    qc = f.read()

nuevas = """
// ---------------------------------------------------------------------------
// v2.0 — LA FUSION DEL SWING: el M1 basico (ACT_MELEE_ATTACK_SWING_GESTURE
// del Lua l.2638) con las piernas de la locomocion. Brazos+UpperTorso+Head
// de swingsub.smd (el swing COMPLETO: brazos == swing.smd a 0.0 grados +
// el delta del addlayer ya aplicado), Root+LowerTorso+piernas de la loco.
// Generadas por fusion_swing_kolossos.py — 23 frames @ 60fps = 0.383s
// ---------------------------------------------------------------------------

$sequence "idle_swing" {
        "kolossos_anims\\idle_swing.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "walk_swing" {
        "kolossos_anims\\walk_swing.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

$sequence "run_swing" {
        "kolossos_anims\\run_swing.smd"
        fadein 0.2
        fadeout 0.2
        fps 60
}

"""
qc_v153 = qc.replace('$collisionjoints "kolossos_physics.smd"',
                     nuevas + '$collisionjoints "kolossos_physics.smd"')
assert qc_v153 != qc, "ancla $collisionjoints no encontrada"
qc_v153 = qc_v153.replace("// v1.5.2: la MANO del agarre",
                          "// v1.5.3: + walk/run/idle_swing (la fusion del M1) | v1.5.2: la MANO del agarre", 1)
with open(QC_OUT, "w", newline="\n") as f:
    f.write(qc_v153)

report["qc_v153"] = QC_OUT
report["TODO_OK"] = bool(all_ok)

with open(os.path.join(OUT_BASE, "fusion_swing_report.json"), "w") as f:
    json.dump(report, f, indent=2, ensure_ascii=False)

print("=== FUSION SWING KOLOSSOS v2.0 ===")
print("fuente swingsub:", len(swing), "frames | loco:", {k: len(v) for k, v in src.items() if k != SWING_SRC})
for n, v in report["validacion"].items():
    print("  %-12s %3d frames  cuerpo=%s swing=%s %s"
          % (n, v["frames"], v["desv_cuerpo"], v["desv_swing"], "OK" if v["OK"] else "!!FALLO!!"))
print("SMD copiados:", copiados, "| QC:", QC_OUT)
print("RESULTADO:", "TODO OK" if all_ok else "HAY FALLOS")
