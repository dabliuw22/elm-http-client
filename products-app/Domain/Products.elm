module Domain.Products exposing
    ( Product
    , ProductCreatedAt(..)
    , ProductId(..)
    , ProductName(..)
    , ProductStock(..)
    , collection
    , createdAtToString
    , decoder
    , idToString
    , nameToString
    , stockToString
    )

import Json.Decode exposing (Decoder, float, list, map, string, succeed)
import Json.Decode.Pipeline exposing (required)


type alias Product =
    { id : ProductId
    , name : ProductName
    , stock : ProductStock
    , createdAt : ProductCreatedAt
    }


type ProductId
    = ProductId String


type ProductName
    = ProductName String


type ProductStock
    = ProductStock Float


type ProductCreatedAt
    = ProductCreatedAt String


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
