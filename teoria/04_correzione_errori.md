# Blocco 3 — Correzione errori (+ purification)

## Il problema

I qubit sono **fragili**: il rumore introduce **errori**. Su un qubit ci sono **due tipi di errore base**:

- **bit-flip** = uno `X`: scambia `|0⟩↔|1⟩` (come il bit classico che si ribalta);
- **phase-flip** = uno `Z`: mette un `−` su `|1⟩` (`α|0⟩+β|1⟩ → α|0⟩−β|1⟩`). Esiste **solo in
  quantistica** (tocca la fase / le coerenze, non il valore).

Vogliamo **proteggere** l'informazione quantistica da questi errori.

## Perché è difficile (due ostacoli)

Nel **classico** correggi **copiando**: mandi `000` invece di `0`; se arriva `010`, **voto di
maggioranza** → `0`. In **quantistica** questa ricetta è **vietata due volte**:

1. **No-cloning** (file 03): non puoi fare 3 **copie** di un qubit sconosciuto.
2. **La misura collassa:** non puoi nemmeno **guardare** il qubit per vedere se è sbagliato →
   misurarlo **distrugge** la sovrapposizione (perdi `α, β`).

Quindi: né "copia", né "controlla guardando". Servono due trucchi.

## I due trucchi della QEC

1. **Ridondanza SENZA copiare.** Invece di copiare lo stato, lo **spalmi** (entangli) su più
   qubit fisici: 1 qubit logico → 3 fisici, `α|0⟩+β|1⟩ → α|000⟩+β|111⟩`. **Non** sono 3 copie di
   `|ψ⟩` (sarebbe no-cloning): è **un** unico stato entangled che porta la stessa info distribuita.
2. **Rilevare l'errore SENZA leggere i dati (la sindrome).** Non misuri i qubit (collasserebbero).
   Misuri invece una **parità**: `Z₁Z₂` chiede *"i qubit 1 e 2 hanno lo stesso valore?"* → dà
   **+1 se concordano**, **−1 se discordano**. (Ti dice *se* sono uguali, **non** *quanto* valgono.)

   *Perché non rivela `α, β`:* nello stato codificato `α|000⟩+β|111⟩` i tre qubit sono **sempre tutti
   concordi** (sia in `|000⟩` sia in `|111⟩`) → la parità fa `+1` in **entrambi** i rami → non
   distingue `|000⟩` da `|111⟩` → lo stato logico **non collassa**.

   *Come localizza l'errore:* un qubit **ribaltato discorda dai vicini**. Dal **pattern** di due
   parità (`Z₁Z₂` e `Z₂Z₃`) capisci quale: entrambe `−1` → il colpevole è il qubit **2** (l'unico
   in tutti e due i confronti); solo la prima `−1` → qubit 1; solo la seconda → qubit 3. (Tabella in §17.)

Poi **correggi:** noto *dove* è l'errore (dalla sindrome), applichi il **gate inverso** (qui una `X`)
e lo annulli.

## Il piano del blocco

**bit-flip** (corregge gli `X`) → **phase-flip** (corregge gli `Z`; è il bit-flip nella base di
Hadamard) → **Shor** (i due insieme → **qualsiasi** errore). Poi la **purification**, che collega
al tuo progetto.

---

## 17. Codice bit-flip (3 qubit) — corregge errori X

### Encoding (bit-flip)

```text
|0⟩ → |000⟩        |1⟩ → |111⟩
α|0⟩+β|1⟩ → α|000⟩+β|111⟩
```

Circuito: 2 CNOT dal qubit dati verso 2 ancille |0⟩.

```text
|ψ⟩ ──●──●──
      │  │
|0⟩ ──⊕──┼──
         │
|0⟩ ─────⊕──
```

Le operazioni (le 2 CNOT sono entrambe controllate da q1):

```text
Inizio:  q1=α|0⟩+β|1⟩,  q2=q3=|0⟩   →   α|000⟩ + β|100⟩

CNOT(q1→q2):  α|000⟩ → α|000⟩          (q1=0, niente)
              β|100⟩ → β|110⟩          (q1=1 → q2: 0→1)
           =  α|000⟩ + β|110⟩

CNOT(q1→q3):  α|000⟩ → α|000⟩          (q1=0, niente)
              β|110⟩ → β|111⟩          (q1=1 → q3: 0→1)
           =  α|000⟩ + β|111⟩          ✓ codificato
```

