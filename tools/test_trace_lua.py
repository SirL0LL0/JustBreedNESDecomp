"""Prova lo script Lua di Mesen con un finto oggetto `emu` (richiede: pip install lupa)."""
import os, sys, tempfile
from lupa import LuaRuntime

here = os.path.dirname(os.path.abspath(__file__))
src = open(os.path.join(here, "mesen_justbreed_trace.lua"), encoding="utf-8").read()
out = tempfile.mkdtemp() + "/"
src = src.replace('"C:/temp/justbreed/"', '"%s"' % out.replace("\\", "/")).replace("AUTOSAVE_FRAMES = 1800", "AUTOSAVE_FRAMES = 2")

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("""
cbs = { write = {}, exec = {}, frame = {}, ended = {} }
emu = {
  callbackType = { write = "write", exec = "exec" },
  eventType = { endFrame = "endFrame", scriptEnded = "scriptEnded" },
  memType = { nesMemory = 0 },
  addMemoryCallback = function(f, t, a, b) table.insert(cbs[t], { f, a, b }) end,
  addEventCallback = function(f, t) if t == "endFrame" then table.insert(cbs.frame, f) else table.insert(cbs.ended, f) end end,
  log = function(s) print(s) end,
  read = function(a, t) return 0xEA end,
  getState = function() return { ["cpu.pc"] = 0xE100 } end,
  drawString = function() end,
}
function do_write(a, v) for _, c in ipairs(cbs.write) do if a >= c[2] and a <= c[3] then c[1](a, v) end end end
function do_exec(a) for _, c in ipairs(cbs.exec) do c[1](a) end end
function do_frame() for _, c in ipairs(cbs.frame) do c() end end
function do_end() for _, c in ipairs(cbs.ended) do c() end end
""")
lua.execute(src)
g = lua.globals()

# power-on: $E000 window = ROM unit 63; program the game's real init
for a, v in [(0x5100, 3), (0x5116, 0xFD), (0x5117, 0xFF), (0x5114, 0x80 | 5), (0x5115, 0x00)]:
    g.do_write(a, v)
for a in (0xE000, 0xE002, 0xE005):          # sequential opcodes in unit 63
    g.do_exec(a)
g.do_exec(0x8010)                             # ROM unit 5
g.do_exec(0xA020); g.do_exec(0xA023)          # WRAM window ($5115=0)
g.do_exec(0x0300)                             # RAM code
g.do_write(0x5115, 0x80 | 9); g.do_exec(0xA020)
g.do_frame(); g.do_frame()                    # triggers autosave
g.do_end()

data = open(out + "jb_exec.bin", "rb").read()
assert len(data) == 512 * 1024
off = lambda unit, o: unit * 8192 + o
assert data[off(63, 0)] == 3                  # first exec = entry (bit1) + code (bit0)
assert data[off(63, 2)] == 1 and data[off(63, 5)] == 1   # sequential: no entry flag
assert data[off(5, 0x10)] == 3                # unit 5 via $8000 window
assert data[off(9, 0x20)] == 3                # unit 9 via $A000 after remap
wram = open(out + "jb_wram_exec.txt").read()
assert "A020" in wram and "0300" in wram and "WRAM0@A000" in wram
regs = open(out + "jb_mmc5_regs.txt").read()
assert "$5117 FF:1" in regs and "$5114 85:1" in regs
log = open(out + "jb_mmc5_log.txt").read()
assert "E100 5115 00" in log
status = open(out + "jb_status.txt").read()
assert "prg_bytes_executed=5" in status, status
print("script Lua OK - output in", out)

