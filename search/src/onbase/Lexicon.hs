module Onbase.Lexicon (
  Lexicon, lexicon
) where

import Onbase.DBTypes
import qualified Data.Map.Strict as M
import qualified Data.Set as S
import Control.Arrow

type Lexicon = M.Map String (S.Set Entity)

-- | lexicon produces a map of unigrams to the expressions they could represent.
lexicon :: [Entity] -> M.Map String (S.Set Entity)
lexicon ents = M.unionsWith S.union $ map (M.fromList . return) $ toSingletons $ keysWithValues ents
    
keyWithValue :: ([String], Entity) -> [(String, Entity)]
keyWithValue (terms, e) = map (\term -> (term, e)) terms

keysWithValues :: [Entity] -> [(String, Entity)]
keysWithValues ents = concat $ map keyWithValue $ map (words . entName &&& id) ents

toSingletons :: [(String, Entity)] -> [(String, (S.Set Entity))]
toSingletons = map (\(s, e) -> (s, S.singleton e))
