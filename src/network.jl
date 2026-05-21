module Network

using QuantumSavory

"""
Create a linear quantum network: Alice + N repeaters + Bob.
- Alice and Bob: 1 memory slot each
- Each repeater: 2 memory slots
"""
function create_network(N::Int; depolarization_rate=0.0)
    # TODO: create RegisterNet with N+2 nodes
end

"""
Generate perfect Bell pairs on all adjacent links (ideal case, instantaneous).
"""
function generate_entanglement_ideal!(net, N::Int)
    # TODO: for each link (i, i+1), generate |Φ+⟩
end

"""
Generate Bell pairs with success probability p_success on each link.
Returns the total time (number of attempts of the slowest link).
"""
function generate_entanglement_probabilistic!(net, N::Int, p_success::Float64)
    # TODO: for each link, sample from geometric distribution and apply decoherence
end

end # module
