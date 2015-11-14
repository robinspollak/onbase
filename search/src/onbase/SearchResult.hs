{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}

module Onbase.SearchResult (
  SearchResult(..),
  FilterWrapper(..),
  toResult
) where

import Onbase.DateParser
import Onbase.Search
import Data.Aeson.TH
import Data.Aeson
import Prelude hiding (filter, id)
import Onbase.DBTypes
import Data.Text as T hiding (filter)

data SearchResult = SearchResult
  { entity :: String
  , id :: String
  , natlang :: String
  , natlangSubject :: String
  , filter :: Maybe FilterWrapper
  } deriving (Show, Eq, Ord)

type FilterWrapper = Time

toResult :: Expression -> SearchResult
toResult exp@(Expression ent filt) = SearchResult
  { entity = entType ent
  , id = entID ent
  , natlang = natlang' exp
  , natlangSubject = entName ent
  , filter = filt
  }

instance ToJSON SearchResult where
  toJSON sr@(SearchResult {}) = object
    [ "entity" .= entity sr
    , "id" .= id sr
    , "natlang" .= natlang sr
    , "natlangSubject" .= natlangSubject sr
    , "filter" .= filter sr
    ]
