--- Single-file DBugR Support plugin, which wraps every cached plugin hook in a DBugR profiler when the DBugR addon is
-- installed.
--
-- Its `ClockworkLoaded` hook detours the hooks in `plugin.GetCache()` once and reports the run time of each to DBugR
-- as `<plugin name>:<hook name>`.

PLUGIN.name = 'DBugR Support'
PLUGIN.author = 'Mr. Meow and NightAngel'
PLUGIN.description = 'Provides plugin hook detours for DBugR.'
PLUGIN.compatibility = '1.2'

if DBugR then
  local hooksDetoured = false

  --- Called when Catwork has loaded; wraps every cached plugin hook in a DBugR profiler.
  --
  -- Each hook's run time is reported to DBugR as `<plugin name>:<hook name>`. Only defined when DBugR is
  -- installed, and only detours the hooks once.
  function PLUGIN:ClockworkLoaded()
    if hooksDetoured then return end

    for hookName, hooks in pairs(plugin.GetCache()) do
      for k, v in ipairs(hooks) do
        local name = 'N/A'
        local func = v[1]

        if v[2] and v[2].GetName then
          name = v[2]:GetName()
        elseif v.id then
          name = v.id
        end

        hooks[k][1] = DBugR.Util.Func.AttachProfiler(func, function(time)
          DBugR.Profilers.Hook:AddPerformanceData(name..':'..hookName, time, func)
        end)
      end
    end

    DBugR.Print('Catwork plugin hooks detoured!')

    hooksDetoured = true
  end
end
