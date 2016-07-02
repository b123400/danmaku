module Kari exposing (getComments)

import Json.Decode as Json exposing ((:=))
import Http
import Task exposing (Task)
import String
import Comment as C exposing (Comment)

getComments : Int -> String -> Task String (List Comment)
getComments anilistId filename =
  getUrl anilistId filename
  |> Http.get decodeCommentResponse
  |> Task.mapError getErrorMessage

getUrl : Int -> String -> String
getUrl anilistId filename = 
  Http.url "/api/comments"
    [ ("anilist_id", toString anilistId)
    , ("filename", filename)
    , ("source", "kari")
    ]

getErrorMessage : Http.Error -> String
getErrorMessage error =
  case error of
    Http.Timeout -> "Timeout"
    Http.NetworkError -> "Network Error"

    Http.UnexpectedPayload str ->
      String.append "Unexpected Payload" str

    Http.BadResponse code str ->
      String.join ","
        [ "BadResponse"
        , toString code
        , str
        ]

decodeCommentResponse : Json.Decoder (List Comment)
decodeCommentResponse =
  ("comments" := C.decodeList)