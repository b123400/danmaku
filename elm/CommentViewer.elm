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
  | Tick Time
  | Resize Size

type Model = Model
  { comments : List Comment
  , danmaku : Danmaku
  , startTime : Maybe Time
  , currentTime : Maybe Time
  , size : Size
  }

init : (Model, Cmd Msg)
init =
  ( Model
      { comments = []
      , danmaku = []
      , startTime = Nothing
      , currentTime = Nothing
      , size =
        { width = 0
        , height = 0
        }
      }
  , Task.perform identity Resize Window.size
  )

port slidingComments : (JD.Value -> msg) -> Sub msg

receiveComments value =
  let
    result = JD.decodeValue C.decodeList value
  in case result of
    Err error   -> Debug.log error <| SetComments []
    Ok comments -> SetComments comments


subscriptions _ =
  Sub.batch
    [ slidingComments receiveComments
    , AnimationFrame.times Tick
    , Window.resizes Resize
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

    Tick time ->
      Model
        { model
        | startTime = Maybe.oneOf [model.startTime, Just time]
        , currentTime = Just time
        }
      ! []

    Resize size ->
      Model
        { model
        | size = size
        , danmaku = CommentLayout.danmaku (toFloat size.width) model.comments
        }
      ! []


view : Model -> Html Msg
view (Model model) =
  let

    delta =
      case (model.startTime, model.currentTime) of
        (Just start, Just current)->
          current - start
        _ -> 0

    visibleComments =
      CommentLayout.visibleDanmaku delta model.danmaku

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
      [ div [] <| List.map (commentDiv delta) visibleComments
      ]
