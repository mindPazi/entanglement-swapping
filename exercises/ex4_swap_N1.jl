using QuantumSavory
using QuantumSavory.ProtocolZoo
using Graphs
using ConcurrentSim

println("=== Exercise 4: Discrete-event swap (N=1) ===\n")

# First contact with the discrete-event simulator. Instead of calling the swap
# circuit by hand, we let ProtocolZoo entities run as parallel processes on a
# simulation clock and orchestrate the whole protocol.

# 3-node path: Alice - R1 - Bob (R1 has 2 memory slots). A tiny classical_delay
# (>0) lets the EntanglementTracker order the classical messages unambiguously.
net = RegisterNet(grid([3]), [
    Register([Qubit()], [QuantumOpticsRepr()]),
    Register([Qubit(), Qubit()], [QuantumOpticsRepr(), QuantumOpticsRepr()]),
    Register([Qubit()], [QuantumOpticsRepr()])
]; classical_delay=1e-9)

sim = get_time_tracker(net)        # <- the ConcurrentSim simulation object
bell = (Z1⊗Z1 + Z2⊗Z2) / sqrt(2)

# 1) Heralded entanglement generation on each link (deterministic: success_prob=1).
for (a, b) in ((1, 2), (2, 3))
    @process EntanglerProt(sim, net, a, b; pairstate=bell, success_prob=1.0,
        attempt_time=1.0, rounds=1, retry_lock_time=nothing)()
end

# 2) The repeater performs a LOCAL Bell-state measurement on its two qubits and
#    announces the outcome on the classical channel (no access to remote memory).
@process SwapperProt(sim, net, 2; nodeL = <(2), nodeH = >(2),
    chooseL = argmin, chooseH = argmax, rounds = 1, retry_lock_time = nothing)()

# 3) A tracker at every node applies the Pauli correction carried by the message.
for v in vertices(net)
    @process EntanglementTracker(sim, net, v)()
end

run(sim, 10.0)                     # advance the clock; the protocol finishes by t≈1

# Alice (node 1) and Bob (node 3) should now hold the reciprocal counterpart tags.
qa = query(net[1], EntanglementCounterpart, 3, ❓)
qb = query(net[3], EntanglementCounterpart, 1, ❓)
connected = !isnothing(qa) && !isnothing(qb)
println("End-to-end entanglement established: $connected  $(connected ? "✓" : "✗")")

xx = real(observable((qa.slot, qb.slot), X⊗X))
zz = real(observable((qa.slot, qb.slot), Z⊗Z))
yy = real(observable((qa.slot, qb.slot), Y⊗Y))
F = (1 + xx + zz - yy) / 4

println("Alice ↔ Bob:  ⟨XX⟩=$(round(xx,digits=3))  ⟨ZZ⟩=$(round(zz,digits=3))  ⟨YY⟩=$(round(yy,digits=3))")
println("F = $F  (expected: 1.0)  $(F ≈ 1.0 ? "✓" : "✗")")
