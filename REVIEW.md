# Review - Entanglement Swapping Project

Stato dopo revisione e fix.

## 1. FIXATO: `p_success = 1.0` nel modello non ideale

**File:** `src/metrics.jl`, `src/network.jl`, `run_ideal.jl`

Il benchmark ideale e il modello probabilistico erano confusi: `single_run(...; p_success=1.0)`
usava sempre la generazione ideale istantanea e restituiva `T = 0`.

Nel modello della consegna, invece, una generazione con `p_success = 1` richiede un tentativo:
`T = 1`. Il caso `T = 0` e' valido solo per il benchmark ideale.

**Fix applicato:** `single_run` ora usa il modello probabilistico di default; il benchmark ideale
passa esplicitamente `ideal=true`.

---

## 2. FIXATO: convenzione del depolarizing channel nel Werner model

**File:** `run_analysis.jl`, `presentation.tex`

QuantumSavory implementa `Depolarization(tau)` con la convenzione fully-mixing:

```text
E(rho) = (1-p) rho + p I/2
```

quindi il vettore di Bloch si contrae come `(1-p)`, non come `(1 - 4p/3)`.

**Fix applicato:**

```julia
w_link = (1.0 - p_depol)^2
```

Anche la formula approssimata e le slide sono state aggiornate da `(1 - 4/3 p_w)` a
`(1 - p_w)`.

---

## 3. FIXATO: confronto Werner con generation times indipendenti

**File:** `src/metrics.jl`, `run_analysis.jl`

Il vecchio confronto MC/Werner ricampionava `gen_times`, quindi non era un confronto per-run.
Questo non falsava necessariamente le medie asintotiche, ma rendeva debole l'interpretazione
dello scarto run-by-run.

**Fix applicato:** aggiunta `Metrics.single_run_detailed`, che restituisce anche i tempi di
generazione usati dalla simulazione; `run_analysis.jl` usa gli stessi tempi per il Werner model.

---

## 4. FIXATO: path delle immagini nella presentazione

**File:** `presentation.tex`, `src/plots.jl`, `run_analysis.jl`, `run_simulation.jl`

Le slide includevano PNG senza path, mentre le figure sono sotto `figures/simulation/` e
`figures/analysis/`.

**Fix applicato:** aggiunto:

```latex
\graphicspath{{figures/simulation/}{figures/analysis/}}
```

Gli script ora salvano direttamente nelle cartelle `figures/simulation` e `figures/analysis`.

---

## 5. FIXATO: termine "multimodal" nella slide Emergent Effects

**File:** `presentation.tex`

La distribuzione di `F` e' descritta in modo piu' prudente come left-skewed, con coda verso
`0.25`, invece che come multimodale.

---

## Da rigenerare

Dopo questi fix, le figure gia' presenti e `pres.pdf` possono essere stale. Rigenerare con:

```bash
julia --project=. run_simulation.jl
julia --project=. run_analysis.jl
```

e poi ricompilare `presentation.tex`.
