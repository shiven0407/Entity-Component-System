# Entity-Component-System

A lightweight **Entity Component System (ECS)** for real-time, server–client multiplayer games, written in **Luau** for Roblox.

▶️ **Demo:** https://www.youtube.com/watch?v=htkHW58SOMM

## Overview

An ECS separates **data** from **logic**. Game objects aren't classes with built-in behaviour. Instead:

- **Entities** are plain objects identified by a unique ID, with no behaviour of their own
- **Components** are pieces of data attached to entities (e.g. `Health`, `Velocity`)
- **Systems** contain the game logic and act on any entity that has the components or tags they need

This keeps gameplay code modular: new behaviour comes from combining components, not from deep inheritance trees. Entity creation and management is handled by a singleton `EntityHandler` module.

## Usage

```lua
local EntityHandler = require(path.to.EntityHandler)
local EntityId = require(path.to.EntityId)

-- Create an entity with initial components and tags
local enemy = EntityHandler.createEntity(EntityId.getNextId(), {
	Health = 100,
	Velocity = Vector3.zero,
}, { "Enemy" })

-- Modify it at runtime
enemy:addComponent("Burning", { duration = 5 })
enemy:removeComponent("Velocity")
enemy:addTag("Boss")

-- A system: find every entity with both components
for id, entity in EntityHandler.queryComponents("Health", "Burning") do
	entity.components.Health -= 1
end

-- Clean up
enemy:destroy()
```

## Entity structure

Each entity contains:

| Field | Description |
|---|---|
| `id` | Unique string identifier |
| `components` | Dictionary of component data (any value, or `true` as a flag) |
| `tags` | List of string tags |
| `connections` | Event connections, disconnected automatically on destroy |
| `destroyed` | Signal fired when the entity is destroyed |

### Entity methods

- `addComponent(type, data?)`: attach a component (defaults to `true` as a flag)
- `removeComponent(type)`
- `addTag(tag)` / `removeTag(tag)` / `hasTag(tag)`
- `destroy()`

## Lifecycle

- Entities are created with `EntityHandler.createEntity(id, initialComponents?, initialTags?)`
- IDs must be unique; creating an entity with an existing ID returns the existing entity instead of a duplicate
- `EntityId.getNextId()` provides sequential unique IDs
- Components and tags can be added or removed at runtime
- On `destroy()`, an entity:
  1. fires its `destroyed` signal
  2. is removed from the global entity registry
  3. disconnects all stored connections
  4. on the server, broadcasts its destruction to all clients

## Queries

Systems find entities dynamically:

- `EntityHandler.queryComponents(...)`: entities that have **all** the given components
- `EntityHandler.queryTags(...)`: entities that have **all** the given tags

Both return a dictionary indexed by entity ID.

## Networking

Entities can be serialised into lightweight data tables for server → client replication:

- `EntityHandler.packEntity(entity)`
- `EntityHandler.packEntities(entities)`

A packed entity contains its `id`, `components` and `tags`, so ECS state can be synchronised between server and clients.

## Design goals

- Clear separation of data and logic
- Modular, extensible architecture
- Efficient handling of dynamic entity sets
- Suitable for real-time multiplayer games

## Files

| File | Purpose |
|---|---|
| `EntityHandler.luau` | Entity class, registry, queries and serialisation |
| `EntityId.luau` | Sequential unique ID generator |

**Dependencies (not included):** this module was extracted from a larger project and expects `Types`, `Signal` and `NetworkPackets` modules in `ReplicatedStorage`.

## Tech

- **Language:** Luau (Lua)
- **Engine:** Roblox Studio

## Credits

- **Signal implementation pattern:** [SignalPlus](https://github.com/AlexanderLindholt/SignalPlus)
