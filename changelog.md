# Assignment 9: Entanglement Swapping
La simulazione è ora
costruita interamente sul paradigma a eventi discreti di QuantumSavory
(ProtocolZoo), non più su uno schedule analitico calcolato a mano. Di seguito la
mappa puntuale tra ciascuna criticità e la modifica apportata.

### 1. Motore a eventi discreti / ProtocolZoo (obiettivo centrale)
La rete gira ora su un clock `ConcurrentSim` (`get_time_tracker`), con entità
parallele come processi `@resumable`/`@process`: `EntanglerProt` (generazione
heralded per link), `SwapperProt` (swap ai repeater), `EntanglementTracker`
(correzioni classiche), più un `detector` `@resumable` che ferma la simulazione
alla consegna end-to-end e misura F e T. Nessun tempo è più campionato
analiticamente: i tempi geometrici emergono dal simulatore.

### 2. Swapping locale + comunicazione classica
Lo swap non è più non-locale. `SwapperProt` esegue una BSM **locale**
(`LocalEntanglementSwap`) sui soli due qubit del repeater ed emette gli esiti
come messaggi classici `EntanglementUpdate`; l'`EntanglementTracker` applica la
correzione di Pauli al qubit **remoto** solo dopo l'arrivo del messaggio sul
canale classico. La separazione misura locale / comunicazione / correzione
remota è ora rispettata.

### 3. Swapping asincrono (fidelity non più sottostimata per N ≥ 2)
Gli swapper sono event-driven (`retry_lock_time = nothing`): ogni repeater
misura appena dispone delle due metà locali, a `max(g_{k-1}, g_k)`, non a T_max.
I qubit interni decoerono quindi meno. Ho verificato numericamente che il Monte
Carlo del simulatore segue il modello di Werner **asincrono** (per-qubit),
mentre lo schedule sincrono sottostima F con scarto crescente in N
(scarto simulatore−sync ≈ 0.05, 0.09, 0.17 per N = 2, 3, 5 a p_s = 0.5,
p_w = 0.05, M = 1000); i due coincidono a N = 1, come atteso.

### 4. Tempo di distribuzione del caso ideale = 1, non 0
La generazione heralded occupa una finestra temporale (`ATTEMPT_TIME = 1`): nel
limite p_success → 1 una sola finestra è sufficiente, quindi T = 1. Il test
ideale (`run_ideal.jl`) dà ora F = 1 e T = 1 per N = 1, 2, 3, 5.

### 5. Intervalli di confidenza al posto di ±std
Le bande nei grafici sono ora i **95% CI della media** (`ci95 = 1.96·s/√M`),
ritagliati al range fisico ([0.25, 1] per F, T ≥ 1), non più la deviazione
standard della distribuzione.

---

Ho aggiornato di conseguenza anche le slide (modello di Werner per-qubit,
framework architetturale ProtocolZoo, confronto async vs sincrono). 