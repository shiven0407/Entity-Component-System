--> SERVICES <--
local RS = game:GetService('ReplicatedStorage')
local RunService = game:GetService('RunService')

--> MODULES <--
local Types = require(RS:WaitForChild("InfoModules"):WaitForChild("Types"))

local Signal = require(RS:WaitForChild("Utils"):WaitForChild("Signal"))

local PlayerDataHandler = require(RS:WaitForChild("Networking"):WaitForChild("PlayerDataHandler"))
local NetworkPackets = require(RS.Networking:WaitForChild("NetworkPackets"))

--> TYPE <--
type EntityHandlerType = {
	entities: {Types.Entity},
	
	--methods
	createEntity: (entityId: string, initialComponents: {[string]: any}?, initialTags: {string}?) -> Types.Entity,
	queryComponents: (...string) -> {[string]: Types.Entity},
	queryTags: (...string) -> {[string]: Types.Entity},
	packEntity: (entity: Types.Entity) -> Types.PackedEntity,
	packEntities: (entities: {Types.Entity}) -> {Types.PackedEntity},
}

local EntityHandler = {} :: EntityHandlerType
EntityHandler.entities = {}

-->> ENTITY CLASS <<--
local Entity = {} :: Types.Entity
Entity.__index = Entity

function Entity:addComponent(componentType: string, componentData: any?): ()
	self.components[componentType] = componentData or true
end

function Entity:removeComponent(componentType: string): ()
	self.components[componentType] = nil
end

function Entity:addTag(tag: string): ()
	if self:hasTag(tag) then return end
	table.insert(self.tags, tag)
end

function Entity:removeTag(tag: string): ()
	local index = table.find(self.tags, tag)
	if not index then return end
	table.remove(self.tags, index)
end

function Entity:hasTag(tag: string): boolean
	return table.find(self.tags, tag)
end

function Entity:destroy(): ()
	self.destroyed:Fire()
	EntityHandler.entities[self.id] = nil
	for _, connection in self.connections do
		connection:Disconnect()
	end
	
	if RunService:IsServer() then
		NetworkPackets.Entities.Destroy.sendToAll({["packed_entities"] = {EntityHandler.packEntity(self)}})
	end
end

--> ENTITY HANDLER (MODULE SINGLETON) <--
function EntityHandler.createEntity(entityId, initialComponents, initialTags): Types.Entity
	if EntityHandler.entities[entityId] then
		return EntityHandler.entities[entityId]
	end
	assert(type(entityId) == "string", "Invalid Entity ID")

	local self = setmetatable({}, Entity) :: Types.Entity
	self.id = entityId
	self.components = {}
	self.tags = {}
	self.connections = {}
	
	self.destroyed = Signal.new()

	if initialComponents then
		for componentType, componentData in initialComponents do
			self:addComponent(componentType, componentData)
		end
	end

	if initialTags then
		for _, tag in initialTags do
			self:addTag(tag)
		end
	end
	
	EntityHandler.entities[entityId] = self
	return self
end

function EntityHandler.queryComponents(...)
	local requiredComponents = {...}
	local result = {}

	for entityId, entity in EntityHandler.entities do
		local valid = true
		for _, componentType in requiredComponents do
			if entity.components[componentType] then continue end
			valid = false
			break
		end
		if valid then
			result[entityId] = entity
		end
	end

	return result
end

function EntityHandler.queryTags(...)
	local requiredTags = {...}
	local result = {}

	for entityId, entity in EntityHandler.entities do
		local valid = true
		for _, tag in requiredTags do
			if entity.tags[tag] then continue end
			valid = false
			break
		end
		if valid then
			result[entityId] = entity
		end
	end

	return result
end

function EntityHandler.packEntity(entity)
	local packed_entity = {}
	packed_entity.id = entity.id
	packed_entity.components = entity.components
	packed_entity.tags = entity.tags
	return packed_entity
end

function EntityHandler.packEntities(entities)
	local packed_entities = {}
	for _, entity in entities do
		local packed_entity = EntityHandler.packEntity(entity)
		table.insert(packed_entities, packed_entity)
	end
	return packed_entities
end

return EntityHandler
