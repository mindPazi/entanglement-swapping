module PlotGeneration

using Plots

const SIM_FIG_DIR = joinpath("figures", "simulation")

function simulation_plot_path(filename)
    mkpath(SIM_FIG_DIR)
    joinpath(SIM_FIG_DIR, filename)
end

"""
Plot 1: Distribution time vs p_success, with curves for different N values.
`results` is a Dict (N, p_s) => (f_mean, f_std, t_mean, t_std).
"""
function plot_time_vs_psuccess(results, p_success_range; N_values=[1, 3, 5])
    ps = collect(p_success_range)
    plt = plot(xlabel="p_success", ylabel="Distribution time (mean)",
               title="Distribution time vs p_success", legend=:topright)
    for N in N_values
        t_means = [results[(N, p)][3] for p in ps]
        t_stds  = [results[(N, p)][4] for p in ps]
        plot!(plt, ps, t_means, ribbon=t_stds, fillalpha=0.2, label="N=$N", marker=:circle, ms=3)
    end
    savefig(plt, simulation_plot_path("plot_time_vs_psuccess.png"))
    plt
end

"""
Plot 2: Fidelity vs p_success, with curves for different p_w values.
`results` is a Dict (p_w, p_s) => (f_mean, f_std, t_mean, t_std).
"""
function plot_fidelity_vs_psuccess(results, p_success_range; N=3, pw_values=[0.01, 0.05, 0.10])
    ps = collect(p_success_range)
    plt = plot(xlabel="p_success", ylabel="Fidelity (mean)",
               title="Fidelity vs p_success (N=$N)", legend=:bottomright)
    for pw in pw_values
        f_means = [results[(pw, p)][1] for p in ps]
        f_stds  = [results[(pw, p)][2] for p in ps]
        plot!(plt, ps, f_means, ribbon=f_stds, fillalpha=0.2, label="p_w=$pw", marker=:circle, ms=3)
    end
    savefig(plt, simulation_plot_path("plot_fidelity_vs_psuccess.png"))
    plt
end

"""
Extra plot: Fidelity vs N (scaling with chain length).
`results` is a Dict N => (f_mean, f_std, t_mean, t_std).
"""
function plot_fidelity_vs_N(results, N_range; p_success=0.5, p_w=0.05)
    ns = collect(N_range)
    f_means = [results[n][1] for n in ns]
    f_stds  = [results[n][2] for n in ns]
    plt = plot(ns, f_means, ribbon=f_stds, fillalpha=0.2,
               xlabel="N (repeaters)", ylabel="Fidelity (mean)",
               title="Fidelity vs N (p_s=$p_success, p_w=$p_w)",
               legend=false, marker=:circle, ms=3)
    savefig(plt, simulation_plot_path("plot_fidelity_vs_N.png"))
    plt
end

"""
Extra plot: 2D heatmap F(p_success, p_w) for a fixed N.
`results` is a Dict (p_s, p_w) => f_mean.
"""
function plot_heatmap_fidelity(results, p_success_range, pw_range; N=3)
    ps = collect(p_success_range)
    pws = collect(pw_range)
    F_matrix = [results[(p, pw)] for pw in pws, p in ps]
    plt = heatmap(ps, pws, F_matrix,
                  xlabel="p_success", ylabel="p_w", title="Fidelity heatmap (N=$N)",
                  color=:viridis, clims=(0.25, 1.0))
    savefig(plt, simulation_plot_path("plot_heatmap_fidelity.png"))
    plt
end

end # module
