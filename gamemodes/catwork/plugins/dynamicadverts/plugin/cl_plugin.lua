--- Client-side part of the Dynamic Adverts plugin, which receives the advert list from the server and downloads each
-- advert's image.
--
-- Handles the `DynamicAdverts`, `DynamicAdvertAdd` and `DynamicAdvertRemove` Cable messages and defines
-- `cwDynamicAdverts:CacheMaterial`, which fetches a `png` or `jpg` URL, caches the file under `data/` by the CRC of
-- the URL and stores the resulting material on the advert.

cable.receive('DynamicAdverts', function(data)
  for k, v in ipairs(data) do
    cwDynamicAdverts:CacheMaterial(v)
  end

  cwDynamicAdverts.storedList = data
end)

cable.receive('DynamicAdvertAdd', function(data)
  cwDynamicAdverts:CacheMaterial(data)

  cwDynamicAdverts.storedList[#cwDynamicAdverts.storedList + 1] = data
end)

cable.receive('DynamicAdvertRemove', function(data)
  local storedList = cwDynamicAdverts.storedList

  for k = #storedList, 1, -1 do
    if storedList[k].position == data then
      table.remove(storedList, k)
    end
  end
end)

-- The first bytes of the image formats that `Material` can load from `data/`.
local pngSignature = '\137PNG'
local jpgSignature = '\255\216\255'

--- Downloads an advert's image and stores it as a material on the advert.
--
-- The image is cached under `data/catwork/schemas/<schema>/plugins/adverts/<map>/` by the CRC of its URL
-- and reused from there when present. Only `png` and `jpg`/`jpeg` URLs are supported; other extensions,
-- and adverts that already have a material, are left alone. The download is asynchronous, so
-- `data.material` is set some time after the call. A response that is not a `png` or `jpg` image is not
-- cached.
--
-- @param data [Map The advert: `url` is read, `material` (an `IMaterial`) is set once loaded]
function cwDynamicAdverts:CacheMaterial(data)
  if data.material or !isstring(data.url) then return end

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
    -- An error page saved as an image would be cached and shown as a missing texture from then on.
    if code != 200 or (string.sub(body, 1, 4) != pngSignature and string.sub(body, 1, 3) != jpgSignature) then
      return
    end

    file.Write(path, body)
    data.material = Material('../data/'..path, 'noclamp smooth')
  end)
end
