module MenuComposer exposing (Model, Msg(Sent), init, view, update, updateEnv, updateTime)

import Html exposing (Html, button, div, text, input)
import Html.Attributes exposing (type', value, disabled, style, class)
import Html.Events exposing (onInput, onClick)
import Json.Decode as D exposing ((:=), string)
import Platform.Cmd as Cmd exposing ((!))
import Task
import Time exposing (Time)
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
  , time : Time
  }


init : Env -> Model
init flags = Model
  { anilistId = flags.anilistId
  , filename = flags.filename
  , text = ""
  , isLoading = False
  , time = 0
  }

updateEnv (Model model) env = Model
  { model
  | anilistId = env.anilistId
  , filename = env.filename
  }

updateTime (Model model) time =
  Model { model | time = time }

view : Model -> Html Msg
view (Model model) =
  div
    [ class "danmaku-composer"
    ]
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
      ! [ sendComment model.anilistId model.filename model.time model.text
        ]

    Sent ->
      Model
        { model | isLoading = False }
      ! []


sendComment : Int -> String -> Time -> String -> Cmd Msg
sendComment anilistId filename time text =
  let
    task = API.postComment anilistId filename (Time.inMilliseconds time |> round) text

    fail error = SetText error
    success _ = Sent

  in
    Task.perform fail success task
