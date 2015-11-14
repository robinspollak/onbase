{-# LANGUAGE OverloadedStrings #-}

module Main where

import Onbase.DB
import Onbase.Lexicon
import Onbase.Search
import Web.Scotty
import Control.Monad.IO.Class
import Control.Monad
import Data.Vector as V hiding ((++), map)
import Data.Either
import Onbase.SearchResult
import Onbase.DBTypes
import Onbase.Search
import Onbase.SearchResult
import Network.Wai.Middleware.Cors

fromRight (Right a) = a

main :: IO ()
main = do
  teams <- getAllTeams
  players <- getAllPlayers

  scotty 3000 $ do

    middleware simpleCors

    -- requires ?raw=...
    get "/v1/search" $ do
      query <- param "raw"
      let results = map toResult $ search ((V.toList . fromRight) teams ++ (V.toList . fromRight) players) query
      json results
