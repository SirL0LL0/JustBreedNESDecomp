"""Genera uno script di input per il runner (--script): menu iniziale + input casuali.
Uso: python fuzz_script.py SEED FRAMES out.txt   (serve per esplorare il gioco durante il reverse engineering)"""
import random, sys

seed, total, out = int(sys.argv[1]), int(sys.argv[2]), sys.argv[3]
rnd = random.Random(seed)
lines = ["TURBO ON", "WAIT 400"]
for _ in range(3):                      # Game 1 Start, nome, conferma
    lines += ["HOLD A", "WAIT 6", "RELEASE A", "WAIT 250"]
lines += ["HOLD START", "WAIT 6", "RELEASE START", "WAIT 400"]
used = 400 + 3 * 256 + 406
buttons = ["A"] * 8 + ["B"] + ["START"] + ["UP", "DOWN", "LEFT", "RIGHT"] * 3
while used < total:
    b = rnd.choice(buttons)
    hold = rnd.randint(4, 50) if b in ("UP", "DOWN", "LEFT", "RIGHT") else rnd.randint(2, 6)
    wait = rnd.randint(4, 40)
    lines += ["HOLD " + b, "WAIT %d" % hold, "RELEASE " + b, "WAIT %d" % wait]
    used += hold + wait
lines.append("EXIT 0")
open(out, "w").write("\n".join(lines) + "\n")
