module Evergreen.V1.Types exposing (..)

import Browser
import Browser.Navigation
import Time
import Url


type alias TimeOfDay =
    { hour : Int
    , minute : Int
    }


type WakeState
    = Waking
    | Sleeping


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , wakeTime : TimeOfDay
    , sleepTime : TimeOfDay
    , zone : Maybe Time.Zone
    , wakeState : WakeState
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | Tick Time.Posix
    | NewZone Time.Zone


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
