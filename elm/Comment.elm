module Comment exposing (Comment, text, decodeList, decode, encodeList, encode)
import Json.Decode as D exposing ((:=))
import Json.Encode as E

type Comment = Comment
  { text : String
  }

text (Comment r) = r.text

decodeList : D.Decoder (List Comment)
decodeList = D.list decode

decode : D.Decoder Comment
decode =
  D.object1
    (\s -> Comment { text = s })
    ("text" := D.string)

encodeList : List Comment -> E.Value
encodeList =
  E.list << List.map encode

encode : Comment -> E.Value
encode (Comment comment) =
  E.object
    [ ("text", E.string comment.text)
    ]
