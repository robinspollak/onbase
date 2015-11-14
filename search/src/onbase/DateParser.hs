module Onbase.DateParser (
  Time(..),
  Year,
  parseTimes
) where

import Text.Regex.Posix
import qualified Data.Set as S
import Data.Maybe (catMaybes)

readYear :: String -> Year
readYear s@['0',_] = read $ "20" ++ s
readYear s@['1',_] = read $ "20" ++ s
readYear s@['2',_] = read $ "20" ++ s
readYear s@[_,_] = read $ "19" ++ s
readYear s
  | length s == 4 = read s
  | otherwise = error "can't read year"

absolutePatterns :: [(String, TimeConstructor)]
absolutePatterns = 
  [ ("^([[:digit:]]{2}|[[:digit:]]{4})-([[:digit:]]{2}|[[:digit:]]{4})$", absoluteRangeConstructor . concat)
  , ("^([[:digit:]]{2}|[[:digit:]]{4})$", absoluteYearConstructor . map head) ]

absoluteRangeConstructor :: [String] -> Maybe Time
absoluteRangeConstructor [_, start, end] = Just $ Range (readYear start) (readYear end)
absoluteRangeConstructor _ = Nothing

absoluteYearConstructor :: [String] -> Maybe Time
absoluteYearConstructor [yr] = Just . Time $ readYear yr
absoluteYearConstructor _ = Nothing

parseTimes :: String -> S.Set Time
parseTimes str = S.fromList $ catMaybes $ map (applyPattern str) absolutePatterns
  where
    applyPattern :: String -> (String, TimeConstructor) -> Maybe Time
    applyPattern s (pattern, constructor) = constructor $ (s =~ pattern :: [[String]])

type TimeConstructor = [[String]] -> Maybe Time
type Year = Int
data Time
  = Time Year
  | Range Year Year -- start and end
  deriving (Show, Eq, Ord)
