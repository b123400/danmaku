-module(episode_guesser).          % module attribute
-export([guess/2]).   % module attribute

guess(Filename, AnilistId) ->
  case re:run(Filename, "[0-9]+", [global]) of
    nomatch -> notfound;
    {match, Captured} ->
      Ranges = lists:map(fun(X)-> hd(X) end, Captured),
      Substrings = substrings(Ranges, binary:bin_to_list(Filename)),
      Numbers = lists:filtermap(
        fun(Str)->
          case string:to_integer(Str) of
            {error, _} -> false;
            {Num, _}-> {true, Num}
          end
        end,
        Substrings),
      No_Too_large = lists:filter(fun(Num)-> Num < 1000 end, Numbers),
      No_Resolution = lists:filter(fun(Num)->
        Num /= 960 andalso
        Num /= 720 andalso
        Num /= 576 andalso
        Num /= 480 end, No_Too_large),
      % TODO: Fetch anilist and filter number > total ep count
      case No_Resolution of
        [First | _] -> {found, First};
        []-> notfound
      end
  end.

substrings(Ranges, SourceString) ->
  lists:map(fun({Pos, Len}) ->
    % substr starts at 1, not 0, need to shift 1
    string:substr(SourceString, Pos+1, Len)
  end,
  Ranges).
