# Compares the discrete-event Monte Carlo against analytical predictions:
#   * distribution time : exact order-statistics formula and harmonic approximation
#   * fidelity          : per-qubit Werner model for the ASYNCHRONOUS swap schedule
#                         (the one the simulator actually runs), contrasted with the
#                         older SYNCHRONOUS schedule that underestimates F for N >= 2.

include("src/network.jl")
include("src/swapping.jl")
include("src/metrics.jl")

using .Network, .Swapping, .Metrics
using Plots, Statistics, Printf, Random
using Plots.PlotMeasures: mm
using Distributions: Geometric

const M_RUNS = 1000
const SEED = 2025  # fixed seed so figures and quoted numbers stay in sync
const ANALYSIS_FIG_DIR = joinpath("figures", "analysis")

function analysis_plot_path(filename)
    mkpath(ANALYSIS_FIG_DIR)
    joinpath(ANALYSIS_FIG_DIR, filename)
end

# --- Distribution time (unchanged: T = max link-generation time is correct in both schedules) ---

harmonic(n) = sum(1.0/k for k in 1:n)

"""
Exact expected value of the maximum of n i.i.d. Geometric(p) generation times
(each counted from 1, matching `Geometric(p)+1`):
E[max] = Σ_{t=0}^{∞} [1 - (1 - (1-p)^t)^n].
"""
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

# --- Per-qubit Werner model ------------------------------------------------------

"""Sample the per-link generation times of one run: g_i = Geometric(p)+1 for the
N+1 links, exactly as `EntanglerProt` does inside the simulator."""
sample_gen_times(N, p) = [rand(Geometric(p)) + 1 for _ in 1:(N + 1)]

"""
Fidelity for the ASYNCHRONOUS schedule the simulator runs.

Each repeater swaps as soon as its two local halves exist, i.e. at
s_k = max(g_{k-1}, g_k); the two end qubits (Alice, Bob) are only consumed at the
end-to-end delivery time T = max_i g_i. The waiting time is therefore computed
**per qubit**. For link i the two qubits wait until their holding node measures
them, and survive depolarization by (1-p_w)^{wait}; the Werner parameters
multiply across swaps:
    F = (1 + 3 ∏_i (1-p_w)^{wait_left_i + wait_right_i}) / 4.
"""
function fidelity_werner_async(gen_times, p_w)
    n = length(gen_times)              # number of links = N+1
    T = maximum(gen_times)
    exponent = 0
    for i in 1:n
        mt_left  = i == 1 ? T : max(gen_times[i-1], gen_times[i])   # node i (Alice if i==1)
        mt_right = i == n ? T : max(gen_times[i], gen_times[i+1])   # node i+1 (Bob if i==n)
        exponent += (mt_left - gen_times[i]) + (mt_right - gen_times[i])
    end
    (1.0 + 3.0 * (1.0 - p_w)^exponent) / 4.0
end

"""
Fidelity for the SYNCHRONOUS schedule (every BSM fired at T_max).

Here *all* qubits of link i wait the full T - g_i, so the exponent is
Σ_i 2(T - g_i). This is the model used in the original report; it coincides with
the asynchronous one at N = 1 and underestimates the fidelity for N ≥ 2.
"""
function fidelity_werner_sync(gen_times, p_w)
    T = maximum(gen_times)
    exponent = sum(2 * (T - g) for g in gen_times)
    (1.0 + 3.0 * (1.0 - p_w)^exponent) / 4.0
end

"""Monte Carlo comparison at one (N, p_success, p_w) point. Returns means and 95% CI
half-widths for the simulator and for the two Werner schedules."""
function compare_fidelity(N, M; p_success, p_w)
    f_des = Vector{Float64}(undef, M)
    f_asy = Vector{Float64}(undef, M)
    f_syn = Vector{Float64}(undef, M)
    for i in 1:M
        f_des[i] = Metrics.single_run(N; p_success=p_success, p_w=p_w).fidelity
        g = sample_gen_times(N, p_success)
        f_asy[i] = fidelity_werner_async(g, p_w)
        f_syn[i] = fidelity_werner_sync(g, p_w)
    end
    (mean(f_des), Metrics.ci95(std(f_des), M),
     mean(f_asy), Metrics.ci95(std(f_asy), M),
     mean(f_syn), Metrics.ci95(std(f_syn), M))
