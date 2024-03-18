ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(MatchWatch.Repo, :manual)

# 1. define dynamic mocks
Mox.defmock(ExtractSummonersBehaviourMock, for: ExtractSummonersBehaviour)
Mox.defmock(MatchMonitorBehaviourMock, for: MatchMonitorBehaviour)

# 2. Override the config settings (similar to adding these to config/test.exs)
Application.put_env(:match_watch, :summoners, ExtractSummonersBehaviourMock)
Application.put_env(:match_watch, :monitor, MatchMonitorBehaviourMock)
# ... etc...
