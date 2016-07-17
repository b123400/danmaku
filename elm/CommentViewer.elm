port module CommentViewer exposing (..)

import Task
import String
import Result exposing (Result(Ok, Err))
import Platform.Sub as Sub
import Platform.Cmd as Cmd exposing ((!))
import Time exposing (Time)
import Maybe exposing (Maybe(..))
import Debug

import Html exposing (Html, button, div, text)
import Html.App as Html
import Html.Events exposing (onClick)
import Html.Attributes exposing (style)
import Window exposing (Size)
import Json.Decode as JD
import AnimationFrame

import Comment as C exposing (Comment)
import MenuComposer as MC
import CommentLayout exposing (Danmaku)

main =
  Html.program
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

type Msg
  = SetComments (List Comment)
  | Resize Size
  | SystemTick Time
  | SetTime (Time, Time) -- VideoTime, now
  | SetPlayState Bool
  | NoOps

type Model = Model
  { comments : List Comment
  , danmaku : Danmaku
  , isPlaying : Bool
  , currentTime : Time
  , lastTick : Time
  , size : Size
  }

init : (Model, Cmd Msg)
init =
  ( Model
      { comments = []
      , danmaku = []
      , isPlaying = False
      , currentTime = 0
      , lastTick = 0
      , size =
        { width = 0
        , height = 0
        }
      }
  , Task.perform identity Resize Window.size
  )

port slidingComments : (JD.Value -> msg) -> Sub msg
port setTime : (JD.Value -> msg) -> Sub msg
port setPlayState : (Bool -> msg) -> Sub msg

receiveComments value =
  let
    result = JD.decodeValue C.decodeList value
  in case result of
    Err error   -> Debug.log error <| SetComments []
    Ok comments -> SetComments comments


receiveExternalTime value =
  let
    result = JD.decodeValue (JD.tuple2 (,) JD.float JD.float) value
  in case result of
    Err error      -> Debug.log error <| NoOps
    Ok (time, now) -> SetTime (time * Time.second, now)


subscriptions (Model model) =
  Sub.batch
    [ slidingComments receiveComments
    , AnimationFrame.times SystemTick
    , Window.resizes Resize
    , setTime receiveExternalTime
    , setPlayState SetPlayState
    ]


update msg (Model model) =
  case msg of

    SetComments c ->
      Model
        { model
        | comments = c
        , danmaku = CommentLayout.danmaku (toFloat model.size.width) c
        }
      ! []

    Resize size ->
      Model
        { model
        | size = size
        , danmaku = CommentLayout.danmaku (toFloat size.width) model.comments
        }
      ! []

    SystemTick time ->
      Model
        { model
        | lastTick = time
        , currentTime =
          if model.isPlaying
          then model.currentTime + (time - model.lastTick)
          else model.currentTime
        }
      ! []

    SetTime (time, now) ->
      Model
        { model
        | currentTime = time
        , lastTick = now
        }
      ! []

    SetPlayState playing ->
      Model
        { model
        | isPlaying = playing
        }
      ! []

    NoOps -> (Model model) ! []


view : Model -> Html Msg
view (Model model) =
  let

    visibleComments =
      --Debug.log "visibles" <|
      CommentLayout.visibleDanmaku model.currentTime model.danmaku

    commentDiv time tween =
      let comment = CommentLayout.getComment tween
      in
        div
          [ style
            ([("left", (toString <| CommentLayout.getInitialX tween) ++ "px")
            , ("top", (toString <| CommentLayout.getY tween) ++ "px")
            , ("transform", "translateX(" ++ (toString <| CommentLayout.xDeltaAtTime tween time) ++ "px)")
            , ("position", "absolute")
            , ("width",  (toString <| C.getWidth comment)  ++ "px")
            , ("height", (toString <| C.getHeight comment) ++ "px")
            , ("display", "block")
            , ("background-color", "rgba(0, 1, 0, 0.3)")
            , ("overflow", "visible")
            ]
            ++ (C.styleAttributes comment))
          ]
          [ comment |> C.text |> text
          ]
  in
    div []
      [ div [] <| List.map (commentDiv model.currentTime) visibleComments
      ]
