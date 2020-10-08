module Domain.Products exposing (Product)


type alias Product =
    { id : String
    , name : String
    , stock : Float
    , createdAt : String
    }
