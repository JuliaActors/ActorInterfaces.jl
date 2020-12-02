# ActorInterfaces.jl

`ActorInterfaces.jl` is a formalisation of the actor model family in Julia. Its main goal is to allow writing actor programs independently from any specific implementation of the model. Programs written on top of `ActorInterfaces.jl` will potentially run on several actor systems.

There is no such thing as *The* Actor Model, there are interpretations and extensions of it.
ActorInterfaces tries to handle this diversity by defining a minimalistic base called the Classic
Model, and extensions to it. 

Current State: The Classic interface settled recently, major semantical changes are unlikely. Extensions will be added continously. If you have an extension idea, please open an issue or a topic on Discourse.

Known implementations:

- [`QuickActors.jl`](https://github.com/JuliaActors/QuickActors.jl), reference implementation.

