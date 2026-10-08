--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called when the progress bar info is needed; shows the cleanup progress bar.
-- @return [Map Progress bar `text`, `percentage` and `flash`, or `nil` when no cleanup is running]
function PLUGIN:GetProgressBarInfo()
  local action, percentage = cw.player:GetAction(cw.client, true)

  if !cw.client:IsRagdolled() then
    if action == 'cleanup' then
      return { text = L('#Farming_ProgressBar_Cleanup'), percentage = percentage, flash = percentage < 10 }
    end
  end
end
