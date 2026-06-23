# Entanglement Swapping in Quantum Repeater Chains

Simulation of end-to-end entanglement distribution across a linear quantum network with N repeater nodes, using the entanglement swapping protocol.

Built in **Julia** with [QuantumSavory.jl](https://github.com/QuantumSavory/QuantumSavory.jl).
The network is run as a **discrete-event simulation**: entanglement generation,
swapping and classical tracking are `ProtocolZoo` entities (`EntanglerProt`,
`SwapperProt`, `EntanglementTracker`) executing in parallel on a `ConcurrentSim`
clock. Each repeater performs a *local* Bell-state measurement and broadcasts the
outcome over a classical channel; the remote Pauli correction is applied by the
tracker. Swaps fire **asynchronously** (as soon as a repeater holds both halves),
so the model reflects the real protocol rather than a synchronous approximation.

## Project Structure

```text
├── src/
│   ├── network.jl          # Linear RegisterNet + classical channels + EntanglerProt generation
│   ├── swapping.jl         # Asynchronous SwapperProt + EntanglementTracker (classical corrections)
│   ├── metrics.jl          # Discrete-event run, fidelity detector, Monte Carlo with 95% CI
│   └── plots.jl            # Plot generation (distribution time, fidelity, heatmaps)
├── exercises/              # Incremental QuantumSavory exercises (register → swap → noise)
├── run_ideal.jl            # Entry point: ideal case validation (F = 1.0, T = 1)
├── run_simulation.jl       # Entry point: noisy simulation + plot generation
├── run_analysis.jl         # Entry point: MC vs theory (exact time; async vs synchronous Werner)
├── Project.toml            # Julia project dependencies
└── Manifest.toml           # Julia dependency lockfile
```

## Setup

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

## Usage

```bash
# Phase 1: validate ideal case (no noise, F = 1.0)
julia --project=. run_ideal.jl

# Phase 2-4: run noisy simulation and generate plots
julia --project=. run_simulation.jl

# Phase 5: compare Monte Carlo against analytical predictions
julia --project=. run_analysis.jl
```

`run_simulation.jl` and `run_analysis.jl` seed the global RNG (`seed = 2025`),
so figures and the numbers quoted in the slides are reproducible run-to-run
(`run_ideal.jl` needs no seed: the ideal fidelity does not depend on the
random BSM outcomes).

## Parameters

| Parameter   | Description                                          |
|-------------|------------------------------------------------------|
| `N`         | Number of quantum repeater nodes in the chain        |
| `p_success` | Per-attempt Bell pair generation success probability |
| `p_w`       | Memory depolarization noise parameter                |

## Metrics

- **Fidelity** — F = ⟨Φ⁺|ρ_AB|Φ⁺⟩ measures how close the final Alice-Bob state is to the ideal Bell state
- **Distribution time** — number of discrete time steps to establish end-to-end entanglement
