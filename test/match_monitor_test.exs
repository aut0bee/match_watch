defmodule MatchMonitorTest do
  use ExUnit.Case, async: true

  import Mox

  setup :verify_on_exit!

  alias MatchMonitor, as: Monitor
  alias MatchMonitorSwitch, as: Switch
  alias ExtractSummoners, as: Extract
  alias MatchCache, as: Cache

  setup do
    names = [
      "Icelandic Hero",
      "Anon Summoner",
      "Shogolol",
      "RHINOOOOOOOOOOOO",
      "St3althyNinja",
      "SwagChungusIrony"
    ]

    matches = [
      [
        "BR1_2837800995",
        "BR1_2831126800",
        "BR1_2828183261",
        "BR1_2828155144",
        "BR1_2828128548"
      ]
    ]

    region = "NA1"

    MatchCache.cache_info(:names, "456", names)

    matches
    |> Enum.each(fn match ->
      MatchCache.cache_info(:matches, "456", match)
    end)

    {:ok, _pid} = Monitor.start_link({names, region})

    {:ok, %{names: names, matches: matches, region: region}}
  end

  describe "refresh_matches/2" do
    test "when given a validated list of names and region, a list of associated match lists should be returned " do
      expect(MatchMonitorBehaviourMock, :refresh_matches, fn _, _ ->
        {:ok,
         [
           ["NA123", "NA456", "NA789", "NA345", "NA6531"],
           ["NA1245", "NA44456", "NA78329", "NA3445", "NA65431"],
           ["NA2745", "NA44156", "NA229", "NA3433", "NA65891"]
         ]}
      end)

      assert {:ok, _} = Switch.refresh_matches(@names, @region)
    end
  end
end
