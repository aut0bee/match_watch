defmodule ExtractSummonersBehaviour do
  @callback get_puuid(String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  @callback get_puuids([String.t()], String.t()) :: [any()]
  @callback get_match_ids(String.t(), String.t()) :: [any()]
  @callback get_matches_ids([String.t()], String.t()) :: [any()]
  @callback refresh_match_ids([String.t()], String.t()) :: [any()]
  @callback get_participants([String.t()], String.t()) :: [any()]
  @callback get_names([String.t()], String.t()) :: [any()]
end
