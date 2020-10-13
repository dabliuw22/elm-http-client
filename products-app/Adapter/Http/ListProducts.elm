module Adapter.Http.ListProducts exposing (Model, Msg(..), init, update, view)

import Adapter.Http.Api exposing (..)
import Domain.Products
    exposing
        ( Product
        , collection
        , createdAtToString
        , idToString
        , nameToString
        , stockToString
        )
import Html
    exposing
        ( Html
        , a
        , br
        , button
        , div
        , table
        , text
        , th
        , tr
        )
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
    | ProductsReceived (WebData Products)


init : ( Model, Cmd Msg )
init =
    ( { products = RemoteData.NotAsked }, fetchProducts )


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ button [ onClick FetchProducts ] [ text "Get Products" ]
            , viewProducts model
            ]
        , br [] []
        , div []
            [ a [ href "/products/new" ] [ text "New Product" ] ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchProducts ->
            ( { model | products = RemoteData.Loading }, fetchProducts )

        ProductsReceived response ->
            ( { model | products = response }, Cmd.none )


fetchProducts : Cmd Msg
fetchProducts =
    Http.get
        { url = base ++ products
        , expect = collection |> Http.expectJson (RemoteData.fromResult >> ProductsReceived)
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
        , th [] [ a [ href ("/products/" ++ id ++ "/delete") ] [ text "Delete" ] ]
        , th [] [ a [ href ("/products/" ++ id ++ "/update") ] [ text "Update" ] ]
        ]


tableHeader : Html Msg
tableHeader =
    tr []
        [ th [] [ text "id" ]
        , th [] [ text "name" ]
        , th [] [ text "stock" ]
        , th [] [ text "created" ]
        ]
