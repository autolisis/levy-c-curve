module Main exposing (..)

import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import String.Extra exposing (fromFloat)
import Keyboard.Extra exposing (..)
import Mouse exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { xdown : Int
    , ydown : Int
    , xup : Int
    , yup : Int
    , iterations : Int
    }


initialModel : Model
initialModel =
    { xdown = 100
    , ydown = 100
    , xup = 200
    , yup = 200
    , iterations = 3
    }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )



-- UPDATE


type Msg
    = MDown Int Int
    | MUp Int Int
    | KeyUp Key


update : Msg -> Model -> ( Model, Cmd a )
update msg model =
    case msg of
        MDown x y ->
            ( { model | xdown = x, ydown = y }, Cmd.none )

        MUp x y ->
            ( { model | xup = x, yup = y }, Cmd.none )

        KeyUp key ->
            case key of
                ArrowUp ->
                    ( { model | iterations = (model.iterations + 1) }, Cmd.none )

                ArrowDown ->
                    ( { model | iterations = (model.iterations - 1) }, Cmd.none )

                _ ->
                    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Mouse.downs
            (\{ x, y } -> MDown x y)
        , Mouse.ups
            (\{ x, y } -> MUp x y)
        , Keyboard.Extra.ups KeyUp
        ]


view : Model -> Html a
view model =
    -- Html.program
    --     { model = model
    --     , view = view
    --     , update = update
    --     , init = init
    --     }
    let
        len =
            sqrt (toFloat ((model.xup - model.xdown) ^ 2 + (model.yup - model.ydown) ^ 2))

        alpha =
            atan2 (toFloat (model.yup - model.ydown)) (toFloat (model.xup - model.xdown))
    in
        svg
            [ version "1.1"
            , fromFloat 646 |> height
            , fromFloat 1366 |> width
            , stroke "white"
            , Svg.Attributes.style "background:black"
            ]
            (ccurve model.iterations (toFloat (model.xdown)) (toFloat (model.ydown)) len alpha)


ccurve : Int -> Float -> Float -> Float -> Float -> List (Svg msg)
ccurve n p1x p1y len alpha =
    case n of
        0 ->
            let
                p2x =
                    p1x + len * (cos alpha)

                p2y =
                    p1y + len * (sin alpha)
            in
                [ line
                    [ fromFloat (p1x) |> x1
                    , fromFloat (p1y) |> y1
                    , fromFloat (p2x) |> x2
                    , fromFloat (p2y) |> y2
                    ]
                    []
                ]

        _ ->
            let
                newLen =
                    (len / sqrt (2))

                newCoordx =
                    (p1x + newLen * cos (pi / 4 + alpha))

                newCoordy =
                    (p1y + newLen * sin (pi / 4 + alpha))
            in
                List.append
                    (ccurve (n - 1) p1x p1y newLen (alpha + pi / 4))
                    (ccurve (n - 1) newCoordx newCoordy newLen (alpha - pi / 4))
