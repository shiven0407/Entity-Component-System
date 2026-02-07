# Entity-Component-System
Demo: https://www.youtube.com/watch?v=htkHW58SOMM

## Overview
This project implements a lightweight Entity Component System (ECS) in Lua,
designed for real-time, server–client game environments.

### Architecture
- **Entities** are uniquely identified objects with no embedded behaviour
- **Components** are stored as key–value data attached to entities
- **Systems** operate externally by querying entities based on required
  components or tags

Entity creation and management is handled through a singleton `EntityHandler`
module.

### Entity Structure
Each entity consists of:
- `id` — unique string identifier
- `components` — dictionary of component data
- `tags` — list of string tags
- `connections` — stored event connections for cleanup
- `destroyed` — signal fired when the entity is destroyed

Components may store arbitrary data or act as boolean flags.

### Lifecycle Management
- Entities are created using `EntityHandler.createEntity`
- Duplicate entity IDs are prevented
- Components and tags can be added or removed at runtime
- On destruction, entities:
  - fire a destruction signal
  - disconnect stored connections
  - are removed from the global entity registry

### Query System
Entities can be queried dynamically using:

- `queryComponents(...)` — returns entities containing all specified components
- `queryTags(...)` — returns entities containing all specified tags

Queries return a dictionary indexed by entity ID.

### Networking Support
Entities can be serialised into lightweight data tables using:
- `packEntity(entity)`
- `packEntities(entities)`

Packed entities include the entity ID, components, and tags, allowing the ECS
state to be synchronised between server and clients.

### Design Goals
- Clear separation of data and logic
- Modular and extensible architecture
- Efficient handling of dynamic entity sets
- Suitable for real-time multiplayer systems

---

## Credits
- **Signal implementation pattern:** https://github.com/AlexanderLindholt/SignalPlus

