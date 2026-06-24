using QuantumSavory
using QuantumSavory.ProtocolZoo
using Graphs
using ConcurrentSim
using ConcurrentSim: StopSimulation
using ResumableFunctions
using Statistics
using Random
using Distributions: Geometric

println("=== Exercise 7: Theory vs simulation (the analytical bridge) ===\n")

# Last rung of the ladder. ex4–ex6 built the discrete-event simulator by hand;
# now we PREDICT its output with closed-form models (this file is run_analysis.jl
# in miniature) and check that theory reproduces the simulator. Two questions:
#   (A) how long does end-to-end delivery take?  → order statistics of the link times
#   (B) what fidelity, and why does the ASYNC schedule beat the SYNC one for N≥2?

const BELL = (Z1⊗Z1 + Z2⊗Z2) / sqrt(2)

# ──────────────────────────────────────────────────────────────────────────
# Ground truth: the discrete-event simulator (same machinery as ex6).
# We measure the end-to-end pair at its delivery time and stop the clock.
# ──────────────────────────────────────────────────────────────────────────
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

# ──────────────────────────────────────────────────────────────────────────
# The analytical models (the same formulas as run_analysis.jl, kept verbatim so
# the bridge is 1:1). A whole run is summarised by the N+1 per-link generation
# times g_i = Geometric(p)+1 — exactly what EntanglerProt samples inside the sim.
# ──────────────────────────────────────────────────────────────────────────
sample_gen_times(N, p) = [rand(Geometric(p)) + 1 for _ in 1:(N + 1)]

# Distribution time T = max_i g_i ------------------------------------------------
harmonic(n) = sum(1.0 / k for k in 1:n)

# Exact E[max of n i.i.d. Geometric(p)+1] = Σ_{t≥0} [1 − (1 − (1−p)^t)^n].
function expected_max_geometric(n, p; max_terms=5000)
    q = 1 - p
    s = 0.0
    for t in 0:max_terms
        term = 1.0 - (1.0 - q^t)^n
        s += term
        term < 1e-12 && break
    end
    s
end

# Fidelity, per-qubit Werner model -----------------------------------------------
# ASYNC (what the simulator runs): repeater k swaps as soon as its two halves
# exist, at s_k = max(g_{k-1}, g_k); the end qubits are consumed at T = max_i g_i.
# Each qubit survives depolarization by (1−p_w)^wait and the factors multiply.
function fidelity_werner_async(gen_times, p_w)
    n = length(gen_times)              # number of links = N+1
    T = maximum(gen_times)
    exponent = 0
    for i in 1:n
        mt_left  = i == 1 ? T : max(gen_times[i-1], gen_times[i])   # node i
        mt_right = i == n ? T : max(gen_times[i], gen_times[i+1])   # node i+1
        exponent += (mt_left - gen_times[i]) + (mt_right - gen_times[i])
    end
    (1.0 + 3.0 * (1.0 - p_w)^exponent) / 4.0
end

# SYNC (pessimistic baseline): every BSM fires at T_max, so all qubits of link i
# wait the full T − g_i. Coincides with async at N=1, underestimates F for N≥2.
function fidelity_werner_sync(gen_times, p_w)
    T = maximum(gen_times)
    exponent = sum(2 * (T - g) for g in gen_times)
    (1.0 + 3.0 * (1.0 - p_w)^exponent) / 4.0
end

const M = 400   # Monte Carlo samples per point (enough for stable checks)

# ──────────────────────────────────────────────────────────────────────────
# Part A — distribution time: simulator vs order statistics
# ──────────────────────────────────────────────────────────────────────────
println("Part A — distribution time  (DES Monte Carlo vs theory)\n")

Random.seed!(2025)
for (N, p) in ((1, 0.5), (3, 0.3))
    n_links = N + 1
    t_mc = mean(run_once(N; p_success=p, p_w=0.0).dist_time for _ in 1:M)
    t_exact = expected_max_geometric(n_links, p)
    t_harm  = harmonic(n_links) / p
    err = abs(t_mc - t_exact) / t_exact
    ok = err < 0.06
    println("  N=$N p=$p:  MC=$(round(t_mc,digits=3))  E[max]=$(round(t_exact,digits=3))  ",
            "H(n)/p=$(round(t_harm,digits=3))  err=$(round(100err,digits=2))%  $(ok ? "✓" : "✗")")
end

# N=1 has a closed form: E[max of 2 geometrics] = (3−2p)/(p(2−p)).
println("\n  N=1 closed form  E[T] = (3−2p)/(p(2−p)):")
for p in (0.3, 0.5, 0.7)
    t_series = expected_max_geometric(2, p)
    t_closed = (3 - 2p) / (p * (2 - p))
    ok = isapprox(t_series, t_closed; rtol=1e-6)
    println("    p=$p:  series=$(round(t_series,digits=4))  closed=$(round(t_closed,digits=4))  ",
            "$(ok ? "✓" : "✗")")
end

# ──────────────────────────────────────────────────────────────────────────
# Part B — fidelity: async vs sync Werner, and async vs the simulator
# ──────────────────────────────────────────────────────────────────────────
println("\nPart B — fidelity  (async vs sync Werner, and async vs DES)\n")

# Check 1: at N=1 the two schedules are identical run-by-run (the waiting
# exponents are algebraically equal, both 2(T−g₁)+2(T−g₂)).
Random.seed!(2025)
n1_equal = all(let g = sample_gen_times(1, 0.5)
                   fidelity_werner_async(g, 0.05) ≈ fidelity_werner_sync(g, 0.05)
               end for _ in 1:2000)
println("  N=1: async ≡ sync run-by-run (exact)  $(n1_equal ? "✓" : "✗")")

# Checks 2–3: at N=3 async ≥ sync, async reproduces the DES, sync underestimates.
N, p, p_w = 3, 0.5, 0.05
Random.seed!(2025)
f_des = [run_once(N; p_success=p, p_w=p_w).fidelity for _ in 1:M]
Random.seed!(2025)
gens  = [sample_gen_times(N, p) for _ in 1:M]
f_asy = [fidelity_werner_async(g, p_w) for g in gens]
f_syn = [fidelity_werner_sync(g, p_w) for g in gens]
m_des, m_asy, m_syn = mean(f_des), mean(f_asy), mean(f_syn)

closer = abs(m_asy - m_des) < abs(m_syn - m_des)   # async tracks the simulator
under  = m_syn < m_des                              # sync is pessimistic
ge     = m_asy ≥ m_syn - 1e-9                        # async never below sync

println("  N=$N p=$p p_w=$p_w  (M=$M):")
println("    ⟨F⟩ DES   = $(round(m_des,digits=4))")
println("    ⟨F⟩ async = $(round(m_asy,digits=4))   |async−DES| = $(round(abs(m_asy-m_des),digits=4))")
println("    ⟨F⟩ sync  = $(round(m_syn,digits=4))   |sync −DES| = $(round(abs(m_syn-m_des),digits=4))")
println("    async closer to DES than sync   $(closer ? "✓" : "✗")")
println("    sync underestimates the DES     $(under  ? "✓" : "✗")")
println("    async ≥ sync                     $(ge     ? "✓" : "✗")")
