module ActorInterfaces

export ActorException

abstract type ActorException <: Exception end

include("Classic.jl")
include("Armstrong.jl")

include("impl/Implementation.jl")

end # module ActorInterfaces