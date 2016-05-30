-module(episode_guesser).          % module attribute
-export([guess/2]).   % module attribute

guess(Filename, AnilistId) ->
	Filename.