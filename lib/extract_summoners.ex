defmodule ExtractSummoners do
  alias RiotApiCalls, as: Riot

  @behaviour ExtractSummonersBehaviour

  def get_puuid(name, region) do
    cond do
      is_invalid_region?(region) ->
        "Invalid region. Try a popular region like 'KR' (Korea), 'NA1' (North America) or 'TW2' (Taiwan)"

      true ->
        summoner = Riot.get_puuid_by_name(name, region)
        puuid = Map.get(summoner, "puuid", nil)

        case puuid do
          nil ->
            "Summoner not found"

          _ ->
            puuid
        end
    end
  end

  defp is_invalid_region?(region) do
    region not in [
      "NA1",
      "BR1",
      "LA1",
      "LA2",
      "KR",
      "JP1",
      "EUN1",
      "EUW1",
      "RU",
      "TR1",
      "OC1",
      "PH2",
      "SG2",
      "TH2",
      "TW2",
      "VN2"
    ]
  end

  def get_puuids(names, region) do
    names
    |> Enum.map(&Task.async(fn -> Riot.get_puuid_by_name(&1, region) end))
    |> Enum.map(&Task.await(&1))
    |> Enum.map(& &1["puuid"])
    |> Enum.reject(&is_nil(&1))
    |> Enum.uniq()
  end

  def get_match_ids(puuid, region) do
    Riot.get_matches_list(puuid, region)
  end

  def get_matches_ids(puuids, region) do
    puuids
    |> Enum.map(&Task.async(fn -> Riot.get_matches_list(&1, region) end))
    |> Enum.map(&Task.await(&1))
    |> Enum.reject(&Enum.empty?/1)
    |> List.flatten()
  end

  def refresh_match_ids(puuids, region) do
    puuids
    |> Enum.map(&Task.async(fn -> Riot.get_fresh_matches_list(&1, region) end))
    |> Enum.map(&Task.await(&1))
    |> Enum.reject(&Enum.empty?/1)
    |> List.flatten()
  end

  def get_participants(match_ids, region) do
    match_ids
    |> Enum.map(&Task.async(fn -> Riot.get_match_info(&1, region) end))
    |> Enum.map(&Task.await(&1))
    |> Enum.map(&get_in(&1, ["metadata", "participants"]))
    |> List.flatten()
    |> Enum.uniq()
  end

  def get_names(puuids, region) do
    puuids
    |> Enum.map(&Task.async(fn -> Riot.get_summoner_by_puuid(&1, region) end))
    |> Enum.map(&Task.await(&1))
    |> Enum.map(& &1["name"])
    |> Enum.map(fn name ->
      if is_nil(name) || name == "", do: "Anon Summoner", else: name
    end)
  end
end
