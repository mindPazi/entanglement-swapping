module Network

using QuantumSavory
using Graphs
using Distributions: Geometric

"""
Create a linear quantum network: Alice + N repeaters + Bob.
- Alice and Bob: 1 memory slot each
- Each repeater: 2 memory slots
"""
function create_network(N::Int; depolarization_rate=0.0)
    registers = Register[]

    make_reg(n_slots) = if depolarization_rate > 0
        Register(
            fill(Qubit(), n_slots),
            fill(QuantumOpticsRepr(), n_slots),
            fill(Depolarization(-1 / log(1 - depolarization_rate)), n_slots)
        )
    else
        Register(
            fill(Qubit(), n_slots),
            fill(QuantumOpticsRepr(), n_slots)
        )
    end

    push!(registers, make_reg(1))          # Alice
    for _ in 1:N
        push!(registers, make_reg(2))      # repeaters
    end
    push!(registers, make_reg(1))          # Bob

    RegisterNet(grid([N + 2]), registers)
end

"""
Generate perfect Bell pairs on all adjacent links (ideal case, instantaneous).
"""
function generate_entanglement_ideal!(net, N::Int)
    bell = (Z1⊗Z1 + Z2⊗Z2) / sqrt(2)
    for i in 1:(N + 1)
        slot_left = i == 1 ? 1 : 2  # Alice: slot 1, repeaters: slot 2 (right side)
        initialize!((net[i][slot_left], net[i + 1][1]), bell)
    end
end

"""
Generate Bell pairs with success probability p_success on each link.
Returns (total_time, gen_times), where total_time is the slowest link.
"""
function generate_entanglement_probabilistic!(net, N::Int, p_success::Float64)
    0.0 < p_success <= 1.0 || throw(ArgumentError("p_success must be in (0, 1]"))

    bell = (Z1⊗Z1 + Z2⊗Z2) / sqrt(2)
    n_links = N + 1
    gen_times = [rand(Geometric(p_success)) + 1 for _ in 1:n_links]
    T = maximum(gen_times)

    for i in 1:n_links
        slot_left = i == 1 ? 1 : 2
        initialize!((net[i][slot_left], net[i + 1][1]), bell; time=Float64(gen_times[i]))
    end

    all_slots = vcat(
        [net[1][1]],
        vcat([[net[k][1], net[k][2]] for k in 2:(N + 1)]...),
        [net[N + 2][1]]
    )
    uptotime!(all_slots, Float64(T))

    (T, gen_times)
end

end # module
