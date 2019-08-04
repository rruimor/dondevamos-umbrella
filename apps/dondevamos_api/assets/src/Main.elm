import Array exposing (Array, append, length, push, set, slice, toIndexedList, toList)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field)
import String exposing (fromChar)
import Url.Builder exposing (absolute, toQuery)
import Date exposing (Date, day, month, weekday, year)
import DatePicker exposing (DateEvent(..), defaultSettings)



-- MAIN


main =
  Browser.element { init = init
                  , update = update
                  , subscriptions = always Sub.none
                  , view = view
                  }




-- MODEL

type alias Model =
    { searchForm: SearchForm
    , searchResults: SearchResult
    , datePicker: DatePicker.DatePicker
    }


type alias SearchForm =
    { origins: Array String
    , departureDate: Maybe Date
    }

type SearchResult
    = Halt
    | Failure
    | Loading
    | Success (List FlightResult)


init : () -> (Model, Cmd Msg)
init _ =
  let
      ( datePicker, datePickerFx ) =
          DatePicker.init
  in
  ({ searchForm = (SearchForm (Array.fromList [""]) Nothing)
   , searchResults = Halt
   , datePicker = datePicker
  }, Cmd.map ToDatePicker datePickerFx)


settings : DatePicker.Settings
settings =
    { defaultSettings
    | placeholder = "Departure date"
    , dateFormatter = Date.format "yyyy-MM-dd"
    }



-- UPDATE


type Msg
  = UpdateOrigin Int String
  | AddOrigin
  | RemoveOrigin Int
  | SearchFlights
  | GotFlights (Result Http.Error (List FlightResult))
  | NoOp
  | ToDatePicker DatePicker.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update msg ({ searchForm, searchResults, datePicker } as model) =
  case msg of
    UpdateOrigin index origin ->
        ({ model | searchForm = { searchForm | origins = set index origin searchForm.origins } }, Cmd.none)

    AddOrigin ->
        ({ model | searchForm = { searchForm | origins = push "" searchForm.origins } }, Cmd.none)

    RemoveOrigin index ->
        ({ model | searchForm = { searchForm | origins = removeFromArray searchForm.origins index } }, Cmd.none)

    SearchFlights ->
        ({ model | searchResults = Loading }, getFlights searchForm )

    GotFlights result ->
        case result of
            Ok flights ->
                ({ model | searchResults = (Success flights) }, Cmd.none)
            Err _ ->
                ({ model | searchResults = Failure }, Cmd.none)

    NoOp ->
           (model, Cmd.none)

    ToDatePicker subMsg ->
        let
            ( newDatePicker, dateEvent ) =
                DatePicker.update settings subMsg datePicker

            newDate =
                case dateEvent of
                    Picked changedDate ->
                        Just changedDate

                    _ ->
                        searchForm.departureDate
        in
        ( { model
            | searchForm = { searchForm | departureDate = newDate }
            , datePicker = newDatePicker
          }
        , Cmd.none
        )


removeFromArray : Array a -> Int -> Array a
removeFromArray array index =
    if index <= (length array) - 1 then
        append (slice 0 index array) (slice (index + 1) (length array) array)
    else
        array




-- VIEW


view : Model -> Html Msg
view model =
      div [ class "container" ]
          [ viewSearchForm model.searchForm model.datePicker
          , div
            [ style "margin-top" "20px" ]
            [ viewSearchResult model.searchResults
            ]
          ]


viewSearchForm : SearchForm -> DatePicker.DatePicker -> Html Msg
viewSearchForm searchForm datePicker =
    section []
    [ h2 [] [ text "Select origin(s)" ]
    , viewOriginsForm searchForm.origins
    , button [ onClick AddOrigin ] [ text "Add origin" ]
    , DatePicker.view searchForm.departureDate settings datePicker
                |> Html.map ToDatePicker
    , button
        [ onClick SearchFlights
        , class "full-width"
        ]
        [ text "Search flights!" ]
    ]


viewOriginsForm : Array String -> Html Msg
viewOriginsForm origins =
    div []
    ( toIndexedList origins |> List.map
          (\(index, l) ->
              div [ style "display" "flex"]
                  [ viewInput "text" "Origin" l (UpdateOrigin index)
                  , if length origins > 1 then
                        (button [ onClick (RemoveOrigin index) ] [ text "X" ])
                    else
                        (button
                            [ attribute "disabled" ""
                            , onClick (NoOp) ]
                            [ text "X"
                            ]
                        )
                  ]

          )
      )



viewSearchResult : SearchResult -> Html Msg
viewSearchResult searchResult =
    case searchResult of
        Failure ->
            div [ class "centered" ]
                [ text "Something went wrong, please retry."
                ]


        Loading ->
            div [ class "centered" ]
                [ viewLoader
                ]

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
                            , h5 []
                                 [ text ((formatPrice result.averagePrice) ++ " / person")
                                 ]
                            ]
                        ]
                    ) results)
            ]

        Halt -> text ""


formatPrice : Float -> String
formatPrice price =
    (String.fromFloat price) ++ " " ++ (fromChar (Char.fromCode 8364))


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

getFlights : SearchForm -> Cmd Msg
getFlights searchParams =
    Http.get
    { url = absolute [ "api", "flights" ] [] ++ getFlightsQueryParams searchParams
    , expect = Http.expectJson GotFlights flightsResponseDecoder
    }


getFlightsQueryParams : SearchForm -> String
getFlightsQueryParams searchParams =
    let
        departureDate =
            case searchParams.departureDate of
                Just date ->
                    Date.format "yyyy-MM-dd" date

                Nothing ->
                    ""
    in
    (( toList searchParams.origins ) |> List.map (\l -> Url.Builder.string "origin[]" l))
    ++ [ Url.Builder.string "departure_date" departureDate ]
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
