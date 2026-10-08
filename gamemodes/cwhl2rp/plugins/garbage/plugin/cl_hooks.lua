--[[
  Catwork © 2016-2017 TeslaCloud Studios
  Please find license under LICENSE.

  Original code by Alex Grist, 'impulse and Conna Wiles
  with contributions from Cloud Sixteen community.
--]]

--- Called to get the progress bar to draw; shows the harvesting bar during the `farming` action.
--
-- @return [Map The bar's `text`, `percentage` and `flash` fields, or `nil` to show nothing]
function cwGarbage:GetProgressBarInfo()
  local action, percentage = cw.player:GetAction(cw.client, true)

  if !cw.client:IsRagdolled() then
    if action == 'farming' then
      return {
        text = cw.lang:TranslateText('#Garbage_ProgressHarvesting'),
        percentage = percentage,
        flash = percentage < 10
      }
    end
  end
end
