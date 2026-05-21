module Metrics

using QuantumSavory

"""
Compute the fidelity of the final state with respect to |Φ+⟩.
F = ⟨Φ+| ρ_AB |Φ+⟩
"""
function compute_fidelity(net, alice_slot, bob_slot)
    # TODO: extract ρ_AB and compute ⟨Φ+|ρ|Φ+⟩
end

"""
Run a single simulation (ideal or noisy).
Returns (fidelity, distribution_time).
"""
function single_run(N::Int; p_success=1.0, p_w=0.0)
    # TODO: create network, generate entanglement, perform swapping, measure
end

"""
Run M Monte Carlo iterations and collect statistics.
Returns (fidelity_mean, fidelity_std, time_mean, time_std).
"""
function monte_carlo(N::Int, M::Int; p_success=1.0, p_w=0.0)
    # TODO: loop over single_run, compute mean and standard deviation
end

end # module
