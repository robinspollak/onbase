module Onbase.SearchResult (
) where

import Onbase.DateParser

data SearchResult = SearchResult
  { entity :: String
  , ids :: [String]
  , natlang :: String
  , natlangSubject :: String
  , filter :: Maybe FilterWrapper
  }

data FilterWrapper = FilterWrapper
  { filterType :: String
  , value :: Time
  , filterNatlang :: String
  }
