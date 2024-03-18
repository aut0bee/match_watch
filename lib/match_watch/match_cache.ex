defmodule MatchCache do
  use GenServer

  @match_table :matches
  @name_table :names
  @ttl_seconds 3600

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    :ets.new(@match_table, [:named_table, read_concurrency: true])
    :ets.new(@name_table, [:named_table, read_concurrency: true])
    {:ok, %{}}
  end

  def cache_info(table, id, info) do
    GenServer.cast(__MODULE__, {:cache_info, table, id, info})
  end

  def get_cached_info(table, id) do
    GenServer.call(__MODULE__, {:get_cached_info, table, id})
  end

  def handle_cast({:cache_info, table, key, info}, state) do
    :ets.insert(table, {key, info, System.system_time(:second)})
    {:noreply, state}
  end

  def handle_call({:get_cached_info, table, key}, _from, state) do
    case :ets.lookup(table, key) do
      [{^key, info, timestamp}] ->
        if System.system_time(:second) - timestamp <= @ttl_seconds do
          {:reply, {:ok, info}, state}
        else
          {:reply, :not_found, state}
        end

      [] ->
        {:reply, :not_found, state}
    end
  end
end
