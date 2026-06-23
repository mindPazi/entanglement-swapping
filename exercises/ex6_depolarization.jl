using QuantumSavory
using QuantumSavory.ProtocolZoo
using Graphs
using ConcurrentSim
using ConcurrentSim: StopSimulation
using ResumableFunctions
using Statistics
using Random

println("=== Exercise 6: Depolarization on the simulation clock ===\n")

# Final step before the real code: memory noise. Each slot carries a
# Depolarization background with τ = -1/ln(1 - p_w), so after Δt steps a qubit
# is depolarized with probability 1 - (1-p_w)^Δt. The key idea: the decoherence
# is applied by the simulation clock, NOT by a schedule we compute by hand.

const BELL = (Z1⊗Z1 + Z2⊗Z2) / sqrt(2)

# Detector: waits until Alice and Bob share a pair, measures the fidelity at the
# (finite) delivery time, and stops the simulation. Measuring at the delivery
# time is what makes the end qubits decohere for exactly the time they waited.
@resumable function detector(sim, net, N)
    while true
        qa = query(net[1], EntanglementCounterpart, N + 2, ❓; assigned=true)
        isnothing(qa) && (@yield onchange(net[1], Tag); continue)
        qb = query(net[N + 2], EntanglementCounterpart, 1, qa.slot.idx; assigned=true)
        isnothing(qb) && (@yield onchange(net[N + 2], Tag); continue)
        t = now(sim)
        xx = real(observable((qa.slot, qb.slot), X⊗X; time=t))
        zz = real(observable((qa.slot, qb.slot), Z⊗Z; time=t))
        yy = real(observable((qa.slot, qb.slot), Y⊗Y; time=t))
        throw(StopSimulation((fidelity=(1 + xx + zz - yy) / 4, dist_time=t)))
    end
end

function run_once(N; p_success, p_w)
    mk(n) = p_w > 0 ?
        Register(fill(Qubit(), n), fill(QuantumOpticsRepr(), n),
                 fill(Depolarization(-1 / log(1 - p_w)), n)) :
        Register(fill(Qubit(), n), fill(QuantumOpticsRepr(), n))
    regs = Register[mk(1)]
    for _ in 1:N; push!(regs, mk(2)); end
    push!(regs, mk(1))
    net = RegisterNet(grid([N + 2]), regs; classical_delay=1e-9)
    sim = get_time_tracker(net)

    for i in 1:(N + 1)
        @process EntanglerProt(sim, net, i, i + 1; pairstate=BELL, success_prob=p_success,
            attempt_time=1.0, rounds=1, retry_lock_time=nothing)()
    end
    for node in 2:(N + 1)
        @process SwapperProt(sim, net, node; nodeL = <(node), nodeH = >(node),
            chooseL = argmin, chooseH = argmax, rounds = 1, retry_lock_time = nothing)()
    end
    for v in vertices(net); @process EntanglementTracker(sim, net, v)(); end
    @process detector(sim, net, N)
    run(sim, 1.0e6)
end

N = 2

# (a) Deterministic links (p_success=1): both arrive at t=1, the repeater swaps
#     immediately, nobody waits -> fidelity stays 1 even with strong noise.
r = run_once(N; p_success=1.0, p_w=0.1)
println("p_success=1.0, p_w=0.10 -> F=$(round(r.fidelity,digits=4))  T=$(r.dist_time)  ",
        "(no waiting ⇒ F≈1)  $(r.fidelity ≈ 1.0 ? "✓" : "✗")")

# (b) Probabilistic links (p_success<1): links arrive at different times, qubits
#     wait and depolarize. Average fidelity drops, and drops more for larger p_w.
println("\nMean fidelity over 200 runs (N=$N, p_success=0.5):")
prev = 1.0
for p_w in (0.0, 0.02, 0.05, 0.10)
    Random.seed!(2025)
    fs = [run_once(N; p_success=0.5, p_w=p_w).fidelity for _ in 1:200]
    F = mean(fs)
    mono = F ≤ prev + 1e-9
    println("  p_w=$(rpad(p_w,4))  ⟨F⟩=$(round(F,digits=4))  $(mono ? "✓ (≤ previous)" : "✗")")
    global prev = F
end
