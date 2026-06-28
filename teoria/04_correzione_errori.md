# Blocco 3 — Correzione errori (+ purification)

Filo conduttore: **bit-flip** (errori X) → **phase-flip** = bit-flip in base Hadamard (errori Z) → **Shor** = i due insieme (qualsiasi errore). Poi la **purification** che collega al progetto.

Idea base della QEC: non posso copiare (no-cloning) né misurare i dati (collasso). Allora:
**ridondanza** (1 qubit logico su più qubit fisici) + **misuro solo la sindrome** (le parità, non lo stato) → scopro *dove* è l'errore senza leggere α,β → correggo.

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

### Errore + sindrome

Un X su un qubit, es. `α|010⟩+β|101⟩`. Misuro **le parità** (stabilizzatori)
`Z₁Z₂` e `Z₂Z₃` con 2 ancille — confrontano coppie di qubit **senza** misurare α,β:

| Z₁Z₂ | Z₂Z₃ | errore su |
| --- | --- | --- |
| +1 | +1 | nessuno |
| −1 | +1 | qubit 1 |
| −1 | −1 | qubit 2 |
| +1 | −1 | qubit 3 |

### Correzione

Applico X sul qubit segnalato (= **voto di maggioranza**). Corregge **1** errore, non 2.

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

Un errore Z fa `|+⟩↔|−⟩`: è un "bit-flip" nella base `±`. Si rileva con le parità
`X₁X₂`, `X₂X₃` (le X al posto delle Z) e si corregge con Z sul qubit segnalato.

> Riassunto da dire: *"Phase-flip = bit-flip sandwich tra Hadamard. Stessa struttura,
> base ruotata."*

---

## 19. Codice di Shor (9 qubit) — corregge QUALSIASI errore singolo

**Concatenazione** dei due codici: prendi il **phase-flip** (esterno, 3 blocchi) e
codifica ognuno dei suoi 3 qubit con il **bit-flip** (interno, 3 qubit ciascuno) → 9 qubit.

```text
|0⟩ → (|000⟩+|111⟩)(|000⟩+|111⟩)(|000⟩+|111⟩) / (2√2)
|1⟩ → (|000⟩−|111⟩)(|000⟩−|111⟩)(|000⟩−|111⟩) / (2√2)
```

- Il livello **interno (bit-flip)** corregge gli **errori X**.
- Il livello **esterno (phase-flip)** corregge gli **errori Z** → **risponde alla domanda "Shor per il phase flip"**.
- `Y = XZ` (X e Z insieme) → corretto perché entrambi i livelli agiscono.
- **Digitizzazione degli errori:** un errore continuo arbitrario è combinazione di I,X,Z,Y;
  la misura di sindrome lo "proietta" su uno di questi → basta correggere gli errori discreti.
  Quindi Shor corregge **qualsiasi** errore su **un** qubit.

---

## 20. Entanglement Purification — DOMANDA "fidelity in swapping e purification"

**Problema:** lo swapping e il rumore **abbassano** la fidelity. La purification la **rialza**.

### Idea

Da **2 (o più) coppie a bassa fidelity** F, con sole operazioni locali + comunicazione
classica (LOCC: tipicamente CNOT bilaterali + misura), produci **1 coppia a fidelity più alta** F′ > F,
in modo **probabilistico**. Sacrifichi **quantità** per **qualità**.
(Protocolli: BBPSSW, DEJMPS.) Iterando, F → 1 (se parti da F > 1/2, la soglia).

### Come cambia la fidelity ad ogni passo (la risposta completa)

Modella le coppie rumorose come **stati di Werner**, fidelity `F=(1+3w)/4` con parametro `w∈[0,1]`.

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
