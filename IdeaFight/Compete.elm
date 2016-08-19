module IdeaFight.Compete exposing (Model, Msg, init, update, subscriptions, view)

import IdeaFight.PartialForest as Forest
import IdeaFight.Shuffle as Shuffle

import Html.App as App
import Html exposing (Html, br, button, div, li, text, ul)
import Html.Events exposing (onClick)

import Random
import String

type Model = Uninitialized | Initialized (Forest.Forest String)
type Msg = ShuffledContents (List String) | Choice String

init : String -> (Model, Cmd Msg)
init contents =
  let lines = String.lines contents
  in (Uninitialized, Random.generate ShuffledContents <| Shuffle.shuffle lines)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case model of
    Uninitialized ->
      case msg of
        ShuffledContents contents -> (Initialized <| Forest.fromList contents, Cmd.none)
        _ -> Debug.crash "Somehow you got a non-initialization message on an uninitialized state"
    Initialized forest ->
      case msg of
        Choice choice -> (Initialized <| Forest.choose forest choice, Cmd.none)
        _ -> Debug.crash "Somehow you got an initialization message on an initialized state"

subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none

chooser : Forest.Forest String -> Html Msg
chooser forest =
  case Forest.getNextPair forest of
    Just (lhs, rhs) -> div [] [
      text "Which of these ideas do you like better?",
      br [] [],
      button [onClick <| Choice lhs] [text lhs],
      button [onClick <| Choice rhs] [text rhs]
    ]
    Nothing -> text "The forest is totally ordered!"

topValuesSoFar : Forest.Forest String -> Html Msg
topValuesSoFar forest =
  let topValues = Forest.topN forest
  in ul [] <| List.map (\value -> li [] [ text value ]) topValues

view : Model -> Html Msg
view model =
  case model of
    Uninitialized -> text ""
    Initialized forest ->
      div [] [
        chooser forest,
        br [] [],
        topValuesSoFar forest
      ]
