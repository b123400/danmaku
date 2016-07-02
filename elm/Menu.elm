port module Menu exposing (..)

import Html exposing (Html, button, div, text)
import Html.App as Html
import Html.Events exposing (onClick)
import Platform.Sub as Sub
import Platform.Cmd as Cmd exposing ((!))
import Task
import String
import Comment as C exposing (Comment)
import Kari
import Json.Encode as Json
import Debug

main =
  Html.programWithFlags
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
  , flags : Flags
  }

type alias Flags =
  { anilistId : Int
  , filename : String
  }


init : Flags -> (Model, Cmd a)
init flags =
  ( Model
      { source = Kari
      , comments = []
      , flags = flags
      }
  , Cmd.none
  )

subscriptions _ = Sub.none

port comments : Json.Value -> Cmd msg
sendComments = comments << C.encodeList


update msg (Model model) =
  case msg of
    SwitchSource source ->
      Model
        { model | source = source }
      ! [ loadComment source model.flags.anilistId model.flags.filename
        , Task.perform identity identity <| Task.succeed <| SetComments []
        ]

    SetComments c ->
      Model { model | comments = c }
      ! [ sendComments c ]


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


loadComment : CommentSource -> Int -> String -> Cmd Msg
loadComment source anilistId filename =
  let
    task =
      case source of
        None -> Task.succeed []
        Kari -> Kari.getComments anilistId filename

    fail error = Debug.log error <| SetComments []
    success a = SetComments a

  in
    Task.perform fail success task
