module CommentLayout exposing (Danmaku, danmaku, getY, getInitialX, getComment, xDeltaAtTime, visibleDanmaku)

import Maybe exposing (Maybe(..))
import Lazy exposing (Lazy)
import Time exposing (Time, inSeconds)
import List
import String
import Debug

import Comment as C exposing (Comment)
import LazyUtil

type alias Danmaku = List CommentTween

type CommentTween = CommentTween
  { comment : Comment
  , y : Lazy Float
  , initialX : Float
  , containerWidth : Float
  }

type alias YRange = (Float, Float)

getComment : CommentTween -> Comment
getComment (CommentTween t) = t.comment

getY : CommentTween -> Float
getY (CommentTween t) = Lazy.force t.y

getLazyYRange : CommentTween -> Lazy YRange
getLazyYRange (CommentTween t) =
  let height = C.getHeight t.comment
  in  Lazy.map (\y-> (y, height)) t.y

getInitialX : CommentTween -> Float
getInitialX (CommentTween t) = t.initialX

startTime : Comment -> Time
startTime = C.time

duration : Float -> Comment -> Time
duration containerWidth c =
  let
    width = C.getWidth c
  in
    (width + containerWidth) / (abs <| speed containerWidth c)

endTime : Float -> Comment -> Time
endTime containerWidth c =
  (startTime c) + (duration containerWidth c)

touchEdgeTime : Float -> Comment -> Time
touchEdgeTime containerWidth c =
  (startTime c) + containerWidth / (abs <| speed containerWidth c)

speed : Float -> Comment -> Float
speed containerWidth c = -(100 + (C.getWidth c)*0.4) / Time.second
-- Minus 100px per second

xDeltaAtTime : CommentTween -> Time -> Float
xDeltaAtTime (CommentTween tween) t =
  let
    s = speed tween.containerWidth tween.comment
    localTime = t - (startTime tween.comment)
  in
    s * localTime

danmaku : Float -> List Comment -> Danmaku
danmaku containerWidth = case containerWidth of
  0 -> \_-> []
  _ -> List.foldl (appendComment containerWidth) []

appendComment : Float -> Comment -> Danmaku -> Danmaku
appendComment containerWidth comment danmaku =
  let
    lazyY =
      danmaku
      |> visibleDanmaku (C.time comment)
      |> List.filter (willCollideX comment)
      |> List.map getLazyYRange
      |> LazyUtil.collect
      |> Lazy.map (List.sortBy fst)
      |> Lazy.map (minimumY <| C.getHeight comment)
    tween =
      CommentTween
        { comment = comment
        , y = lazyY
        , initialX = containerWidth
        , containerWidth = containerWidth
        }
  in
    danmaku ++ [tween]

visibleDanmaku : Time -> Danmaku -> Danmaku
visibleDanmaku time =
  let
    isVisible (CommentTween c) =
      (startTime c.comment) <= time && (endTime c.containerWidth c.comment) >= time
  in List.filter isVisible

willCollideX : Comment -> CommentTween -> Bool
willCollideX curr tween =
  let
    prev = getComment tween
    containerWidth = tween |> \(CommentTween t)-> t.containerWidth
  in
    (endTime containerWidth prev) > (touchEdgeTime containerWidth curr) ||
    (abs <| xDeltaAtTime tween <| C.time curr) < C.getWidth prev

minimumY : Float -> List YRange -> Float
minimumY currHeight =
  let
    suggestedY (y, height) curr =
      if (y > curr && y < curr + currHeight) || (y <= curr && y + height >= curr)
      then y + height
      else curr
  in
    List.foldl suggestedY 0