end

# --- Distribution time: MC vs exact vs harmonic ---------------------------------

function analysis_distribution_time()
    println("Distribution time: Monte Carlo vs theory")

    p_values = 0.1:0.1:0.9
    N_values = [1, 3, 5]

    println(@sprintf("\n%-4s  %-6s  %10s  %10s  %10s  %8s  %8s",
        "N", "p_s", "MC mean", "Exact", "Harmonic", "Err_ex%", "Err_ha%"))
    println("-" ^68)

    results = Dict()
    for N in N_values
        n_links = N + 1
        for ps in p_values
            _, _, t_mc, _ = Metrics.monte_carlo(N, M_RUNS; p_success=ps, p_w=0.0)
            t_exact = expected_max_geometric(n_links, ps)
            t_harmonic = harmonic(n_links) / ps
            err_ex = abs(t_mc - t_exact) / t_exact * 100
            err_ha = abs(t_mc - t_harmonic) / t_harmonic * 100
            println(@sprintf("N=%d   p=%.1f  %10.3f  %10.3f  %10.3f  %7.2f%%  %7.2f%%",
                N, ps, t_mc, t_exact, t_harmonic, err_ex, err_ha))
            results[(N, ps)] = (t_mc, t_exact, t_harmonic)
        end
    end

    plt = plot(xlabel="p_success", ylabel="Distribution time",
               title="Distribution time: MC vs Theory", legend=:topright)
    colors = [:blue, :red, :green]
    for (idx, N) in enumerate(N_values)
        ps_vec = collect(p_values)
        mc_vals = [results[(N, p)][1] for p in ps_vec]
        exact_vals = [results[(N, p)][2] for p in ps_vec]
        harm_vals = [results[(N, p)][3] for p in ps_vec]
        plot!(plt, ps_vec, mc_vals, marker=:circle, ms=4, label="MC N=$N", color=colors[idx])
        plot!(plt, ps_vec, exact_vals, ls=:solid, lw=2, label="Exact N=$N", color=colors[idx])
        plot!(plt, ps_vec, harm_vals, ls=:dash, lw=1, label="H(N+1)/p N=$N", color=colors[idx], alpha=0.6)
    end
    savefig(plt, analysis_plot_path("analysis_time_comparison.png"))
    println("  saved figures/analysis/analysis_time_comparison.png\n")
end

# Distribution time scaling with N at fixed p_success: E[T] grows like H(N+1)/p_s.
function analysis_time_vs_N()
    println("Distribution time vs N (p_success fixed)")

    ps_fixed = 0.5
    N_range = 1:7

    println(@sprintf("\n%-4s  %10s  %10s  %10s", "N", "MC mean", "Exact", "Harmonic"))
    println("-" ^40)

    mc_vals = Float64[]
    exact_vals = Float64[]
    harm_vals = Float64[]
    for N in N_range
        n_links = N + 1
        _, _, t_mc, _ = Metrics.monte_carlo(N, M_RUNS; p_success=ps_fixed, p_w=0.0)
        t_exact = expected_max_geometric(n_links, ps_fixed)
        t_harmonic = harmonic(n_links) / ps_fixed
        println(@sprintf("N=%d   %10.3f  %10.3f  %10.3f", N, t_mc, t_exact, t_harmonic))
        push!(mc_vals, t_mc); push!(exact_vals, t_exact); push!(harm_vals, t_harmonic)
    end

    ns = collect(N_range)
    plt = plot(ns, mc_vals, marker=:circle, ms=5, label="Monte Carlo",
               xlabel="N (repeaters)", ylabel="Distribution time",
               title="Time scaling with N (p_s=$ps_fixed)", legend=:topleft)
    plot!(plt, ns, exact_vals, ls=:solid, lw=2, label="Exact E[max]")
    plot!(plt, ns, harm_vals, ls=:dash, lw=2, label="H(N+1)/p_s")
    savefig(plt, analysis_plot_path("analysis_time_vs_N.png"))
    println("  saved figures/analysis/analysis_time_vs_N.png\n")
