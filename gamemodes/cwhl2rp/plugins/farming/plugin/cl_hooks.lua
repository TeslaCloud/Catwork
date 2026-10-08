--- Client-side hooks of the Farming plugin: `GetProgressBarInfo` shows the `#Farming_ProgressBar_Cleanup` progress bar
-- while the local player performs the `cleanup` action.

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
