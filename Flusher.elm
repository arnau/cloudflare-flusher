port module Flusher exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Attributes.Aria exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decoder exposing ((:=), Decoder)
import Json.Encode as Encoder
import String
import Task exposing (..)

import Gear exposing (gear)


main : Program (Maybe Model)
main =
  App.programWithFlags
    { init = init
    , view = view
    , update = updateWithStorage
    , subscriptions = \_ -> Sub.none
    }

port setStorage : Model -> Cmd msg

{-|
  We want to `setStorage` on every update. This function adds the setStorage
  command for every step of the update function.
-}
updateWithStorage : Msg -> Model -> (Model, Cmd Msg)
updateWithStorage msg model =
  let
    (newModel, cmds) =
      update msg model
  in
    ( newModel
    , Cmd.batch [ setStorage newModel, cmds ]
    )




-- MODEL

type alias Model =
  { result : String
  , success : Maybe Bool
  , version : String
  , zoneIdentifier : String
  , email : String
  , token : String
  , urls : List String
  , isSettingsActive : Bool
  }

emptyModel : Model
emptyModel =
  { result = ""
  , success = Nothing
  , isSettingsActive = True
  , version = "v0.1.0"
  , email = ""
  , token = ""
  , zoneIdentifier = ""
  , urls = []
  }


init : Maybe Model -> (Model, Cmd Msg)
init model' =
  (Maybe.withDefault emptyModel model' |> resetModel, Cmd.none)

-- Reset state from last time
resetModel : Model -> Model
resetModel model =
  { model
  | result = ""
  , success = Nothing
  }

-- UPDATE

type Msg
    = NoOp
    | FlushCache
    | ChangeUrl String
    | ChangeIdentifier String
    | ChangeEmail String
    | ChangeToken String
    | FlushSucceed FlushResponse
    | FlushFail Http.Error
    | ToggleSettings

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NoOp ->
      (model, Cmd.none)

    ChangeUrl url ->
      ({ model
       | urls = [url]
       , success = Nothing
       }, Cmd.none)

    ChangeIdentifier identifier ->
      ({ model
       | zoneIdentifier = identifier
       , success = Nothing
       }, Cmd.none)

    ChangeEmail email ->
      ({ model
       | email = email
       , success = Nothing
       }, Cmd.none)

    ChangeToken token ->
      ({ model
       | token = token
       , success = Nothing
       }, Cmd.none)

    FlushCache ->
      (model, flushCache model)

    FlushSucceed res ->
      if res.success then
        ({ model
         | success = Just True
         }, Cmd.none)
      else
        ({ model
         | success = Just False
         , result = toString res.errors
         }, Cmd.none)

    FlushFail err ->
      ({ model
       | success = Just False
       , result = handleError err
       }, Cmd.none)

    ToggleSettings ->
      ({ model
       | isSettingsActive = not model.isSettingsActive
       }, Cmd.none)


handleError err =
  case err of
    Http.Timeout ->
      "Timeout"

    Http.NetworkError ->
      "Network error"

    Http.UnexpectedPayload txt ->
      txt

    Http.BadResponse code txt ->
      (toString code) ++ " " ++ txt


flushCache : Model -> Cmd Msg
flushCache model =
  -- Cmd.none
  httpDelete model
    |> Task.perform FlushFail FlushSucceed


httpDelete : Model -> Task.Task Http.Error FlushResponse
httpDelete model =
  Http.send Http.defaultSettings
            { verb = "DELETE"
            , url = ("https://api.cloudflare.com/client/v4/zones/" ++ model.zoneIdentifier ++ "/purge_cache")
            , body = payloadEncoder model.urls
            , headers = [ ("Content-Type", "application/json")
                        , ("X-Auth-Email", model.email)
                        , ("X-Auth-Key", model.token)
                        ]
            }
            |> Http.fromJson flushResponseDecoder


type alias FlushResponse =
  { success : Bool
  , errors : List FlushError
  }

type alias FlushError =
  { code : Int
  , message : String
  }

flushResponseDecoder : Decoder FlushResponse
flushResponseDecoder =
  Decoder.object2 FlushResponse
                  ("success" := Decoder.bool)
                  ("errors" := (Decoder.list flushErrorDecoder))

flushErrorDecoder : Decoder FlushError
flushErrorDecoder =
  Decoder.object2 FlushError
                  ("code" := Decoder.int)
                  ("message" := Decoder.string)


payloadEncoder urls =
  Encoder.object [ ("files", Encoder.list (List.map Encoder.string urls)) ]
    |> Encoder.encode 0
    |> Http.string


-- VIEW

view : Model -> Html Msg
view model =
  div [ class "wrapper" ]
      [ div []
            [ button [ class "settings-trigger"
                     , onClick ToggleSettings
                     , ariaChecked (toString model.isSettingsActive)
                     ]
                     [ gear "settings-icon" ]
            ]
      , viewPage model
      ]

viewPage model =
  if model.isSettingsActive then
    viewSettings model
  else
    viewApp model

viewSettings model =
  div [ class "settings" ]
      [ p [ class "version" ] [ text model.version ]
      , p []
          [ label [ for "identifier" ] [ text "Zone identifier:" ]
          , input [ id "identifier"
                  , required True
                  , value model.zoneIdentifier
                  , onInput ChangeIdentifier
                  ] []
          ]
      , p []
          [ label [ for "email" ] [ text "Email:" ]
          , input [ id "email"
                  , required True
                  , value model.email
                  , onInput ChangeEmail
                  ] []
          ]
      , p []
          [ label [ for "token" ] [ text "Token:" ]
          , input [ id "token"
                  , required True
                  , value model.token
                  , onInput ChangeToken
                  ] []
          ]
      , p [ class "note" ]
          [ span [] [ text "This app lets you flush your Cloud Flare cache as described in "
                    , a [ href "https://api.cloudflare.com/#zone-purge-individual-files-by-url-and-cache-tags" ]
                        [ text "https://api.cloudflare.com/#zone-purge-individual-files-by-url-and-cache-tags" ]
                    ]
          ]
      ]



viewApp model =
  div [ class "app" ]
      [ input [ id "url"
              , type' "url"
              , onInput ChangeUrl
              , required True
              , value (viewUrl model.urls)
              ] []
      , button [ class (statusClass model.success)
               , onClick FlushCache
               ]
               [ text "Flush" ]
      , p []
          [ text model.result ]
      ]

statusClass status =
  case status of
    Nothing ->
      "flushit ready"

    Just success ->
      if success then
        "flushit success"
      else
        "flushit error"

viewUrl urls =
  List.head urls
    |> Maybe.withDefault ""
