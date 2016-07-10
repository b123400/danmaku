module TextMeasure exposing (font, measure, measureComment, getCommentHeight)

import String
import Native.TextMeasure
import Comment as C exposing (Comment)

-- Family, font size
type Font = Font String Float

font = Font
family (Font family _) = family
fontSize (Font _ size) = size


nativeMeasure : String -> String -> Float
nativeMeasure font text =
  Native.TextMeasure.measureText font text

makeFontString : Font -> String
makeFontString font =
  String.join " "
    [ family font
    , font
      |> fontSize
      |> toString
      |> (++) "px"
    ]

measure : Font -> String -> Float
measure font =
  nativeMeasure (makeFontString font)

getCommentFont _ = Font "Arial" 16
getCommentHeight c =
  c
  |> getCommentFont
  |> fontSize

measureComment : Comment -> Float
measureComment c =
  measure (getCommentFont c) (C.text c)
