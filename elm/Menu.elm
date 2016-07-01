module Menu exposing (..)

import Html exposing (Html, button, div, text)
import Html.App as Html
import Html.Events exposing (onClick)
import Platform.Sub as Sub
import Platform.Cmd as Cmd
import Task
import String

main =
  Html.program
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

type Msg
  = SwitchSource CommentSource
  | SetComments (List String)

type CommentSource = Kari | None

type alias Model =
  { source : CommentSource
  , comments : List String
  }

init : (Model, Cmd a)
init =
  ( { source = Kari
    , comments = []
    }
  , Cmd.none
  )

subscriptions _ = Sub.none

update msg model =
  case msg of
    SwitchSource source ->
      ( { model | source = source }
      , loadComment source
      )
    SetComments comments ->
      ( { model | comments = comments }
      , Cmd.none
      )

view : Model -> Html Msg
view model =
  div []
    [ div [] [ model.source |> selectedText |> text ]
    , div [] [ String.join "," model.comments |> text ]
    , switcher
    ]

selectedText : CommentSource -> String
selectedText source =
  case source of
    Kari -> "kari"
    None -> "None"

switcher =
  div []
    [ button [onClick (SwitchSource Kari) ] [ text "kari" ]
    , button [onClick (SwitchSource None) ] [ text "none" ]
    ]

loadComment : CommentSource -> Cmd Msg
loadComment source =
  let
    task =
      case source of
        None -> Task.succeed ["1", "a"]
        Kari -> Task.succeed ["2", "b", "c"]

    fail _ = SetComments []
    success a = SetComments a

  in
    Task.perform fail success task
