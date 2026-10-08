--- Main and only file of the Stop Breaking My Freaking Wood plugin, which makes wooden props undamageable once the map
-- has loaded.
--
-- On the server its `ClockworkInitPostEntity` hook creates a `filter_activator_name` damage filter named `woodnorris`
-- and applies it to every non-player entity whose model name contains wood, table, bench, chair, box, cardboard or
-- pallet.

--- Called after Catwork has loaded all map entities; gives wooden props a damage filter.
--
-- One second later the server creates a `filter_activator_name` entity named `woodnorris` and
-- applies it to every non-player entity whose model name contains wood, table, bench, chair,
-- box, cardboard or pallet.
function PLUGIN:ClockworkInitPostEntity()
  if SERVER then
    timer.Simple(1, function()
      if !IsValid(WoodDamageFilter) then
        WoodDamageFilter = ents.Create('filter_activator_name')
        WoodDamageFilter:SetKeyValue('targetname', 'woodnorris')
        WoodDamageFilter:SetKeyValue('negated', '1')
        WoodDamageFilter:Spawn()
      end

      for k, v in pairs(ents.GetAll()) do
        local model = v:GetModel()

        if model then model = model:lower() end

        if !v:IsPlayer() and model and (model:find('wood') or model:find('table') or model:find('bench')
        or model:find('chair') or model:find('box') or model:find('cardboard') or model:find('pallet')) then
          v:Fire('setdamagefilter', 'woodnorris', 0)
        end
      end
    end)
  end
end
