# ActorInterfaces.jl

`ActorInterfaces.jl` is a formalisation of the actor model family in Julia. Its main goal is to allow writing actor programs independently from any specific implementation of the model. Programs written on top of `ActorInterfaces.jl` will potentially run on several actor systems.

There is no such thing as *The* Actor Model, there are interpretations and extensions of it.
ActorInterfaces tries to handle this diversity by defining a minimalistic base called the Classic
Model, and extensions to it. 

Current State: Early stage. The Classic Model is usable but not yet settled. No extension is defined yet. If you have an idea to discuss, please send a PR or create an issue.

Known implementations:

- [`QuickActors.jl`](https://github.com/JuliaActors/QuickActors.jl), reference implementation.

```@index
```

!!! info "Note"
    Please refer the source for more details.

```@autodocs
Modules = [ActorInterfaces]
```

```@autodocs
Modules = [ActorInterfaces.Classic]
```