### Errore + sindrome

Misuro le parità `Z₁Z₂` e `Z₂Z₃` (con 2 ancille), **senza** toccare α,β. La sindrome dice dove:

| Z₁Z₂ | Z₂Z₃ | errore su |
| --- | --- | --- |
| +1 | +1 | nessuno |
| −1 | +1 | qubit 1 |
| −1 | −1 | qubit 2 |
| +1 | −1 | qubit 3 |

**Il circuito che misura le parità** (2 ancille `|0⟩`, una per parità):

```text
Z₁Z₂  (ancilla a1 confronta q1 e q2):
q1 ──●───────
     │
q2 ──┼──●────
     │  │
a1 ──⊕──⊕── M

Z₂Z₃  (ancilla a2 confronta q2 e q3):
q2 ──●───────
     │
q3 ──┼──●────
     │  │
a2 ──⊕──⊕── M

misuri le ancille:  0 → +1 (concordi)   1 → −1 (discordi)
```

I dati `q1,q2,q3` sono solo **controlli** → restano intatti; le ancille raccolgono la parità.

### Correzione

Dalla sindrome sai **quale** qubit è sbagliato. Applichi una `X` su quello → annulla il flip
(`X·X=I`):

```text
es. sindrome (−1,−1) → X sul qubit 2:   q2 ──[X]──
```

(= **voto di maggioranza**.) Corregge **1** errore, non 2.

---

## 18. Codice phase-flip (3 qubit) — corregge errori Z

**Il trucco (la connessione d'oro):** `Z` in base computazionale = `X` in base di Hadamard,
perché `HZH=X`. Quindi il phase-flip code è **il bit-flip code coniugato con H**.

### Encoding (phase-flip)

```text
|0⟩ → |+++⟩        |1⟩ → |−−−⟩
```

Circuito: identico al bit-flip, ma aggiungi **H su tutti e 3** i qubit alla fine.

```text
|ψ⟩ ──●──●──H──
      │  │
|0⟩ ──⊕──┼──H──
         │
|0⟩ ─────⊕──H──
```

### Sindrome + correzione (phase-flip)

Un errore `Z` fa `|+⟩↔|−⟩`: un "flip" nella base `±`. Si rileva con le **X-parità** (`X₁X₂`, `X₂X₃`)
e si corregge con una `Z` sul qubit segnalato. È **§17 con X e Z scambiati**.

**Circuito della misura (X-parità):** come §17 ma "coniugato con H" — l'**ancilla** è il **controllo**
(parte in `|+⟩` con una `H`) e i **dati** sono i **target**; poi `H` sull'ancilla e misuri:

```text
X₁X₂  (ancilla a1, confronta q1 e q2):
a1 ─H─●──●─H─ M
      │  │
q1 ───⊕──┼───
         │
q2 ──────⊕───

X₂X₃  (ancilla a2, confronta q2 e q3):
a2 ─H─●──●─H─ M
      │  │
q2 ───⊕──┼───
         │
q3 ──────⊕───
```

**Sindrome → dove** (stessa tabella di §17, con X al posto di Z):

| X₁X₂ | X₂X₃ | errore su |
| --- | --- | --- |
| +1 | +1 | nessuno |
| −1 | +1 | qubit 1 |
| −1 | −1 | qubit 2 |
| +1 | −1 | qubit 3 |

**Correzione:** `Z` sul qubit segnalato (es. sindrome `(−1,−1)` → `Z` su q2).

> Riassunto da dire: *"Phase-flip = bit-flip sandwich tra Hadamard. Stessa struttura,
> base ruotata."*

---

## 19. Codice di Shor (9 qubit) — corregge QUALSIASI errore singolo

**Concatenazione = incateni due codifiche una dopo l'altra** (prima una, poi l'altra su ogni
qubit); il **risultato** è un codice **annidato dentro l'altro**. I due codici sono quelli
già visti:

- **phase-flip** (§18, contro errori `Z`) → livello **ESTERNO**;
- **bit-flip** (§17, contro errori `X`) → livello **INTERNO**.

