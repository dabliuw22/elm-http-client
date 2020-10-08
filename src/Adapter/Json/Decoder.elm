module Adapter.Json.Decoder exposing (collection, decoder)

import Domain.Products exposing (Product)
import Json.Decode exposing (Decoder, float, list, string, succeed)
import Json.Decode.Pipeline exposing (required)


decoder : Decoder Product
decoder =
    succeed Product
        |> required "product_id" string
        |> required "product_name" string
        |> required "product_stock" float
        |> required "product_created_at" string


collection : Decoder (List Product)
collection =
    list decoder