end

# --- Fidelity: MC vs async Werner (correct) vs sync Werner (pessimistic) ---------

function analysis_fidelity()
    println("Fidelity: Monte Carlo vs async Werner vs synchronous Werner")

    p_values = 0.1:0.1:1.0
    pw_values = [0.01, 0.05, 0.10]
    N_fixed = 3

    println(@sprintf("\n%-6s  %-6s  %8s  %8s  %8s  %9s  %9s",
        "p_w", "p_s", "MC", "Async", "Sync", "|MC-As|", "MC-Sync"))
    println("-" ^66)

    results = Dict()
    for pw in pw_values
        for ps in p_values
            fd, _, fa, _, fs, _ = compare_fidelity(N_fixed, M_RUNS; p_success=ps, p_w=pw)
            println(@sprintf("pw=%.2f  p=%.1f  %8.4f  %8.4f  %8.4f  %9.4f  %9.4f",
                pw, ps, fd, fa, fs, abs(fd - fa), fd - fs))
            results[(pw, ps)] = (fd, fa, fs)
        end
    end

    ps_vec = collect(p_values)
    colors = [:blue, :orange, :green]

    # Left panel: MC vs async Werner (should coincide)
    plt1 = plot(xlabel="p_success", ylabel="Fidelity",
                title="MC vs async Werner (N=$N_fixed)", legend=:bottomright)
    for (idx, pw) in enumerate(pw_values)
        mc_vals = [results[(pw, p)][1] for p in ps_vec]
        as_vals = [results[(pw, p)][2] for p in ps_vec]
        plot!(plt1, ps_vec, mc_vals, marker=:circle, ms=4, label="MC p_w=$pw", color=colors[idx])
        plot!(plt1, ps_vec, as_vals, ls=:dash, lw=2, label="Async p_w=$pw", color=colors[idx])
    end

    # Right panel: MC vs synchronous Werner (underestimates for N>=2)
    plt2 = plot(xlabel="p_success", ylabel="Fidelity",
                title="MC vs synchronous Werner (N=$N_fixed)", legend=:bottomright)
    for (idx, pw) in enumerate(pw_values)
        mc_vals = [results[(pw, p)][1] for p in ps_vec]
        sy_vals = [results[(pw, p)][3] for p in ps_vec]
        plot!(plt2, ps_vec, mc_vals, marker=:circle, ms=4, label="MC p_w=$pw", color=colors[idx])
        plot!(plt2, ps_vec, sy_vals, ls=:dot, lw=2, label="Sync p_w=$pw", color=colors[idx])
    end

    plt = plot(plt1, plt2, layout=(1, 2), size=(1200, 450), left_margin=5mm)
    savefig(plt, analysis_plot_path("analysis_fidelity_comparison.png"))
    println("  saved figures/analysis/analysis_fidelity_comparison.png\n")
end

# Fidelity scaling with N: async Werner tracks the MC, synchronous Werner falls away.
function analysis_scaling_N()
    println("Fidelity scaling with N")

    N_range = 1:7
    ps_fixed = 0.5
    pw_fixed = 0.05

    println(@sprintf("\n%-4s  %8s  %8s  %8s  %9s  %9s",
        "N", "MC F", "Async", "Sync", "|MC-As|", "MC-Sync"))
    println("-" ^56)

    mc_vals = Float64[]; mc_cis = Float64[]
    as_vals = Float64[]; sy_vals = Float64[]
    for N in N_range
        fd, fd_ci, fa, _, fs, _ = compare_fidelity(N, M_RUNS; p_success=ps_fixed, p_w=pw_fixed)
        println(@sprintf("N=%d   %8.4f  %8.4f  %8.4f  %9.4f  %9.4f",
            N, fd, fa, fs, abs(fd - fa), fd - fs))
        push!(mc_vals, fd); push!(mc_cis, fd_ci); push!(as_vals, fa); push!(sy_vals, fs)
    end

    ns = collect(N_range)
    plt = plot(ns, mc_vals, ribbon=mc_cis, fillalpha=0.2, marker=:circle, ms=5,
               label="Monte Carlo (95% CI)",
               xlabel="N (repeaters)", ylabel="Fidelity",
               title="Fidelity scaling (p_s=$ps_fixed, p_w=$pw_fixed)", legend=:topright)
    plot!(plt, ns, as_vals, ls=:dash, lw=2, marker=:square, ms=3, label="Async Werner")
    plot!(plt, ns, sy_vals, ls=:dot, lw=2, marker=:diamond, ms=3, label="Synchronous Werner")
    savefig(plt, analysis_plot_path("analysis_scaling_N.png"))
    println("  saved figures/analysis/analysis_scaling_N.png\n")
