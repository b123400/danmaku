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
      Ranges = lists:map(fun(X)-> hd(X) end, Captured),
      Substrings = substrings(Ranges, binary:bin_to_list(Filename)),
      Numbers = lists:filtermap(
        fun(Str)->
          case string:to_float(Str) of
            {error, _} -> false;
            % Save the original string becoz float_to_string is not accurate
            {Num, _}-> {true, {Num, Str}}
          end
        end,
        Substrings),
      % > 1000 is not an episode number
      No_Too_large = lists:filter(fun({Num, _})-> Num < 1000 end, Numbers),
      % These numbers are usually resolution
      No_Resolution = lists:filter(fun({Num, _})->
        Num /= 960 andalso
        Num /= 720 andalso
        Num /= 576 andalso
        Num /= 480 end, No_Too_large),
      % TODO: Fetch anilist and filter number > total ep count
      case No_Resolution of
        []-> notfound;
        [{_, First} | _] -> {found, First}
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

substrings(Ranges, SourceString) ->
  lists:map(fun({Pos, Len}) ->
    % substr starts at 1, not 0, need to shift 1
    string:substr(SourceString, Pos+1, Len)
  end,
  Ranges).
