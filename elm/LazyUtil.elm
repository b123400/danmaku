module LazyUtil exposing (foldl, foldr, collect)

import List exposing ((::))
import Lazy as L exposing (Lazy, lazy, andThen)

foldl : (a -> b -> Lazy b) -> Lazy b -> List (Lazy a) -> Lazy b
foldl reduce =
  let 
    reduce' lazyA lazyB =
      lazyA `andThen` \a ->
      lazyB `andThen` \b ->
      reduce a b
  in List.foldl reduce'

foldr : (a -> b -> Lazy b) -> Lazy b -> List (Lazy a) -> Lazy b
foldr reduce =
  let 
    reduce' lazyA lazyB =
      lazyA `andThen` \a ->
      lazyB `andThen` \b ->
      reduce a b
  in List.foldr reduce'

collect : List (Lazy a) -> Lazy (List a)
collect =
  let
    reduce' a b =
      lazy <| always <| a :: b
  in foldl reduce' (lazy <| always [])

