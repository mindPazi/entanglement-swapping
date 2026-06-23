module Metrics

using ..Network, ..Swapping
using QuantumSavory
using QuantumSavory.ProtocolZoo: EntanglementCounterpart
using ConcurrentSim: Simulation, @process, Process, @yield, now, run, StopSimulation
using ResumableFunctions
using Statistics

export single_run, monte_carlo, ci95

"""Safety cap on the simulation clock. The detector normally stops the run much
earlier (at end-to-end delivery); this only guards against a non-terminating run."""
const HORIZON = 1.0e6

"""
Detector process (`@resumable`, i.e. a discrete-event coroutine).

It waits on tag changes until Alice (node 1) and Bob (node N+2) hold the
reciprocal `EntanglementCounterpart` tags — that is, until the end-to-end pair is
actually delivered. It then measures the fidelity **at the finite delivery time**
`t = now(sim)` (so Alice's and Bob's qubits decohere for exactly the time they
waited) and stops the simulation, returning `(fidelity, dist_time)`.

Measuring inside the simulation is essential: decoherence in QuantumSavory is
applied lazily by `uptotime!`, so the end qubits must be evaluated at the delivery
time rather than after the run has advanced the clock.
"""
@resumable function detector(sim::Simulation, net::RegisterNet, N::Int)
    regA = net[1]
    regB = net[N + 2]
    while true
        qa = query(regA, EntanglementCounterpart, N + 2, ❓; assigned=true)
        if isnothing(qa)
            @yield onchange(regA, Tag)
            continue
        end
        qb = query(regB, EntanglementCounterpart, 1, qa.slot.idx; assigned=true)
        if isnothing(qb)
            @yield onchange(regB, Tag)
            continue
        end
        a = qa.slot
        b = qb.slot
        t = now(sim)
        xx = real(observable((a, b), X ⊗ X; time=t))
        zz = real(observable((a, b), Z ⊗ Z; time=t))
        yy = real(observable((a, b), Y ⊗ Y; time=t))
        fidelity = (1 + xx + zz - yy) / 4
        throw(StopSimulation((fidelity=fidelity, dist_time=t)))
    end
end

"""
Run a single discrete-event simulation of the repeater chain.

Builds the network, starts the entanglement-generation, swapping and tracking
protocols as parallel entities on the simulation clock, then runs the engine
until the detector reports end-to-end delivery.

Returns a NamedTuple `(fidelity, dist_time)`. The distribution time is rounded to
the nearest integer: it counts heralded-generation windows (the sub-step residue
is only the negligible classical-message latency). The ideal case
(`p_success = 1`, `p_w = 0`) gives `F = 1` at `T = 1`.
"""
function single_run(N::Int; p_success=1.0, p_w=0.0)
    net = Network.build_network(N; p_w=p_w)
    sim = get_time_tracker(net)

    Network.start_entanglers!(sim, net, N; p_success=p_success)
    Swapping.start_swappers!(sim, net, N)
    Swapping.start_trackers!(sim, net)
    @process detector(sim, net, N)

    result = run(sim, HORIZON)
    result isa NamedTuple ||
        error("end-to-end entanglement not established within horizon " *
              "(N=$N, p_success=$p_success, p_w=$p_w)")

    (fidelity=result.fidelity, dist_time=round(Int, result.dist_time))
end

"""Half-width of the 95% confidence interval of the mean (normal approximation):
1.96 · s / √M, where s is the sample standard deviation."""
ci95(s, M) = 1.959964 * s / sqrt(M)

"""
Run M independent Monte Carlo iterations.

Returns `(fidelity_mean, fidelity_ci, time_mean, time_ci)` where the second and
fourth entries are the **half-widths of the 95% confidence interval of the mean**
(not the per-run standard deviation).
"""
function monte_carlo(N::Int, M::Int; p_success=1.0, p_w=0.0)
    fidelities = Vector{Float64}(undef, M)
    times = Vector{Float64}(undef, M)

    for i in 1:M
        result = single_run(N; p_success=p_success, p_w=p_w)
        fidelities[i] = result.fidelity
        times[i] = result.dist_time
    end

    (mean(fidelities), ci95(std(fidelities), M),
     mean(times), ci95(std(times), M))
end

end # module
