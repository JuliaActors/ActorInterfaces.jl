"""
    module ActorInterfaces.Classic

The Classic model is the one described by Gul Agha in the book ["ACTORS: A Model of
Concurrent Computation in Distributed Systems"](https://dl.acm.org/doi/book/10.5555/7929)

An actor is spawned from a behavior (a function or other callable object),
incoming messages will be dispatched to it. While handling the message,
the behavior can use the primitives `send`, `spawn`, `become` and `self`.

A so-called context will also be provided by the runtime to the behavior, in
the keyword argument `ctx`. It must be forwarded to the primitives, helping
the runtime to manage actors without having global state. The macro `@ctx`
does this forwarding automatically.

Note on async and blocking: `@async` is allowed in actor code, but async code should
not operate directly on the actor state, only through messages. Blocking operations will
also work inside `onmessage`, but in the Classic model it is up to the implementation to
provide any or no concurrency of blocked actors, so blocking should generally be avoided
if possible.
    
# Examples

```
using ActorInterfaces.Classic

mutable struct Counter
    counter::Int
end

struct Increment end

@ctx function (me::Counter)(msg::Increment)
    me.counter += 1
end
```
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
    send(recipient::Addr, msg...; ctx)

Send the message `msg` to a `recipient` actor address.

It is possible to send multiple arguments as a single message.

The ctx argument can be automatically injected by [`@ctx`](@ref).
"""
function send end

"""
    spawn(behavior; ctx) :: Addr
    spawn(behavior, aquintances...; ctx) :: Addr

Create a new actor with the given `behavior` and optionally arguments
`aquintances` to it.

`behavior` can be any callable object (function, closure or functor).

If `aquintances` are given, they will be stored and later provided with
every incoming message to the behavior (as the first arguments to the call,
before the message), simulating state in a functional style.

If behavior is a functor, it can store its state inside,
without externally given aquintances (called the OOP style).

The returned address can be used to send messages to the newly created actor.
The actor itself is not accessible directly.

The ctx argument can be automatically injected by [`@ctx`](@ref).
"""
function spawn end

"""
    become(behavior; ctx)
    become(behavior, aquintances...; ctx)

Replace the current actor behavior with the given
`behavior` and optionally arguments `aquintances` to it.

The new behavior will be effective at the processing of the next message.

The ctx argument can be automatically injected by [`@ctx`](@ref).

See also [`spawn`](@ref).

"""
function become end

"""
    self(; ctx) :: Addr

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
    if expr.head != :function
        error("@ctx only handles method definitions")
    end
    return esc(inject_ctx!(expr))
end

function needs_ctx(expr)
    expr.head != :call && return false
    fnexpr = expr.args[1]
    return fnexpr in (:spawn, :self, :send, :become) ||
        fnexpr isa Expr && fnexpr.head == :(::)
end

function inject_ctx!(expr)
    if needs_ctx(expr)
        if length(expr.args) >= 2 && expr.args[2] isa Expr && expr.args[2].head == :parameters
            push!(expr.args[2].args, :ctx)
        else
            param = Expr(:parameters)
            push!(param.args, :ctx)
            expr.args = [expr.args[1], param, expr.args[2:end]...]
        end
    end
    for subexpr in expr.args
        subexpr isa Expr && inject_ctx!(subexpr)
    end
    return expr
end

end # module
