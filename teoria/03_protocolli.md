# Blocco 2 — Protocolli (Bell + Pauli)

Tutti questi protocolli usano lo stesso lego: **una coppia di Bell condivisa + correzioni di Pauli**. Imparane uno bene (teleportation) e gli altri sono variazioni.

---

## 12. Quantum Teleportation — DOMANDA

**Scopo:** Alice trasmette uno stato **sconosciuto** `|ψ⟩=α|0⟩+β|1⟩` a Bob
**senza spedire il qubit fisico**, usando 1 coppia di Bell condivisa + 2 bit classici.

### Setup

- Qubit 1 (Alice): lo stato sconosciuto `|ψ⟩`.
- Qubit 2 (Alice) + Qubit 3 (Bob): coppia di Bell `|Φ⁺⟩₂₃` condivisa in anticipo.

### Circuito (da saper disegnare)

```text
 q1 |ψ⟩ ──●────H──── M ═╗   (m1)
          │             ║
 q2 ──────⊕──────────M ═╣   (m2)
                        ║
 q3 ───────────────────╫── Xᵐ² ── Zᵐ¹ ── |ψ⟩
```

1. Alice: **CNOT(q1→q2)**, poi **H(q1)**.
2. Alice **misura** q1→m1 e q2→m2 (2 bit classici).
3. Alice **manda m1,m2 a Bob** (canale classico).
4. Bob applica `Zᵐ¹ Xᵐ²` su q3 → ottiene `|ψ⟩`.

### Tabella di correzione

| m1 m2 | stato di Bob prima | Bob applica |
| ------- | -------------------- | ------------- |
| 0 0 | \|ψ⟩ | I |
| 0 1 | X\|ψ⟩ | X |
| 1 0 | Z\|ψ⟩ | Z |
| 1 1 | XZ\|ψ⟩ | ZX (X poi Z) |

**Come leggere la tabella:** colonna 2 = lo stato "sporcato" che Bob possiede; colonna 3 = il
gate che Bob applica per pulirlo, cioè l'**inverso** di quel Pauli. I 2 bit `(m1,m2)` dicono a
Bob **quale** Pauli ha sporcato il qubit, quindi la correzione è **univocamente determinata**.

- Pauli singolo: l'inverso è sé stesso (`X·X=I`, `Z·Z=I`) → applica lo **stesso** gate.
- `XZ`: l'inverso è `ZX` (ordine rovesciato), `ZX·(XZ|ψ⟩) = |ψ⟩`.

Noti `m1,m2`, il risultato è **deterministico**: Bob recupera **esattamente** `|ψ⟩`.

### I 3 punti che chiede sempre il prof

- **Serve il canale classico** (m1,m2): senza, Bob ha uno stato casuale → **niente comunicazione più veloce della luce**.
- **L'originale viene distrutto** dalla misura → **no-cloning rispettato** (non è una copia, è un trasferimento).
- Si **consuma** la coppia di Bell (una teleportation = una coppia).

---

## 13. Entanglement Swapping = teleportation dell'entanglement (IL TUO PROGETTO)

È teleportation in cui il qubit "sconosciuto" è esso stesso **metà di un'altra coppia di Bell**.

```text
prima:   A ──|Φ⁺⟩── R ──|Φ⁺⟩── B      (R ha 2 qubit: r1 con A, r2 con B)
         il ripetitore R fa una misura di Bell (BSM) su (r1, r2)
dopo:    A ─────────|Φ⁺⟩───────── B    (A e B ora entangled, mai stati vicini!)
```

- R misura **i suoi due qubit** in base di Bell → 2 bit classici → correzione di Pauli su B (o A).
- L'esito proietta A–B in uno dei 4 stati di Bell; la correzione lo riporta a `|Φ⁺⟩`.
- Una **BSM ideale preserva l'entanglement perfettamente** → in assenza di rumore F=1.
  L'unica perdita nel progetto è la **decoerenza durante l'attesa** (Blocco 1 + file 06).

Nel codice: `SwapperProt` fa la BSM locale, `EntanglementTracker` applica la correzione
classica (`src/swapping.jl`). Catena di N ripetitori → N swap successivi finché A e B
condividono `|Φ⁺⟩`.

---

## 14. Superdense Coding — DOMANDA (il "duale" della teleportation)

**Scopo:** Alice manda **2 bit classici** a Bob spedendo **1 solo qubit**, usando una coppia di Bell condivisa.

### Protocollo

Coppia `|Φ⁺⟩` condivisa. Alice codifica i suoi 2 bit (b1 b2) sul **suo** qubit:

