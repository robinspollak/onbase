module Onbase.SearchResult (
) where

import Onbase.DateParser

data SearchResult = SearchResult
  { entity :: String
  , ids :: [String]
  , natlang :: String
  , natlangSubject :: String
  , filter :: Maybe FilterWrapper
  } deriving (Show, Eq, Ord)

data FilterWrapper = FilterWrapper
  { filterType :: String
  , value :: Time
  , filterNatlang :: String
  } deriving (Show, Eq, Ord)
