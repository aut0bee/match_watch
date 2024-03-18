defmodule ExtractSummonersSwitch do
  def get_puuid(name, region) do
    extract_impl().get_puuid(name, region)
  end

  def get_puuids(names, region) do
    extract_impl().get_puuids(names, region)
  end

  def get_match_ids(puuid, region) do
    extract_impl().get_match_ids(puuid, region)
  end

  def get_matches_ids(puuids, region) do
    extract_impl().get_matches_ids(puuids, region)
  end

  def refresh_match_ids(puuids, region) do
    extract_impl().refresh_match_ids(puuids, region)
  end

  def get_participants(match_ids, region) do
    extract_impl().get_participants(match_ids, region)
  end

  def get_names(puuids, region) do
    extract_impl().get_names(puuids, region)
  end

  defp extract_impl() do
    Application.get_env(:match_watch, :summoners, ExtractSummoners)
  end
end