| bit | Alice applica | stato risultante |
| ----- | --------------- | ------------------ |
| 00 | I | \|Φ⁺⟩ |
| 01 | X | \|Ψ⁺⟩ |
| 10 | Z | \|Φ⁻⟩ |
| 11 | ZX | \|Ψ⁻⟩ |

Poi Alice **spedisce il suo qubit** a Bob. Bob ora ha **entrambi** i qubit e fa una
**misura di Bell** (CNOT poi H, poi misura) → legge i 2 bit:

```text
 qA ──●──H── M  (b1)
      │
 qB ──⊕───── M  (b2)
```

I 4 stati di Bell sono ortogonali → Bob li distingue con certezza → 2 bit esatti.

### Il punto

1 qubit trasporta 2 bit **perché l'entanglement era pre-condiviso**.
È il **duale** della teleportation:

- teleportation: 1 coppia + 2 bit classici → trasferisce 1 qubit;
- superdense: 1 coppia + 1 qubit → trasferisce 2 bit classici.

---

## 15. No-Cloning Theorem — DOMANDA

> **Non esiste un'operazione unitaria che copi uno stato quantistico arbitrario sconosciuto.**
> Cioè: non esiste `U` con `U(|ψ⟩|0⟩)=|ψ⟩|ψ⟩` per **ogni** `|ψ⟩`.

### Dimostrazione (per assurdo, 3 righe — impararla)

Supponi che funzioni per due stati `|ψ⟩` e `|φ⟩`:

```text
U|ψ⟩|0⟩ = |ψ⟩|ψ⟩      U|φ⟩|0⟩ = |φ⟩|φ⟩
```

Fai il prodotto interno dei due lati. A sinistra (U è unitaria, conserva i prodotti interni):

```text
⟨ψ|φ⟩·⟨0|0⟩ = ⟨ψ|φ⟩
```

A destra:

```text
⟨ψ|φ⟩·⟨ψ|φ⟩ = ⟨ψ|φ⟩²
```

Quindi `⟨ψ|φ⟩ = ⟨ψ|φ⟩²` → `x = x²` → `x=0` oppure `x=1`.
Cioè la clonazione funziona **solo** se gli stati sono identici o ortogonali,
**non** per stati arbitrari (es. non ortogonali). □

### Conseguenze (collega al progetto, slide 2)

- Non puoi **amplificare** un segnale quantistico come uno classico → in fibra le perdite
  sono esponenziali e non rimediabili copiando → **servono i quantum repeater** (swapping!).
- Non contraddice la teleportation: lì l'originale viene **distrutto**.
- Base di sicurezza della QKD: un intercettatore non può copiare i qubit.

---

## 16. Protocollo E91 (Ekert 1991) — DOMANDA

QKD (distribuzione di chiave) basata sull'**entanglement** e sul **test di Bell**.
(Tu lo hai scritto "E92": è **E91**, da Artur Ekert, 1991.)

### Come funziona

1. Una sorgente emette coppie di Bell (tipicamente il singoletto `|Ψ⁻⟩`), una metà ad Alice una a Bob.
2. Alice e Bob misurano ciascuno lungo **assi scelti a caso** tra alcune direzioni prefissate.
3. Dopo, annunciano (canale classico) **quali assi** hanno usato, non gli esiti:
   - assi **compatibili** → esiti perfettamente (anti)correlati → **bit di chiave** condivisi;
   - assi **incompatibili** → usati per stimare il parametro di Bell/**CHSH** `S`.

### Sicurezza

- Stati entangled genuini → `S` **viola** la disuguaglianza di Bell (`|S|≤2` classico, fino a `2√2` quantistico).
- Un intercettatore (Eve) che misura/clona introduce realismo locale → **abbassa la violazione** (`S→≤2`).
- Quindi: **se il test di Bell passa, la chiave è sicura**; se `S` cala, c'è Eve → si scarta.

### Differenza da BB84

- BB84: sicurezza dal **no-cloning** di singoli qubit non ortogonali.
- E91: sicurezza dall'**entanglement** + violazione di Bell. (Concetti collegati.)

---

## Rule card

| Protocollo | In → out | Ingrediente |
| --- | --- | --- |
| Teleportation | 1 coppia Bell + 2 bit classici → 1 qubit | BSM + Pauli |
| Swapping | 2 coppie Bell + BSM → 1 coppia a distanza | teleportation di metà coppia |
| Superdense | 1 coppia Bell + 1 qubit → 2 bit classici | Pauli encode + Bell measure |
| No-cloning | — | linearità/unitarietà: `x=x²` |
| E91 | coppie Bell + test di Bell → chiave segreta | violazione CHSH |
