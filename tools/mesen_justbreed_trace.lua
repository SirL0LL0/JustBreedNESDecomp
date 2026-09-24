-- mesen_justbreed_trace.lua : traccia per Mesen 2 pensata per il porting di Just Breed (MMC5).
--
-- USO: Debug > Script Window > File > Open, spunta "Allow access to I/O and OS functions",
--      poi Run. Poi gioca normalmente (piu' aree/meccaniche possibile). Non serve il Debugger.
--      L'emulazione puo' rallentare (callback Lua su ogni istruzione): metti LOG_EXEC = false
--      per tenere solo il log dei registri MMC5.
--
-- OUTPUT (cartella OUT_DIR, riscritti ogni AUTOSAVE_FRAMES frame e a fine script):
--   jb_exec.bin       1 byte per byte di PRG-ROM: bit0 = opcode eseguito, bit1 = arrivo non sequenziale
--                     (target di salto/chiamata). Stesso layout della ROM -> unibile con i CDL.
--   jb_mmc5_regs.txt  per ogni registro MMC5: valori scritti e quante volte
--   jb_mmc5_log.txt   sequenza (frame, PC scrittore, reg, valore) delle prime MAX_LOG scritture ai
--                     registri di banco/IRQ/CHR (cambi di valore soltanto)
--   jb_wram_exec.txt  indirizzi eseguiti da RAM / finestra WRAM (con i byte trovati): codice da RAM!
--   jb_status.txt     copertura e contatori
--
-- Se l'ambiente non consente io.open lo script lo dice nel log e non scrive nulla.

local OUT_DIR         = "C:/temp/justbreed/"
local PRG_SIZE        = 512 * 1024
local AUTOSAVE_FRAMES = 1800        -- circa 30 s
local LOG_EXEC        = true
local MAX_LOG         = 20000

-- ------------------------------------------------------------------ stato MMC5
local prg_mode  = 3
local prg_reg   = { [0] = 0, 0, 0 }   -- $5114..$5116
local prg_last  = 0xFF                -- $5117
local wram_bank = 0

local win = {}                        -- finestra 0..3 -> {rom=true, unit=N} | {rom=false, unit=N}
local function resolve(i, reg, span, idx, forced)
  if forced or (reg & 0x80) ~= 0 then
    local unit = ((reg & 0x7F) & ~(span - 1)) + idx
    win[i] = { rom = true, unit = unit % (PRG_SIZE // 8192) }
  else
    win[i] = { rom = false, unit = ((reg & 7) & ~(span - 1)) + idx }
  end
end
local function remap()
  local m = prg_mode & 3
  if m == 0 then
    for i = 0, 3 do resolve(i, prg_last, 4, i, true) end
  elseif m == 1 then
    resolve(0, prg_reg[1], 2, 0, false); resolve(1, prg_reg[1], 2, 1, false)
    resolve(2, prg_last, 2, 0, true);    resolve(3, prg_last, 2, 1, true)
  elseif m == 2 then
    resolve(0, prg_reg[1], 2, 0, false); resolve(1, prg_reg[1], 2, 1, false)
    resolve(2, prg_reg[2], 1, 0, false); resolve(3, prg_last, 1, 0, true)
  else
    resolve(0, prg_reg[0], 1, 0, false); resolve(1, prg_reg[1], 1, 0, false)
    resolve(2, prg_reg[2], 1, 0, false); resolve(3, prg_last, 1, 0, true)
  end
end
remap()

-- ------------------------------------------------------------------ dati raccolti
local flags = {}                      -- indice 0..PRG_SIZE-1 -> bit
local covered = 0
local frame = 0
local regvals = {}                    -- reg -> { valore -> conteggio }
local last_written = {}
local mmc5_log = {}
local wram_exec = {}                  -- addr -> { count, byte }
local last_addr, last_win_unit = nil, nil
local exec_count = 0
local windows_seen = {}               -- "unit@base" -> conteggio, per capire quali banchi girano in quale finestra

local function cpu_pc()
  local ok, st = pcall(emu.getState)
  if not ok or type(st) ~= "table" then return -1 end
  local pc = st["cpu.pc"] or (st.cpu and st.cpu.pc)
  return pc or -1
end

-- ------------------------------------------------------------------ callback
local function on_mmc5_write(addr, value)
  regvals[addr] = regvals[addr] or {}
  regvals[addr][value] = (regvals[addr][value] or 0) + 1
  if addr == 0x5100 then prg_mode = value & 3; remap()
  elseif addr >= 0x5114 and addr <= 0x5116 then prg_reg[addr - 0x5114] = value; remap()
  elseif addr == 0x5117 then prg_last = value; remap()
  elseif addr == 0x5113 then wram_bank = value & 7 end
  if last_written[addr] ~= value and #mmc5_log < MAX_LOG then
    mmc5_log[#mmc5_log + 1] = string.format("%d %04X %04X %02X", frame, cpu_pc() & 0xFFFF, addr, value)
  end
  last_written[addr] = value
end

local function on_exec(addr)
  exec_count = exec_count + 1
  if addr < 0x8000 then
    local e = wram_exec[addr]
    if not e then
      local b = 0
      pcall(function() b = emu.read(addr, emu.memType.nesMemory) end)
      wram_exec[addr] = { 1, b }
    else e[1] = e[1] + 1 end
    last_addr = nil
    return
  end
  local w = (addr - 0x8000) >> 13
  local info = win[w]
  if not info.rom then
    local key = string.format("WRAM%d@%04X", info.unit, 0x8000 + w * 0x2000)
    local e = wram_exec[addr]
    if not e then
      local b = 0
      pcall(function() b = emu.read(addr, emu.memType.nesMemory) end)
      wram_exec[addr] = { 1, b, key }
    else e[1] = e[1] + 1 end
    last_addr = nil
    return
  end
  local off = info.unit * 8192 + (addr & 0x1FFF)
  local f = flags[off] or 0
  if (f & 1) == 0 then covered = covered + 1 end
  f = f | 1
  local sequential = last_addr and addr > last_addr and addr - last_addr <= 3 and last_win_unit == info.unit
  if not sequential then f = f | 2 end
  flags[off] = f
  last_addr, last_win_unit = addr, info.unit
end

-- ------------------------------------------------------------------ scrittura file
local function open_out(name, mode)
  local ok, f = pcall(io.open, OUT_DIR .. name, mode or "w")
  if ok and f then return f end
  return nil
end

local warned = false
local function flush()
  local f = open_out("jb_exec.bin", "wb")
  if not f then
    if not warned then emu.log("[jb] impossibile scrivere in " .. OUT_DIR .. " (crea la cartella e abilita l'accesso I/O)"); warned = true end
    return
  end
  local chunk = {}
  for i = 0, PRG_SIZE - 1 do
    chunk[#chunk + 1] = string.char(flags[i] or 0)
    if #chunk == 4096 then f:write(table.concat(chunk)); chunk = {} end
  end
  if #chunk > 0 then f:write(table.concat(chunk)) end
  f:close()

  f = open_out("jb_mmc5_regs.txt")
  if f then
    local regs = {}
    for r in pairs(regvals) do regs[#regs + 1] = r end
    table.sort(regs)
    for _, r in ipairs(regs) do
      local vals = {}
      for v, c in pairs(regvals[r]) do vals[#vals + 1] = { v, c } end
      table.sort(vals, function(a, b) return a[1] < b[1] end)
      local parts = {}
      for _, p in ipairs(vals) do parts[#parts + 1] = string.format("%02X:%d", p[1], p[2]) end
      f:write(string.format("$%04X %s\n", r, table.concat(parts, " ")))
    end
    f:close()
  end

  f = open_out("jb_mmc5_log.txt")
  if f then f:write("# frame writerPC reg value\n"); f:write(table.concat(mmc5_log, "\n"), "\n"); f:close() end

  f = open_out("jb_wram_exec.txt")
  if f then
    local addrs = {}
    for a in pairs(wram_exec) do addrs[#addrs + 1] = a end
    table.sort(addrs)
    f:write("# addr count byte [window]\n")
    for _, a in ipairs(addrs) do
      local e = wram_exec[a]
      f:write(string.format("%04X %d %02X %s\n", a, e[1], e[2], e[3] or ""))
    end
    f:close()
  end

  f = open_out("jb_status.txt")
  if f then
    f:write(string.format("frame=%d\nexec_instructions=%d\nprg_bytes_executed=%d (%.2f%%)\nwram_exec_addrs=%d\nmmc5_log_entries=%d\n",
      frame, exec_count, covered, 100 * covered / PRG_SIZE, (function() local n = 0 for _ in pairs(wram_exec) do n = n + 1 end return n end)(), #mmc5_log))
    f:close()
  end
end

local function on_frame()
  frame = frame + 1
  pcall(function()
    emu.drawString(4, 4, string.format("JB trace: %d B code (%.1f%%)", covered, 100 * covered / PRG_SIZE), 0xFFFFFF, 0x80000000)
  end)
  if frame % AUTOSAVE_FRAMES == 0 then flush() end
end

-- ------------------------------------------------------------------ registrazione
for _, range in ipairs({ { 0x5100, 0x5107 }, { 0x5113, 0x5117 }, { 0x5120, 0x512B }, { 0x5130, 0x5130 },
                          { 0x5200, 0x5206 }, { 0x5800, 0x5800 } }) do
  emu.addMemoryCallback(on_mmc5_write, emu.callbackType.write, range[1], range[2])
end
if LOG_EXEC then
  emu.addMemoryCallback(on_exec, emu.callbackType.exec, 0x0000, 0xFFFF)
end
emu.addEventCallback(on_frame, emu.eventType.endFrame)
pcall(function() emu.addEventCallback(flush, emu.eventType.scriptEnded) end)

emu.log("[jb] traccia attiva. Output in " .. OUT_DIR .. " (autosave ogni " .. AUTOSAVE_FRAMES .. " frame)")
