module Adapter.Http.ListProducts exposing (Model, Msg(..), init, update, view)

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
import RemoteData exposing (RemoteData, WebData)


type alias Products =
    List Product


type alias Model =
    { products : WebData Products
    }


type Msg
    = FetchProducts
    | ProductReceived (WebData Products)


init : ( Model, Cmd Msg )
init =
    ( { products = RemoteData.NotAsked }, fetchProducts )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick FetchProducts ] [ text "Get Products" ]
        , viewProducts model
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchProducts ->
            ( { model | products = RemoteData.Loading }, fetchProducts )

        ProductReceived response ->
            ( { model | products = response }, Cmd.none )


fetchProducts : Cmd Msg
fetchProducts =
    Http.get
        { url = "http://localhost:8080/products"
        , expect = collection |> Http.expectJson (RemoteData.fromResult >> ProductReceived)
        }


viewProducts : Model -> Html Msg
viewProducts model =
    case model.products of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Failure error ->
            div [] [ text "Failure" ]

        RemoteData.Success products ->
            table [] ([ tableHeader ] ++ List.map viewProduct products)


viewProduct : Product -> Html Msg
viewProduct product =
    let
        id =
            idToString product.id
    in
    tr []
        [ th [] [ a [ href ("/products/" ++ id) ] [ text id ] ]
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
