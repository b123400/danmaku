module API exposing (getComments, postComment)

import Json.Decode as Json exposing ((:=))
import Http exposing (multipart, stringData)
import Task exposing (Task)
import String
import Comment as C exposing (Comment)

apiHost : String
apiHost = "https://danmaku.b123400.net"

getComments : Int -> String -> Task String (List Comment)
getComments anilistId filename =
  getCommentUrl anilistId filename
  |> Http.get decodeCommentsResponse
  |> Task.mapError getErrorMessage

postComment : Int -> String -> Int -> String -> Task String Comment
postComment anilistId filename time text =
  let
    body = multipart
      [ stringData "anilist_id" <| toString anilistId
      , stringData "filename" filename
      , stringData "text" text
      , stringData "time" <| toString time
      , stringData "source" "kari"
      ]
  in
    Http.post decodeCommentResponse postCommentUrl body
    |> Task.mapError getErrorMessage

getCommentUrl : Int -> String -> String
getCommentUrl anilistId filename =
  Http.url (apiHost ++ "/api/comments")
    [ ("anilist_id", toString anilistId)
    , ("filename", filename)
    , ("source", "kari")
    ]

postCommentUrl = apiHost ++ "/api/comments/add"

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

