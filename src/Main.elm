module Main exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html
import Html.Attributes as Attr
import Lamdera
import Task
import Time
import Types exposing (..)
import Url
import Frontend exposing (init, update, view)

main : Program () Frontend.Model FrontendMsg
main =
    Browser.application
        { init = \_ -> init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , subscriptions = \m -> Time.every 1000 Tick
        , view = view
        }