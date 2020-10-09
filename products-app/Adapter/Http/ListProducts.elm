module Adapter.Http.ListProducts exposing (Model, Msg, init, update, view)

import Domain.Products
    exposing
        ( Product
        , collection
        , createdAtToString
        , idToString
        , nameToString
        , stockToString
        )
import Html exposing (Html, a, button, div, table, text, th, tr)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Http


type alias Products =
    List Product


type Model
    = Failure
    | Loading
    | Success Products


type Msg
    = FetchProducts
    | ProductReceived (Result Http.Error Products)


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, fetchProducts )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick FetchProducts ] [ text "Refresh Products" ]
        , viewProducts model
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchProducts ->
            ( Loading, fetchProducts )

        ProductReceived response ->
            case response of
                Ok products ->
                    ( Success products, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )


fetchProducts : Cmd Msg
fetchProducts =
    Http.get
        { url = "http://localhost:8080/products"
        , expect = collection |> Http.expectJson ProductReceived
        }


viewProducts : Model -> Html Msg
viewProducts model =
    case model of
        Failure ->
            div [] [ text "Failure" ]

        Loading ->
            text "Loading..."

        Success products ->
            table [] ([ tableHeader ] ++ List.map viewProduct products)


viewProduct : Product -> Html Msg
viewProduct product =
    let
        id =
            idToString product.id
    in
    tr []
        [ th [] [ a [ href ("http://localhost:8000/" ++ id) ] [ text id ] ]
        , th [] [ text (nameToString product.name) ]
        , th [] [ text (stockToString product.stock) ]
        , th [] [ text (createdAtToString product.createdAt) ]
        ]


tableHeader : Html Msg
tableHeader =
    tr []
        [ th [] [ text "id" ]
        , th [] [ text "name" ]
        , th [] [ text "stock" ]
        , th [] [ text "created" ]
        ]
