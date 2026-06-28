# Blocco 0 — Fondamenta (la cassetta degli attrezzi)

Niente di magico: sono vettori e matrici. Senza questo, niente regge.

---

## 1. Il qubit

Bit classico = 0 o 1. Qubit = **sovrapposizione**:

```text
|ψ⟩ = α|0⟩ + β|1⟩        con  |α|² + |β|² = 1
```

Vettori base:

```text
|0⟩ = [1]      |1⟩ = [0]
      [0]            [1]
```

quindi `|ψ⟩ = [α, β]ᵀ`. `α, β` complessi (ampiezze). Il vincolo `|α|²+|β|²=1`
= "le probabilità sommano a 1".

---

## 2. Notazione di Dirac (bra-ket)

- **ket** `|ψ⟩` = vettore colonna.
- **bra** `⟨ψ|` = coniugato-trasposto (riga). Se `|ψ⟩=[α,β]ᵀ` → `⟨ψ|=[α*, β*]`.
- **inner product** `⟨φ|ψ⟩` = riga × colonna = **numero** (quanto si assomigliano).
  `⟨0|0⟩=1`, `⟨0|1⟩=0` (base ortonormale).
- **outer product** `|ψ⟩⟨φ|` = colonna × riga = **matrice**. ← serve per la densità.

```text
|0⟩⟨0| = [1][1 0] = [1 0]
         [0]        [0 0]
```

---

## 3. Gate a 1 qubit (matrici 2×2)

`|ψ'⟩ = U|ψ⟩`. I quattro da sapere a memoria:

```text
X = [0 1]    Z = [1  0]    H = 1/√2 [1  1]    Y = [0 -i]
    [1 0]        [0 -1]             [1 -1]        [i  0]
```

- **X** = NOT / bit-flip: `X|0⟩=|1⟩`, `X|1⟩=|0⟩`.
- **Z** = phase-flip: `Z|0⟩=|0⟩`, `Z|1⟩=−|1⟩` (tocca solo |1⟩).
- **H** = Hadamard, crea sovrapposizione: `H|0⟩=|+⟩`, `H|1⟩=|−⟩`.
- **Y** = `iXZ` (bit-flip e phase-flip insieme).

```text
|+⟩ = (|0⟩+|1⟩)/√2        |−⟩ = (|0⟩−|1⟩)/√2
```

Fatti chiave:

- `X, Z, H` sono **unitarie e hermitiane**. `H·H = I` (H è la sua inversa).
- Autostati di `Z`: `|0⟩,|1⟩` (autovalori +1,−1). Autostati di `X`: `|+⟩,|−⟩`.
- **`X` e `Z` sono la stessa cosa in basi diverse, scambiate da H:** `HXH=Z`, `HZH=X`.
  ← questa è la chiave del phase-flip code (Blocco 3).

---

## 4. La misura (regola di Born)

Misurando `|ψ⟩=α|0⟩+β|1⟩` in base computazionale:

- esito `0` con prob `|α|²`, stato collassa a `|0⟩`;
- esito `1` con prob `|β|²`, stato collassa a `|1⟩`.

`|+⟩` → 50% e 50%. **La misura distrugge la sovrapposizione, è irreversibile.**
(È il motivo per cui esiste il no-cloning, Blocco 2.)

Valore di aspettazione: `⟨ψ|Z|ψ⟩ = |α|²−|β|² = P(0)−P(1)`. Per `|+⟩` vale 0.

---

## 5. Due qubit: prodotto tensoriale + gate controllati

Due qubit → spazio dimensione 4. Base col **prodotto tensoriale** `⊗` (mette insieme i due qubit):

```text
|00⟩=[1,0,0,0]ᵀ   |01⟩=[0,1,0,0]ᵀ   |10⟩=[0,0,1,0]ᵀ   |11⟩=[0,0,0,1]ᵀ
```

Convenzione: in `|ab⟩` il **primo** simbolo è il qubit 1, il **secondo** è il qubit 2.
Regola pratica del tensore: `[a,b]ᵀ ⊗ [c,d]ᵀ = [ac, ad, bc, bd]ᵀ`.
Stato generico a 2 qubit: `[c₀₀, c₀₁, c₁₀, c₁₁]ᵀ`.

### Applicare un gate a UN solo qubit (la regola per i circuiti)

