# ActorInterfaces.jl

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
 -->
<!--
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliaactors.github.io/ActorInterfaces.jl/stable)
-->
[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://juliaactors.github.io/ActorInterfaces.jl/dev)

A formalization of the actor model family in Julia.

The goal of this project is to provide a standard and usable API for actor programming. Applications written using this API will be independent from any specific actor library, and will run under all implementations of ActorInterfaces.jl.

There is no such thing as *The* Actor Model, there are interpretations and extensions of it.
ActorInterfaces tries to handle this diversity by defining a minimalistic base called the Classic
Model, and extensions to it. 

### The `Classic` model

The Classic model is the one described by Gul Agha in the book ["ACTORS: A Model of
Concurrent Computation in Distributed Systems"](https://dl.acm.org/doi/book/10.5555/7929):


> Actors are computational agents which map each incoming communication
> to a 3-tuple consisting of:
> 1. a finite set of communications sent to other actors;
> 2. a new behavior (which will govern the response to the next communication processed); and,
> 3. a finite set of new actors created.

`ActorInterfaces.Classic` maps these to the primitives `send()`, `become()` and `spawn()`. The incoming communication will be dispatched to `onmessage()`.

Agha's stack example illustrates the API:

```julia
using ActorInterfaces.Classic

struct Pop
    customer::Addr
end

struct Push
    content
end

struct StackNode
    content
    link::Union{Addr, Nothing} # The next node
end

struct Forwarder
    target::Addr
end

@ctx function Classic.onmessage(me::Forwarder, msg)
    send(me.target, msg)
end

@ctx function Classic.onmessage(me::StackNode, msg::Push)
    p = spawn(StackNode(me.content, me.link))
    become(StackNode(msg.content, p))
end

@ctx function Classic.onmessage(me::StackNode, msg::Pop)
    if !isnothing(me.link)
        become(Forwarder(me.link))
    end
    send(msg.customer, me.content)
end
```

_Please note that this runs inefficiently on implementations that lack forward-chain optimization._

Actor libraries currently provide their own API for exchanging messages with actors from the outside of the actor system. It is not yet covered by ActorInterfaces. 

### Known implementations

- [QuickActors.jl](https://github.com/JuliaActors/QuickActors.jl), the reference implementation.

### Project Status

The Classic interface settled recently, major semantical changes are unlikely.
Extensions will be added continously. If you have an extension idea, please open an issue or
a topic on Discourse.