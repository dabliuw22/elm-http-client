module Adapter.Json.Products exposing
    ( collection
    , createdAtToString
    , decoder
    , encoder
    , idToString
    , nameToString
    , stockToString
    )

import Domain.Products
    exposing
        ( Product
        , ProductCreatedAt(..)
        , ProductId(..)
        , ProductName(..)
        , ProductStock(..)
        )
import Json.Decode exposing (Decoder, float, list, map, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode


idToString : ProductId -> String
idToString (ProductId id) =
    id


nameToString : ProductName -> String
nameToString (ProductName name) =
    name


stockToString : ProductStock -> String
stockToString (ProductStock stock) =
    String.fromFloat stock


createdAtToString : ProductCreatedAt -> String
createdAtToString (ProductCreatedAt createdAt) =
    createdAt


decoder : Decoder Product
decoder =
    succeed Product
        |> required "product_id" idDecoder
        |> required "product_name" nameDecoder
        |> required "product_stock" stockDecoder
        |> required "product_created_at" createdAtDecoder


collection : Decoder (List Product)
collection =
    list decoder


idDecoder : Decoder ProductId
idDecoder =
    map ProductId string


nameDecoder : Decoder ProductName
nameDecoder =
    map ProductName string


stockDecoder : Decoder ProductStock
stockDecoder =
    map ProductStock float


createdAtDecoder : Decoder ProductCreatedAt
createdAtDecoder =
    map ProductCreatedAt string


encoder : ( ProductName, ProductStock ) -> Encode.Value
encoder ( name, stock ) =
    Encode.object
        [ ( "product_name", nameEncoder name )
        , ( "product_stock", stockEncoder stock )
        ]


nameEncoder : ProductName -> Encode.Value
nameEncoder (ProductName name) =
    Encode.string name


stockEncoder : ProductStock -> Encode.Value
stockEncoder (ProductStock stock) =
    Encode.float stock
