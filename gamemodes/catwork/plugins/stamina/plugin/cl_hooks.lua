--- Client-side hook of the Stamina plugin that adds the stamina bar to the HUD.
--
-- The bar is shown while stamina is below 95, eases towards the `Stamina` net var and has its limit lowered by the
-- `Fatigue` net var.

--- Called to collect the HUD bars; adds the stamina bar, with fatigue as its limit, while stamina is below 95.
--
-- The displayed value eases towards the `Stamina` net var by one point per call.
--
-- @param bars [Map The bar list; entries are added with `bars:Add`]
function cwStamina:GetBars(bars)
  local stamina = cw.client:GetNetVar('Stamina') or 100
  local fatigue = cw.client:GetNetVar('Fatigue') or 0

  if !self.stamina then
    self.stamina = stamina
  else
    self.stamina = math.Approach(self.stamina, stamina, 1)
  end

  if self.stamina < 95 then
    bars:Add(
      '#Bars_Stamina',
      Color(100, 175, 100, 255),
      '',
      self.stamina,
      100,
      self.stamina < 10,
      nil,
      100 - fatigue,
      '#Bars_Fatigue'
    )
  end
end