end

# N=1 closed form check for the distribution time.
function analysis_N1_closed_form()
    println("N=1 closed form check")
    println("\nFor N=1, T = max(Geo(p)+1, Geo(p)+1).")
    println("E[T] = (3 - 2p) / (p(2-p))  [exact for max of 2 geometrics]\n")

    ps_values = 0.1:0.1:0.9

    println(@sprintf("%-6s  %10s  %10s  %8s", "p_s", "MC T", "Closed T", "Err%"))
    println("-" ^40)

    for ps in ps_values
        _, _, tm, _ = Metrics.monte_carlo(1, M_RUNS; p_success=ps, p_w=0.0)
        t_closed = (3 - 2 * ps) / (ps * (2 - ps))
        err = abs(tm - t_closed) / t_closed * 100
        println(@sprintf("p=%.1f   %10.3f  %10.3f  %7.2f%%", ps, tm, t_closed, err))
    end
    println()
end

# Fidelity distribution shape and fidelity-time correlation.
function analysis_emergent()
    println("Fidelity distribution and fidelity-time correlation")

    N = 3
    ps = 0.3
    pw = 0.05
    M = 2000

    fidelities = Float64[]
    times = Float64[]
    for _ in 1:M
        result = Metrics.single_run(N; p_success=ps, p_w=pw)
        push!(fidelities, result.fidelity)
        push!(times, result.dist_time)
    end

    println(@sprintf("\nN=%d, p_s=%.1f, p_w=%.2f, M=%d runs:", N, ps, pw, M))
    println(@sprintf("  Fidelity:  mean=%.4f  std=%.4f  min=%.4f  max=%.4f",
        mean(fidelities), std(fidelities), minimum(fidelities), maximum(fidelities)))
    println(@sprintf("  Time:      mean=%.2f  std=%.2f  min=%d  max=%d",
        mean(times), std(times), minimum(times), maximum(times)))
    println(@sprintf("  Correlation(F, T) = %.4f  (expected: negative)", cor(fidelities, times)))

    p1 = histogram(fidelities, bins=30, xlabel="Fidelity", ylabel="Count",
                    title="Fidelity distribution (N=$N, p_s=$ps, p_w=$pw)",
                    legend=false, fillalpha=0.7)
    p2 = scatter(times, fidelities, xlabel="Distribution time", ylabel="Fidelity",
                 title="Fidelity vs Time (N=$N)", legend=false, ms=2, alpha=0.3)
    p3 = histogram(times, bins=30, xlabel="Distribution time", ylabel="Count",
                   title="Time distribution (N=$N, p_s=$ps)",
                   legend=false, fillalpha=0.7)

    plt = plot(p1, p2, p3, layout=(1, 3), size=(1500, 400), left_margin=10mm, bottom_margin=5mm)
    savefig(plt, analysis_plot_path("analysis_emergent.png"))
    println("  saved figures/analysis/analysis_emergent.png\n")
end

function main()
    Random.seed!(SEED)
    println("Numerical vs theoretical analysis ($M_RUNS runs per point)\n")

    analysis_distribution_time()
    analysis_time_vs_N()
    analysis_fidelity()
    analysis_scaling_N()
    analysis_N1_closed_form()
    analysis_emergent()

    println("Figures written to figures/analysis/")
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    main()
end
