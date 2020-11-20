"""
    module ActorInterfaces.Classic

The Classic model is the one described by Gul Agha in the book ["ACTORS: A Model of
Concurrent Computation in Distributed Systems"](https://dl.acm.org/doi/book/10.5555/7929)
"""
module Classic

using ..ActorInterfaces

export Actor, Addr,

 send, spawn, become,

 onmessage,

 addr, behavior,

 SendStyle, CopySendable, Sendable, Racing

"""
    abstract type Actor{TBehavior}

`Actor` is the unit of concurrency, a single-threaded computation which reacts to incoming
asynchronous messages by sending out other messages, by spawning other actors and/or by changing 
its own behavior.

`Actor` has a behavior, which can be of any type. The type of the behavior is used for message
dispatch, and it can also hold the state of the actor. It is allowed for the behavior to
be a mutable type, and if so, then it can be modified from [`onmessage`](@ref).
"""
abstract type Actor{TBehavior} end

"""
    abstract type Addr

`Addr` uniquely identifies an actor, and can be used as the target of messages.
"""
abstract type Addr end

abstract type SendStyle end
struct Sendable <: SendStyle end
struct CopySendable <: SendStyle end
struct Racing <: SendStyle end
struct NonSendable <: SendStyle end

"""
    Trait SendStyle: Sendable, CopySendable, Racing, NonSendable

Trait for marking types that can be sent to actors.
    
Sending mutable data between actors breaks the model and it may lead to data races,
so - as a general rule - it should be avoided.

By default, every type is `NonSendable`. You have to mark yor message types as `Sendable`,
`CopySendable` or `Racing` before sending them. e.g.

```
abstract type MyMessage end
Classic.SendStyle(::Type{<:MyMessage}) = Racing()

struct SafeMsg end
Classic.SendStyle(::Type{SafeMsg}) = Sendable()
```

`CopySendable` types will be deep copied before sending.

When using `Sendable`, you have to be sure that it is really safe to share the data. Note that
immutable structs may also contain mutable data deeper down.

With `Racing` you warn the user to trait the message as unsafe shared state. It will
be delivered to a special `onmessage` method with an extra ::Racing argument for the
receiver to be warned.
"""
SendStyle(::Type{<:Any}) = NonSendable()

"""
    send(sender::Actor, target::Addr, msg)

Send the message `msg` from `sender` to the actor with `target` address.

The type of `msg` must be marked as `Sendable`, `CopySendable` or `Racing`. See [`SendStyle`](@ref)
"""
function send end

function send(sender::Actor, target::Addr, msg)
    send(sender, target, msg, SendStyle(typeof(msg)))
end
struct SendingNonSendable <: ActorException
    type::Type
end
send(sender::Actor, target::Addr, msg, ::NonSendable) = throw(SendingNonSendable(typeof(msg)))
send(sender::Actor, target::Addr, msg, ::CopySendable) = send(sender, target, deepcopy(msg), Sendable())
# Implementations must at least handle Sendable and Racing

"""
    function spawn(spawner::Actor, behavior)::Addr

Create a new `Actor` from the given `behavior` and and schedule it.

The returned address can be used to send messages to the newly created actor.
The actor itself is not accessible directly.
"""
function spawn end

"""
    function become(source::Actor, target)

Change the behavior of the `source` actor to `target`.

Behavior change will be effective at the next message processing.
Note that when the behavior of `source` is mutable, then it can be
mutated from `onmessage` directly. This function can change the type
of the behavior, and it can also replace immutable behaviors.
"""
function become end

"""
    function onmessage(me::Actor, msg)
    function onmessage(me::Actor, msg, ::Racing)

Handle the incoming message `msg` received by actor `me`.

The second form will be called for `Racing` messages to
warn the programmer that the message breaks the actor model and accessing it
without locking may introduce data races.

Note on async and blocking: `@async` is allowed in `onmessage`, but async code should
not operate directly on the actor state, only through messages. Blocking operations will
also work inside `onmessage`, but it is up to the implementation to provide any or no
concurrency of blocked actors, so blocking should generally avoided if possible.

# Examples

```
mutable struct Counter
    counter::Int
end

struct Increment <: MyMessage end

function Classic.onmessage(me::Actor{Counter}, ::Increment)
    behavior(me).counter += 1
end
```
"""
function onmessage end

"""
    function behavior(actor::Actor)

Return the behavior of the actor.

The behavior can be of any type, it specifies how the actor reacts to events, and it
holds the state of the actor.
"""
function behavior end

"""
    function addr(actor::Actor)

Return the address of an actor.
"""
function addr end

end # module Classic