Se hai due qubit e applichi un gate (es. H) **solo a q1**, su q2 **non fai niente**:
lasci q2 com'è e **distribuisci il `⊗` sulla somma** (come `(a+b)·c = a·c + b·c`).

```text
|00⟩ = |0⟩ ⊗ |0⟩                       (q1=|0⟩, q2=|0⟩)

applico H solo a q1, q2 resta |0⟩:
   (H|0⟩) ⊗ |0⟩  =  |+⟩ ⊗ |0⟩

espando |+⟩ e distribuisco il ⊗:
   = [(|0⟩ + |1⟩)/√2] ⊗ |0⟩
   = (|0⟩⊗|0⟩  +  |1⟩⊗|0⟩) / √2
   = (  |00⟩   +   |10⟩  ) / √2
```

dove `|0⟩⊗|0⟩=|00⟩` e `|1⟩⊗|0⟩=|10⟩` (scrivi i due simboli vicini: primo q1, secondo q2).

> **Regola:** gate su un qubit = lascia l'altro com'è, poi distribuisci `⊗` sulla somma.
> (Verifica col vettore: `|+⟩=[1/√2,1/√2]`, `|0⟩=[1,0]` → tensore `[1/√2,0,1/√2,0]` =
> posizioni |00⟩ e |10⟩. ✓)

### Cos'è un gate controllato (controllo + target)

Un **gate controllato** agisce su due qubit con ruoli diversi:

- **qubit di controllo** = fa da "interruttore". **Non** viene modificato.
- **qubit target** (bersaglio) = quello su cui *forse* si applica un'operazione.

Regola (come un `if` classico):
> **se il qubit di controllo è |1⟩, applica il gate al target; se è |0⟩, non fare niente.**

Intuizione: "se l'interruttore (controllo) è acceso, ribalta la lampadina (target)".
La cosa quantistica in più: il controllo può essere in **sovrapposizione**; allora il gate
si applica "in parte sì e in parte no" → nasce l'**entanglement** (è così che si crea la
coppia di Bell, sezione 7).

### CNOT (controlled-NOT)

Controllo = qubit 1, target = qubit 2. Applica **X (NOT)** al target **se** il controllo è |1⟩:

```text
CNOT|00⟩=|00⟩   CNOT|01⟩=|01⟩     (controllo=0 → target invariato)
CNOT|10⟩=|11⟩   CNOT|11⟩=|10⟩     (controllo=1 → target flippato)
```

Come matrice (lascia stare |00⟩,|01⟩; scambia |10⟩↔|11⟩):

```text
        [1 0 0 0]
CNOT =  [0 1 0 0]
        [0 0 0 1]
        [0 0 1 0]
```

### CZ (controlled-Z)

Applica **Z** al target se il controllo è |1⟩. Siccome Z mette `−1` solo su |1⟩, l'effetto netto è:
**fattore `−1` solo su `|11⟩`**, tutto il resto invariato.

```text
        [1 0 0 0]
CZ =    [0 1 0 0]
        [0 0 1 0]
        [0 0 0 -1]
```

- CZ è **simmetrico**: non conta quale dei due chiami controllo, il risultato è identico.
- **H sul target trasforma CZ ↔ CNOT** (perché `HZH=X`). ← utile per i circuiti (Blocco 4).

---

## 6. Come si disegna un circuito quantistico

