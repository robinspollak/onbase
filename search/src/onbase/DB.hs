module Onbase.DB where

import Onbase.DBTypes
import Data.Csv
import Data.ByteString.Lazy as L
import Data.Vector

getAllTeams :: IO (Either String (Vector Entity))
getAllTeams = do
  fileConts <- L.readFile "./data/teams.csv"
  return $ (decode NoHeader fileConts :: Either String (Vector Entity))

getAllPlayers :: IO (Either String (Vector Entity))
getAllPlayers = do
  fileConts <- L.readFile "./data/players.csv"
  return $ (decode NoHeader fileConts :: Either String (Vector Entity))
