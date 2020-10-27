module Adapter.Http.UpdateProduct exposing (Model, Msg(..), init, update, view)

import Adapter.Http.Api exposing (base, products)
import Adapter.Json.Products
    exposing
        ( decoder
        , encoder
        , idToString
        , nameToString
        , stockToString
        )
import Browser.Navigation exposing (load)
import Domain.Products
    exposing
        ( Product
        , ProductId
        , ProductName(..)
        , ProductStock(..)
        )
import Html
    exposing
        ( Html
        , a
        , br
        , button
        , div
        , form
        , h1
        , input
        , text
        )
import Html.Attributes exposing (href, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import RemoteData exposing (RemoteData, WebData)


type alias Model =
    { id : ProductId
    , name : ProductName
    , stock : ProductStock
    , product : WebData Product
    , updated : Bool
    , error : Bool
    }


type Msg
    = UpdateName ProductName
    | UpdateStock ProductStock
    | UpdateProduct
    | ValidateProduct
    | ProductReceived (WebData Product)
    | ProductUpdated (Result Http.Error String)


init : ProductId -> ( Model, Cmd Msg )
init id =
    ( { id = id
      , name = ProductName ""
      , stock = ProductStock 0
      , product = RemoteData.NotAsked
      , updated = False
      , error = False
      }
    , fetchProduct id
    )


view : Model -> Html Msg
view model =
    viewProduct model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateName name ->
            ( { model | name = name }, Cmd.none )

        UpdateStock stock ->
            ( { model | stock = stock }, Cmd.none )

        ValidateProduct ->
            if isValid model then
                update UpdateProduct model

            else
                ( model, Cmd.none )

        UpdateProduct ->
            ( model, updateProduct model.id model.name model.stock )

        ProductReceived response ->
            let
                newModel =
                    { model | product = response }
            in
            case response of
                RemoteData.Success product ->
                    ( { newModel | name = product.name, stock = product.stock }, Cmd.none )

                _ ->
                    ( newModel, Cmd.none )

        ProductUpdated response ->
            case response of
                Ok _ ->
                    ( { model | updated = True }, load "/products" )

                Err _ ->
                    ( { model | error = True }, Cmd.none )


fetchProduct : ProductId -> Cmd Msg
fetchProduct id =
    Http.get
        { url = base ++ products ++ "/" ++ idToString id
        , expect = decoder |> Http.expectJson (RemoteData.fromResult >> ProductReceived)
        }


updateProduct : ProductId -> ProductName -> ProductStock -> Cmd Msg
updateProduct id name stock =
    let
        tuple =
            ( name, stock )
    in
    Http.request
        { method = "PUT"
        , headers = []
        , url = base ++ products ++ "/" ++ idToString id
        , body = Http.jsonBody (encoder tuple)
        , expect = Http.expectString ProductUpdated
        , timeout = Nothing
        , tracker = Nothing
        }


isValid : Model -> Bool
isValid { name, stock } =
    not (String.isEmpty (nameToString name))


viewProduct : Model -> Html Msg
viewProduct model =
    case model.product of
        RemoteData.NotAsked ->
            text ""

        RemoteData.Loading ->
            text "Loading..."

        RemoteData.Failure _ ->
            div [] [ text "Failure" ]

        RemoteData.Success product ->
            div []
                [ h1 [] [ text "New Product" ]
                , viewForm model product
                , br [] []
                , div []
                    [ a [ href "/products" ] [ text "All Products" ] ]
                , br [] []
                , div []
                    [ let
                        msg =
                            if model.updated then
                                "Updated"

                            else
                                "Not Updated"
                      in
                      text msg
                    ]
                ]


viewForm : Model -> Product -> Html Msg
viewForm model _ =
    form []
        [ div []
            [ text "Name"
            , br [] []
            , input
                [ type_ "text"
                , value (nameToString model.name)
                , onInput (\name -> UpdateName (ProductName name))
                ]
                []
            ]
        , div []
            [ text "Stock"
            , br [] []
            , input
                [ type_ "number"
                , value (stockToString model.stock)
                , onInput (\stock -> UpdateStock (ProductStock (getStock stock)))
                ]
                []
            ]
        , div []
            [ button [ type_ "button", onClick ValidateProduct ]
                [ text "Submit" ]
            ]
        ]


getStock : String -> Float
getStock input =
    let
        value =
            String.toFloat input
    in
    case value of
        Just v ->
            v

        _ ->
            0
