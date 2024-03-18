defmodule ExtractSummonersTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  alias ExtractSummonersSwitch, as: Extract

  describe "get_puuid/2" do
    test "a puuid should be returned when given a valid name and region" do
      expect(
        ExtractSummonersBehaviourMock,
        :get_puuid,
        fn _, _ ->
          {:ok, "abc123"}
        end
      )

      assert {:ok, _} = Extract.get_puuid("Bill", "NA1")
    end

    test "a helpful error message should be returned when an invalid region is given as an input" do
      expect(
        ExtractSummonersBehaviourMock,
        :get_puuid,
        fn _, _ ->
          {:error, "Invalid region. Try a popular region like 'KR' (Korea)."}
        end
      )

      assert {:error, _} = Extract.get_puuid("Bill", "NA154")
    end

    test "a notification should be returned when a summoner cannot be found" do
      expect(
        ExtractSummonersBehaviourMock,
        :get_puuid,
        fn _, _ ->
          {:ok, "Summoner not found"}
        end
      )

      assert {:ok, _} = Extract.get_puuid("1aw2qde3", "NA1")
    end
  end

  describe "get_puuids/2" do
    test "when given a verified existing list of names and region, a list of their corresponding puuids should be returned" do
      expect(
        ExtractSummonersBehaviourMock,
        :get_puuids,
        fn _, _ ->
          {:ok, ["123", "456", "789"]}
        end
      )

      assert {:ok, _} = Extract.get_puuids(["WildBubble", "Kaion", "Anatech"], "NA1")
    end
  end

  describe "get_match_ids/2" do
    test "a list of the 5 most recent matches should be returned when given a valid puuid and region" do
      expect(
        ExtractSummonersBehaviourMock,
        :get_match_ids,
        fn _, _ ->
          {:ok, ["NA123", "NA456", "NA789", "NA345", "NA6531"]}
        end
      )

      assert {:ok, _} = Extract.get_match_ids("43521346424", "NA1")
    end
  end

  describe "get_matches_ids/2" do
    test "when given a verified existing list of puuids and region, a list of their corresponding matches should be returned" do
      expect(
        ExtractSummonersBehaviourMock,
        :get_matches_ids,
        fn _, _ ->
          {:ok,
           [
             ["NA123", "NA456", "NA789", "NA345", "NA6531"],
             ["NA1245", "NA44456", "NA78329", "NA3445", "NA65431"],
             ["NA2745", "NA44156", "NA229", "NA3433", "NA65891"]
           ]}
        end
      )

      assert {:ok, _} = Extract.get_matches_ids(["43521346424", "34785y3443", "537834278"], "NA1")
    end
  end

  describe "get_participants/2" do
    test "when given a verified existing list of match ids and region, a list of their associated puuids should be returned" do
      expect(
        ExtractSummonersBehaviourMock,
        :get_participants,
        fn _, _ ->
          {:ok,
           [
             "bmu5allvODG-jPUsJqu2FSA",
             "yscDmv1lK61_Rw9DaQYu3T_Q",
             "JHHJpMv1MSPuVnVtHwaAUefG"
           ]}
        end
      )

      assert {:ok, _} =
               Extract.get_participants(
                 [
                   ["NA123", "NA456", "NA789", "NA345", "NA6531"],
                   ["NA1245", "NA44456", "NA78329", "NA3445", "NA65431"],
                   ["NA2745", "NA44156", "NA229", "NA3433", "NA65891"]
                 ],
                 "NA1"
               )
    end
  end

  describe "get_names/2" do
    test "when given a verified existing list of puuids and region, a list of their corresponding names should be returned" do
      expect(
        ExtractSummonersBehaviourMock,
        :get_names,
        fn _, _ ->
          {:ok, ["WildBubble", "Kaion", "Anatech"]}
        end
      )

      assert {:ok, _} =
               Extract.get_names(
                 [
                   "bmu5allvODG-jPUsJqu2FSA",
                   "yscDmv1lK61_Rw9DaQYu3T_Q",
                   "JHHJpMv1MSPuVnVtHwaAUefG"
                 ],
                 "NA1"
               )
    end
  end
end
