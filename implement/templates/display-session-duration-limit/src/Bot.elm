{- This app demonstrates how to use the session time limit.
   Some bots should consider the remaining time in the current session when choosing the next activity.
   This template demonstrates how to get the remaining time in the current session.
-}
{-
   bot-catalog-tags:template,demo-interface-to-host
-}


module Bot exposing
    ( State
    , initState
    , processEvent
    )

import BotEngine.Interface_To_Host_20190808 as InterfaceToHost


type alias State =
    { timeInMilliseconds : Int
    , sessionTimeLimitInMilliseconds : Maybe Int
    }


initState : State
initState =
    { timeInMilliseconds = 0, sessionTimeLimitInMilliseconds = Nothing }


processEvent : InterfaceToHost.BotEvent -> State -> ( State, InterfaceToHost.BotResponse )
processEvent event stateBefore =
    let
        state =
            stateBefore |> integrateEvent event
    in
    ( state
    , InterfaceToHost.ContinueSession
        { statusDescriptionText = state |> statusMessageFromState
        , startTasks = []
        , notifyWhenArrivedAtTime = Just { timeInMilliseconds = state.timeInMilliseconds + 1000 }
        }
    )


integrateEvent : InterfaceToHost.BotEvent -> State -> State
integrateEvent event stateBefore =
    case event of
        InterfaceToHost.ArrivedAtTime { timeInMilliseconds } ->
            { stateBefore | timeInMilliseconds = timeInMilliseconds }

        InterfaceToHost.SetBotConfiguration _ ->
            stateBefore

        InterfaceToHost.CompletedTask _ ->
            stateBefore

        InterfaceToHost.SetSessionTimeLimit { timeInMilliseconds } ->
            { stateBefore | sessionTimeLimitInMilliseconds = Just timeInMilliseconds }


statusMessageFromState : State -> String
statusMessageFromState state =
    case state.sessionTimeLimitInMilliseconds of
        Nothing ->
            "I did not yet receive information about a session time limit."

        Just sessionTimeLimitInMilliseconds ->
            let
                remainingTotalSeconds =
                    (sessionTimeLimitInMilliseconds - state.timeInMilliseconds) // 1000

                remainingTotalMinutes =
                    (sessionTimeLimitInMilliseconds - state.timeInMilliseconds) // 1000 // 60

                remainingSecondsInMinute =
                    remainingTotalSeconds - remainingTotalMinutes * 60
            in
            "This session ends in "
                ++ (remainingTotalMinutes |> String.fromInt)
                ++ " minutes and "
                ++ (remainingSecondsInMinute |> String.fromInt)
                ++ " seconds."
