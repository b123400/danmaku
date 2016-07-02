module MenuComposer exposing (Model, Msg, init, view, update, updateEnv)

import Html exposing (Html, button, div, text, input)
import Html.Attributes exposing (type', value)
import Html.Events exposing (onInput, onClick)
import Json.Decode as D exposing ((:=), string)
import Platform.Cmd as Cmd exposing ((!))
import Task
import API

type Msg
  = SetText String
  | Send

type alias Env =
  { anilistId : Int
  , filename : String
  }

type Model = Model
  { anilistId : Int
  , filename : String
  , text : String
  }


init : Env -> Model
init flags = Model
  { anilistId = flags.anilistId
  , filename = flags.filename
  , text = ""
  }

updateEnv (Model model) env = Model
  { model
  | anilistId = env.anilistId
  , filename = env.filename
  }

view : Model -> Html Msg
view (Model model) =
  div []
    [ input
      [ type' "text"
      , value model.text
      , onInput SetText
      ]
      []
    , button [ onClick <| Send ] [ text "Send" ]
    ]


update msg (Model model) =
  case msg of
    SetText text ->
      Model { model | text = text } ! []

    Send ->
      Model { model | text = "" }
      ! [ sendComment model.anilistId model.filename model.text
        ]


sendComment : Int -> String -> String -> Cmd Msg
sendComment anilistId filename text =
  let
    task = API.postComment anilistId filename text

    fail error = SetText error
    success _ = SetText "sent"

  in
    Task.perform fail success task
