"""
Phase 2-4: Full noisy simulation.
Run Monte Carlo for all parameter combinations
and generate the required plots.
"""

include("src/network.jl")
include("src/swapping.jl")
include("src/metrics.jl")
include("src/plots.jl")

using .Network, .Swapping, .Metrics, .PlotGeneration

# --- Parameters ---
const P_SUCCESS_RANGE = 0.1:0.1:1.0
const PW_VALUES = [0.01, 0.05, 0.10]
const N_VALUES = [1, 3, 5]
const M_RUNS = 500

function main()
    println("=== Noisy simulation ===\n")

    # --- Plot 1: Distribution time vs p_success for different N ---
    # TODO: loop over N_VALUES and P_SUCCESS_RANGE, collect results, plot

    # --- Plot 2: Fidelity vs p_success for different p_w ---
    # TODO: fix N, loop over PW_VALUES and P_SUCCESS_RANGE, collect results, plot

    # --- Extra plots ---
    # TODO: heatmap, fidelity vs N, etc.
end

main()
