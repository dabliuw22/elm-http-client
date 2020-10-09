module Adapter.Http.Route exposing (Route(..), parseUrl)

import Url exposing (Url)
import Url.Parser
    exposing
        ( Parser
        , map
        , oneOf
        , parse
        , s
        , top
        )


type Route
    = NotFound
    | Products


parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        _ ->
            NotFound


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Products top
        , map Products (s "products") -- /products
        ]
