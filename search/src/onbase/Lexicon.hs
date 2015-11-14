module Onbase.Lexicon (
  Lexicon, lexicon, completions
) where

import Onbase.DBTypes
import qualified Data.Map.Strict as M
import qualified Data.Set as S
import Control.Arrow ((&&&))
import qualified Data.Trie as T
import qualified Data.ByteString.Char8 as C8
import qualified Data.Char as C

completions :: Lexicon -> String -> [String]
completions l s = map C8.unpack $ T.keys subtrie
  where
    trie = T.fromList $ map (\key -> (C8.pack key, ())) $ M.keys l
    subtrie = T.submap (C8.pack s) trie

type Lexicon = M.Map String (S.Set Entity)

-- | lexicon produces a map of unigrams to the expressions they could represent.
lexicon :: [Entity] -> M.Map String (S.Set Entity)
lexicon ents = M.unionsWith S.union $ map (M.fromList . return) $ toSingletons $ keysWithValues ents
    
keyWithValue :: ([String], Entity) -> [(String, Entity)]
keyWithValue (terms, e) = map (\term -> (term, e)) terms

keysWithValues :: [Entity] -> [(String, Entity)]
keysWithValues ents = concat $ map keyWithValue $
  map (words . map C.toLower . entName &&& id) ents

toSingletons :: [(String, Entity)] -> [(String, (S.Set Entity))]
toSingletons = map (\(s, e) -> (s, S.singleton e))
