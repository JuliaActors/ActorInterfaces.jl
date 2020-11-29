"""
    module ActorInterfaces.Classic

The Classic model is the one described by Gul Agha in the book ["ACTORS: A Model of
Concurrent Computation in Distributed Systems"](https://dl.acm.org/doi/book/10.5555/7929)
"""
module Classic

using ..ActorInterfaces

export Addr, @ctx, self, send, spawn, become

"""
    Addr

`Addr` uniquely identifies an actor, and can be used as the target of messages.
"""
abstract type Addr end

"""
    send(recipient::Addr, msg, [ctx])

Send the message `msg` to a `recipient` actor address.

The ctx argument can be automatically injected by [`@ctx`](@ref).
"""
function send end

"""
    spawn(behavior, [ctx]) :: Addr

Create a new actor from the given behavior and schedule it.

The returned address can be used to send messages to the newly created actor.
The actor itself is not accessible directly.

The ctx argument can be automatically injected by [`@ctx`](@ref).
"""
function spawn end

"""
    become(behavior, [ctx])

Replace the behavior of the current actor with `behavior`. 

The new behavior will be effective at the processing of the next message.

The ctx argument can be automatically injected by [`@ctx`](@ref).
"""
function become end

"""
    Classic.onmessage(me, msg, ctx)
    @ctx Classic.onmessage(me, msg)

Handle the incoming message `msg` received by an actor with behavior `me`.

Messages will be dispatched to methods of this function.

Note on async and blocking: `@async` is allowed in `onmessage`, but async code should
not operate directly on the actor state, only through messages. Blocking operations will
also work inside `onmessage`, but in the Classic model it is up to the implementation to
provide any or no concurrency of blocked actors, so blocking should generally be avoided
if possible.

    
# Examples

```
mutable struct Counter
    counter::Int
end

struct Increment end

@ctx function Classic.onmessage(me::Counter, msg::Increment)
    me.counter += 1
end
```
"""
function onmessage end

"""
    self([ctx]) :: Addr

Get the address of the current actor.

The ctx argument can be automatically injected by [`@ctx`](@ref).
"""
function self end

"""
    @ctx

Inject the actor context into [`onmessage`](@ref) methods automatically.

The "actor context" allows the runtime to identify the current actor efficiently.
It is passed to `onmessage` and must be provided to every actor primitive
call. It can either be handled explicitly by the user or implicitly by
the @ctx macro.

When an `onmessage` method definition is marked with `@ctx`, calls to `send`,
`spawn`, etc. from it need not to handle the `ctx` argument, it will be injected
by the macro.
"""
macro ctx(expr)
    if expr.head != :function ||  expr.args[1].args[1] != :(Classic.onmessage)
        error("@ctx only handles Classic.onmessage method definitions")
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

end # module
