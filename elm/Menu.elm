port module Menu exposing (..)

import Html exposing (Html, button, div, text)
import Html.App as Html
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Platform.Sub as Sub
import Platform.Cmd as Cmd exposing ((!))
import Task
import Json.Encode as Json
import String
import Comment as C exposing (Comment)
import API
import MenuComposer as MC
import Debug

main =
  Html.programWithFlags
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

type Msg
  = SetFlags Flags
  | SwitchSource CommentSource
  | SetComments (List Comment)
  | ComposerMsg MC.Msg

type CommentSource = Kari | None

type Model = Model
  { source : CommentSource
  , comments : List Comment
  , flags : Flags
  , composer : MC.Model
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
      , composer = MC.init flags
      }
  , Cmd.none
  )

port comments : Json.Value -> Cmd msg
sendComments = comments << C.encodeList


port flags : (Flags -> msg) -> Sub msg

subscriptions _ = flags SetFlags


update msg (Model model) =
  case msg of
    SetFlags flags ->
      Model
        { model
        | flags = flags
        , composer = MC.updateEnv model.composer flags
        , comments =
          case flags.anilistId of
            -1 -> []
            _  -> model.comments
        }
      ! [ loadComment model.source flags.anilistId flags.filename
        ]

    SwitchSource source ->
      Model
        { model | source = source }
      ! [ loadComment source model.flags.anilistId model.flags.filename
        , Task.perform identity identity <| Task.succeed <| SetComments []
        ]

    SetComments c ->
      Debug.log "set comments" <|
      Model { model | comments = c }
      ! [ sendComments c ]

    ComposerMsg msg ->
      let
        (composerModel, cmd) = MC.update msg model.composer
        reloadCmd =
          case msg of
            MC.Sent   -> loadComment model.source model.flags.anilistId model.flags.filename
            otherwise -> Cmd.none
      in
        Model { model | composer = composerModel }
        ! [ Cmd.map ComposerMsg cmd
          , reloadCmd
          ]

view : Model -> Html Msg
view (Model model) =
  div []
    [ MC.view model.composer
      |> Html.map ComposerMsg
    , switcher model.source
    ]


selectedText : CommentSource -> String
selectedText source =
  case source of
    Kari -> "kari"
    None -> "None"


switcher source =
  case source of
    None -> button [ class "danmaku-menu-switcher-button", onClick <| SwitchSource Kari ] [ text "Danmaku OFF" ]
    Kari -> button [ class "danmaku-menu-switcher-button", onClick <| SwitchSource None ] [ text "Danmaku ON" ]


loadComment : CommentSource -> Int -> String -> Cmd Msg
loadComment source anilistId filename =
  let
    task =
      case source of
        None -> Task.succeed []
        Kari -> API.getComments anilistId filename

    fail error = Debug.log error <| SetComments []
    success a = SetComments a

  in
    Task.perform fail success task
