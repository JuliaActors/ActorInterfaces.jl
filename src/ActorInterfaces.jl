module ActorInterfaces

export ActorException

abstract type ActorException <: Exception end

"""

    MissingActorSystem <: ActorException

No ActorInterface implementation is loaded.
"""
struct MissingActorSystem <: ActorException end

"""
    actorsystem()::Module

Return the currently active implementation of ActorInterfaces, or throw `MissingActorSystem`.
"""
function actorsystem()
    if applicable(_actorsystem)
        return _actorsystem()
    end
    throw(MissingActorSystem())
end

"""
    _actorsystem
"""
function _actorsystem end

include("Classic.jl")
include("Armstrong.jl")

include("impl/Implementation.jl")

end # module ActorInterfaces