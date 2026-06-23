# Noiseless sanity check: swapping N repeaters over perfect links must give F = 1,
# and the heralded generation must cost exactly one time step (T = 1).

include("src/network.jl")
include("src/swapping.jl")
include("src/metrics.jl")

using .Network, .Swapping, .Metrics

function main()
    println("Noiseless swap, expecting F=1 and T=1:")
    for N in [1, 2, 3, 5]
        result = Metrics.single_run(N; p_success=1.0, p_w=0.0)
        ok = result.fidelity ≈ 1.0 && result.dist_time == 1
        println("  N=$N  F=$(result.fidelity)  T=$(result.dist_time)  $(ok ? "OK" : "FAIL")")
    end
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    main()
end
