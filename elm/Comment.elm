module Comment exposing (Comment, text, decodeList, decode, encodeList, encode, time)

import Json.Decode as D exposing ((:=))
import Json.Encode as E
import Time exposing (Time, millisecond, inMilliseconds)


type Comment = Comment
  { text : String
  , time : Time
  }

text (Comment r) = r.text
time (Comment r) = r.time

decodeList : D.Decoder (List Comment)
decodeList = D.list decode

decode : D.Decoder Comment
decode =
  D.object2
    (\s-> \t -> Comment
      { text = s
      , time = t
      })
    ("text" := D.string)
    ("time" := timeDecoder)

timeDecoder : D.Decoder Time
timeDecoder =
  D.float
  |> D.map ((*) millisecond) 

encodeList : List Comment -> E.Value
encodeList =
  E.list << List.map encode

encode : Comment -> E.Value
encode (Comment comment) =
  E.object
    [ ("text", E.string comment.text)
    , ("time", E.float (inMilliseconds comment.time))
    ]
