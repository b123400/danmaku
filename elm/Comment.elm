module Comment exposing (Comment, text, decodeList, decode)
import Json.Decode as Json exposing ((:=))

type Comment = Comment
  { text : String
  }

text (Comment r) = r.text

decodeList : Json.Decoder (List Comment)
decodeList = Json.list decode

decode : Json.Decoder Comment
decode =
  Json.object1
    (\s -> Comment { text = s })
    ("text" := Json.string)
