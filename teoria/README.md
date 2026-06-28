# Teoria per l'esame di Quantum Computing

Cartella di ripasso. Un file per blocco. Obiettivo: 30L.
Esame: lunedì. Parti da `01_fondamenta.md` e scendi.

---

## La mappa: 12 domande → 4 blocchi collegati

```text
        ┌─────────────────────────────────────────────┐
        │  BLOCCO 0 · FONDAMENTA (sblocca tutto)        │
        │  qubit · gate (X,Y,Z,H,CNOT,CZ) · misura ·    │
        │  stati di Bell · tensor product               │
        └───────────────┬─────────────────────────────┘
                        │
     ┌──────────────────┼─────────────────────┬────────────────────┐
     ▼                  ▼                     ▼                    ▼
 BLOCCO 1            BLOCCO 2             BLOCCO 3             BLOCCO 4
 STATI &             PROTOCOLLI           CORREZIONE           CIRCUITI
 DENSITÀ             (Bell + Pauli)       ERRORI               (saper fare)
 puro vs misto       teleportation        bit-flip (3q)        circuito semplice
 traccia parziale    superdense           phase-flip (3q)      3 qubit H + CZ
 fidelity            no-cloning           Shor (9q)            (+ modifica)
 reasoning           E91 (QKD)            purification → F↑
        ▲                  ▲
        └── IL TUO PROGETTO ┘  (swapping = teleportation; rumore = mixing)
```

Ogni blocco usa **solo** il precedente. Non sono 12 cose: è una scala.

---

## File

| File | Blocco | Contenuto |
| --- | --- | --- |
| `01_fondamenta.md` | 0 | qubit, Dirac, gate, misura, tensor, stati di Bell |
| `02_densita_e_entanglement.md` | 1 | matrice densità, puro/misto, traccia parziale, fidelity |
| `03_protocolli.md` | 2 | teleportation, swapping, superdense, no-cloning, E91 |
| `04_correzione_errori.md` | 3 | bit-flip, phase-flip, Shor, purification |
| `05_circuiti.md` | 4 | risolvere circuiti, 3 qubit H+CZ + modifica |
| `06_progetto.md` | — | il tuo progetto spiegato per difenderlo all'esame |

---

## Indice domande passate → dove sta la risposta

| Domanda d'esame (passata) | File |
| --- | --- |
| Circuito della teleportation + come funziona | `03` |
| Superdense coding (come funziona, circuito) | `03` |
| No-cloning theorem | `03` |
| Protocollo E91 (Ekert) | `03` |
| Domanda di ragionamento sull'entanglement | `02` (§ entanglement) |
| Riconoscere stati puri/misti dalla matrice di densità | `02` (§ puro vs misto) |
| Densità di uno stato a 2 qubit + traccia parziale per isolare A | `02` (§ traccia parziale) |
| Codice di Shor per la correzione phase-flip | `04` |
| Bit-flip e phase-flip error correction | `04` |
| Come cambia la fidelity ad ogni passo di swapping e purification | `04` (§ purification) + `06` |
| Circuito 3 qubit con Hadamard e CZ, poi modifica per risultato costante | `05` |
| Risolvere un circuito semplice | `05` |

---

## Piano 4 giorni

- **Giovedì** — `01` + `02` (fondamenta + densità). Il giorno più importante.
- **Venerdì** — `03` (protocolli) + `06` (capire il progetto a fondo).
- **Sabato** — `04` (correzione errori + purification) + E91.
- **Domenica** — `05` (circuiti a mano) + ripasso a voce di tutto.

Tecnica per il 30L: dopo aver letto un file, **chiudilo e ripeti a voce** come se fossi all'esame. Quello che non sai ridire, rileggilo.
