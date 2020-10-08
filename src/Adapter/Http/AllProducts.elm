module Adapter.Http.AllProducts exposing (main)

import Adapter.Http.Server exposing (basepath, products)
import Adapter.Json.Decoder exposing (collection)
import Browser
import Domain.Products exposing (Product)
import Html exposing (Html, div, h2, li, text, ul)
import Http


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }


type alias Products =
    List Product


type Model
    = Failure
    | Loading
    | Success Products


type Msg
    = SendHttpRequest
    | DataReceived (Result Http.Error Products)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, request )


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Domain" ]
        , print model
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        SendHttpRequest ->
            ( Loading, Cmd.none )

        DataReceived result ->
            case result of
                Ok products ->
                    let
                        _ =
                            Debug.log "Ok " products
                    in
                    ( Success products, Cmd.none )

                Err error ->
                    let
                        _ =
                            Debug.log "Error " error
                    in
                    ( Failure, Cmd.none )


url : String
url =
    basepath ++ products


request : Cmd Msg
request =
    Http.get
        { url = url
        , expect = Http.expectJson DataReceived collection
        }


print : Model -> Html Msg
print model =
    case model of
        Failure ->
            div [] [ text "Failure" ]

        Loading ->
            text "Loading..."

        Success products ->
            ul [] (List.map viewProduct products)


viewProduct : Product -> Html Msg
viewProduct product =
    li [] [ text product.name ]
