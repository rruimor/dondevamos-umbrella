
import Array exposing (Array, length, push, set, slice, toIndexedList, append)
import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)



-- MAIN


main =
  Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
  { origins: Array String
  , departureDate: String
  }


init : Model
init =
  Model (Array.fromList [""]) ""



-- UPDATE


type Msg
  = UpdateOrigin Int String
  | AddOrigin
  | RemoveOrigin Int
  | UpdateDepartureDate String
  | SearchFlights


update : Msg -> Model -> Model
update msg model =
  case msg of
    UpdateOrigin index origin ->
      { model | origins = set index origin model.origins }

    AddOrigin ->
      { model | origins = push "" model.origins }

    RemoveOrigin index ->
      { model | origins = removeFromArray model.origins index }

    UpdateDepartureDate newDepartureDate ->
      { model | departureDate = newDepartureDate }

    SearchFlights ->
      model



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
    [ ul []
        ( toIndexedList model.origins |> List.map
            (\(index, l) -> li []
                [ div [ style "display" "flex"]
                    [ viewInput "text" "Origin" l (UpdateOrigin index)
                    , button [ onClick (RemoveOrigin index) ] [ text "X" ]
                    ]
                ]
            )
        )
    , button [ onClick AddOrigin ] [ text "Add origin" ]
    , viewInput "text" "Departure Date" model.departureDate UpdateDepartureDate
    , button [ onClick SearchFlights ] [ text "Search flights!" ]
    ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []
