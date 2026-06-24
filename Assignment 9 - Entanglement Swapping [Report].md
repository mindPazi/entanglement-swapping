# Osservazioni sul Progetto "Assignment 9: Entanglement Swapping"

La valutazione tiene conto non solo della correttezza dei risultati numerici, ma soprattutto dell'uso corretto del simulatore secondo il paradigma mostrato a lezione (simulazione a eventi discreti e ProtocolZoo). Questo è uno degli obiettivi formativi centrali del corso: usare in modo appropriato uno strumento allo stato dell'arte, non reimplementare a mano un modello alternativo che, pur fornendo (in gran parte) numeri corretti, aggira l'infrastruttura del simulatore.

## Slides

- Struttura chiara e coerente con le specifiche (motivazione, protocollo, modello di rumore, architettura, validazione ideale, Monte Carlo, confronto numerico vs teorico, conclusioni). Entrambi i grafici richiesti sono presenti.

- Presentazione dei risultati chiara; ogni grafico è corredato di parametri e interpretazione.

- Dal punto di vista formale, le formule sono matematicamente corrette, ma codificano un modello semplificato (swapping sincrono) che non corrisponde al funzionamento reale del protocollo (vedi sotto). Notazione coerente, terminologia appropriata.

- Criticità sostanziali nella presentazione dei risultati:

  - L'assunzione di "swapping sincrono" (tutte le BSM eseguite al tempo T = T_max) è presentata come semplice "caso pessimistico", ma in realtà è la conseguenza di non aver modellato il protocollo in modo realistico. Nel funzionamento corretto ogni switch effettua lo swap NON appena dispone delle due metà locali, tipicamente modellato da entità in esecuzione parallela. Questo NON è un semplice peggioramento: per N ≥ 2 il modello sincrono SOTTOSTIMA sistematicamente la fidelity (i qubit dei repeater vengono in realtà misurati prima e accumulano meno decoerenza). Per N = 1 i due modelli coincidono.
  - La struttura del modello di Werner [F = (1 + 3 w_tot)/4, swap moltiplicativo] resta valida, ma la parametrizzazione mostrata è legata allo schedule sincrono: nel modello realistico i due qubit di un link interno sono misurati a tempi di swap diversi, le attese vanno calcolate per-qubit, risultano minori e la fidelity attesa è più alta. La predizione teorica delle slide andrebbe quindi rivista.

- Qualità della presentazione (forma): livello di dettaglio adeguato (un paio di slide dense), grafici e tabelle adeguati, buona capacità di sintesi, slide ben bilanciate.

## Codice

### QuantumSavory/Julia

- Il codice è leggibile ed esegue correttamente.

- Punti positivi (a livello di singoli costrutti e di ingegneria del codice):

  - Buona modularità: separazione in `network.jl`, `swapping.jl`, `metrics.jl`, `plots.jl` con tre entry point distinti; docstring chiare.
  - Buona impostazione statistica: Monte Carlo ripetuto (M = 500–2000), seed fissato (2025), media e deviazione standard.

- Criticità principale — uso NON corretto del simulatore (obiettivo formativo centrale del corso, ribadito più volte a lezione):

  - Il motore a eventi discreti non è mai istanziato: nessun oggetto di simulazione / time-tracker, nessun processo `@resumable`, nessun uso di `ProtocolZoo` (`EntanglerProt`, `SwapperProt`, `EntanglementTracker`). I tempi geometrici sono campionati analiticamente e la decoerenza è applicata con `uptotime!` su uno schedule calcolato a mano. Il progetto in esame rappresenta proprio lo scenario d'uso tipico per cui QuantumSavory è pensato — simulazione di rete con entità che eseguono in parallelo, come mostrato nelle attività di laboratorio (lezione "Entangling" disponibile su Teams del corso) — eppure questa infrastruttura non viene sfruttata.
  - Lo swapping è modellato in modo non locale: `CircuitZoo.EntanglementSwap` applica le correzioni di Pauli direttamente sui qubit remoti nello stesso circuito, come se lo switch potesse accedere alle memorie dei nodi remoti. Lo stato finale numerico coincide, ma non si modella il vincolo realistico (misura locale + comunicazione classica del risultato + correzione remota, oppure Pauli-frame tracking via `EntanglementTracker`). Viene meno la separazione delle responsabilità tipica di una simulazione di rete; in scenari con latenza o decoerenza durante la comunicazione i risultati cambierebbero.
  - Conseguenza sui risultati: lo swapping sincrono a T_max sottostima la fidelity per N ≥ 2. I trend qualitativi reggono, ma i valori per catene più lunghe non sono quelli di un'implementazione corretta.

- Ulteriori errori concettuali:

  - Caso ideale con tempo di distribuzione 0: incoerente con il limite p_success → 1 del modello stocastico, che dà T = 1 (una finestra di heralded entanglement generation). Il caso ideale dovrebbe valere 1, non 0; il valore 0 bypassa il tempo dell'operazione di generazione. Con un approccio a eventi discreti, in cui la generazione occupa naturalmente un passo temporale, questa incoerenza non si sarebbe presentata.

- Gestione di rumore/decoerenza: la dichiarazione del background `Depolarization(τ)` sui registri, con mappatura τ = -1/ln(1 - p_w), è il meccanismo nativo corretto per modellare il rumore. La sua applicazione, però, è guidata da uno schedule calcolato a mano anziché dall'orologio della simulazione a eventi.

- Analisi statistica: le bande nei grafici sono ±1 std della distribuzione, NON intervalli di confidenza della media (es. 95% CI).

## Valutazione Complessiva

- Le specifiche, lette in senso stretto sui deliverable, risultano formalmente soddisfatte (caso ideale, modello con rumore depolarizzante e generazione geometrica, le due metriche, i due grafici richiesti, discussione dei trend). Tuttavia, l'obiettivo formativo centrale — usare correttamente QuantumSavory come simulatore di rete a eventi discreti — NON è raggiunto: il progetto adotta un modello analitico/sequenziale alternativo che aggira il paradigma del simulatore.

- Punti di forza: codice modulare e ben documentato; buona ripetizione statistica con seed; grafici curati; assunzioni dichiarate in modo onesto.

- Principali criticità:

  - Mancato uso del motore a eventi discreti e di ProtocolZoo: nessun processo `@resumable`, nessun oggetto di simulazione, swapping non orchestrato da entità parallele.
  - Modellazione non locale dello swapping (correzioni applicate sui qubit remoti, nessuna comunicazione classica modellata).
  - Errori concettuali con impatto sui risultati: fidelity sottostimata per N ≥ 2 (swapping sincrono a T_max); tempo di distribuzione ideale pari a 0 anziché 1. La giustificazione teorica via Werner, valida nella struttura, è parametrizzata sul modello semplificato.
  - Uso di bande ±std al posto di intervalli di confidenza opportunamente calcolati.

Nel complesso, il progetto si colloca su un livello medio-basso dal punto di vista della compliance con il comportamento realistico dell'entanglement swapping in uno scenario di networking. I risultati sono in larga parte corretti e l'ingegneria del codice è buona, ma lo strumento di simulazione non è stato utilizzato come previsto dagli obiettivi del corso e dalle attività di laboratorio: vi sono inoltre veri e propri errori concettuali (swapping sincrono che sottostima la fidelity, tempo ideale nullo, correzioni non locali) che alterano i risultati e il modo di concepire la simulazione, e che in scenari più complessi causerebbero problemi ulteriori.