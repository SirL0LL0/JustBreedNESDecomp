#!/usr/bin/env python3
"""Editor offline della traduzione italiana di Just Breed (Tkinter, nessuna dipendenza).

  python tools/editor.py

Schede:
  Dialoghi     ~1994 messaggi: testo giapponese a sinistra, italiano modificabile, anteprima con lo STESSO font e le
               stesse coppie a larghezza variabile (VWF) che finiscono nella ROM, controllo token / colonne / byte.
  Interfaccia  stringhe inline dei menu (text/ui_it.tsv).
  Tabelle      nomi di oggetti, magie, luoghi, personaggi (text/tables_it.tsv), con il limite di colonne del record.
  Glifi stretti  editor a pixel dei glifi da 4 px usati dal VWF (text/narrow_glyphs.json).

Barra strumenti: Salva (Ctrl+S), Costruisci ROM (riflusso + build_it.py), Avvia nel launcher, Esporta ROM per hardware
reale e Esporta patch IPS. I sorgenti restano in text/*.tsv (esclusi da git: contengono testo dell'opera originale).
"""
import os, re, sys, subprocess, threading, shutil, base64
import tkinter as tk
from tkinter import ttk, messagebox, filedialog

here = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(here, ".."))
sys.path.insert(0, here)
import charmap_it, charmap_jp, vwf, text_wrap, text_check, preview, build_it, ui_patch, ips

TEXT = os.path.join(ROOT, "text")
JP_ROM = os.path.join(ROOT, "baserom_jp.nes")
OUT_ROM = os.path.join(ROOT, "build_rom", "jb_it_preview.nes")
LAUNCHER = os.path.join(ROOT, "build_ui", "JustBreedRecomp.exe")
TOKEN = vwf.TOKEN


def read_tsv(path, ncols):
    rows = []
    if os.path.exists(path):
        for l in open(path, encoding="utf-8"):
            p = l.rstrip("\n").split("\t")
            if len(p) >= ncols:
                rows.append(p)
    return rows


def png_bytes(pix, scale=2, fg=(240, 240, 240), bg=(16, 16, 32)):
    import zlib, struct
    h, w = len(pix) * scale, len(pix[0]) * scale
    raw = bytearray()
    for row in pix:
        line = bytearray([0])
        for v in row:
            line += bytes(fg if v else bg) * scale
        raw += bytes(line) * scale
    def chunk(t, d):
        c = struct.pack(">I", len(d)) + t + d
        return c + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)
    return b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 2, 0, 0, 0)) + \
           chunk(b"IDAT", zlib.compress(bytes(raw), 6)) + chunk(b"IEND", b"")


def photo(pix, scale=2):
    return tk.PhotoImage(data=base64.b64encode(png_bytes(pix, scale)))


