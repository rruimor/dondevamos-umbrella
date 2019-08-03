import Array exposing (Array, append, length, push, set, slice, toIndexedList, toList)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field)
import String exposing (fromChar)
import Url.Builder exposing (absolute, toQuery)



-- MAIN


main =
  Browser.element { init = init
                  , update = update
                  , subscriptions = always Sub.none
                  , view = view
                  }




-- MODEL

type Model
    = NoSearch SearchParams
    | WithSearch SearchParams SearchResult


type alias SearchParams =
    { origins: Array String
    , departureDate: String
    }

type SearchResult
    = Failure
    | Loading
    | Success (List FlightResult)


init : () -> (Model, Cmd Msg)
init _ =
  (NoSearch (SearchParams (Array.fromList [""]) ""), Cmd.none)




-- UPDATE


type Msg
  = UpdateOrigin Int String
  | AddOrigin
  | RemoveOrigin Int
  | UpdateDepartureDate String
  | SearchFlights
  | GotFlights (Result Http.Error (List FlightResult))
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  let
    formParams =
        case model of
            NoSearch searchParams ->
                searchParams

            WithSearch searchParams _ ->
                searchParams

  in
  case msg of
    UpdateOrigin index origin ->
        (NoSearch { formParams | origins = set index origin formParams.origins }, Cmd.none)

    AddOrigin ->
        (NoSearch { formParams | origins = push "" formParams.origins }, Cmd.none)

    RemoveOrigin index ->
        (NoSearch { formParams | origins = removeFromArray formParams.origins index }, Cmd.none)

    UpdateDepartureDate newDepartureDate ->
        (NoSearch { formParams | departureDate = newDepartureDate}, Cmd.none)

    SearchFlights ->
        (WithSearch formParams Loading, getFlights formParams)

    GotFlights result ->
        case result of
            Ok flights ->
                (WithSearch formParams (Success flights), Cmd.none)
            Err _ ->
                (WithSearch formParams Failure, Cmd.none)

    NoOp ->
           (model, Cmd.none)


removeFromArray : Array a -> Int -> Array a
removeFromArray array index =
    if index <= (length array) - 1 then
        append (slice 0 index array) (slice (index + 1) (length array) array)
    else
        array




-- VIEW


view : Model -> Html Msg
view model =
  case model of
      NoSearch searchParams ->
          div [ class "container" ]
              [ viewSearchForm searchParams
              ]

      WithSearch searchParams searchResult ->
          div [ class "container" ]
              [ viewSearchForm searchParams
              , div [ style "margin-top" "20px" ]
                [ viewSearchResult searchResult
                ]
              ]


viewSearchForm : SearchParams -> Html Msg
viewSearchForm searchParams =
    section []
    [ h2 [] [ text "Select origin(s)" ]
    , ul []
      ( toIndexedList searchParams.origins |> List.map
          (\(index, l) -> li []
              [ div [ style "display" "flex"]
                  [ viewInput "text" "Origin" l (UpdateOrigin index)
                  , if length searchParams.origins > 1 then
                        (button [ onClick (RemoveOrigin index) ] [ text "X" ])
                    else
                        (button
                            [ attribute "disabled" ""
                            , onClick (NoOp) ]
                            [ text "X"
                            ]
                        )
                  ]
              ]
          )
      )
    , button [ onClick AddOrigin ] [ text "Add origin" ]
    , viewInput "text" "Departure Date" searchParams.departureDate UpdateDepartureDate
    , button
        [ onClick SearchFlights
        , class "full-width"
        ]
        [ text "Search flights!" ]
    ]


viewSearchResult : SearchResult -> Html Msg
viewSearchResult searchResult =
    case searchResult of
        Failure ->
            p []
              [ text "Something went wrong, please retry"
              , span
                [ onClick SearchFlights
                , class "retry-icon"
                ]
                [ text (" " ++ fromChar (Char.fromCode 8635)) ]
              ]

        Loading ->
            viewLoader

        Success results ->
            div []
            [ h2 [] [ text "Found combined flights" ]
            , ul []
                (List.map
                    (\result -> li []
                        [ div
                            [ class "flight-result"
                            ]
                            [ h5 [] [ text result.destination ]
                            , h5 [] [ text ((String.fromFloat result.averagePrice) ++ " " ++ (fromChar (Char.fromCode 8364)) ++ " / person") ]
                            ]
                        ]
                    ) results)
            ]



viewLoader : Html msg
viewLoader =
    div [ class "lds-roller" ]
        [ div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        , div [] []
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, name p, placeholder p, value v, onInput toMsg ] []



-- HTTP

getFlights : SearchParams -> Cmd Msg
getFlights searchParams =
    Http.get
    { url = absolute [ "api", "flights" ] [] ++ getFlightsParams searchParams
    , expect = Http.expectJson GotFlights flightsResponseDecoder
    }


getFlightsParams : SearchParams -> String
getFlightsParams searchParams =
    (( toList searchParams.origins ) |> List.map (\l -> Url.Builder.string "origin[]" l))
    ++ [ Url.Builder.string "departure_date" searchParams.departureDate ]
    |> toQuery


flightsResponseDecoder : Decoder (List FlightResult)
flightsResponseDecoder =
    field "data" (Json.Decode.list flightDecoder)

type alias FlightResult =
    { destination: String
    , totalPrice: Float
    , averagePrice: Float
    }

flightDecoder : Decoder FlightResult
flightDecoder =
    Json.Decode.map3
        FlightResult
            ( field "destination" Json.Decode.string )
            ( field "total_price" Json.Decode.float )
            ( field "average_price" Json.Decode.float )
