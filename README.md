# MatchWatch

Works with the Riot Games API https://developer.riotgames.com/apis

- Given a valid summoner_name and region MatchWatch will fetch all summoners this summoner has played with in the last 5 matches.
- These fetched summoners will now be monitored for new matches every minute for the next hour.
- When a summoner plays a new match, the summoner and match id is logged to the console.

## Implementation Details

- User interacts directly with match_watch.ex, which chains together functions in extract_summoners.ex and starts our match_monitor.ex.
- extract_summoners.ex interacts directly with riot_api_calls.ex and is our parsing logic for extracting the API data into useful values. Here we can take our broad API data and do whatever specific transformations we'd like for present and future use cases.
- riot_api_calls.ex is our API client that directly interacts with the urls, using our http_client() and decoding JSON with Jason. We also interact with our ETS cache (match_cache.ex) here, reading and writing to eliminate uneccessary API calls. If a request is made, we check the cache first and return that entry if it exists. If not, then we call the API. These API calls are as general and broad as possible, to give us flexibility and modularity for the future.
- match_monitor.ex is a GenServer that we start in match_watch.ex with the returned values from inspect_matches/2 as the args to start_link/1. match_monitor.ex does the logic of comparing our existing matches in match_cache.ex to a newly refreshed matches list for the given names. If a new match is found, the monitor logs it.
- match_cache.ex is out ETS GenServer that starts in our application's supervisor tree. It has two tables, :matches and :names. It services both our API and Monitor, allowing us to do on the fly data comparisons and elminating unneccessary API calls.
- Tests are using Mox, there are behaviour and switch files for this dependency.

## Setup

1. Clone this repo.

2. In preferred terminal:

```
cd match_watch
mix deps.get
mix test
export RIOT_API_KEY="YOUR-API_KEY"

```

3. in IEx, useage and sample behavior

```
iex(1)> name = "bobjenkins1"
"bobjenkins1"
iex(2)> region = "NA1"
"NA1"
iex(3)> summoners = MatchWatch.inspect_matches(name, region)
bobjenkins1 has recently played with
["SzSzSzSzS", "Anon Summoner", "Ur Uncle Sam ", "Shogolol", "RHINOOOOOOOOOOOO",
"bobjenkins1", "KeeL9", "seranxk", "Dragonminkim", "poome1", "Anon Summoner",
"WildBubble", "Anon Summoner", "Anatech", "MexicanHotGrill", "Anon Summoner",
"jjad14", "King Sunny", "Anon Summoner", "sup line", "Anon Summoner",
"Anon Summoner", "Saxonaxe", "Anon Summoner", "Etanuantonet", "St3althyNinja",
"SwagChungusIrony"]
iex(4)> MatchWatch.start_monitor(summoners, region)
Monitoring Summoners
Refreshed data at 19:17:37.611753
{:ok, #PID<0.577.0>}
Match NA1_4948494727 is new
log_match name: ["SzSzSzSzS", "Icelandic Hero", "Ur Uncle Sam ", "Shogolol", "RHINOOOOOOOOOOOO",
"bobjenkins1", "KeeL9", "Anon Summoner", "Dragonminkim", "poome1",
"Anon Summoner", "WildBubble", "Kaion", "Anatech", "Anon Summoner", "Henmi",
"jjad14", "King Sunny", "Anon Summoner", "Anon Summoner", "9nYPEE52tBXsUFUD",
"Spawwwwn", "Saxonaxe", "Anon Summoner", "Etanuantonet", "St3althyNinja",
"SwagChungusIrony"]
Summoners SzSzSzSzS, Icelandic Hero, Ur Uncle Sam , Shogolol, RHINOOOOOOOOOOOO, bobjenkins1, KeeL9, Anon Summoner, Dragonminkim, poome1, Anon Summoner, WildBubble, Kaion, Anatech, Anon Summoner, Henmi, jjad14, King Sunny, Anon Summoner, Anon Summoner, 9nYPEE52tBXsUFUD, Spawwwwn, Saxonaxe, Anon Summoner, Etanuantonet, St3althyNinja, SwagChungusIrony completed match NA1_4948494727
Monitoring Summoners
--one minute later
Refreshed data at 19:18:37.611753
Match NA1_4948494727 is already in cache
```
