defmodule MatchMonitor do
  use GenServer, restart: :transient

  @behaviour MatchMonitorBehaviour

  alias MatchCache, as: Cache

  defdelegate get_puuids(names, region), to: ExtractSummoners
  defdelegate get_matches_ids(puuids, region), to: ExtractSummoners
  defdelegate refresh_match_ids(puuids, region), to: ExtractSummoners

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    send(self(), :monitor_matches)
    Process.send_after(self(), :timeout, 3_600_000)

    {:ok, args}
  end

  def handle_info(:monitor_matches, state) do
    IO.puts("Monitoring Summoners")
    current_time = Time.utc_now()
    IO.puts("Refreshed data at #{current_time}")

    names = elem(state, 0)
    region = elem(state, 1)

    refreshed_match_ids = refresh_matches(names, region)

    Enum.each(refreshed_match_ids, fn match_id ->
      if is_new_match?(match_id) do
        log_match(names, match_id)
      end
    end)

    Process.send_after(self(), :monitor_matches, 60_000)
    {:noreply, state}
  end

  def refresh_matches(names, region) do
    names
    |> get_puuids(region)
    |> refresh_match_ids(region)
  end

  defp is_new_match?(match_id) do
    case Cache.get_cached_info(:matches, match_id) do
      :not_found ->
        # IO.puts demonstrates comparison loop functioning, can be taken out
        IO.puts("Match #{match_id} is new")
        true

      _ ->
        # IO.puts demonstrates comparison loop functioning, can be taken out
        IO.puts("Match #{match_id} is already in cache")
        false
    end
  end

  defp log_match(name, match_id) do
    name_str = Enum.join(name, ", ")
    IO.puts("Summoners #{name_str} completed match #{match_id}\n")

    Cache.cache_info(:matches, match_id, :logged)
  end
end
