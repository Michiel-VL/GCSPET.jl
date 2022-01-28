"""
    struct Crane

Struct representing a rail-mounted gantry crane as modeled in the GCSPET. Straight forward model of crane-movement at constant `speed` (`default = 1`), with a zone of `safety` (`default = 1`) wide that must be kept free on either side of the crane.

# Functionality
- id(q): identifier and position in the order of cranes along the non-crossing axis
- speed(q): movement speed of the crane
- starting_position(q): initial position of the crane along the non-crossing axis
- zone(q): minimum and maximum position of the crane along the non-crossing axis
- safety(q): minimal distance that must be kept free on either side of the crane
"""
struct Crane
    id::Int
    l0::Int
    speed::Int
    zone::UnitRange{Int64}
    safety::Int
end

id(c::Crane) = c.id
starting_position(c::Crane) = c.l0
speed(c::Crane) = c.speed
zone(c::Crane) = c.zone
safety(c::Crane) = c.safety