Codifichi col phase-flip (ti dà 3 qubit, i "capi"), poi **ricodifichi ognuno** col bit-flip
(3 qubit ciascuno) → `3×3 = 9`. Così sei protetto da **entrambi** i tipi di errore.

`α` e `β` sono i coefficienti del qubit logico `|ψ⟩=α|0⟩+β|1⟩`: dopo l'encoding `α` moltiplica
tutto il blocco-`|0⟩`, `β` tutto il blocco-`|1⟩`:

```text
α|0⟩ + β|1⟩   →
   α·(|000⟩+|111⟩)(|000⟩+|111⟩)(|000⟩+|111⟩) / (2√2)
 + β·(|000⟩−|111⟩)(|000⟩−|111⟩)(|000⟩−|111⟩) / (2√2)

(i due blocchi sono mostrati separati sotto, ma lo stato è la loro somma α·.. + β·..)
```

### La struttura

9 qubit in **3 blocchi da 3**: `[1,2,3]`, `[4,5,6]`, `[7,8,9]`. I "capi" dei blocchi sono **1, 4, 7**.
Due livelli: **fuori** il phase-flip (sui 3 capi), **dentro** il bit-flip (in ogni blocco).

### Encoding (come generare lo stato)

Parti da `|ψ⟩=α|0⟩+β|1⟩` sul qubit 1, gli altri 8 a `|0⟩`. Due livelli:

**Livello 1 — phase-flip sui 3 capi** (q1, q4, q7):

```text
q1 |ψ⟩ ──●──●──[H]──
         │  │
q4 |0⟩ ──⊕──┼──[H]──     →  i capi diventano   α|+++⟩ + β|−−−⟩
            │
q7 |0⟩ ─────⊕──[H]──
```

(Le 2 CNOT spalmano q1 sui capi → `α|000⟩+β|111⟩`; le 3 `H` → `α|+++⟩+β|−−−⟩`.)

**Livello 2 — bit-flip dentro OGNI blocco** (= l'encoder di §17, una volta per blocco):

```text
blocco 1 (capo = q1):
q1 ──●──●──
     │  │
q2 ──⊕──┼──
        │
q3 ─────⊕──

identico nel blocco 2 (capo q4 → q5, q6)  e  nel blocco 3 (capo q7 → q8, q9)
```

Ogni capo `|+⟩` → `(|000⟩+|111⟩)/√2`, ogni `|−⟩` → `(|000⟩−|111⟩)/√2` → lo stato a 9 qubit qui sopra.

### Correzione (due tipi, indipendenti)

**Bit-flip (errori X)** — DENTRO ogni blocco, come §17: in ogni blocco misuri le **Z-parità**
(blocco 1: `Z₁Z₂, Z₂Z₃`; idem gli altri) → **6 controlli** (2 per blocco) → localizzi l'`X` e correggi con `X`.

**Phase-flip (errori Z)** — TRA i blocchi: un `Z` su un qubit **ribalta il segno** del suo blocco
(`(|000⟩+|111⟩) → (|000⟩−|111⟩)`). Per scoprire **quale blocco** ha il segno girato, confronti i segni
tra blocchi con due **X-parità a 6 qubit**:

```text
X₁X₂X₃  vs  X₄X₅X₆     (segno blocco 1 contro blocco 2)
X₄X₅X₆  vs  X₇X₈X₉     (segno blocco 2 contro blocco 3)
```

→ ti dicono il blocco "girato" → correggi con una `Z` su **un** qubit di quel blocco (rimette il segno).

### Perché corregge QUALSIASI errore singolo

- **interno** → errori `X`; **esterno** → errori `Z`; `Y = XZ` → preso da **entrambi** i livelli.
- **Digitizzazione:** un errore continuo arbitrario è combinazione di `I, X, Z, Y`; la misura di
  sindrome lo **proietta** su uno di questi → basta correggere gli errori discreti. Quindi Shor
  corregge **qualsiasi** errore su **un** qubit.

---

## 20. Entanglement Purification — DOMANDA "fidelity in swapping e purification"

**Problema:** lo swapping e il rumore **abbassano** la fidelity. La purification la **rialza**.

### Idea

Da **2 (o più) coppie a bassa fidelity** F, con sole operazioni locali + comunicazione
classica (LOCC: tipicamente CNOT bilaterali + misura), produci **1 coppia a fidelity più alta** F′ > F,
in modo **probabilistico**. Sacrifichi **quantità** per **qualità**.
(Protocolli: BBPSSW, DEJMPS.) Iterando, F → 1 (se parti da F > 1/2, la soglia).

### Il circuito (come fa salire F)

Prendi **2 coppie** rumorose: la **coppia 1** (`a1`–`b1`, da tenere) e la **coppia 2**
(`a2`–`b2`, sacrificabile). **CNOT bilaterale** (Alice tra i suoi 2 qubit, Bob tra i suoi 2),
poi misuri la coppia 2 e confronti gli esiti:

```text
a1 ──●──────     (Alice, coppia 1 → TIENI)
     │
a2 ──⊕── M       (Alice, coppia 2 → misuri)

b2 ──⊕── M       (Bob, coppia 2 → misuri)
     │
b1 ──●──────     (Bob, coppia 1 → TIENI)

confronti M(a2), M(b2):  concordano → TIENI coppia 1 (F più alta);  discordano → BUTTA
```

**"Bilaterale"** = la **stessa** CNOT fatta da **entrambi i lati**, ognuno solo sui **propri** 2 qubit:
Alice `CNOT(a1→a2)`, Bob `CNOT(b1→b2)` (qubit della coppia 1 = controllo, della coppia 2 = target).
Nessuno tocca i qubit dell'altro → è un'operazione **locale** (LOCC).

**Perché F sale:** la CNOT bilaterale "travasa" l'info d'errore della coppia 1 sulla coppia 2;
misurando la coppia 2 **rilevi** se c'era un errore → **tieni solo i casi che passano** (esiti
concordi) e scarti i sospetti → la fidelity media dei sopravvissuti **sale**. È **probabilistico**:
riesci solo quando concordano (sacrifichi una coppia + probabilità di successo per più qualità).

