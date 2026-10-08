--- Client-side hooks of the Farming plugin: `GetProgressBarInfo` shows the `#Farming_ProgressBar_Harvest` progress bar
-- while the local player performs the `farming` action.

--- Called when the progress bar info is needed; shows the harvesting progress bar.
-- @return [Map Progress bar `text`, `percentage` and `flash`, or `nil` when no harvest is running]
function PLUGIN:GetProgressBarInfo()
  local action, percentage = cw.player:GetAction(cw.client, true)

  if !cw.client:IsRagdolled() then
    if action == 'farming' then
      return { text = L('#Farming_ProgressBar_Harvest'), percentage = percentage, flash = percentage < 10 }
    end
  end
end
