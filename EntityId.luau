local EntityId = {
	currentId = 0,
}

function EntityId.getNextId(): string
	EntityId.currentId += 1
	return tostring(EntityId.currentId)
end

return EntityId
