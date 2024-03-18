defmodule MatchMonitorSwitch do
  def refresh_matches(names, region) do
    monitor_impl().refresh_matches(names, region)
  end

  defp monitor_impl() do
    Application.get_env(:match_watch, :monitor, MatchMonitor)
  end
end
