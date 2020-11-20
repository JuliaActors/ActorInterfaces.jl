module Tick

export tick!

using ..Implementation

function tick!(sdl::Scheduler)
    return false # No work left
end

end