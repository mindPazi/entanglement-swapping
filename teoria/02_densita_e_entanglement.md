# Blocco 1 — Densità, stati puri/misti, entanglement

Qui dentro ci sono **3 domande d'esame intere**. Conti per esteso.

---

## 7. Perché serve la matrice di densità

Il vettore `|ψ⟩` (il ket) descrive bene **un** qubit in uno stato preciso e isolato.
Il problema è che ci sono due situazioni che **non** puoi scrivere come un singolo ket:

1. **Incertezza classica.** Ho il qubit in `|0⟩` col 50% o in `|1⟩` col 50%, e *non so quale*
   (es. una macchina che ne sforna a caso uno dei due). Attenzione: **questo NON è `|+⟩`!**
   `|+⟩=(|0⟩+|1⟩)/√2` è una **sovrapposizione** (un ket, con le coerenze); qui invece è una
   **mistura classica**: o è 0 o è 1, manca solo l'informazione. Sono stati fisici diversi
   (stesse popolazioni, coerenze diverse — vedi §8) → servono due descrizioni diverse,
   e il ket non basta per la mistura.
2. **Un pezzo di un sistema più grande.** Il qubit di Alice da solo, quando è entangled con
   Bob, non *ha* un suo ket (l'informazione sta nelle correlazioni). Serve comunque descriverlo.

Lo strumento che copre **entrambi** i casi è la **matrice di densità `ρ`** (una matrice al
posto di un vettore).

**Caso stato puro** (un solo ket noto `|ψ⟩`): `ρ = |ψ⟩⟨ψ|`.
È l'**outer product** = colonna × riga → una matrice. Esempio con `|+⟩`:

```text
ρ = |+⟩⟨+| = [1/√2]·[1/√2  1/√2] = [1/2  1/2] = ½[1 1]
             [1/√2]                 [1/2  1/2]      [1 1]
```

**Caso mistura** (più stati `|ψᵢ⟩`, ciascuno con probabilità `pᵢ`): `ρ = Σᵢ pᵢ |ψᵢ⟩⟨ψᵢ|`.
È solo una **media pesata** delle singole matrici. Esempio "50% |0⟩, 50% |1⟩":

```text
ρ = ½|0⟩⟨0| + ½|1⟩⟨1| = ½[1 0] + ½[0 0] = [½ 0]
                          [0 0]    [0 1]    [0 ½]
```

(diagonale, coerenze zero → mistura classica, non sovrapposizione).

**Tre proprietà sempre vere** (sono solo "ρ ha senso come descrizione di probabilità"):

- **`ρ` hermitiana** (`ρ† = ρ`): garantisce che le quantità misurabili vengano fuori reali.
- **`Tr(ρ) = 1`**: la diagonale sono le probabilità degli esiti → devono sommare a 1.
- **autovalori ≥ 0**: gli autovalori sono probabilità → non possono essere negativi.

---

## 8. Puro vs misto — DOMANDA

> **Regola d'oro:** calcola `Tr(ρ²)`.
> `Tr(ρ²)=1` → **PURO**.  `Tr(ρ²)<1` → **MISTO**.

Equivalente: puro ⇔ `ρ²=ρ` (proiettore) ⇔ un solo autovalore =1, gli altri =0.
`Tr(ρ²)` = *purezza*; per un qubit va da 1 (puro) a 1/2 (massimamente misto).

### Esempio: stesso aspetto, esiti opposti

`|+⟩` **puro**:

```text
ρ = |+⟩⟨+| = ½ [1 1]      ρ²=ρ → Tr(ρ²)=1 → PURO
               [1 1]
```

Massimamente **misto** (50% |0⟩, 50% |1⟩):

```text
ρ = ½|0⟩⟨0| + ½|1⟩⟨1| = [0.5  0 ]    Tr(ρ²)=0.25+0.25=0.5 <1 → MISTO
                        [ 0  0.5]
```

**Colpo d'occhio che vuole il prof:** stessa **diagonale** (popolazioni 0.5/0.5),
ma il puro ha i **termini fuori-diagonale** (le *coerenze*, gli 1), il misto no.
Coerenze = "quantità di sovrapposizione quantistica". Niente coerenze → misto.

Risposta tipo: *"Riconosco un misto perché Tr(ρ²)<1; visivamente perché ha perso
le coerenze fuori-diagonale rispetto al corrispondente stato puro."*

### Come calcolare Tr(ρ²) in fretta

`Tr(ρ²) = Σᵢⱼ |ρᵢⱼ|²` (somma dei moduli quadri di **tutti** gli elementi).

---

## 9. Traccia parziale — DOMANDA ("isolare il sistema A")

Hai `ρ_AB` (4×4) e vuoi il solo qubit di Alice, ignorando Bob:
`ρ_A = Tr_B(ρ_AB)`.

### Ricetta pratica (2 qubit)

Scrivi la 4×4 in **blocchi 2×2** indicizzati dal qubit A:

```text
ρ_AB = [ B₀₀  B₀₁ ]      (ogni Bᵢⱼ è 2×2, "appartiene" a Bob)
       [ B₁₀  B₁₁ ]
```

- `ρ_A` = sostituisci ogni blocco con la sua **traccia**:
  `ρ_A = [[Tr B₀₀, Tr B₀₁],[Tr B₁₀, Tr B₁₁]]`
- `ρ_B` = **somma dei blocchi diagonali**: `ρ_B = B₀₀ + B₁₁`

### Esempio svolto su |Φ⁺⟩ (lo stato del progetto)

```text
ρ_AB = |Φ⁺⟩⟨Φ⁺| = ½ [1 0 0 1]      base |00⟩,|01⟩,|10⟩,|11⟩
                     [0 0 0 0]
                     [0 0 0 0]
                     [1 0 0 1]
```

Blocchi: `B₀₀=½[[1,0],[0,0]]`, `B₀₁=½[[0,1],[0,0]]`,
`B₁₀=½[[0,0],[1,0]]`, `B₁₁=½[[0,0],[0,1]]`.
Tracce: `½, 0, 0, ½`. Quindi:

```text
ρ_A = [0.5  0 ] = I/2   → MISTO (massimamente)
      [ 0  0.5]
```

---

## 10. Domanda di ragionamento sull'entanglement

All'esame è una **domanda aperta e concettuale** (non un calcolo): il prof chiede di
*ragionare* sull'entanglement. Non ha un testo unico fisso — le forme precise in cui può
arrivare sono le **D1–D4** qui sotto. Prima il concetto che serve per rispondere, poi le
risposte pronte.

### Il concetto chiave

> **Lo stato globale `|Φ⁺⟩` è PURO (`Tr(ρ_AB²)=1`), ma ogni singolo qubit è MISTO (`ρ_A=ρ_B=I/2`).**
> Questo È l'entanglement: l'informazione sta nelle **correlazioni** tra i due qubit, non nei
> singoli. Un qubit da solo "non sa niente" (50/50); l'ordine si vede solo guardando la coppia.

**Attenzione: "puro" e "misto" qui parlano di due sistemi DIVERSI** — non è una contraddizione.

- **il TUTTO** = i due qubit *insieme*, stato `|Φ⁺⟩` → **PURO**;
- **la PARTE** = *un* qubit da solo — e vale per **entrambi**: `ρ_A = ρ_B = I/2` → **MISTO**
  (per `|Φ⁺⟩` sono uguali per simmetria; in generale `ρ_A` e `ρ_B` possono differire).

`|Φ⁺⟩` non è un singolo qubit, è la coppia; un singolo qubit non ha nemmeno un ket, è `ρ_A` (o `ρ_B`).
La firma dell'entanglement è proprio questa **coesistenza**: tutto puro + parti miste. La regola
"entangled ⟺ singolo misto" è il test qui sotto, e parte sempre da una coppia in stato puro.

**Test di entanglement (stati puri):** fai la traccia parziale e guarda il ridotto.
`ρ_A` **misto** → entangled; `ρ_A` **puro** → stato prodotto (separabile).

**Contro-esempio (non entangled):** lo stato prodotto `|0⟩⊗|+⟩` dà `ρ_A=|0⟩⟨0|`, che resta
**puro** → non entangled. Serve a mostrare che il test distingue davvero (non risponde
"entangled" a qualsiasi stato).

**Perché "stati puri"?** Il test vale **solo** se il globale è puro. Se il globale è **misto**,
la purezza del singolo non dice più niente: lo stato `I/4` (globale misto) ha `ρ_A=I/2` **misto**
ma è **separabile** — la *stessa* `ρ_A` di `|Φ⁺⟩`, che invece è entangled. Stesso singolo,
entanglement opposto: l'unica differenza è la purezza globale. Quindi:

- globale **puro** → dalla purezza del singolo deduci prodotto vs entangled;
- globale **misto** → dal singolo **non** deduci niente (servono criteri tipo Peres-Horodecki, fuori programma).

### Sottosistema di un entangled = misto (l'ombra dell'entanglement)

Punto di ragionamento utile, e una trappola da evitare:

- **Entanglement e mistura sono due facce della stessa cosa.** Se due qubit sono entangled e
  ne **ignori uno** (traccia parziale su B), il qubit rimasto `ρ_A` risulta **misto**. Quella
  mistura **è l'ombra dell'entanglement**: la correlazione con B che hai lasciato fuori
  riappare come incertezza classica su A. (Per `|Φ⁺⟩`: `ρ_A = I/2`, massimamente misto.)
- **Trappola — "ignorare" ≠ "misurare".** È l'**ignorare** (la traccia parziale) a produrre il
  misto, **non il misurare**. Misurare B è un atto fisico che **collassa** B (e con lui A) a un
  valore **definito**; tracciare via B è solo "descrivo A da solo, senza guardarlo" → nessun
  esito, nessun collasso, e A esce **misto**.

> **One-liner:** un pezzo di una coppia entangled, guardato da solo, è sempre misto — e quella
> mistura è proprio l'entanglement, nascosto nelle correlazioni con il partner ignorato.

### Le forme della domanda + risposta da dire a voce

Le quattro forme tipiche in cui può arrivare, con la risposta pronta:

#### D1 — "Cos'è l'entanglement / cosa significa che due qubit sono entangled?" (la più probabile)

> Due qubit sono entangled quando il loro stato **non si può scrivere come prodotto** dei
> due singoli (`|ψ⟩_AB ≠ |a⟩⊗|b⟩`). Conseguenza: ogni qubit **da solo** è **misto** (casuale),
> ma i due sono **perfettamente correlati**. L'informazione sta nella **correlazione**, non
> nei singoli. Esempio: `|Φ⁺⟩=(|00⟩+|11⟩)/√2`, sempre uguali, ma ciascuno da solo è 50/50.

#### D2 — "Come capisci se uno stato è entangled?"

> Per uno stato puro: faccio la **traccia parziale** e guardo il ridotto. Se `ρ_A` è **misto**
> (`Tr(ρ_A²)<1`) → **entangled**; se resta **puro** → **separabile**. Es: `|Φ⁺⟩→ρ_A=I/2`
> misto → entangled; `|0⟩⊗|+⟩→ρ_A=|0⟩⟨0|` puro → no.

#### D3 — "Se misuri un qubit della coppia di Bell, cosa succede all'altro? Si comunica più veloce della luce?"

> L'altro **collassa all'istante** nello stato corrispondente (per `|Φ⁺⟩`, lo stesso valore).
> Ma **non** è comunicazione FTL: il mio esito è **casuale**, non lo scelgo; l'altro vede solo
> un risultato casuale finché non gli mando l'esito su un **canale classico** (≤ velocità luce).

#### D4 — "Perché `|Φ⁺⟩` non si può scrivere come `|a⟩⊗|b⟩`?" (versione "dimostrala")

> Se fosse `(α|0⟩+β|1⟩)⊗(γ|0⟩+δ|1⟩)`, avresti `αγ|00⟩+αδ|01⟩+βγ|10⟩+βδ|11⟩`. Per `|Φ⁺⟩`
> servono `|00⟩,|11⟩` presenti (`αγ,βδ≠0`) ma `|01⟩,|10⟩` assenti (`αδ=βγ=0`). Impossibile:
> se `αγ≠0` e `βδ≠0` allora tutti e 4 i numeri sono ≠0, quindi anche `αδ,βγ≠0`. Contraddizione
> → **non fattorizzabile → entangled**.

**Strategia:** parti da **D1** (definizione + "l'info è nella correlazione"). Se vuole di più,
aggiungi il **test** (D2) o il **collasso senza FTL** (D3). La **D4** se chiede di dimostrarlo.
Tutte escono dalle "monete magiche": ognuna casuale, ma sempre uguali.

---

## 11. Fidelity (il ponte col progetto)

Quanto uno stato `ρ` è vicino a uno stato target `|φ⟩`:

```text
F = ⟨φ|ρ|φ⟩         (F=1 identici, F piccola lontani)
```

Per il target Bell `|Φ⁺⟩`, usando il proiettore
`|Φ⁺⟩⟨Φ⁺| = (II + XX − YY + ZZ)/4`:

```text
F = (1 + ⟨XX⟩ + ⟨ZZ⟩ − ⟨YY⟩) / 4
```

← è **esattamente** la formula del detector del progetto (`src/metrics.jl`).

Casi limite:

- Coppia perfetta `ρ=|Φ⁺⟩⟨Φ⁺|` → F=1.
- Coppia massimamente mista `ρ=I/4` → F=1/4 = **0.25** (il pavimento delle heatmap).

Attenzione: la fidelity guarda lo stato **congiunto** AB. I marginali `ρ_A, ρ_B`
restano `I/2` (misti) anche nella coppia perfetta — è normale per uno stato entangled.

---

## Rule card

- **Puro** — `ρ=|ψ⟩⟨ψ|`, `ρ²=ρ`, **Tr(ρ²)=1**
- **Misto** — `ρ=Σpᵢ|ψᵢ⟩⟨ψᵢ|`, **Tr(ρ²)<1**
- **Misto a occhio** — coerenze fuori-diagonale ridotte/assenti
- **Tr(ρ²) veloce** — somma di tutti i `|ρᵢⱼ|²`
- **Isolare A** — `ρ_A = Tr_B`: traccia di ogni blocco 2×2
- **Test entanglement (puri)** — ridotto misto ⇒ entangled
- **`|Φ⁺⟩`** — puro, ma `ρ_A=ρ_B=I/2`
- **Fidelity Bell** — `F=(1+⟨XX⟩+⟨ZZ⟩−⟨YY⟩)/4`

---

## Prova tu

1. `|ψ⟩=(|0⟩+i|1⟩)/√2`. Scrivi ρ, calcola Tr(ρ²): puro o misto?
2. `ρ=0.75|0⟩⟨0|+0.25|1⟩⟨1|`: puro o misto? Tr(ρ²)=?
3. Stato prodotto `|0⟩⊗|+⟩`: scrivi i 4 numeri, fai Tr_B, verifica `ρ_A=|0⟩⟨0|`.

> Soluzioni: (1) puro, Tr(ρ²)=1 — è ancora un ket singolo, solo con una fase i.
> (2) misto, Tr(ρ²)=0.75²+0.25²=0.625. (3) vettore [1/√2,1/√2,0,0]ᵀ; ρ_A=|0⟩⟨0|, puro → non entangled.
