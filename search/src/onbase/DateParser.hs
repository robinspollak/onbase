module Onbase.DateParser where

import Text.Regex
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
  [ ("between (\\d{2}|\\d{4})( and |-)(\\d{2}\\d{4})", absoluteRangeConstructor)
  , ("(\\d{2}|\\d{4})\\w*-\\w*(\\d{2}|\\d{4})", absoluteRangeConstructor)
  , ("(\\d{2}|\\d{4})", absoluteYearConstructor) ]

absoluteRangeConstructor :: [String] -> Time
absoluteRangeConstructor [start, end] = Range (readYear start) (readYear end)
absoluteRangeConstructor _ = error "can't construct range"

absoluteYearConstructor :: [String] -> Time
absoluteYearConstructor [yr] = Time $ readYear yr
absoluteYearConstructor _ = error "can't construct year"

parseTimes :: String -> S.Set Time
parseTimes str = S.fromList $ catMaybes $ map (applyPattern str) absolutePatterns
  where
    applyPattern :: String -> (String, TimeConstructor) -> Maybe Time
    applyPattern s (pattern, constructor) = fmap constructor $ matchRegex (mkRegex pattern) s

type TimeConstructor = [String] -> Time
type Year = Int
data Time
  = Time Year
  | Range Year Year -- start and end
  deriving (Show, Eq, Ord)
