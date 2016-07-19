-module(episode_guesser).          % module attribute
-export([guess/2]).   % module attribute

% return a char array to elixir, need to_string to make it a string
% return notfound, or {found, String}
guess(Filename, AnilistId) ->
  FilteredFilename = remove_rubbish(Filename),
  Finders = [
    fun()-> ova_oad_special_and_preview(FilteredFilename) end,
    fun()-> sp_episode(FilteredFilename) end,
    fun()-> number_in_bracket(FilteredFilename, AnilistId) end,
    fun()-> number_and_string_in_bracket(FilteredFilename, AnilistId) end,
    fun()-> ep_suffix(FilteredFilename) end,
    fun()-> ep_prefix(FilteredFilename) end,
    fun()-> first_sensible_number(FilteredFilename, AnilistId) end ],
  lists:foldl(fun(Curr, Prev)->
    case Prev of
        notfound -> Curr();
        A -> A
    end
  end, notfound, Finders).

remove_rubbish(Filename) ->
  No_big5 = re:replace(Filename, "BIG5", ""),
  {ok, MP} = re:compile("([0-9]+(?:\\.[0-9]+)?)[期季]", [unicode]),
  No_season = re:replace(No_big5, MP, "", [global]),
  binary:bin_to_list(iolist_to_binary(No_season)).

% Match numbers in bracket with optional suffix
% [13], [12.5], [14.5話]
number_in_bracket(Filename, _AnilistId) ->
  case re:run(Filename, "\\[([0-9]+(?:\\.[0-9]+)?)]*\\]", [global]) of
    nomatch -> notfound;
    {match, Captured} ->
      Ranges = lists:map(fun([_, X | _])-> X end, Captured),
      Substrings = substrings(Ranges, Filename),
      Filtered = filter_nonsense(Substrings),
      case Filtered of
        []-> notfound;
        [First | _] -> {found, First}
      end
  end.

% Match numbers in bracket with optional suffix
% [13], [12.5], [14.5話]
number_and_string_in_bracket(Filename, _AnilistId) ->
  case re:run(Filename, "\\[([0-9]+(?:\\.[0-9]+)?)[^\\]]*\\]", [global]) of
    nomatch -> notfound;
    {match, Captured} ->
      Ranges = lists:map(fun([_, X | _])-> X end, Captured),
      Substrings = substrings(Ranges, Filename),
      Filtered = filter_nonsense(Substrings),
      case Filtered of
        []-> notfound;
        [First | _] -> {found, First}
      end
  end.

first_sensible_number(Filename, _AnilistId) ->
  case re:run(Filename, "[0-9]+(?:\\.[0-9]+)?", [global]) of
    nomatch -> notfound;
    {match, Captured} ->
      % io:format("~p", [Captured]),
      Ranges = lists:map(fun(X)-> hd(X) end, Captured),
      Substrings = substrings(Ranges, Filename),
      Filtered = filter_nonsense(Substrings),
      case Filtered of
        []-> notfound;
        [First | _] -> {found, First}
      end
  end.

sp_episode(Filename)->
  case re:run(Filename, "\\W(SP\\W{0,1}[0-9]{1,2})") of
    nomatch -> notfound;
    {match, Captured} ->
      Ranges = lists:map(fun([_, X | _])-> X end, Captured),
      Substrings = substrings(Ranges, Filename),
      case Substrings of
        [] -> notfound;
        [First | _] -> {found, First}
      end
  end.

ova_oad_special_and_preview(Filename) ->
  case re:run(Filename, "(?:OVA|OAD|Special|Preview|Prev)", [global]) of
    nomatch -> notfound;
    {match, Captured} ->
      Ranges = lists:map(fun(X)-> hd(X) end, Captured),
      Substrings = substrings(Ranges, Filename),
      case Substrings of
        []-> notfound;
        [First | _] -> {found, First}
      end
  end.

ep_suffix(Filename) ->
  {ok, MP} = re:compile("([0-9]+(?:\\.[0-9]+)?)(?:話|集)", [unicode]),
  case re:run(Filename, MP) of
    nomatch -> notfound;
    {match, [_ , {Pos, Len}]} ->
      {found, string:substr(Filename, Pos+1, Len)}
  end.

ep_prefix(Filename) ->
  {ok, MP} = re:compile("(?:EP|第) *([0-9]+(?:\\.[0-9]+)?)[^期季]", [unicode]),
  case re:run(Filename, MP, [global]) of
    nomatch -> notfound;
    {match, Captured} ->
      Ranges = lists:map(fun([_, X | _])-> X end, Captured),
      Substrings = substrings(Ranges, Filename),
      case Substrings of
        []-> notfound;
        [First | _] -> {found, First}
      end
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
    % H264
    Num == 264 -> false;
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
