--- Client-side part of the Dynamic Adverts plugin, which receives the advert list from the server and downloads each
-- advert's image.
--
-- Handles the `DynamicAdverts`, `DynamicAdvertAdd` and `DynamicAdvertRemove` netstream messages and defines
-- `cwDynamicAdverts:CacheMaterial`, which fetches a `png` or `jpg` URL, caches the file under `data/` by the CRC of
-- the URL and stores the resulting material on the advert.

netstream.Hook('DynamicAdverts', function(data)
  for k, v in ipairs(data) do
    cwDynamicAdverts:CacheMaterial(v)
  end

  cwDynamicAdverts.storedList = data
end)

netstream.Hook('DynamicAdvertAdd', function(data)
  cwDynamicAdverts:CacheMaterial(data)

  cwDynamicAdverts.storedList[#cwDynamicAdverts.storedList + 1] = data
end)

netstream.Hook('DynamicAdvertRemove', function(data)
  for k, v in ipairs(cwDynamicAdverts.storedList) do
    if v.position == data then
      table.remove(cwDynamicAdverts.storedList, k)
    end
  end
end)

--- Downloads an advert's image and stores it as a material on the advert.
--
-- The image is cached under `data/catwork/schemas/<schema>/plugins/adverts/<map>/` by the CRC of its URL
-- and reused from there when present. Only `png` and `jpg`/`jpeg` URLs are supported; other extensions,
-- and adverts that already have a material, are left alone. The download is asynchronous, so
-- `data.material` is set some time after the call.
--
-- @param data [Map The advert: `url` is read, `material` (an `IMaterial`) is set once loaded]
function cwDynamicAdverts:CacheMaterial(data)
  if data.material then return end

  local exploded = string.Explode('/', data.url)
  local extension = (string.GetExtensionFromFilename(exploded[#exploded]) or ''):lower():match('^%a+')

  -- file.Write only accepts whitelisted extensions, and Material can only load png and jpg from data/.
  if extension == 'jpeg' then
    extension = 'jpg'
  elseif extension != 'png' and extension != 'jpg' then
    return
  end

  local path =
    'catwork/schemas/'..cw.core:GetSchemaFolder()..'/plugins/adverts/'..game.GetMap()..'/'..util.CRC(data.url)..
    '.'..extension

  if _file.Exists(path, 'DATA') then
    data.material = Material('../data/'..path, 'noclamp smooth')
    return
  end

  local directories = string.Explode('/', path)
  local currentPath = ''

  for k, v in pairs(directories) do
    if k < #directories then
      currentPath = currentPath..v..'/'
      file.CreateDir(currentPath)
    end
  end

  http.Fetch(data.url, function(body, length, headers, code)
    file.Write(path, body)
    data.material = Material('../data/'..path, 'noclamp smooth')
  end)
end
