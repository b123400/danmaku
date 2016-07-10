module CommentLayout exposing (Danmaku, danmaku, getY)

import Maybe exposing (Maybe(..))
import Lazy exposing (Lazy)
import Time exposing (Time, inSeconds)
import List

import Comment as C exposing (Comment)
import TextMeasure as Measure exposing (measureComment, getCommentHeight)
import LazyUtil

type alias Danmaku = List CommentTween

type CommentTween = CommentTween
  { comment : Comment
  , y : Lazy Float
  }

type alias YRange = (Float, Float)

getComment : CommentTween -> Comment
getComment (CommentTween t) = t.comment

getY : CommentTween -> Float
getY (CommentTween t) = Lazy.force t.y

getLazyYRange : CommentTween -> Lazy YRange
getLazyYRange (CommentTween t) =
  let height = getCommentHeight t.comment
  in  Lazy.map (\y-> (y, height)) t.y

startTime : Comment -> Time
startTime c =
  (C.time c)

duration : Float -> Comment -> Time
duration containerWidth c =
  let
    width = measureComment c
  in
    (width + containerWidth) / (abs speed)

endTime : Float -> Comment -> Time
endTime containerWidth c =
  (startTime c) + (duration containerWidth c)

touchEdgeTime : Float -> Comment -> Time
touchEdgeTime containerWidth c =
  (startTime c) + containerWidth / (abs speed)

speed : Float
speed = -100 / Time.second
-- Minus 100px per second

offsetAtTimeDelta : Time -> Float
offsetAtTimeDelta timeDelta =
  speed * (inSeconds timeDelta)

danmaku : Float -> List Comment -> Danmaku
danmaku containerWidth =
  List.foldl (appendComment containerWidth) []

appendComment : Float -> Comment -> Danmaku -> Danmaku
appendComment containerWidth comment danmaku =
  let
    lazyY =
      danmaku
      |> visibleDanmaku containerWidth (C.time comment)
      |> List.filter (getComment >> willCollideX containerWidth comment)
      |> List.map getLazyYRange
      |> LazyUtil.collect
      |> Lazy.map (List.sortBy fst)
      |> Lazy.map (minimumY (getCommentHeight comment))
    tween =
      CommentTween
        { comment = comment
        , y = lazyY
        }
  in
    danmaku ++ [tween]

visibleDanmaku : Float -> Time -> Danmaku -> Danmaku
visibleDanmaku containerWidth time =
  let
    isVisible c =
      let comment = getComment c
      in (startTime comment) < time && (endTime containerWidth comment) > time
  in List.filter isVisible

willCollideX : Float -> Comment -> Comment -> Bool
willCollideX containerWidth curr prev =
  (endTime containerWidth prev) > (touchEdgeTime containerWidth curr)

minimumY : Float -> List YRange -> Float
minimumY currHeight =
  let
    suggestedY (y, height) curr =
      if (y >= curr && y <= curr + currHeight) || (y <= curr && y + height >= curr)
      then y + height
      else curr
  in
    List.foldr suggestedY 0
