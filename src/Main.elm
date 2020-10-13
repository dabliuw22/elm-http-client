module Main exposing (main)

import Adapter.Http.CreateProduct as C
import Adapter.Http.DeleteProduct as D
import Adapter.Http.ListProducts as L
import Adapter.Http.OneProduct as O
import Adapter.Http.Route exposing (Route(..), parseUrl)
import Adapter.Http.UpdateProduct as U
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Nav
import Domain.Products exposing (ProductId(..))
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
    | ListPage L.Model
    | OnePage O.Model
    | FormPage C.Model
    | DeletePage D.Model
    | UpdatePage U.Model


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    }


type Msg
    = ListPageMsg L.Msg
    | OnePageMsg O.Msg
    | FormPageMsg C.Msg
    | DeletePageMsg D.Msg
    | UpdatePageMsg U.Msg
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
            L.view pageModel |> Html.map ListPageMsg

        OnePage pageModel ->
            O.view pageModel |> Html.map OnePageMsg

        FormPage pageModel ->
            C.view pageModel |> Html.map FormPageMsg

        DeletePage pageModel ->
            D.view pageModel |> Html.map DeletePageMsg

        UpdatePage pageModel ->
            U.view pageModel |> Html.map UpdatePageMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( ListPageMsg pageMsg, ListPage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    L.update pageMsg pageModel
            in
            ( { model | page = ListPage updatedPageModel }, Cmd.map ListPageMsg updatedCmd )

        ( OnePageMsg pageMsg, OnePage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    O.update pageMsg pageModel
            in
            ( { model | page = OnePage updatedPageModel }, Cmd.map OnePageMsg updatedCmd )

        ( FormPageMsg pageMsg, FormPage pageMadel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    C.update pageMsg pageMadel
            in
            ( { model | page = FormPage updatedPageModel }, Cmd.map FormPageMsg updatedCmd )

        ( DeletePageMsg pageMsg, DeletePage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    D.update pageMsg pageModel
            in
            ( { model | page = DeletePage updatedPageModel }, Cmd.map DeletePageMsg updatedCmd )

        ( UpdatePageMsg pageMsg, UpdatePage pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    U.update pageMsg pageModel
            in
            ( { model | page = UpdatePage updatedPageModel }, Cmd.map UpdatePageMsg updatedCmd )

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
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage

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
                            L.init
                    in
                    ( ListPage pageModel, Cmd.map ListPageMsg pageCmds )

                Product id ->
                    let
                        ( pageModel, pageCmds ) =
                            O.init (ProductId id)
                    in
                    ( OnePage pageModel, Cmd.map OnePageMsg pageCmds )

                NewProduct ->
                    let
                        ( pageModel, pageCmds ) =
                            C.init
                    in
                    ( FormPage pageModel, Cmd.map FormPageMsg pageCmds )

                DeleteProduct id ->
                    let
                        ( pageModel, pageCmds ) =
                            D.init (ProductId id)
                    in
                    ( DeletePage pageModel, Cmd.map DeletePageMsg pageCmds )

                UpdateProduct id ->
                    let
                        ( pageModel, pageCmds ) =
                            U.init (ProductId id)
                    in
                    ( UpdatePage pageModel, Cmd.map UpdatePageMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )
