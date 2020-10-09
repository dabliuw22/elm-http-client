module Main exposing (main)

import Adapter.Http.ListProducts as P
import Adapter.Http.Route exposing (Route(..), parseUrl)
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Html exposing (Html, text)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


type Page
    = NotFoundPage
    | ListPage P.Model


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    }


type Msg
    = ListPageMsg P.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        model =
            { route = parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            }
    in
    initCurrentPage ( model, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "Products App"
    , body = [ body model ]
    }


body : Model -> Html Msg
body model =
    case model.page of
        NotFoundPage ->
            text "Oops! The page you requested was not found!"

        ListPage pageModel ->
            P.view pageModel |> Html.map ListPageMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ListPageMsg pageMsg, ListPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    P.update pageMsg pageModel
            in
            ( { model | page = ListPage updatedPageModel }, Cmd.map ListPageMsg updatedCmd )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.navKey (Url.toString url) )

                Browser.External url ->
                    ( model, Nav.load url )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none ) |> initCurrentPage

        ( _, _ ) ->
            ( model, Cmd.none )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                NotFound ->
                    ( NotFoundPage, Cmd.none )

                Products ->
                    let
                        ( pageModel, pageCmds ) =
                            P.init
                    in
                    ( ListPage pageModel, Cmd.map ListPageMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )
