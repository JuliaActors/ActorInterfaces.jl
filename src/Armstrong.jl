"""
    module Armstrong

The model specified in [Making reliable distributed systems in the presence of software errors](https://erlang.org/download/armstrong_thesis_2003.pdf)
by Joe Armstrong.

This is just a stub yet.

"""
module Armstrong

export PID, pidtype

using ..Classic

abstract type PID end
function pidtype end

end # module Armstrong