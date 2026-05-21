# Entanglement Swapping in Quantum Repeater Chains

Simulation of end-to-end entanglement distribution across a linear quantum network with N repeater nodes, using the entanglement swapping protocol.

Built in **Julia** with [QuantumSavory.jl](https://github.com/QuantumSavory/QuantumSavory.jl).

## Project Structure

```text
├── src/
│   ├── network.jl          # Network topology and Bell pair generation (ideal + probabilistic)
│   ├── swapping.jl         # Entanglement swapping protocol (BSM + Pauli corrections)
│   ├── metrics.jl          # Fidelity computation, single run, Monte Carlo engine
│   └── plots.jl            # Plot generation (distribution time, fidelity, heatmaps)
├── run_ideal.jl            # Entry point: ideal case validation (F must equal 1.0)
├── run_simulation.jl       # Entry point: noisy simulation + plot generation
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
```

## Parameters

| Parameter   | Description                                          |
|-------------|------------------------------------------------------|
| `N`         | Number of quantum repeater nodes in the chain        |
| `p_success` | Per-attempt Bell pair generation success probability |
| `p_w`       | Memory depolarization noise parameter                |

## Metrics

- **Fidelity** — F = ⟨Φ⁺|ρ_AB|Φ⁺⟩ measures how close the final Alice-Bob state is to the ideal Bell state
- **Distribution time** — number of discrete time steps to establish end-to-end entanglement
