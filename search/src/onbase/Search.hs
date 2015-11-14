{-# LANGUAGE TemplateHaskell #-}

module Onbase.Search (
  search,
  Expression(..),
  natlang'
) where

import Data.List
import Onbase.DateParser
import Onbase.Lexicon
import Data.Maybe
import Onbase.DBTypes
import qualified Data.Map.Strict as M
import qualified Data.Set as S

type Filter = Time

data Expression = Expression Entity (Maybe Filter) deriving (Show, Eq, Ord)

natlang' :: Expression -> String
natlang' (Expression ent filt) = entNatlang ++ filtNatlang
  where
    filtNatlang = case filt of
      Nothing -> ""
      Just (Time y) -> " in " ++ (show y)
      Just (Range y y') -> " between " ++ (show y) ++ " and " ++ (show y')
    entNatlang = entName ent

search :: [Entity] -> String -> [Expression]
search ents str = Expression <$> lexicalExps <*> S.toList filterCandidates
  where
    uniqueTokens = nub . words $ str
    l = lexicon ents
    uniqueCompletions = nub $ concatMap (completions l) uniqueTokens
    lexicalExps = nub $ S.toList $ S.unions $ catMaybes $
      map ((flip M.lookup) l) $ uniqueCompletions
    years = S.unions $ map parseTimes uniqueTokens
    filterCandidates
      | null years = S.singleton Nothing
      | otherwise = S.map Just years
