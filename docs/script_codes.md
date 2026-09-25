# Codici dei messaggi (dialoghi) di Just Breed - appunti di reverse engineering

Fonte: 1994 messaggi decodificati con `tools/dialog_decode.py` (indice `0x0000-0x0F92`, passo 2).
Il testo e' una sequenza di byte = ID tile del font (vedi `tools/charmap_jp.py`). Il flusso compresso (Huffman) codifica
byte 0-255; il decoder del gioco tratta alcuni simboli in modo speciale:

| Simbolo | Significato | Parametro |
|---------|-------------|-----------|
| `00` | fine messaggio | - |
| `01 kk` | kanji (pagina 0), `kk` = ID tile sinistra (pari, 00-FE) | 7 bit nel flusso, ×2 |
| `02`, `03`, `04`, `60`-`63` | comandi | 1 byte (8 bit) nel flusso |
| altri | carattere normale (ID tile) | - |

Nel testo decodificato compaiono inoltre questi byte con significato di comando (da confermare col motore di stampa):

| Byte / sequenza | Frequenza | Ipotesi |
|-----------------|-----------|---------|
| `05` | ~8500 | a capo / nuova riga nella finestra |
| `59` ... `5A` | 138 | apertura e chiusura di un messaggio di sistema (finestra) |
| `24 dd` (`$n`) | molto comune | inserisce il nome del membro `n` del gruppo (`$0`, `$1`, `$2`) |
| `23 21 dd dd` (`#!nn`) | comune | id del parlante / ritratto |
| `2A 2E dd dd dd` (`*.nnn`) | comune | dà l'oggetto/evento numero nnn (?) |
| `2B dd` / `2D dd` (`+n`, `-n`) | comune | stato del dialogo / salto (?) |
| `25 dd` (`%n`) | comune | scelta multipla con n voci, seguita da `05 voce1 05 voce2 ...` |
| `5E`, `5B`, `4C`, `49`, `40`, `47`, `42` | 880/248/204/174/78/47/34 | segnaposto/icone (glifi decorativi del font: nomi speciali, cifre grandi) |

Regola per la traduzione: **tutti i token si copiano invariati nello stesso ordine**; si traduce solo il testo comune tra
i token. Il codificatore (in arrivo) lavora sui byte, quindi conserva i token.

Vincoli per il testo italiano:
* niente simboli `00`-`04`, `60`-`63` come lettere (sono codici speciali del decoder);
* `59`/`5A` (Y/Z maiuscole nel font attuale), `49` (I), `4C` (L) ecc. sono usati come comandi: le lettere italiane vanno
  assegnate a ID liberi (sostituendo i glifi kana nel CHR, banchi 60/61).
