"""
    module ActorInterfaces.Classic

The Classic model is the one described by Gul Agha in the book ["ACTORS: A Model of
Concurrent Computation in Distributed Systems"](https://dl.acm.org/doi/book/10.5555/7929)
"""
module Classic

using ..ActorInterfaces

export Addr, @actor, self, send, spawn, become

"""
    Addr

`Addr` uniquely identifies an actor, and can be used as the target of messages.
"""
abstract type Addr end

"""
    send(recipient::Addr, msg)

Send the message `msg` to a `recipient` actor address.
"""
function send end

"""
    spawn(behavior) :: Addr

Create a new actor from the given behavior` and schedule it.

The returned address can be used to send messages to the newly created actor.
The actor itself is not accessible directly.
"""
function spawn end

"""
    become(behavior)

Replace the behavior of the current actor with `behavior`. 

The new behavior will be effective at the next message processing.
"""
function become end

"""
    onmessage(me, msg)

Handle the incoming message `msg` received by an actor with behavior `me`.

Messages will be dispatched to methods of this function. Method definitions
must be marked with `@actor` for technical reasons.

Note on async and blocking: `@async` is allowed in `onmessage`, but async code should
not operate directly on the actor state, only through messages. Blocking operations will
also work inside `onmessage`, but it is up to the implementation to provide any or no
concurrency of blocked actors, so blocking should generally avoided if possible.

# Examples

```
mutable struct Counter
    counter::Int
end

struct Increment end

@actor function Classic.onmessage(me::Counter, msg::Increment)
    me.counter += 1
end
```
"""
function onmessage end

"""
    self() :: Addr

Get the address of the current actor.
"""
function self end

"""
    @actor

    TODO
"""
macro actor(expr)
    if expr.head != :function ||  expr.args[1].args[1] != :(Classic.onmessage)
        error("@actor only handles Classic.onmessage method definitions")
    end
    return esc(inject_ctx!(expr))
end

function needs_ctx(expr)
    return expr.head == :call && expr.args[1] in (:(Classic.onmessage), :spawn, :self, :send, :become)
end

function inject_ctx!(expr)
    if needs_ctx(expr) && expr.args[end] != :ctx
        push!(expr.args, :ctx)
    end
    for subexpr in expr.args
        subexpr isa Expr && inject_ctx!(subexpr)
    end
    return expr
end


end
