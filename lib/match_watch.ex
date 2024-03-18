defmodule MatchWatch do
  alias ExtractSummoners, as: Extract
  alias MatchMonitor, as: Monitor

  def inspect_matches(name, region) do
    IO.puts("#{name} has recently played with")

    summoners =
      name
      |> Extract.get_puuid(region)
      |> Extract.get_match_ids(region)
      |> Extract.get_participants(region)
      |> Extract.get_names(region)

    summoners
  end

  def start_monitor(summoners, region) do
    Monitor.start_link({summoners, region})
  end
end
