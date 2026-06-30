# Blocco 4 — Circuiti (saper fare con le mani)

Questo è uno **skill**, non teoria. All'esame ti danno un circuito e devi tracciarne lo stato. Metodo + esempi.

---

## 21. Metodo generale: risolvere un circuito

Risolvere un circuito = **seguire lo stato che cambia, gate dopo gate**. Tre fasi:

- **INPUT** = lo stato **iniziale** dei qubit (da cui parti). Di solito `|0…0⟩` (tutti resettati).
- **SVOLGIMENTO** = applichi i gate **uno alla volta, da sinistra a destra**, aggiornando lo stato
  a ogni passo. Ogni gate prende lo stato corrente e lo trasforma nel successivo. Due modi:
  *basis-tracking* (vedi cosa fa il gate a ogni `|...⟩` presente, più veloce a mano) oppure
  *matrice × vettore* (moltiplichi, più meccanico).
- **OUTPUT** = lo stato **finale** (dopo l'ultimo gate). Se il circuito finisce con una **misura**,
  le **probabilità** degli esiti sono i `|ampiezza|²` dello stato finale.

Promemoria gate (da `01_fondamenta.md`):

- `H|0⟩=|+⟩`, `H|1⟩=|−⟩`, `H|+⟩=|0⟩`, `H|−⟩=|1⟩`.
- `X` scambia |0⟩↔|1⟩. `Z` mette −1 su |1⟩. `CZ` mette −1 **solo** su |11⟩.
- `CNOT`: flippa il target se il controllo è |1⟩.

### Esempio svolto (1 qubit): `H – Z – H` su `|0⟩`

```text
INPUT:     |0⟩

H:   H|0⟩ = |+⟩ = (|0⟩+|1⟩)/√2
Z:   Z|+⟩ = (|0⟩−|1⟩)/√2 = |−⟩      (Z mette −1 su |1⟩)
H:   H|−⟩ = |1⟩

OUTPUT:    |1⟩   → misurando esce SEMPRE 1 (deterministico)
```

(Infatti `HZH = X`, e `X|0⟩=|1⟩`.)

### Esempio svolto (2 qubit): `H(q1) – CNOT(q1→q2)` su `|00⟩`

```text
INPUT:     |00⟩

H su q1:   (H|0⟩)⊗|0⟩ = |+⟩⊗|0⟩ = (|00⟩+|10⟩)/√2
CNOT:      flippa q2 se q1=1:   |00⟩→|00⟩,  |10⟩→|11⟩
           = (|00⟩+|11⟩)/√2

OUTPUT:    |Φ⁺⟩ = (|00⟩+|11⟩)/√2
           → misurando: 50% "00", 50% "11"   (|ampiezza|² = 1/2 ciascuno)
```

---

## 22. Circuito 3 qubit: Hadamard + Controlled-Z — DOMANDA

> *"3 qubit con Hadamard e poi delle CZ; poi modificare per ottenere un risultato diverso e costante."*

L'esatto circuito d'esame non è fissato qui, quindi imparane il **comportamento** e i due
strumenti che servono per la parte "modifica".

### Passo 1: H su tutti e 3

```text
|000⟩ --H⊗H⊗H--> |+++⟩ = (1/√8) Σ tutti gli 8 stati |000⟩…|111⟩
```

Sovrapposizione uniforme: misurando, ogni esito ha prob 1/8 → **risultato casuale**.

### Passo 2: le CZ

Ogni `CZ(i,j)` mette un fattore **−1** sui termini in cui **entrambi** i qubit i,j valgono 1.
Non cambia le **probabilità** (i moduli restano 1/8), cambia solo le **fasi** → crea uno
**stato grafo / cluster** (i qubit diventano correlati). Misurando in base computazionale,
ancora 1/8 ciascuno: gli effetti delle fasi si vedono solo se poi **ruoti la base** (altre H).

### Passo 3: "modifica per un risultato diverso e COSTANTE"

"Costante" = **deterministico**: lo stato finale deve essere uno stato **di base** (un solo
`|...⟩`, nessuna sovrapposizione) → la misura dà sempre lo stesso esito.

**Strumento chiave:** `H` manda un autostato di X in uno di Z:

```text
H|+⟩=|0⟩      H|−⟩=|1⟩
```

Quindi se dopo le CZ un qubit si trova in `|+⟩` o `|−⟩`, **una H finale lo "congela"** in
`|0⟩` o `|1⟩` (deterministico).

**Caso pulito da ricordare** — se NON metti CZ tra due qubit, restano in `|+⟩`:

```text
|+⟩ --H--> |0⟩        // ogni qubit non accoppiato torna a |0⟩ → esito costante 000…
```

Più in generale: `H – (niente o gate diagonali che lasciano ± ) – H` riporta a uno stato
di base. Se invece le CZ hanno accoppiato i qubit, una **singola** H finale non basta: lo
stato grafo dà esiti correlati ma ancora casuali. La "modifica" tipica per ottenere il
**costante** è togliere/neutralizzare le CZ (o aggiungere gate che disfano la fase) e
chiudere con H → si torna a uno stato prodotto di base.

> Risposta a voce: *"Con H su tutti ottengo sovrapposizione uniforme: misura casuale. Le CZ
> aggiungono solo fasi (stato grafo), le probabilità restano uniformi. Per un risultato
> costante devo far collassare ogni qubit in un autostato di Z: sfrutto `H|±⟩=|0/1⟩`,
> cioè chiudo con una H quando il qubit è in |+⟩/|−⟩, così la misura è deterministica."*

(Se mi mandi il circuito **esatto** dell'esame, te lo risolvo numero per numero.)

---

## 23. Circuiti dei protocolli da saper ridisegnare a memoria

- **Bell |Φ⁺⟩:** `|00⟩ – H(q1) – CNOT(q1→q2)`.
- **Teleportation:** `CNOT(q1→q2) – H(q1) – misura q1,q2 – Bob: Zᵐ¹Xᵐ²` (file 03).
- **Superdense:** Alice `{I,X,Z,ZX}` sul suo qubit – lo manda – Bob `CNOT – H – misura` (file 03).
- **Encoder bit-flip:** `CNOT(q1→q2) – CNOT(q1→q3)` (file 04).

---

## Rule card

| Cosa | Regola |
| --- | --- |
| Risolvere circuito | stato iniziale → gate a sinistra-destra → \|ampiezza\|² |
| HZH | = X |
| H + CNOT | = Bell \|Φ⁺⟩ |
| CZ | solo fase −1 su \|11⟩, non cambia le probabilità |
| Risultato "costante" | stato finale = base; usa `H\|±⟩=\|0/1⟩` |
