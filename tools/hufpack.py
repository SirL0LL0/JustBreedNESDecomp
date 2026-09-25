#!/usr/bin/env python3
"""Codificatore dei dialoghi di Just Breed: albero di Huffman + flusso di bit + tabella dei puntatori.

Formato (ricavato dalla routine del gioco $D094/$D161, banco 62):
  * albero serializzato a $8000 del banco 46 (max 512 byte), nodo = header + dati:
      00 a b        due figli foglia: a (bit 0) e b (bit 1)
      01 a <nodo>   figlio 0 = foglia a, figlio 1 = nodo che segue
      n  <L> <R>    n >= 2: figlio 0 = nodo L (che segue subito), figlio 1 = nodo R a header+1+n (n = byte di L)
  * simboli speciali: 00 fine messaggio; 01 + 7 bit = kanji (codice/2); 02,03,04,60-63 + 8 bit = comando con parametro
  * bit MSB-first, ogni messaggio inizia a un confine di byte; blob <= 256 byte (il gioco ne copia 256 in $6400)
  * tabella puntatori a $8200 del banco 46 (indice = 2*n): lo, hi; posizione = unita' 16+(hi>>4), offset byte =
    ((hi&0xF)<<8 | lo) * 2 nella finestra $8000; il blob puo' continuare nell'unita' successiva.
"""
import heapq, itertools
from collections import Counter

UNIT = 8192
PARAM_SYMS = {0x02, 0x03, 0x04, 0x60, 0x61, 0x62, 0x63}


class Node:
    def __init__(self, sym=None, left=None, right=None, freq=0):
        self.sym, self.left, self.right, self.freq = sym, left, right, freq

    @property
    def leaf(self):
        return self.sym is not None


def tokenize(raw):
    """Divide i byte grezzi di un messaggio in simboli: (simbolo, param_bits, param_valore)."""
    out, i = [], 0
    while i < len(raw):
        c = raw[i]
        if c == 0x01:
            out.append((1, 7, raw[i + 1] >> 1)); i += 2
        elif c in PARAM_SYMS:
            out.append((c, 8, raw[i + 1])); i += 2
        else:
            out.append((c, 0, 0)); i += 1
    out.append((0, 0, 0))                 # fine messaggio
    return out


def build_tree(freqs):
    cnt = itertools.count()
    heap = [(f, next(cnt), Node(sym=s, freq=f)) for s, f in freqs.items()]
    if len(heap) == 1:                    # albero degenere: aggiunge un simbolo fittizio
        heap.append((0, next(cnt), Node(sym=(heap[0][2].sym + 1) & 0xFF, freq=0)))
    heapq.heapify(heap)
    while len(heap) > 1:
        f1, _, a = heapq.heappop(heap)
        f2, _, b = heapq.heappop(heap)
        heapq.heappush(heap, (f1 + f2, next(cnt), Node(left=a, right=b, freq=f1 + f2)))
    return heap[0][2]


def serialize(node, codes, prefix=""):
    """Serializza il sottoalbero (nodo interno) e riempie codes[sym] = stringa di bit. Ritorna i byte."""
    a, b = node.left, node.right
    # foglia sempre a sinistra se ce n'e' una sola; se entrambi interni il sottoalbero piu' piccolo a sinistra
    if not a.leaf and b.leaf:
        a, b = b, a
    if a.leaf and b.leaf:
        codes[a.sym] = prefix + "0"; codes[b.sym] = prefix + "1"
        return bytes([0, a.sym, b.sym])
    if a.leaf:
        codes[a.sym] = prefix + "0"
        return bytes([1, a.sym]) + serialize(b, codes, prefix + "1")
    left = serialize(a, codes, prefix + "0")
    right = serialize(b, codes, prefix + "1")
    if len(left) > 255 or len(left) < 2:
        # scambia: il piu' corto a sinistra (i codici vanno rigenerati)
        codes_tmp = {}
        left2 = serialize(b, codes_tmp, prefix + "0")
        right2 = serialize(a, codes_tmp, prefix + "1")
        if len(left2) > 255:
            raise ValueError("albero troppo grande: sottoalbero sinistro %d byte" % len(left2))
        codes.update(codes_tmp)
        return bytes([len(left2)]) + left2 + right2
    return bytes([len(left)]) + left + right


def encode_messages(msgs):
    """msgs: lista di byte grezzi. Ritorna (albero_serializzato, [blob per messaggio], codes)."""
    freqs = Counter()
    toks = [tokenize(m) for m in msgs]
    for t in toks:
        for s, _, _ in t:
            freqs[s] += 1
    root = build_tree(freqs)
    codes = {}
    tree = serialize(root, codes)
    blobs = []
    for t in toks:
        bits = []
        for s, nb, val in t:
            bits.append(codes[s])
            if nb:
                bits.append(format(val, "0%db" % nb))
        bs = "".join(bits)
        bs += "0" * (-len(bs) % 8)
        blobs.append(int(bs, 2).to_bytes(len(bs) // 8, "big") if bs else b"")
    return tree, blobs, codes


def layout(blobs, first_unit=16, last_unit=31, start_unit_off=0):
    """Posiziona i blob in sequenza (allineati a 2 byte) nello spazio lineare unita' first..last.
    Ritorna (posizioni, dimensione_usata). posizioni[i] = offset lineare dall'inizio dell'unita' first_unit."""
    pos, p = [], start_unit_off
    for b in blobs:
        if p & 1:
            p += 1
        pos.append(p)
        p += len(b)
    return pos, p


def pointer_entry(linear):
    g, off = divmod(linear, UNIT)
    assert off % 2 == 0 and off // 2 < 0x1000 and g < 16, (g, off)
    w = off // 2
    return bytes([w & 0xFF, (g << 4) | (w >> 8)])
