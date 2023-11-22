port module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html
import Html.Attributes as Attr
import Lamdera
import Task
import Time
import Types exposing (..)
import Url


port noise : String -> Cmd msg


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Time.every 1000 Tick
        , view = view
        }


getTimeZone : Cmd FrontendMsg
getTimeZone =
    Task.perform NewZone Time.here


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , wakeTime = { hour = 10, minute = 0 }
      , sleepTime = { hour = 23, minute = 0 }
      , wakeState = Waking
      , zone = Nothing
      }
    , getTimeZone
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( model, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        Tick posix ->
            handleTick model posix

        NewZone zone ->
            ( { model | zone = Just zone }, Cmd.none )


handleTick : Model -> Time.Posix -> ( Model, Cmd FrontendMsg )
handleTick model time =
    case model.zone of
        Nothing ->
            ( model, Cmd.none )

        Just zone ->
            let
                currentHour =
                    Time.toHour zone time

                currentMinute =
                    Time.toMinute zone time

                currentMinutes =
                    currentHour * 60 + currentMinute

                wakingMinutes =
                    model.wakeTime.hour * 60 + model.wakeTime.minute

                sleepingMinutes =
                    model.sleepTime.hour * 60 + model.sleepTime.minute

                ( wakeState, cmd ) =
                    if currentMinutes == wakingMinutes then
                        ( Waking, noise "Play" )

                    else if currentMinutes == sleepingMinutes then
                        ( Sleeping, noise "Pause" )

                    else
                        ( model.wakeState, Cmd.none )
            in
            ( { model | wakeState = wakeState }, cmd )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )


pad : Int -> String
pad n =
    if n < 10 then
        "0" ++ String.fromInt n

    else
        String.fromInt n


todString : TimeOfDay -> String
todString { hour, minute } =
    pad
        (if hour > 12 then
            hour - 12

         else
            hour
        )
        ++ ":"
        ++ pad minute
        ++ (if hour >= 12 then
                "pm"

            else
                "am"
           )


colorForWakeState : WakeState -> String
colorForWakeState ws =
    case ws of
        Waking ->
            "#7ED7C1"

        Sleeping ->
            "#FD841F"


showWakeState : WakeState -> String
showWakeState s =
    case s of
        Waking ->
            "Waking"

        Sleeping ->
            "Sleeping"


wakeStateEmoji ws =
    case ws of
        Waking ->
            "🌅"

        Sleeping ->
            "🌑"


wakeStateView : WakeState -> Html.Html FrontendMsg
wakeStateView ws =
    Html.div [ Attr.style "font-size" "6em" ] [ Html.text (wakeStateEmoji ws) ]


view : Model -> Browser.Document FrontendMsg
view model =
    { title = ""
    , body =
        [ Html.div
            [ Attr.style "height" "100vh"
            , Attr.style "text-align" "center"
            , Attr.style "padding-top" "40px"
            , Attr.style "background-color" (colorForWakeState model.wakeState)
            , Attr.style "color" "white"
            ]
            [ Html.div
                [ Attr.style "font-family" "sans-serif"
                , Attr.style "padding-top" "40px"
                , Attr.style "font-size" "2em"
                , Attr.style "text-shadow" "-1px 0px 1px black"
                ]
                [ Html.p [] [ Html.text ("Sleep at " ++ todString model.sleepTime) ]
                , Html.p [] [ Html.text ("Wake at " ++ todString model.wakeTime) ]
                ]
            , wakeStateView model.wakeState
            ]
        ]
    }
