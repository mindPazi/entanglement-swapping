module PlotGeneration

using Plots, StatsBase

"""
Plot 1: Distribution time vs p_success, with curves for different N values.
"""
function plot_time_vs_psuccess(results; N_values=[1, 3, 5])
    # TODO: generate plot with 3 curves + error bars
end

"""
Plot 2: Fidelity vs p_success, with curves for different p_w values.
"""
function plot_fidelity_vs_psuccess(results; pw_values=[0.01, 0.05, 0.10])
    # TODO: generate plot with 3 curves + error bars
end

"""
Extra plot: Fidelity vs N (scaling with chain length).
"""
function plot_fidelity_vs_N(results; p_success=0.5, p_w=0.05)
    # TODO: optional
end

"""
Extra plot: 2D heatmap F(p_success, p_w) for a fixed N.
"""
function plot_heatmap_fidelity(results; N=3)
    # TODO: optional
end

end # module
