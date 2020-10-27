module Domain.Products exposing
    ( Product
    , ProductCreatedAt(..)
    , ProductId(..)
    , ProductName(..)
    , ProductStock(..)
    )


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
