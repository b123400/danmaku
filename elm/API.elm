module API exposing (getComments, postComment)

import Json.Decode as Json exposing ((:=))
import Http exposing (multipart, stringData)
import Task exposing (Task)
import String
import Comment as C exposing (Comment)

getComments : Int -> String -> Task String (List Comment)
getComments anilistId filename =
  getCommentUrl anilistId filename
  |> Http.get decodeCommentsResponse
  |> Task.mapError getErrorMessage

postComment : Int -> String -> String -> Task String Comment
postComment anilistId filename text =
  let
    body = multipart
      [ stringData "anilist_id" <| toString anilistId
      , stringData "filename" filename
      , stringData "text" text
      , stringData "source" "kari"
      ]
  in
    Http.post decodeCommentResponse postCommentUrl body
    |> Task.mapError getErrorMessage

getCommentUrl : Int -> String -> String
getCommentUrl anilistId filename = 
  Http.url "/api/comments"
    [ ("anilist_id", toString anilistId)
    , ("filename", filename)
    , ("source", "kari")
    ]

postCommentUrl = "/api/comments/add"

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

decodeCommentsResponse : Json.Decoder (List Comment)
decodeCommentsResponse =
  ("comments" := C.decodeList)

decodeCommentResponse : Json.Decoder Comment
decodeCommentResponse =
  ("comment" := C.decode)

