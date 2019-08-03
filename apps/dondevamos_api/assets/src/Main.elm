
import Array exposing (Array, append, length, push, set, slice, toIndexedList, toList)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field)
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
    | Success String


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
  | GotFlights (Result Http.Error String)
  | NoOp


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    UpdateOrigin index origin ->
        case model of
            NoSearch searchParams ->
                (NoSearch { searchParams | origins = set index origin searchParams.origins }, Cmd.none)
            WithSearch searchParams _ ->
                (NoSearch { searchParams | origins = set index origin searchParams.origins }, Cmd.none)

    AddOrigin ->
        case model of
            NoSearch searchParams ->
                (NoSearch { searchParams | origins = push "" searchParams.origins }, Cmd.none)
            WithSearch searchParams _ ->
                (NoSearch { searchParams | origins = push "" searchParams.origins }, Cmd.none)


    RemoveOrigin index ->
        case model of
            NoSearch searchParams ->
              (NoSearch { searchParams | origins = removeFromArray searchParams.origins index }, Cmd.none)
            WithSearch searchParams _ ->
                (NoSearch { searchParams | origins = removeFromArray searchParams.origins index }, Cmd.none)

    UpdateDepartureDate newDepartureDate ->
        case model of
            NoSearch searchParams ->
                (NoSearch { searchParams | departureDate = newDepartureDate}, Cmd.none)
            WithSearch searchParams _ ->
                (NoSearch { searchParams | departureDate = newDepartureDate}, Cmd.none)


    SearchFlights ->
        case model of
            NoSearch searchParams ->
                (WithSearch searchParams Loading, getFlights searchParams)

            WithSearch searchParams _ ->
                (WithSearch searchParams Loading, getFlights searchParams)

    GotFlights result ->
        case model of
            NoSearch searchParams ->
                case result of
                    Ok url ->
                        (WithSearch searchParams (Success url), Cmd.none)
                    Err _ ->
                        (WithSearch searchParams Failure, Cmd.none)


            WithSearch searchParams _ ->
                case result of
                    Ok url ->
                        (WithSearch searchParams (Success url), Cmd.none)
                    Err _ ->
                        (WithSearch searchParams Failure, Cmd.none)



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
              [ ul []
                  ( toIndexedList searchParams.origins |> List.map
                      (\(index, l) -> li []
                          [ div [ style "display" "flex"]
                              [ viewInput "text" "Origin" l (UpdateOrigin index)
                              , button [ onClick (RemoveOrigin index) ] [ text "X" ]
                              ]
                          ]
                      )
                  )
              , button [ onClick AddOrigin ] [ text "Add origin" ]
              , viewInput "text" "Departure Date" searchParams.departureDate UpdateDepartureDate
              , button [ onClick SearchFlights ] [ text "Search flights!" ]
              ]

      WithSearch searchParams searchResult ->
          div [ class "container" ]
              [ ul []
                    ( toIndexedList searchParams.origins |> List.map
                        (\(index, l) -> li []
                            [ div [ style "display" "flex"]
                                [ viewInput "text" "Origin" l (UpdateOrigin index)
                                , button [ onClick (RemoveOrigin index) ] [ text "X" ]
                                ]
                            ]
                        )
                    )
              , button [ onClick AddOrigin ] [ text "Add origin" ]
              , viewInput "text" "Departure Date" searchParams.departureDate UpdateDepartureDate
              , button [ onClick SearchFlights ] [ text "Search flights!" ]
              , div []
                [ case searchResult of
                    Failure ->
                        text "Something went wrong!"

                    Loading ->
                        text "Loading!"

                    Success string ->
                        text string
                ]
              ]



viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []



-- HTTP

getFlights : SearchParams -> Cmd Msg
getFlights searchParams =
    Http.get
    { url = absolute [ "api", "flights" ] [] ++ getFlightsParams searchParams
    , expect = Http.expectJson GotFlights flightsDecoder}


getFlightsParams : SearchParams -> String
getFlightsParams searchParams =
    (( toList searchParams.origins ) |> List.map (\l -> Url.Builder.string "origin[]" l))
    ++ [ Url.Builder.string "departure_date" searchParams.departureDate ]
    |> toQuery


flightsDecoder : Decoder String
flightsDecoder =
    field "data" (field "yolo" Json.Decode.string)
