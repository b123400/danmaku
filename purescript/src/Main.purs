module Main where

import Prelude

import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Class (liftEff)

import Halogen
import Halogen.Util (awaitBody, runHalogenAff)
import Halogen.HTML.Indexed as H
import Halogen.HTML.Events.Indexed as E
import DOM.HTML.Types (HTMLElement(), htmlElementToNode, readHTMLElement, htmlDivElementToHTMLElement)
import DOM.Node.Document (createElement)
import DOM.Node.Element (setId)
import DOM.Node.Node (appendChild, ownerDocument)
import DOM.Node.Types (Element(), ElementId(ElementId), Node, elementToNode)
import Data.Maybe (Maybe(Just))
import Data.Either (Either(..))
import Data.Nullable (toMaybe)
import Data.Foreign(toForeign)
import Control.Monad.Eff.Exception (EXCEPTION(), throw)

data Query a = ToggleState a

type State = { on :: Boolean }

initialState :: State
initialState = { on: false }

ui :: forall g. Component State Query g
ui = component { render, eval }
  where

  render :: State -> ComponentHTML Query
  render state =
    H.div_
      [ H.h1_
          [ H.text "Hello world!" ]
      , H.p_
          [ H.text "Why not toggle this button:" ]
      , H.button
          [ E.onClick (E.input_ ToggleState) ]
          [ H.text
              if not state.on
              then "Don't push me"
              else "I said don't push me!"
          ]
      ]

  eval :: Natural Query (ComponentDSL State Query g)
  eval (ToggleState next) = do
    modify (\state -> { on: not state.on })
    pure next

forceHTMLElement :: forall eff. Element -> Eff (err :: EXCEPTION | eff) HTMLElement
forceHTMLElement element =
  case (readHTMLElement $ toForeign element) of
    Left a -> throw $ show a
    Right b -> return b

addOverlay :: HTMLElement -> Eff (HalogenEffects ()) HTMLElement
addOverlay body =
  (toMaybe <$> ownerDocument bodyNode) >>= \(Just document)->
  createElement "div" document >>= \newElement ->
  setId (ElementId "commentsOverlay") newElement >>= \_ ->
  appendChild (elementToNode newElement) bodyNode >>= \_ ->
  forceHTMLElement newElement
  where
  bodyNode = htmlElementToNode body

main :: Eff (HalogenEffects ()) Unit
main = runHalogenAff $
  awaitBody >>= \body ->
  liftEff (addOverlay body) >>= \node ->
  runUI ui initialState node
