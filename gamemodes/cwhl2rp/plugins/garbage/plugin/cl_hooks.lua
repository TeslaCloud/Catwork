--- Client-side hooks of the Garbage plugin: `GetProgressBarInfo` shows the `#Garbage_ProgressCleanup` progress bar
-- while the local player performs the `cleanup` action.

--- Called to get the progress bar to draw; shows the cleanup bar during the `cleanup` action.
--
-- @return [Map The bar's `text`, `percentage` and `flash` fields, or `nil` to show nothing]
function cwGarbage:GetProgressBarInfo()
  local action, percentage = cw.player:GetAction(cw.client, true)

  if !cw.client:IsRagdolled() then
    if action == 'cleanup' then
      return {
        text = cw.lang:TranslateText('#Garbage_ProgressCleanup'),
        percentage = percentage,
        flash = percentage < 10
      }
    end
  end
end