class Editor(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Just Breed - editor traduzione italiana")
        self.geometry("1280x860")
        self.dirty = False
        self.load_all()
        self.build_ui()
        self.refresh_font()
        self.fill_list()
        self.bind("<Control-s>", lambda e: self.save_all())
        self.protocol("WM_DELETE_WINDOW", self.on_close)

    # ------------------------------------------------------------------ dati
    def load_all(self):
        self.jp = {}                      # id -> testo giapponese (display)
        self.order = []
        for r in read_tsv(os.path.join(TEXT, "dialog_jp.tsv"), 3):
            if r[0] != "id":
                self.jp[r[0]] = r[2]; self.order.append(r[0])
        self.it = {r[0]: r[1] for r in read_tsv(os.path.join(TEXT, "it.tsv"), 2) if r[0] != "id"}
        self.ui_jp = [(r[0], r[3]) for r in read_tsv(os.path.join(TEXT, "inline_jp.tsv"), 4) if r[0] != "offset"]
        self.ui_it = {r[0]: r[1] for r in read_tsv(os.path.join(TEXT, "ui_it.tsv"), 2) if r[0] != "offset"}
        self.tab_it = {(r[0], int(r[1])): r[2] for r in read_tsv(os.path.join(TEXT, "tables_it.tsv"), 3) if r[0] != "table"}
        self.tab_jp = {}
        if os.path.exists(JP_ROM):
            rom = open(JP_ROM, "rb").read()
            for tab, (base, width, count) in build_it.TABLES.items():
                for i in range(count):
                    rec = rom[16 + base + i * width:16 + base + (i + 1) * width]
                    rec = rec.split(b"\x00")[0]
                    self.tab_jp[(tab, i)] = charmap_jp.decode_line(rec).rstrip()
        self.alloc = vwf.alloc_from_dialog(os.path.join(TEXT, "it.tsv")) if os.path.exists(os.path.join(TEXT, "it.tsv")) else {}
        text_wrap.ALLOC = self.alloc
        text_check.ALLOC = self.alloc

    def refresh_font(self):
        self.font = preview.load_font(JP_ROM, self.alloc) if os.path.exists(JP_ROM) else None

    def realloc(self):
        """Ricalcola le coppie VWF dal testo corrente (come fa la build)."""
        lines = []
        for t in self.it.values():
            lines += t.split("<05>")
        self.alloc = vwf.build_alloc(lines)
        text_wrap.ALLOC = self.alloc
        text_check.ALLOC = self.alloc
        self.refresh_font()

    # -------------------------------------------------------------- interfaccia
    def build_ui(self):
        bar = ttk.Frame(self); bar.pack(fill="x", padx=6, pady=4)
        for txt, cmd in (("Salva (Ctrl+S)", self.save_all), ("Costruisci ROM", self.build_rom),
                         ("Avvia nel launcher", self.run_rom), ("Esporta ROM (hardware)", self.export_rom),
                         ("Esporta patch IPS", self.export_ips)):
            ttk.Button(bar, text=txt, command=cmd).pack(side="left", padx=3)
        self.status = tk.StringVar(value="pronto")
        ttk.Label(bar, textvariable=self.status).pack(side="right")
        self.nb = ttk.Notebook(self); self.nb.pack(fill="both", expand=True, padx=6, pady=4)
        self.tab_dialog(); self.tab_ui(); self.tab_tables(); self.tab_glyphs()
        self.log = tk.Text(self, height=7, state="disabled", bg="#111", fg="#ccc"); self.log.pack(fill="x", padx=6, pady=4)

    def logmsg(self, s):
        self.log.config(state="normal"); self.log.insert("end", s + "\n"); self.log.see("end"); self.log.config(state="disabled")

    # ------------------------------------------------------------- scheda dialoghi
    def tab_dialog(self):
        f = ttk.Frame(self.nb); self.nb.add(f, text="Dialoghi")
        left = ttk.Frame(f); left.pack(side="left", fill="y", padx=4, pady=4)
        top = ttk.Frame(left); top.pack(fill="x")
        self.q = tk.StringVar(); self.q.trace_add("write", lambda *a: self.fill_list())
        ttk.Entry(top, textvariable=self.q, width=16).pack(side="left")
        self.flt = tk.StringVar(value="tutti")
        cb = ttk.Combobox(top, textvariable=self.flt, values=("tutti", "tradotti", "da tradurre"), width=11, state="readonly")
        cb.pack(side="left", padx=3); cb.bind("<<ComboboxSelected>>", lambda e: self.fill_list())
        self.lb = tk.Listbox(left, width=36, height=40, exportselection=False)
        sb = ttk.Scrollbar(left, command=self.lb.yview); self.lb.config(yscrollcommand=sb.set)
        self.lb.pack(side="left", fill="y"); sb.pack(side="left", fill="y")
        self.lb.bind("<<ListboxSelect>>", self.on_select)
        right = ttk.Frame(f); right.pack(side="left", fill="both", expand=True, padx=4, pady=4)
        self.cur = None
        ttk.Label(right, text="Originale (giapponese)").pack(anchor="w")
        self.t_jp = tk.Text(right, height=6, wrap="word", state="disabled", bg="#eee"); self.t_jp.pack(fill="x")
        ttk.Label(right, text="Italiano  (invio = a capo del gioco <05>; token come <59> {02:0A} $1 vanno lasciati)").pack(anchor="w")
        self.t_it = tk.Text(right, height=8, wrap="none", undo=True, font=("Consolas", 11)); self.t_it.pack(fill="x")
        self.t_it.bind("<<Modified>>", self.on_edit)
        self.info = tk.StringVar()
        ttk.Label(right, textvariable=self.info, foreground="#a00", justify="left").pack(anchor="w", pady=3)
        ttk.Label(right, text="Anteprima (riflusso automatico, stesso font della ROM)").pack(anchor="w")
        self.cv = tk.Canvas(right, bg="#101020", height=420); self.cv.pack(fill="both", expand=True)
        self._img = None
        self._after = None

    def msg_text_to_edit(self, s):
        return s.replace("<05>", "\n")

    def edit_to_msg_text(self, s):
        return s.rstrip("\n").replace("\n", "<05>") if False else s.replace("\n", "<05>")

    def fill_list(self):
        q, flt = self.q.get().lower(), self.flt.get()
        self.lb.delete(0, "end"); self.ids = []
        for mid in self.order:
            done = mid in self.it and self.it[mid].strip() != ""
            if flt == "tradotti" and not done or flt == "da tradurre" and done:
                continue
            txt = (self.it.get(mid) if done else self.jp[mid]).replace("<05>", " ")
            if q and q not in mid.lower() and q not in txt.lower():
                continue
            self.lb.insert("end", "%s %s %s" % (mid, "✔" if done else "·", txt[:40]))
            self.ids.append(mid)

    def on_select(self, ev=None):
        sel = self.lb.curselection()
        if not sel:
            return
        self.commit_current()
        self.cur = self.ids[sel[0]]
        self.t_jp.config(state="normal"); self.t_jp.delete("1.0", "end")
        self.t_jp.insert("1.0", self.msg_text_to_edit(self.jp[self.cur])); self.t_jp.config(state="disabled")
        self.loading = True
        self.t_it.delete("1.0", "end"); self.t_it.insert("1.0", self.msg_text_to_edit(self.it.get(self.cur, "")))
        self.t_it.edit_reset(); self.t_it.edit_modified(False); self.loading = False
        self.update_preview()

    def commit_current(self):
        if self.cur is None:
            return
        s = self.edit_to_msg_text(self.t_it.get("1.0", "end-1c"))
        if s.strip() == "":
            if self.cur in self.it:
                del self.it[self.cur]; self.dirty = True
        elif self.it.get(self.cur) != s:
            self.it[self.cur] = s; self.dirty = True

    def on_edit(self, ev=None):
        if getattr(self, "loading", False) or not self.t_it.edit_modified():
            return
        self.t_it.edit_modified(False)
        self.dirty = True
        if self._after:
            self.after_cancel(self._after)
        self._after = self.after(250, self.update_preview)

    def update_preview(self):
        self._after = None
        if self.cur is None:
            return
        s = self.edit_to_msg_text(self.t_it.get("1.0", "end-1c"))
        problems = []
        if s.strip():
            jp_tok = [t for t in TOKEN.findall(self.jp[self.cur]) if t not in ("<05>", "<5E>")]
            it_tok = [t for t in TOKEN.findall(s) if t not in ("<05>", "<5E>")]
            if jp_tok != it_tok:
                problems.append("TOKEN diversi da quelli giapponesi:\n   JP %s\n   IT %s" % (jp_tok, it_tok))
            try:
                wrapped = text_wrap.wrap_message(s)
                n = len(charmap_it.encode_text(wrapped, self.alloc))
                cols = max([text_check.visible_lines(l)[0] for l in wrapped.split("<05>")] + [0])
                if n > 254:
                    problems.append("troppo lungo: %d byte (max 254)" % n)
                self.info.set("%d byte | riga piu' larga %d colonne (max 26) | coppie VWF attive: %d" % (n, cols, len(self.alloc)))
                pages = preview.render_message(wrapped, self.alloc)
                if self.font and pages:
                    self._img = photo(preview.tile_pixels(pages, self.font), 2)
                    self.cv.delete("all"); self.cv.create_image(4, 4, anchor="nw", image=self._img)
                    self.cv.config(scrollregion=(0, 0, 440, self._img.height() + 8))
            except ValueError as e:
                problems.append(str(e))
        else:
            self.info.set("(non tradotto)")
            self.cv.delete("all")
        if problems:
            self.info.set(self.info.get() + "\n" + "\n".join(problems))

    # -------------------------------------------------------------- scheda interfaccia
    def tab_ui(self):
        f = ttk.Frame(self.nb); self.nb.add(f, text="Interfaccia")
        cols = ("offset", "jp", "it")
        self.tv_ui = ttk.Treeview(f, columns=cols, show="headings", height=22)
        for c, w in zip(cols, (90, 380, 380)):
            self.tv_ui.heading(c, text={"offset": "Offset", "jp": "Giapponese", "it": "Italiano"}[c]); self.tv_ui.column(c, width=w)
        self.tv_ui.pack(fill="both", expand=True, padx=4, pady=4)
        for off, jp in self.ui_jp:
            self.tv_ui.insert("", "end", iid=off, values=(off, jp.replace("<05>", " ⏎ "), self.ui_it.get(off, "").replace("<05>", " ⏎ ")))
        ed = ttk.Frame(f); ed.pack(fill="x", padx=4, pady=4)
        self.e_ui = tk.StringVar(); ttk.Entry(ed, textvariable=self.e_ui, width=100).pack(side="left")
        ttk.Button(ed, text="Applica", command=self.apply_ui_edit).pack(side="left", padx=4)
        self.ui_info = tk.StringVar(); ttk.Label(ed, textvariable=self.ui_info, foreground="#a00").pack(side="left")
        self.tv_ui.bind("<<TreeviewSelect>>", lambda e: self.e_ui.set(self.ui_it.get(self.tv_ui.selection()[0], "")) if self.tv_ui.selection() else None)
        ttk.Label(f, text="Usa <05> per andare a capo; i comandi {02:xx} vanno lasciati identici; ogni offset e' una stringa dopo JSR $97CF.").pack(anchor="w", padx=4)

    def apply_ui_edit(self):
        sel = self.tv_ui.selection()
        if not sel:
            return
        off, text = sel[0], self.e_ui.get()
        jp = dict(self.ui_jp)[off]
        try:
            charmap_it.encode_text(text)
        except ValueError as e:
            self.ui_info.set(str(e)); return
        pj = re.findall(r"\{[0-9A-F]{2}:[0-9A-F]{2}\}", jp); pi = re.findall(r"\{[0-9A-F]{2}:[0-9A-F]{2}\}", text)
        if pj != pi:
            self.ui_info.set("comandi {cc:pp} diversi: %s" % pj); return
        if text.strip():
            self.ui_it[off] = text
        else:
            self.ui_it.pop(off, None)
        self.tv_ui.item(off, values=(off, jp.replace("<05>", " ⏎ "), text.replace("<05>", " ⏎ ")))
        self.ui_info.set(""); self.dirty = True

    # ---------------------------------------------------------------- scheda tabelle
    def tab_tables(self):
        f = ttk.Frame(self.nb); self.nb.add(f, text="Tabelle")
        cols = ("tab", "id", "jp", "it", "max")
        self.tv_tab = ttk.Treeview(f, columns=cols, show="headings", height=22)
        for c, w, t in zip(cols, (80, 50, 240, 240, 60), ("Tabella", "Id", "Giapponese", "Italiano", "Max")):
            self.tv_tab.heading(c, text=t); self.tv_tab.column(c, width=w)
        self.tv_tab.pack(fill="both", expand=True, padx=4, pady=4)
        for (tab, i), jp in sorted(self.tab_jp.items(), key=lambda kv: (list(build_it.TABLES).index(kv[0][0]), kv[0][1])):
            self.tv_tab.insert("", "end", iid="%s:%d" % (tab, i),
                               values=(tab, i, jp, self.tab_it.get((tab, i), ""), build_it.TABLES[tab][1] - 1))
        ed = ttk.Frame(f); ed.pack(fill="x", padx=4, pady=4)
        self.e_tab = tk.StringVar(); ttk.Entry(ed, textvariable=self.e_tab, width=40).pack(side="left")
        ttk.Button(ed, text="Applica", command=self.apply_tab_edit).pack(side="left", padx=4)
        self.tab_info = tk.StringVar(); ttk.Label(ed, textvariable=self.tab_info, foreground="#a00").pack(side="left")
        self.tv_tab.bind("<<TreeviewSelect>>", self.on_tab_select)
        ttk.Label(f, text="Il campo ha larghezza fissa (Max colonne): niente VWF nelle tabelle.").pack(anchor="w", padx=4)

    def on_tab_select(self, ev=None):
        sel = self.tv_tab.selection()
        if sel:
            tab, i = sel[0].split(":")
            self.e_tab.set(self.tab_it.get((tab, int(i)), ""))

    def apply_tab_edit(self):
        sel = self.tv_tab.selection()
        if not sel:
            return
        tab, i = sel[0].split(":"); i = int(i); text = self.e_tab.get()
        try:
            n = len(charmap_it.encode_text(text))
        except ValueError as e:
            self.tab_info.set(str(e)); return
        mx = build_it.TABLES[tab][1] - 1
        if n > mx:
            self.tab_info.set("%d colonne (max %d)" % (n, mx)); return
        if text.strip():
            self.tab_it[(tab, i)] = text
        else:
            self.tab_it.pop((tab, i), None)
        v = list(self.tv_tab.item(sel[0], "values")); v[3] = text; self.tv_tab.item(sel[0], values=v)
        self.tab_info.set(""); self.dirty = True

    # ------------------------------------------------------------ scheda glifi stretti
    def tab_glyphs(self):
        f = ttk.Frame(self.nb); self.nb.add(f, text="Glifi stretti (VWF)")
        left = ttk.Frame(f); left.pack(side="left", fill="y", padx=6, pady=6)
        self.g_chars = list(vwf.NARROW)
        self.g_lb = tk.Listbox(left, height=16, width=8, exportselection=False, font=("Consolas", 14))
        for c in self.g_chars:
            self.g_lb.insert("end", repr(c))
        self.g_lb.pack(); self.g_lb.bind("<<ListboxSelect>>", self.on_glyph_select)
        ttk.Button(left, text="Ripristina", command=self.glyph_reset).pack(pady=4)
        self.gc = tk.Canvas(f, width=4 * 24 + 2, height=16 * 24 + 2, bg="#222"); self.gc.pack(side="left", padx=10, pady=6)
        self.gc.bind("<Button-1>", lambda e: self.glyph_click(e, None)); self.gc.bind("<B1-Motion>", lambda e: self.glyph_click(e, self.g_paint))
        self.gc.bind("<Button-3>", lambda e: self.glyph_click(e, 0))
        self.g_cur = None; self.g_paint = 1
        rt = ttk.Frame(f); rt.pack(side="left", fill="both", expand=True, padx=6, pady=6)
        ttk.Label(rt, text="Clic sinistro = disegna/cancella (trascina), destro = cancella.\nOgni glifo occupa 4 pixel (x=0..3); l'inchiostro sta in x=1..2, con 1 px di margine.\nAnteprima di alcune coppie:").pack(anchor="w")
        self.g_prev = tk.Label(rt, bg="#101020"); self.g_prev.pack(anchor="w", pady=6)
        ttk.Button(rt, text="Salva glifi (text/narrow_glyphs.json)", command=self.save_glyphs).pack(anchor="w")

    def on_glyph_select(self, ev=None):
        sel = self.g_lb.curselection()
        if sel:
            self.g_cur = self.g_chars[sel[0]]; self.draw_glyph()

    def draw_glyph(self):
        self.gc.delete("all")
        rows = vwf.NARROW[self.g_cur]
        for y in range(16):
            for x in range(4):
                on = rows[y] >> (3 - x) & 1
                self.gc.create_rectangle(x * 24 + 2, y * 24 + 2, x * 24 + 26, y * 24 + 26, fill="#eee" if on else "#333", outline="#555")
        self.update_glyph_preview()

    def glyph_click(self, ev, val):
        if self.g_cur is None:
            return
        x, y = (ev.x - 2) // 24, (ev.y - 2) // 24
        if not (0 <= x < 4 and 0 <= y < 16):
            return
        rows = list(vwf.NARROW[self.g_cur]); bit = 1 << (3 - x)
        cur = bool(rows[y] & bit)
        if val is None:
            self.g_paint = 0 if cur else 1; val = self.g_paint
        rows[y] = (rows[y] | bit) if val else (rows[y] & ~bit & 15)
        vwf.NARROW[self.g_cur] = rows; self.draw_glyph(); self.dirty = True

    def update_glyph_preview(self):
        if not self.font:
            return
        sample = "il rito fatti, tra li'.;:! rit t f j"
        tmp = vwf.build_alloc([sample])
        tiles_font = dict(preview.load_font(JP_ROM, tmp))
        pix = preview.tile_pixels([[preview.line_tiles(sample, tmp)]], tiles_font)[:16]
        self._gimg = photo(pix, 3); self.g_prev.config(image=self._gimg)

    def glyph_reset(self):
        if self.g_cur:
            import importlib
            vwf.NARROW.pop(self.g_cur, None)
            fresh = importlib.reload(vwf)
            self.draw_glyph()

    def save_glyphs(self):
        import json
        json.dump({k: v for k, v in vwf.NARROW.items()}, open(os.path.join(TEXT, "narrow_glyphs.json"), "w", encoding="utf-8"))
        self.refresh_font(); self.status.set("glifi salvati"); self.update_preview()

    # ---------------------------------------------------------------- salvataggio
    def save_all(self):
        self.commit_current()
        os.makedirs(TEXT, exist_ok=True)
        with open(os.path.join(TEXT, "it.tsv"), "w", encoding="utf-8", newline="\n") as f:
            f.write("id\tit\n")
            for mid in self.order:
                if mid in self.it and self.it[mid].strip():
                    f.write("%s\t%s\n" % (mid, self.it[mid]))
        with open(os.path.join(TEXT, "ui_it.tsv"), "w", encoding="utf-8", newline="\n") as f:
            f.write("offset\tit\n")
            for off, _ in self.ui_jp:
                if off in self.ui_it:
                    f.write("%s\t%s\n" % (off, self.ui_it[off]))
        with open(os.path.join(TEXT, "tables_it.tsv"), "w", encoding="utf-8", newline="\n") as f:
            f.write("table\tid\tit\n")
            for (tab, i), t in sorted(self.tab_it.items(), key=lambda kv: (list(build_it.TABLES).index(kv[0][0]), kv[0][1])):
                f.write("%s\t%d\t%s\n" % (tab, i, t))
        self.dirty = False
        self.realloc()
        self.update_preview()
        self.status.set("salvato")

    # --------------------------------------------------------------- build / export
    def run_cmd(self, cmds, done=None):
        def work():
            ok = True
            for c in cmds:
                self.after(0, self.logmsg, "$ " + " ".join(os.path.basename(x) for x in c))
                p = subprocess.Popen([sys.executable] + c, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, encoding="utf-8", errors="replace")
                for line in p.stdout:
                    self.after(0, self.logmsg, line.rstrip())
                if p.wait() != 0:
                    ok = False; break
            self.after(0, lambda: (self.status.set("fatto" if ok else "ERRORE (vedi log)"), done(ok) if done else None))
        self.status.set("in corso..."); threading.Thread(target=work, daemon=True).start()

    def build_rom(self, done=None):
        self.save_all()
        os.makedirs(os.path.dirname(OUT_ROM), exist_ok=True)
        self.run_cmd([[os.path.join("tools", "text_wrap.py"), "text/it.tsv", "text/it_wrapped.tsv"],
                      [os.path.join("tools", "build_it.py"), "baserom_jp.nes", "text/it_wrapped.tsv", "build_rom/jb_it_preview.nes"]], done)

    def run_rom(self):
        def go(ok):
            if not ok:
                return
            if not os.path.exists(LAUNCHER):
                messagebox.showerror("Launcher", "Non trovo %s (compilalo con cmake)." % LAUNCHER); return
            env = dict(os.environ, JB_ANY_ROM="1")
            subprocess.Popen([LAUNCHER, OUT_ROM], cwd=os.path.dirname(LAUNCHER), env=env)
            self.status.set("avviato")
        self.build_rom(go)

    def export_rom(self):
        def go(ok):
            if not ok:
                return
            dst = filedialog.asksaveasfilename(defaultextension=".nes", initialfile="JustBreed_ITA.nes", filetypes=[("NES ROM", "*.nes")])
            if dst:
                shutil.copyfile(OUT_ROM, dst)
                messagebox.showinfo("Esportata", "ROM iNES mapper 5 (MMC5), stessa dimensione dell'originale.\n"
                                    "Per hardware reale: cartuccia/flash cart con supporto MMC5 e WRAM da 8KB con batteria.")
        self.build_rom(go)

    def export_ips(self):
        def go(ok):
            if not ok:
                return
            dst = filedialog.asksaveasfilename(defaultextension=".ips", initialfile="JustBreed_ITA.ips", filetypes=[("IPS", "*.ips")])
            if dst:
                a, b = open(JP_ROM, "rb").read(), open(OUT_ROM, "rb").read()
                p = ips.make_ips(a, b); assert ips.apply_ips(a, p) == b
                open(dst, "wb").write(p)
                messagebox.showinfo("Patch IPS", "Scritta %s (%d byte). Si applica alla ROM giapponese originale." % (dst, len(p)))
        self.build_rom(go)

    def on_close(self):
        if self.dirty and messagebox.askyesno("Salvare?", "Ci sono modifiche non salvate. Salvare?"):
            self.save_all()
        self.destroy()


if __name__ == "__main__":
    app = Editor()
    if "--selftest" in sys.argv:
        app.after(800, app.destroy)
    app.mainloop()
