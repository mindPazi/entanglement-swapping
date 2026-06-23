module Swapping

using QuantumSavory
using QuantumSavory.ProtocolZoo: SwapperProt, EntanglementTracker
using ConcurrentSim: @process, Process
using Graphs: vertices

export start_swappers!, start_trackers!

"""
Launch an asynchronous `SwapperProt` at every repeater node (2 … N+1).

Key point (the realistic behaviour the synchronous model was missing): each
swapper is *event-driven* (`retry_lock_time=nothing`) and fires **as soon as its
two local halves are available**, independently of the other repeaters. Internal
repeater qubits are therefore measured early — at their own local swap time
`max(g_{k-1}, g_k)` — and accumulate decoherence only until then, instead of
waiting for the slowest link. For N ≥ 2 this yields a higher fidelity than the
synchronous "all BSMs at T_max" schedule; for N = 1 the two coincide.

`nodeL = <(node)` / `nodeH = >(node)` restrict the swap to a left/right partner,
and `chooseL = argmin` / `chooseH = argmax` always pick the partners furthest
toward Alice and Bob, so successive swaps extend the entanglement outward until
Alice and Bob share a pair.

Internally `SwapperProt` performs a **local** Bell-state measurement
(`LocalEntanglementSwap`) on the two repeater qubits only and emits the two
measurement outcomes as classical `EntanglementUpdate` messages — it never
touches the remote memories directly.
"""
function start_swappers!(sim, net::RegisterNet, N::Int)
    for node in 2:(N + 1)
        prot = SwapperProt(sim, net, node;
            nodeL = <(node), nodeH = >(node),
            chooseL = argmin, chooseH = argmax,
            rounds = 1,
            retry_lock_time = nothing,
        )
        @process prot()
    end
end

"""
Launch an `EntanglementTracker` at every node.

Trackers are the classical half of the protocol: they listen on each node's
message buffer for the `EntanglementUpdate` packets produced by the swaps,
apply the corresponding Pauli-frame correction to the *local* qubit, and update
the entanglement bookkeeping. This is what makes the swap non-local in space but
local in operations: measurement happens at the repeater, the correction happens
at the remote end node only after the classical message arrives.
"""
function start_trackers!(sim, net::RegisterNet)
    for v in vertices(net)
        @process EntanglementTracker(sim, net, v)()
    end
end

end # module
