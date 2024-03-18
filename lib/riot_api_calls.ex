defmodule RiotApiCalls do
  alias MatchCache, as: Cache

  def get_puuid_by_name(name, region) do
    cache_key = {name, region}

    fetch_info(:names, cache_key, fn ->
      "https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-name/#{name}"
    end)
  end

  def get_matches_list(puuid, region) do
    loc = url_loc(region)

    fetch_info(:matches, puuid, fn ->
      "#{loc}/lol/match/v5/matches/by-puuid/#{puuid}/ids?start=0&count=5"
    end)
  end

  def get_fresh_matches_list(puuid, region) do
    loc = url_loc(region)

    refresh_info(fn ->
      "#{loc}/lol/match/v5/matches/by-puuid/#{puuid}/ids?start=0&count=5"
    end)
  end

  def get_match_info(match_id, region) do
    loc = url_loc(region)

    fetch_info(:matches, match_id, fn ->
      "#{loc}/lol/match/v5/matches/#{match_id}"
    end)
  end

  def get_summoner_by_puuid(puuid, region) do
    fetch_info(:names, puuid, fn ->
      "https://#{region}.api.riotgames.com/lol/summoner/v4/summoners/by-puuid/#{puuid}"
    end)
  end

  defp fetch_info(table, key, url_fun) do
    case Cache.get_cached_info(table, key) do
      {:ok, info} ->
        # IO.puts("Fetching from cache") # can be commented back in for verbose demonstration purposes
        info

      :not_found ->
        # IO.puts("Fetching from API") # can be commented back in for verbose demonstration purposese
        url = url_fun.()
        headers = build_headers()
        info = handle_response(url, headers)
        Cache.cache_info(table, key, info)
        info
    end
  end

  defp refresh_info(url_fun) do
    url = url_fun.()
    headers = build_headers()
    info = handle_response(url, headers)
    info
  end

  defp handle_response(url, headers) do
    case http_client().get(url, headers) do
      {:ok, %{body: body}} ->
        Jason.decode!(body)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp http_client, do: Application.get_env(:match_watch, :http_client)

  defp url_loc(region) do
    cond do
      region in ["NA1", "BR1", "LA1", "LA2"] ->
        "https://americas.api.riotgames.com"

      region in ["KR", "JP1"] ->
        "https://asia.api.riotgames.com"

      region in ["EUN1", "EUW1", "RU", "TR1"] ->
        "https://europe.api.riotgames.com"

      region == ["OC1", "PH2", "SG2", "TH2", "TW2", "VN2"] ->
        "https://sea.api.riotgames.com"

      true ->
        "invalid region"
    end
  end

  defp build_headers() do
    [
      {"X-Riot-Token", System.get_env("RIOT_API_KEY")},
      {"Content-Type", "application/json"}
    ]
  end
end
