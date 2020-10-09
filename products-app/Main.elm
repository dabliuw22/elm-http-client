module Main exposing (main)

import Adapter.Http.ListProducts exposing (..)
import Browser


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }
