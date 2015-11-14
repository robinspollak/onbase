module Onbase.Search (
) where

import Data.List
import Onbase.DateParser
import Onbase.Lexicon
import Data.Maybe
import Onbase.DBTypes
import qualified Data.Map.Strict as M
import qualified Data.Set as S

data Expression = Expression Entity (Maybe Filter) deriving (Show, Eq, Ord)

type Filter = Time

{-search :: String -> [Entity] -> [Expression]-}
search str ents = Expression <$> lexicalExps <*> filterCandidates
  where
    uniqueTokens = nub . words $ str
    l = lexicon ents
    uniqueCompletions = nub $ concatMap (completions l) uniqueTokens
    lexicalExps = nub $ S.toList $ S.unions $ catMaybes $
      map ((flip M.lookup) l) $ uniqueCompletions
    years = parseTimes str
    filterCandidates = S.toList $
      S.singleton Nothing `S.union` (S.map Just years)
