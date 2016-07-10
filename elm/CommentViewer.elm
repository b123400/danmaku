port module CommentViewer exposing (..)

import Task
import String
import Result exposing (Result(Ok, Err))
import Platform.Sub as Sub
import Platform.Cmd as Cmd exposing ((!))
import Debug

import Html exposing (Html, button, div, text)
import Html.App as Html
import Html.Events exposing (onClick)
import Json.Decode as JD

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

type Model = Model
  { comments : List Comment
  }

init : (Model, Cmd a)
init =
  ( Model { comments = [] }
  , Cmd.none
  )

port slidingComments : (JD.Value -> msg) -> Sub msg

receiveComments value =
  let
    result = JD.decodeValue C.decodeList value
  in case result of
    Err error   -> Debug.log error <| SetComments []
    Ok comments -> SetComments comments


subscriptions _ = slidingComments receiveComments


update msg (Model model) =
  case msg of
    SetComments c ->
      Debug.log (CommentLayout.danmaku 1024 c |> debugDanmaku)
      Model { model | comments = c } ! []


view : Model -> Html Msg
view (Model model) =
  div []
    [ div [] [ model.comments
               |> List.map C.text 
               |> String.join ", " 
               |> text
             ]
    ]

debugDanmaku : Danmaku -> String
debugDanmaku danmaku =
  danmaku
  |> List.map (\a-> (a, CommentLayout.getY a))
  |> toString
