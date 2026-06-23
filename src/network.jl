module Network

using QuantumSavory
using QuantumSavory.ProtocolZoo: EntanglerProt
using ConcurrentSim: Simulation, @process, Process
using Graphs

export build_network, start_entanglers!

"""Bell state |Φ⁺⟩ that the heralded entanglement generation produces on each link."""
const BELL = (Z1⊗Z1 + Z2⊗Z2) / sqrt(2)

"""Duration of a single (heralded) entanglement-generation attempt.
One attempt = one discrete time step, so the distribution time is naturally
measured in heralded-generation windows (this is why the ideal case costs T = 1,
not 0: generation always occupies at least one window)."""
const ATTEMPT_TIME = 1.0

"""Tiny classical-communication latency. It is kept negligible (so results match
the "instantaneous classical messages" assumption) but strictly positive, which
serializes otherwise simultaneous `EntanglementUpdate` messages and lets the
`EntanglementTracker` compose the swaps of a long chain unambiguously."""
const CLASSICAL_DELAY = 1e-9

"""
Build the linear quantum network used by the discrete-event simulation:
Alice + N repeaters + Bob, laid out on a path graph.

- Alice and Bob: 1 memory slot each.
- Each repeater: 2 memory slots (one toward the left neighbour, one toward the right).
- Every slot carries a `Depolarization` background with τ = -1/ln(1 - p_w), so the
  native QuantumSavory machinery applies memory decoherence on the simulation clock
  (per step Δt = 1 the depolarization probability is exactly p_w).
- Adjacent nodes are connected by classical channels (`classical_delay`), used to
  transmit the BSM outcomes that drive the remote Pauli corrections.
"""
function build_network(N::Int; p_w=0.0)
    make_reg(n_slots) = if p_w > 0
        Register(
            fill(Qubit(), n_slots),
            fill(QuantumOpticsRepr(), n_slots),
            fill(Depolarization(-1 / log(1 - p_w)), n_slots),
        )
    else
        Register(
            fill(Qubit(), n_slots),
            fill(QuantumOpticsRepr(), n_slots),
        )
    end

    registers = Register[make_reg(1)]      # Alice
    for _ in 1:N
        push!(registers, make_reg(2))      # repeaters
    end
    push!(registers, make_reg(1))          # Bob

    RegisterNet(grid([N + 2]), registers; classical_delay=CLASSICAL_DELAY)
end

"""
Launch one `EntanglerProt` per physical link (Alice–R₁, R₁–R₂, …, R_N–Bob).

Each entangler runs a single round of probabilistic heralded generation: it makes
geometric attempts with per-attempt success probability `p_success`, each lasting
`ATTEMPT_TIME`. A link therefore becomes ready after `Geometric(p_success) + 1`
time steps, sampled by the simulator itself — no schedule is computed by hand.
"""
function start_entanglers!(sim::Simulation, net::RegisterNet, N::Int; p_success)
    for i in 1:(N + 1)
        prot = EntanglerProt(sim, net, i, i + 1;
            pairstate=BELL,
            success_prob=p_success,
            attempt_time=ATTEMPT_TIME,
            rounds=1,
            retry_lock_time=nothing,   # event-driven: react to tag changes, no polling
        )
        @process prot()
    end
end

end # module
