module TextMeasure exposing (Font, font, measure, measureHeight)

import String
import Native.TextMeasure

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

measureHeight : Font -> String -> Float
measureHeight f _ = fontSize f