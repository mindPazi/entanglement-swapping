using QuantumSavory
using QuantumSavory.ProtocolZoo
using Graphs
using ConcurrentSim

println("=== Exercise 5: Discrete-event chain (N=2) ===\n")

# Same machinery as ex4, but now with TWO repeaters. The point: we do not chain
# the swaps by hand. We start one SwapperProt per repeater; they run as
# independent parallel entities and the EntanglementTracker composes their
# classical messages until Alice and Bob are connected end-to-end.

N = 2
# 4-node path: Alice - R1 - R2 - Bob.
regs = [Register([Qubit()], [QuantumOpticsRepr()])]
for _ in 1:N
    push!(regs, Register([Qubit(), Qubit()], [QuantumOpticsRepr(), QuantumOpticsRepr()]))
end
push!(regs, Register([Qubit()], [QuantumOpticsRepr()]))
net = RegisterNet(grid([N + 2]), regs; classical_delay=1e-9)

sim = get_time_tracker(net)
bell = (Z1⊗Z1 + Z2⊗Z2) / sqrt(2)

# Generation on each of the N+1 links.
for i in 1:(N + 1)
    @process EntanglerProt(sim, net, i, i + 1; pairstate=bell, success_prob=1.0,
        attempt_time=1.0, rounds=1, retry_lock_time=nothing)()
end

# One swapper per repeater node (2 … N+1), each firing independently.
for node in 2:(N + 1)
    @process SwapperProt(sim, net, node; nodeL = <(node), nodeH = >(node),
        chooseL = argmin, chooseH = argmax, rounds = 1, retry_lock_time = nothing)()
end

# Trackers on every node.
for v in vertices(net)
    @process EntanglementTracker(sim, net, v)()
end

run(sim, 10.0)

qa = query(net[1], EntanglementCounterpart, N + 2, ❓)
qb = query(net[N + 2], EntanglementCounterpart, 1, ❓)
connected = !isnothing(qa) && !isnothing(qb)
println("Alice (1) ↔ Bob ($(N+2)) connected through $N repeaters: $connected  $(connected ? "✓" : "✗")")

xx = real(observable((qa.slot, qb.slot), X⊗X))
zz = real(observable((qa.slot, qb.slot), Z⊗Z))
yy = real(observable((qa.slot, qb.slot), Y⊗Y))
F = (1 + xx + zz - yy) / 4
println("F = $F  (expected: 1.0)  $(F ≈ 1.0 ? "✓" : "✗")")
