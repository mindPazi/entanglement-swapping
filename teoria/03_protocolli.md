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

### Cosa succede (il flusso)

1. **La misura di Alice fa due cose insieme.** Il `CNOT + H` su `(q1, q2)` seguito dalla misura:
   - (a) produce **2 bit classici** `(m1, m2)` — esito casuale fra 4 possibilità;
   - (b) **lascia il qubit di Bob (q3) in una versione "modificata" di `|ψ⟩`** — uno dei 4 Pauli-flip
     (`|ψ⟩`, `X|ψ⟩`, `Z|ψ⟩`, `XZ|ψ⟩`). La misura distrugge l'originale su Alice e "scarica" `|ψ⟩`
     (sporcato) su q3 tramite l'entanglement.
2. **I 2 bit dicono QUALE modifica è capitata** — sono il "codice" dello sporco, non lo stato.
3. **Bob decodifica:** applica il **gate inverso** indicato dai bit (`X`, `Z` o entrambi) → annulla
   il Pauli → riottiene il `|ψ⟩` pulito.

> In sintesi: *misura di Alice → **2 bit classici** + **q3 di Bob sporcato**; i bit dicono **come**
> è sporcato; Bob applica il **gate inverso** e decodifica `|ψ⟩`.*

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

### Il flusso (passo per passo)

1. **Stato di partenza.** Alice e Bob **condividono già** una coppia `|Φ⁺⟩` (un qubit a testa).
   Alice ha **2 bit classici** `(b1, b2)` da mandare a Bob.
2. **Codifica.** Alice applica **un Pauli** (scelto dai 2 bit) **sul suo qubit** → la coppia
   condivisa si trasforma in **uno dei 4 stati di Bell** (uno per ogni messaggio possibile).
3. **Invio.** Alice **spedisce fisicamente il suo qubit** a Bob (è il **qubit** a viaggiare, non bit).
4. **Decodifica.** Bob ora ha **entrambi** i qubit → fa una **misura di Bell** (`CNOT + H + misura`)
   → capisce quale dei 4 stati di Bell è → **legge i 2 bit**.

### La codifica (passo 2)

Quale Pauli per quali bit, e in quale stato di Bell finisce la coppia condivisa:

| bit (b1 b2) | Alice applica | la coppia diventa |
| --- | --- | --- |
| 00 | I | \|Φ⁺⟩ |
| 01 | X | \|Ψ⁺⟩ |
| 10 | Z | \|Φ⁻⟩ |
| 11 | ZX | \|Ψ⁻⟩ |

### La decodifica (passo 4)

Bob ha entrambi i qubit (`qA` ricevuto + `qB` la sua metà) e fa la **misura di Bell**:

```text
 qA ──●──H── M  (b1)
      │
 qB ──⊕───── M  (b2)
```

I 4 stati di Bell sono **ortogonali** → Bob li distingue **con certezza** → 2 bit esatti.
(La misura di Bell `CNOT + H + misura` è il **circuito di Bell al contrario**, vedi §13.)

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

### BB84 — l'altro QKD (prepare-and-measure, SENZA entanglement)

Primo protocollo di QKD (Bennett-Brassard, 1984). **Niente coppie di Bell**: Alice **prepara**
qubit e li **manda**, Bob li **misura**.

I 4 stati che Alice può mandare (valore × base):

| bit | base Z | base X |
| --- | --- | --- |
| 0 | \|0⟩ | \|+⟩ |
| 1 | \|1⟩ | \|−⟩ |

Il protocollo:

1. **Alice prepara.** Per ogni bit sceglie **a caso** un valore 0/1 **e** una base (Z o X), e
   manda il corrispondente fra i 4 stati sopra.
2. **Bob misura** ogni qubit in una **base a caso** (Z o X), indipendente da Alice.
3. **Sifting:** annunciano pubblicamente le **basi** (non i valori) e tengono solo i bit dove hanno
   usato la **stessa base** (~50%). Lì il risultato di Bob = bit di Alice → **chiave condivisa**.
4. **Controllo spia:** confrontano un campione dei bit siftati. Se Eve ha misurato i qubit li ha
   **disturbati** → compaiono **errori** → tasso d'errore alto ⇒ scartano.

**Sicurezza (no-cloning + disturbo):** Eve non può **copiare** i qubit (no-cloning) e, non sapendo
la base, deve **indovinarla**; quando sbaglia base **collassa** lo stato nella base sbagliata →
introduce ~25% di errori sui bit siftati → Alice e Bob la **beccano**.

**Come si scopre il disturbo (in pratica):** dopo il sifting i bit di Alice e Bob dovrebbero
essere **identici**. Allora **sacrificano un campione** a caso e lo confrontano **pubblicamente**:

- **errore ≈ 0** → niente spia → tengono il resto come chiave;
- **errore alto** (Eve dà ~25%: sbaglia base nel 50% dei casi, e lì Bob ha 50% di errore → ¼)
  → c'è Eve → **scartano tutto**.

I bit del campione, ormai annunciati, si buttano (non sono più segreti).

### E91 vs BB84

| | **BB84** | **E91** |
| --- | --- | --- |
| tipo | prepare-and-measure | entanglement-based |
| risorsa | Alice prepara e manda qubit | coppie di Bell condivise |
| chi misura | solo Bob | Alice **e** Bob |
| sicurezza da | **no-cloning** + disturbo | **violazione di Bell** (`S>2`) |

Sono **parenti stretti**: E91 è "la versione con entanglement" di BB84.

---

## Rule card

| Protocollo | In → out | Ingrediente |
| --- | --- | --- |
| Teleportation | 1 coppia Bell + 2 bit classici → 1 qubit | BSM + Pauli |
| Swapping | 2 coppie Bell + BSM → 1 coppia a distanza | teleportation di metà coppia |
| Superdense | 1 coppia Bell + 1 qubit → 2 bit classici | Pauli encode + Bell measure |
| No-cloning | — | linearità/unitarietà: `x=x²` |
| E91 | coppie Bell + test di Bell → chiave segreta | violazione CHSH |
