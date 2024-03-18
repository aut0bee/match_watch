defmodule MatchMonitorBehaviour do
  @callback refresh_matches([String.t()], String.t()) :: [any()]
end