"Disegnare un circuito" = fare il **diagramma**: il modo standard di rappresentare cosa
succede ai qubit. È quello che il prof si aspetta sul foglio. (NON è la stringa
`|00⟩ --H--> …`: quella è l'evoluzione algebrica, cioè *cosa produce* il circuito.)

**Come si legge:**

- da **sinistra a destra** = ordine temporale (lo stesso in cui applichi i gate);
- ogni **riga orizzontale** (filo) = un qubit; in alto q1, sotto q2, ecc.;
- a **sinistra** lo stato iniziale (di solito |0⟩), a **destra** il risultato.

**Legenda dei simboli:**

| Simbolo | Significato |
| --- | --- |
| `─────` | un qubit (filo); il tempo scorre → |
| `[H]` `[X]` `[Z]` | gate a 1 qubit su quel filo |
| `●` | qubit di **controllo** |
| `⊕` | target di una **CNOT** (la X controllata) |
| `│` (linea verticale) | collega controllo e target |
| `[M]` | misura |

Esempio — H su q1, poi CNOT (controllo q1, target q2):

```text
q1 |0⟩ ──[H]──●──
              │
q2 |0⟩ ───────⊕──
```

Si legge: *"su q1 applico H; poi una CNOT con controllo q1 e target q2"*.

### Il principio: un circuito è una RICETTA

Un circuito **prepara** uno stato. Tre ingredienti:

- **input fisso e noto:** parti sempre da uno stato deciso, di solito `|0…0⟩` (i qubit
  "resettati", il foglio bianco). **Non è "a caso"**: è la condizione iniziale standard.
- **sequenza fissa di gate:** li applichi in ordine.
- **output deterministico:** i gate sono trasformazioni deterministiche, quindi lo stesso
  input dà **sempre** lo stesso output. (La casualità entra **solo** quando *misuri*.)

Perciò *"circuito per ottenere |Φ⁺⟩"* significa: *"la ricetta di gate che, partendo da
`|00⟩`, produce `|Φ⁺⟩` ogni volta"*. Cambiando l'input cambia l'output: lo **stesso** circuito
H+CNOT partendo da `|10⟩` darebbe `|Φ⁻⟩`. Per questo l'input `|00⟩` fa parte della ricetta.

---

## 7. Stati di Bell (il cuore di tutto)

Quattro stati massimamente entangled:

```text
|Φ⁺⟩ = (|00⟩+|11⟩)/√2      |Ψ⁺⟩ = (|01⟩+|10⟩)/√2
|Φ⁻⟩ = (|00⟩−|11⟩)/√2      |Ψ⁻⟩ = (|01⟩−|10⟩)/√2
```

**Circuito per `|Φ⁺⟩`** (da saper disegnare): da `|00⟩`, **H sul primo qubit**, poi **CNOT**.

Il **diagramma** (questo è ciò che chiede l'esame):

```text
q1 |0⟩ ──[H]──●──
              │
q2 |0⟩ ───────⊕──   →  |Φ⁺⟩ = (|00⟩+|11⟩)/√2
```

Cosa fa, **passo per passo** (l'evoluzione dello stato, serve a te per verificarlo):

```text
|00⟩ --H(q1)--> (|00⟩+|10⟩)/√2 --CNOT--> (|00⟩+|11⟩)/√2 = |Φ⁺⟩
```

**Perché funziona** (il principio della coppia di Bell):

1. `|00⟩` = due qubit separati: niente sovrapposizione, niente entanglement.
2. `H` su q1 → `(|00⟩+|10⟩)/√2`: q1 è "0 e 1 insieme", ma q2 è ancora |0⟩ indipendente →
   **ancora separabili** (è |+⟩⊗|0⟩).
3. `CNOT` → lega q2 a q1: flippa q2 **solo** nel ramo in cui q1=1. Quindi `|00⟩` resta `|00⟩`
   e `|10⟩` diventa `|11⟩`. Risultato `(|00⟩+|11⟩)/√2`: "se q1=0 allora q2=0, se q1=1 allora
   q2=1" → i due qubit sono **correlati = entangled**.

In una frase: **H crea la sovrapposizione, CNOT la trasforma in correlazione (entanglement).**

È esattamente lo stato che `EntanglerProt` mette su ogni link del tuo progetto
(`src/network.jl`, dove `Z1=|0⟩`, `Z2=|1⟩`).

Gli altri 3 si ottengono partendo da |01⟩, |10⟩, |11⟩, oppure applicando un Pauli
a metà di |Φ⁺⟩ (vedi superdense coding, Blocco 2):

```text
X⊗I |Φ⁺⟩ = |Ψ⁺⟩      Z⊗I |Φ⁺⟩ = |Φ⁻⟩      ZX⊗I |Φ⁺⟩ = |Ψ⁻⟩
```

---

## Rule card

| Oggetto | Da ricordare |
| --- | --- |
| Qubit | `α\|0⟩+β\|1⟩`, `\|α\|²+\|β\|²=1` |
| X / Z / H | bit-flip / phase-flip / crea sovrapposizione |
| HZH=X, HXH=Z | X e Z sono uguali in basi diverse |
| Misura | P(0)=\|α\|², collasso, irreversibile |
| CZ | `−1` solo su \|11⟩ |
| Bell \|Φ⁺⟩ | H + CNOT da \|00⟩ |
