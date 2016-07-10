module Comment exposing
  ( Comment
  , text
  , decodeList
  , decode
  , encodeList
  , encode
  , time
  , getWidth
  , getHeight
  , styleAttributes
  )

import Json.Decode as D exposing ((:=))
import Json.Encode as E
import Time exposing (Time, millisecond, inMilliseconds)
import TextMeasure exposing (Font, font)


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

getFont : Comment -> Font
getFont _ = font "Arial" 30

styleAttributes : Comment -> List (String, String)
styleAttributes comment =
  let font = getFont comment
  in
    [ ("font-family", TextMeasure.family font)
    , ("font-size", (toString <| TextMeasure.fontSize font) ++ "px")
    ]

getHeight : Comment -> Float
getHeight c =
  TextMeasure.measureHeight (getFont c) (text c)

getWidth : Comment -> Float
getWidth c =
  TextMeasure.measure (getFont c) (text c)
