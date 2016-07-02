module Menu exposing (..)

import Html exposing (Html, button, div, text)
import Html.App as Html
import Html.Events exposing (onClick)
import Platform.Sub as Sub
import Platform.Cmd as Cmd
import Task
import String
import Comment as C exposing (Comment)
import Kari

main =
  Html.program
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

type Msg
  = SwitchSource CommentSource
  | SetComments (List Comment)

type CommentSource = Kari | None

type Model = Model
  { source : CommentSource
  , comments : List Comment
  }

init : (Model, Cmd a)
init =
  ( Model
      { source = Kari
      , comments = []
      }
  , Cmd.none
  )

subscriptions _ = Sub.none

update msg (Model model) =
  case msg of
    SwitchSource source ->
      ( Model { model | source = source }
      , loadComment source
      )
    SetComments comments ->
      ( Model { model | comments = comments }
      , Cmd.none
      )

view : Model -> Html Msg
view (Model model) =
  div []
    [ div [] [ model.source |> selectedText |> text ]
    , div [] [ model.comments
               |> List.map C.text 
               |> String.join "," 
               |> text
             ]
    , switcher
    ]

selectedText : CommentSource -> String
selectedText source =
  case source of
    Kari -> "kari"
    None -> "None"

switcher =
  div []
    [ button [onClick <| SwitchSource Kari ] [ text "kari" ]
    , button [onClick <| SwitchSource None ] [ text "none" ]
    ]

loadComment : CommentSource -> Cmd Msg
loadComment source =
  let
    task =
      case source of
        None -> Task.succeed []
        Kari -> Kari.getComments 123 "filename"

    fail _ = SetComments []
    success a = SetComments a

  in
    Task.perform fail success task
