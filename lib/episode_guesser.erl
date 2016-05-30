-module(episode_guesser).          % module attribute
-export([guess/2]).   % module attribute

% return a char array to elixir, need to_string to make it a string
guess(Filename, AnilistId) ->
  Finders = [
    fun()-> ova_oad_special_and_preview(Filename) end,
    fun()-> ep_prefix(Filename) end,
    fun()-> first_sensible_number(Filename, AnilistId) end ],
  lists:foldl(fun(Curr, Prev)->
    case Prev of
        notfound -> Curr();
        A -> A
    end
  end, notfound, Finders).

first_sensible_number(Filename, AnilistId) ->
  case re:run(Filename, "[0-9]+(?:\\.[0-9]+)?", [global]) of
    nomatch -> notfound;
    {match, Captured} ->
      io:format("~p", [Captured]),
      Ranges = lists:map(fun(X)-> hd(X) end, Captured),
      Substrings = substrings(Ranges, binary:bin_to_list(Filename)),
      Filtered = filter_nonsense(Substrings),
      % TODO: Fetch anilist and filter number > total ep count
      case Filtered of
        []-> notfound;
        [First | _] -> {found, First}
      end
  end.

ova_oad_special_and_preview(Filename) ->
  case re:run(Filename, "(?:OVA|OAD|Special|Preview|Prev)", [global]) of
    nomatch -> notfound;
    {match, Captured} ->
      Ranges = lists:map(fun(X)-> hd(X) end, Captured),
      Substrings = substrings(Ranges, binary:bin_to_list(Filename)),
      case Substrings of
        []-> notfound;
        [First | _] -> {found, First}
      end
  end.

ep_prefix(Filename) ->
  {ok, MP} = re:compile("(?:EP|第) *([0-9]+(?:\\.[0-9]+)?)", [unicode]),
  case re:run(Filename, MP) of
    nomatch -> notfound;
    {match, [_ , {Pos, Len}]} ->
      {found, string:substr(binary:bin_to_list(Filename), Pos+1, Len)}
  end.

is_make_sense(String)->
  Num = case string:to_float(String) of
    {error, _} ->
      case string:to_integer(String) of
        {error, _} -> false;
        {N, _} -> N
      end;
    {N, _} -> N
  end,
  if
    % > 1000 is not an episode number
    Num > 1000 -> false;
    % These numbers are usually resolution
    Num == 960 -> false;
    Num == 720 -> false;
    Num == 576 -> false;
    Num == 480 -> false;
    true -> true
  end.

filter_nonsense(Strings)->
  % TODO: Fetch anilist and filter number > total ep count
  lists:filter(fun(Str)-> is_make_sense(Str) end, Strings).

substrings(Ranges, SourceString) ->
  lists:map(fun({Pos, Len}) ->
    % substr starts at 1, not 0, need to shift 1
    string:substr(SourceString, Pos+1, Len)
  end,
  Ranges).
