module Main where

import Prelude

import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Class (liftEff)

import Halogen
import Halogen.Util (awaitBody, runHalogenAff)
import Halogen.HTML.Indexed as H
import Halogen.HTML.Events.Indexed as E
import DOM.HTML.Types (HTMLElement(), htmlElementToNode)
import DOM.Node.Document (createElement)
import DOM.Node.Node (appendChild, ownerDocument)
import DOM.Node.Types (Node, elementToNode)
import Data.Maybe (Maybe(Just))
import Data.Nullable (toMaybe)

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

addOverlay :: HTMLElement -> Eff (HalogenEffects ()) Node
addOverlay body =
  (toMaybe <$> ownerDocument bodyNode) >>= \(Just document)->
  createElement "div" document >>= \newElement ->
  appendChild (elementToNode newElement) bodyNode
  where
  bodyNode = htmlElementToNode body

main :: Eff (HalogenEffects ()) Unit
main = runHalogenAff $
  awaitBody >>= \body ->
  liftEff (addOverlay body) >>= \_ ->
  runUI ui initialState body
