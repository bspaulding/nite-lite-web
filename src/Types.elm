module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Navigation exposing (Key)
import Time exposing (Posix, Zone)
import Url exposing (Url)


type WakeState
    = Waking
    | Sleeping


type alias FrontendModel =
    { key : Key
    , wakeTime : TimeOfDay
    , sleepTime : TimeOfDay
    , zone : Maybe Zone
    , wakeState : WakeState
    }


type alias TimeOfDay =
    { hour : Int
    , minute : Int
    }


type alias BackendModel =
    { message : String
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
    | Tick Posix
    | NewZone Zone


type ToBackend
    = NoOpToBackend


type BackendMsg
    = NoOpBackendMsg


type ToFrontend
    = NoOpToFrontend
