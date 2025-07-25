--!strict
-- src/client/Terminal/InMemoryFilesystem.luau

local InMemoryFilesystem = {}
InMemoryFilesystem.__index = InMemoryFilesystem

function InMemoryFilesystem.new()
    local self = setmetatable({
        _root = {
            type = "directory",
            children = {},
            timestamp = os.time(),
        },
    }, InMemoryFilesystem)
    return self
end

function InMemoryFilesystem:_getPathParts(path)
    local parts = {}
    for part in string.gmatch(path, "[^/]+") do
        table.insert(parts, part)
    end
    return parts
end

function InMemoryFilesystem:_resolvePath(pathParts)
    local current = self._root
    local parent = nil
    for i, part in ipairs(pathParts) do
        if current.type ~= "directory" then
            return nil, nil, "Not a directory: " .. table.concat(pathParts, "/")
        end
        parent = current
        current = current.children[part]
        if not current and i < #pathParts then
            return nil, nil, "No such file or directory: " .. table.concat(pathParts, "/")
        end
    end
    return current, parent, nil
end

function InMemoryFilesystem:touch(path)
    local pathParts = self:_getPathParts(path)
    if #pathParts == 0 then return false, "Cannot touch root directory" end

    local name = pathParts[#pathParts]
    local parentPathParts = {unpack(pathParts, 1, #pathParts - 1)}
    local parent, _, err = self:_resolvePath(parentPathParts)

    if not parent or parent.type ~= "directory" then
        return false, err or "Parent directory does not exist or is not a directory"
    end

    if parent.children[name] then
        -- File/directory exists, update timestamp
        parent.children[name].timestamp = os.time()
        return true
    else
        -- Create new file
        parent.children[name] = {
            type = "file",
            content = "",
            timestamp = os.time(),
        }
        return true
    end
end

function InMemoryFilesystem:cat(path)
    local pathParts = self:_getPathParts(path)
    local node, _, err = self:_resolvePath(pathParts)

    if not node then
        return nil, err or "No such file or directory"
    end
    if node.type == "directory" then
        return nil, "Is a directory"
    end
    return node.content, nil
end

function InMemoryFilesystem:mkdir(path)
    local pathParts = self:_getPathParts(path)
    if #pathParts == 0 then return false, "Cannot create root directory" end

    local name = pathParts[#pathParts]
    local parentPathParts = {unpack(pathParts, 1, #pathParts - 1)}
    local parent, _, err = self:_resolvePath(parentPathParts)

    if not parent or parent.type ~= "directory" then
        return false, err or "Parent directory does not exist or is not a directory"
    end

    if parent.children[name] then
        return false, "File exists"
    end

    parent.children[name] = {
        type = "directory",
        children = {},
        timestamp = os.time(),
    }
    return true
end

function InMemoryFilesystem:ls(path)
    local pathParts = self:_getPathParts(path)
    local node, _, err = self:_resolvePath(pathParts)

    if not node then
        return nil, err or "No such file or directory"
    end

    local results = {}
    if node.type == "directory" then
        for name, child in pairs(node.children) do
            table.insert(results, (child.type == "directory" and name .. "/" or name))
        end
    else
        table.insert(results, pathParts[#pathParts])
    end
    table.sort(results)
    return results, nil
end

function InMemoryFilesystem:tree(path, depth, currentDepth, prefix, results)
    currentDepth = currentDepth or 0
    prefix = prefix or ""
    results = results or {}
    depth = depth or -1 -- -1 means infinite depth

    local pathParts = self:_getPathParts(path)
    local node, _, err = self:_resolvePath(pathParts)

    if not node then
        table.insert(results, "Error: " .. (err or "No such file or directory"))
        return results, false
    end

    local nodeName = pathParts[#pathParts] or "/"
    if currentDepth == 0 then
        table.insert(results, nodeName .. (node.type == "directory" and "/" or ""))
    end

    if node.type == "directory" and (depth == -1 or currentDepth < depth) then
        local childrenNames = {}
        for name in pairs(node.children) do
            table.insert(childrenNames, name)
        end
        table.sort(childrenNames)

        for i, name in ipairs(childrenNames) do
            local child = node.children[name]
            local isLast = (i == #childrenNames)
            local newPrefix = prefix .. (isLast and "    " or "│   ")
            local entry = newPrefix .. (isLast and "└── " or "├── ") .. name .. (child.type == "directory" and "/" or "")
            table.insert(results, entry)
            if child.type == "directory" then
                self:tree(path .. "/" .. name, depth, currentDepth + 1, newPrefix, results)
            end
        end
    end
    return results, true
end

function InMemoryFilesystem:writeFile(path, content)
    local pathParts = self:_getPathParts(path)
    if #pathParts == 0 then return false, "Cannot write to root directory" end

    local name = pathParts[#pathParts]
    local parentPathParts = {unpack(pathParts, 1, #pathParts - 1)}
    local parent, _, err = self:_resolvePath(parentPathParts)

    if not parent or parent.type ~= "directory" then
        return false, err or "Parent directory does not exist or is not a directory"
    end

    parent.children[name] = {
        type = "file",
        content = content,
        timestamp = os.time(),
    }
    return true
end

return InMemoryFilesystem
