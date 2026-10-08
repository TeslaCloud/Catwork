--[[
  Flux © 2016-2017 TeslaCloud Studios
  Do not share or re-distribute before
  the framework is publicly released.
--]]

--[[
  Pipeline library lets you create systems that register their stuff via folders.
  It automatically does the boring stuff like converting filenames for you,
  requiring you to write the real thing only.
  Check out sh_item and sh_admin libraries for examples.
--]]

library.New('pipeline', _G)

local stored = pipeline.stored or {}
pipeline.stored = stored

--- Registers a pipeline that loads files through a callback.
--
-- The callback is called by `pipeline.Include` for every file loaded through the pipeline.
--
-- ```
-- pipeline.Register('item', function(uniqueID, fileName, pipe)
--   ITEM = item.New(uniqueID)
--
--   util.Include(fileName)
--
--   ITEM:Register() ITEM = nil
-- end)
-- ```
--
-- @param uniqueID [String Pipeline ID]
-- @param callback [Function Called as `callback(uniqueID, fileName, pipe)`, where `uniqueID` is
-- derived from the file name and `pipe` is the pipeline table]
function pipeline.Register(uniqueID, callback)
  stored[uniqueID] = {
    callback = callback,
    uniqueID = uniqueID
  }
end

--- Returns a registered pipeline.
--
-- @param id [String Pipeline ID]
-- @return [Map The pipeline table with `callback` and `uniqueID` keys, or `nil` if none is
-- registered]
function pipeline.Find(id)
  return stored[id]
end

--- Loads a single file through a pipeline.
--
-- The file's unique ID is its file name without `.lua`, passed through `MakeID`, with a
-- `cl_`, `sh_` or `sv_` prefix removed. Does nothing when the pipeline is not found, the file
-- name is shorter than 7 characters or the resulting ID is empty.
--
-- @param pipe [String Pipeline ID, or the pipeline table itself]
-- @param fileName [String Path of the Lua file]
function pipeline.Include(pipe, fileName)
  if isstring(pipe) then
    pipe = stored[pipe]
  end

  if !pipe then return end
  if !isstring(fileName) or fileName:utf8len() < 7 then return end

  local uniqueID = (string.GetFileFromFilename(fileName) or ''):Replace('.lua', ''):MakeID()

  if uniqueID:StartsWith('cl_') or uniqueID:StartsWith('sh_') or uniqueID:StartsWith('sv_') then
    uniqueID = uniqueID:utf8sub(4, uniqueID:utf8len())
  end

  if uniqueID == '' then return end

  if isfunction(pipe.callback) then
    pipe.callback(uniqueID, fileName, pipe)
  end
end

--- Loads every file in a directory through a pipeline.
--
-- Only files directly inside the directory are loaded, in descending name order; subdirectories
-- are skipped. Does nothing when the pipeline is not registered.
--
-- @param uniqueID [String Pipeline ID]
-- @param directory [String Directory path relative to the Lua mount, with or without a trailing
-- slash]
function pipeline.IncludeDirectory(uniqueID, directory)
  local pipe = stored[uniqueID]

  if !pipe then return end

  if !directory:EndsWith('/') then
    directory = directory..'/'
  end

  local files, dirs = _file.Find(directory..'*', 'LUA', 'namedesc')

  for k, v in ipairs(files) do
    pipeline.Include(pipe, directory..v)
  end
end
