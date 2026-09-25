"""Tabella dei caratteri del testo giapponese di Just Breed (ID tile -> carattere), ricavata dai glifi del CHR.
Il testo usa 1 byte per carattere; 01 xx = kanji (pagina 0, banchi CHR 62/63: xx = ID tile sinistra della coppia)."""

KANA = {}


def _put(start, chars):
    for i, c in enumerate(chars):
        KANA[start + i] = c


_put(0x06, "がぎぐげござじずぜぞ")
_put(0x10, "だぢづでど")
_put(0x15, "ぱぴぷぺぽ")
_put(0x1A, "ばびぶべぼ")
_put(0x20, " !\"#$%&'()*+,-./")
_put(0x30, "0123456789:;<=>?")
_put(0x66, "をぁぃぅぇぉゃゅょっ")
_put(0x71, "あいうえおかきくけこさしすせそ")
_put(0x80, "たちつてとなにぬねのはひふへほま")
_put(0x90, "みむめもやゆよらりるれろわん")
_put(0xA1, "『「」』・ヲァィゥェォャュョッ")
_put(0xB0, "ーアイウエオカキクケコサシスセソ")
_put(0xC0, "タチツテトナニヌネノハヒフヘホマ")
_put(0xD0, "ミムメモヤユヨラリルレロワン゛゜")
_put(0xE6, "ガギグゲゴザジズゼゾ")
_put(0xF0, "ダヂヅデドパピプペポバビブベボ")

KANJI = {}
_KANJI_ROWS = [
    "_司祭気魔法使山", "町早出大空力中神", "下恋名入水武運村", "立星知見女人東西",
    "右姉妹森木目上男", "具日金会先生休学", "火性顔事左小本待", "物?商基地隊長剣",
    "口年戦士城話?手", "塔結界子石思蛮族", "導師機数医穴足晶", "断底持天装備状態",
    "調攻撃防御部形総", "品器鎧盾他弓当海", "道一土巣川巨並全", "麻矢聖宝新南北…",
]
for _r, _row in enumerate(_KANJI_ROWS):
    for _c, _ch in enumerate(_row):
        KANJI[2 * (_r * 8 + _c)] = _ch
# 0x72 e 0x8C sono numeri ("19", "92") disegnati come kanji: anno di copyright
KANJI[0x72] = "[19]"
KANJI[0x8C] = "[92]"


def decode_line(b):
    """Decodifica una riga di byte in stringa leggibile (i byte sconosciuti diventano <xx>)."""
    out, i = [], 0
    while i < len(b):
        c = b[i]
        if c == 0x01 and i + 1 < len(b):
            k = b[i + 1]
            out.append(KANJI.get(k, "<K%02X>" % k))
            i += 2
            continue
        out.append(KANA.get(c, "<%02X>" % c))
        i += 1
    return "".join(out)
