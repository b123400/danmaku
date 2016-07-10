module MenuComposer exposing (Model, Msg(Sent), init, view, update, updateEnv)

import Html exposing (Html, button, div, text, input)
import Html.Attributes exposing (type', value, disabled)
import Html.Events exposing (onInput, onClick)
import Json.Decode as D exposing ((:=), string)
import Platform.Cmd as Cmd exposing ((!))
import Task
import API

type Msg
  = SetText String
  | Send
  | Sent

type alias Env =
  { anilistId : Int
  , filename : String
  }

type Model = Model
  { anilistId : Int
  , filename : String
  , text : String
  , isLoading : Bool
  }


init : Env -> Model
init flags = Model
  { anilistId = flags.anilistId
  , filename = flags.filename
  , text = ""
  , isLoading = False
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
      , disabled model.isLoading
      ]
      []
    , button
      [ onClick <| Send
      , disabled model.isLoading
      ]
      [ text "Send" ]
    ]


update msg (Model model) =
  case msg of
    SetText text ->
      Model { model | text = text } ! []

    Send ->
      Model 
        { model
        | text = ""
        , isLoading = True
        }
      ! [ sendComment model.anilistId model.filename model.text
        ]

    Sent ->
      Model
        { model | isLoading = False }
      ! []


sendComment : Int -> String -> String -> Cmd Msg
sendComment anilistId filename text =
  let
    task = API.postComment anilistId filename 1000 text

    fail error = SetText error
    success _ = Sent

  in
    Task.perform fail success task
