module Adapter.Http.DeleteProduct exposing (Model, Msg(..), init, update, view)

import Adapter.Http.Api exposing (base, products)
import Domain.Products exposing (Product, ProductId(..), idToString)
import Html exposing (Html, a, br, div, text)
import Html.Attributes exposing (href)
import Http


type alias Model =
    { id : ProductId
    , deleted : Bool
    , error : Bool
    }


type Msg
    = ProductDeleted (Result Http.Error String)


init : ProductId -> ( Model, Cmd Msg )
init id =
    ( { id = id
      , deleted = False
      , error = False
      }
    , deleteProduct id
    )


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ let
                msg =
                    if model.deleted then
                        "Deleted"

                    else
                        "Not Deleted"
              in
              text msg
            ]
        , br [] []
        , div []
            [ a [ href "/products" ] [ text "All Products" ] ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ProductDeleted (Ok _) ->
            ( { model | deleted = True }, Cmd.none )

        ProductDeleted (Err _) ->
            ( { model | error = True }, Cmd.none )


deleteProduct : ProductId -> Cmd Msg
deleteProduct id =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = base ++ products ++ "/" ++ idToString id
        , body = Http.emptyBody
        , expect = Http.expectString ProductDeleted
        , timeout = Nothing
        , tracker = Nothing
        }