### Come cambia la fidelity ad ogni passo (la risposta completa)

Modella le coppie rumorose come **stati di Werner** = miscela della coppia perfetta e del caos:
`ρ = w·|Φ⁺⟩⟨Φ⁺| + (1−w)·I/4`. Il parametro `w∈[0,1]` = **quanto Bell è rimasto** (`w=1` perfetta,
`w=0` → `I/4`, niente entanglement); la fidelity è `F=(1+3w)/4`.

- **Generazione:** coppia fresca, F≈1 (w≈1).
- **Attesa in memoria (decoerenza):** depolarizzazione → `w` decade come `(1−p_w)^Δt`.
  Più aspetti, più F scende verso 0.25 (w→0). ← è il cuore del tuo progetto.
- **Swapping (BSM ideale):** combina due coppie → i parametri **si moltiplicano**:
  `w_out = w₁·w₂`. Siccome `w<1`, **la fidelity scende** ad ogni swap.
  Catena di N+1 link: `w_tot = ∏ᵢ wᵢ`, `F=(1+3·w_tot)/4` ← formula del progetto (`run_analysis.jl`).
- **Purification:** prende due coppie a fidelity F e ne restituisce una a **F′>F**
  (con probabilità di successo <1) → **la fidelity risale**.

> Frase da esame: *"Lo swapping moltiplica i parametri di Werner, quindi la fidelity
> decresce di hop in hop; la purification fa il contrario, scambiando coppie e probabilità
> di successo per riportare la fidelity sopra soglia."*

Nel progetto la purification è **lavoro futuro** (slide 16): serve appunto a contrastare
il calo di F con N che vedi nei grafici (F≈0.92 a N=1 → ≈0.65 a N=7).

---

## Rule card

| Codice | Corregge | Encoding | Trucco |
| --- | --- | --- | --- |
| Bit-flip (3q) | X | \|0⟩→\|000⟩ | parità Z₁Z₂, Z₂Z₃ + maggioranza |
| Phase-flip (3q) | Z | \|0⟩→\|+++⟩ | = bit-flip + H (HZH=X) |
| Shor (9q) | qualsiasi singolo | phase∘bit | concatenazione, digitizza l'errore |
| Purification | rialza F | — | 2 coppie + LOCC → 1 coppia F′>F |
| Swapping (fidelity) | abbassa F | — | `w_out=∏ wᵢ` (Werner) |
