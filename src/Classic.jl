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

 addr, behavior

"""
    abstract type Actor{Bhv}

`Actor` is the unit of concurrency, a single-threaded computation which reacts to incoming
asynchronous messages by sending out other messages, by spawning other actors and/or by changing 
its own behavior.

An `Actor` has a behavior and a state.
"""
abstract type Actor{Bhv} end

"""
    abstract type Addr

`Addr` uniquely identifies an actor, and can be used as the target of messages.
"""
abstract type Addr end

"""
    send(recipient::Addr, msg)

Send the message `msg` to a `recipient` actor address.
"""
function send end

"""
```
spawn(context, behavior) :: Addr
spawn(behavior) :: Addr
```

Create a new `Actor` from the given `context` and `behavior`
and schedule it. In the second form the context is delivered
implicitly to the newly created actor.

The returned address can be used to send messages to the newly created actor.
The actor itself is not accessible directly.
"""
function spawn end

"""
    become(source::Actor, target)

Change the behavior of the `source` actor to `target`.

Behavior change will be effective at the next message processing.

????
Note that when the behavior of `source` is mutable, then it can be
mutated from `onmessage` directly. This function can change the type
of the behavior, and it can also replace immutable behaviors.
????
"""
function become end

"""
    onmessage(me::Actor, msg)

Handle the incoming message `msg` received by actor `me`.

Note on async and blocking: `@async` is allowed in `onmessage`, but async code should
not operate directly on the actor state, only through messages. Blocking operations will
also work inside `onmessage`, but it is up to the implementation to provide any or no
concurrency of blocked actors, so blocking should generally avoided if possible.
"""
function onmessage end

"""
    self()::Addr

Get the address of your actor. To be called in behavior
functions.
"""
function self end

#
# Not sure about the following two!
#
# since an actor is not accessible from the outside
# shouldn't those not be internal functions rather than
# beeing part of the interface?
# 
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
