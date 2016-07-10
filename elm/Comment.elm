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
import Lazy exposing (Lazy, lazy)
import TextMeasure exposing (Font, font)

type alias CommentBase =
  { text : String
  , time : Time
  }

type alias CommentExtra a =
  { a
  | width: Lazy Float
  }

type alias CommentFull = CommentExtra CommentBase

type Comment = Comment CommentFull

text : Comment -> String
text (Comment r) = r.text

time : Comment -> Time
time (Comment r) = r.time

makeComment : CommentBase -> Comment
makeComment fields =
  Comment
    { text = fields.text
    , time = fields.time
    , width = lazy (\_-> TextMeasure.measure (getFont 0) fields.text)
    }

decodeList : D.Decoder (List Comment)
decodeList = D.list decode

decode : D.Decoder Comment
decode =
  D.object2
    (\s-> \t -> makeComment
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

--getFont : Comment -> Font
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
getWidth (Comment c) = Lazy.force c.width
