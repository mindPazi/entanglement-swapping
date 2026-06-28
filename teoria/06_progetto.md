# Il tuo progetto — spiegato per difenderlo all'esame

Entanglement Swapping in catene di ripetitori, simulato con **QuantumSavory.jl** (Julia).
Se l'esaminatore parte dal progetto, devi saper raccontare **cosa**, **come**, **perché**.

---

## In una frase

Simulo la distribuzione di entanglement tra Alice e Bob attraverso N ripetitori, e misuro
**fidelity** (quanto è buona la coppia finale) e **distribution time** (quanti passi servono)
al variare del rumore, confrontando una simulazione **Monte Carlo a eventi discreti** con un
**modello teorico** (Werner) — e tornano.

---

## La pipeline (4 passi)

Topologia: `A — R₁ — R₂ — … — Rₙ — B`. Alice/Bob 1 qubit, ogni ripetitore 2 qubit.

1. **Generazione** — su ogni link nasce `|Φ⁺⟩` (heralded), successo con prob `p_success`
   per tentativo → i tempi di generazione sono **geometrici**. `EntanglerProt`, `src/network.jl`.
2. **Swapping** — ogni ripetitore fa una **misura di Bell locale** sui suoi 2 qubit
   (= teleportation, file 03) → "incolla" i due link. `SwapperProt`, `src/swapping.jl`.
3. **Correzione** — la BSM dà 2 bit classici; il nodo remoto applica la **Pauli correction**
   quando arriva il messaggio. `EntanglementTracker`, `src/swapping.jl`.
4. **Rumore + misura** — i qubit in attesa si **depolarizzano** (`p_w`/step); il detector
   misura `F = (1+⟨XX⟩+⟨ZZ⟩−⟨YY⟩)/4` al momento della consegna. `src/metrics.jl`.

---

## Perché serve (la motivazione, slide 2)

- In fibra le perdite crescono **esponenzialmente** con la distanza.
- Per il **no-cloning** (file 03) non puoi amplificare copiando.
- Soluzione: **quantum repeater** = distribuzione di entanglement hop-by-hop con swapping.

---

## I concetti di teoria che il progetto usa (collegamenti)

- **Stati di Bell** (file 01): lo stato di ogni link.
- **Teleportation** (file 03): lo swapping *è* teleportation di metà coppia.
- **Matrice densità / misto** (file 02): la depolarizzazione trasforma la coppia in uno
  stato **misto**; al limite `ρ=I/4` → F=0.25 (pavimento delle heatmap).
- **Fidelity** (file 02): la metrica di qualità, `F=⟨Φ⁺|ρ|Φ⁺⟩`.
- **Purification** (file 04): lavoro futuro per rialzare F.

---

## Come cambia la fidelity (la domanda chiave)

- **BSM ideale**: preserva `|Φ⁺⟩` → senza rumore **F=1 per ogni N** (validato N=1..5, slide 6).
- **Decoerenza in attesa**: ogni qubit sopravvive `(1−p_w)^(tempo di attesa)`.
- **Modello di Werner**: coppia rumorosa = stato di Werner `F=(1+3w)/4`. Gli swap ideali
  **moltiplicano** i parametri: `w_tot = ∏ᵢ wᵢ` → `F=(1+3 w_tot)/4`. Quindi F **scende** con
  N, con `p_w`, e con `p_s` basso (più attesa).

### L'idea originale del progetto: async vs sync

Ogni ripetitore fa lo swap **appena ha entrambe le metà** (a `max(g_{k-1}, g_k)`), non aspetta
il link più lento. Così i qubit **interni** vengono misurati **presto** e decoerono **meno**;
solo i qubit di Alice e Bob aspettano fino a `T = maxᵢ Tᵢ`.
→ Lo schedule **asincrono** dà F **più alta** di quello sincrono (tutte le BSM a T) per N≥2.
Il modello di Werner asincrono (per-qubit) **combacia** col Monte Carlo; il sincrono
**sottostima** F (slide 13–14). Questa è la "scoperta" da raccontare con orgoglio.

---

## Distribution time

- Ogni link: tempo `Geom(p_s)+1`. End-to-end pronto quando arriva il **link più lento**:
  `T = maxᵢ Tᵢ` (i = 1..N+1).
- `E[T]` cresce **logaritmicamente** in N (statistica dell'ordine del massimo di geometriche);
  approssimazione armonica `E[T] ≈ H(N+1)/p_s`.
- Verificato contro la formula esatta con errori <5% (`run_analysis.jl`).

---

## Architettura del codice (se chiede "com'è fatto")

Motore a **eventi discreti** (`ConcurrentSim`): entità `ProtocolZoo` che girano **in parallelo**
su un unico clock di simulazione.

```text
src/network.jl   topologia (RegisterNet) + canali classici + EntanglerProt
src/swapping.jl  SwapperProt (BSM asincrona) + EntanglementTracker (correzioni)
src/metrics.jl   run a eventi discreti + detector fidelity + Monte Carlo con CI 95%
src/plots.jl     grafici
run_ideal.jl       validazione caso ideale (F=1, T=1)
run_simulation.jl  simulazione rumorosa + grafici
run_analysis.jl    Monte Carlo vs teoria (tempo esatto; Werner async vs sync)
```

Esercizi incrementali in `exercises/` (registro → coppia di Bell → swap → rumore): utili
da mostrare come hai costruito la comprensione passo-passo.

---

## Domande probabili sul progetto + risposta lampo

- **Perché F=1 nel caso ideale e non 0?** Una finestra di generazione costa T=1 (non 0); la
  BSM ideale non degrada lo stato → F resta 1.
- **Perché F→0.25 e non 0?** 0.25 = overlap di uno stato 2-qubit **massimamente misto** (I/4)
  con qualsiasi stato di Bell. È il minimo, non lo zero.
- **Perché lo swapping fa scendere F?** Moltiplica i parametri di Werner (`w<1`).
- **Cosa farebbe risalire F?** La **purification** (file 04).
- **Cos'è la BSM?** Misura nei 4 stati di Bell = `CNOT + H + misura`; proietta i 2 qubit del
  ripetitore e teletrasporta l'entanglement ai nodi esterni.
- **Perché serve il canale classico?** Per portare gli esiti della BSM e applicare le
  correzioni di Pauli: senza, niente entanglement end-to-end utilizzabile.
