module Onbase.SearchResult (
) where

data SearchResult = SearchResult
  { entity :: String
  , ids :: [String]
  , natlang :: String
  , natlangSubject :: String
  , filter :: Maybe Filter
  }

type Year = Int

data FilterWrapper = FilterWrapper
  {
  }

data Filter = 
