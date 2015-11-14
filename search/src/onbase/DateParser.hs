{-# LANGUAGE OverloadedStrings #-}

module Onbase.DateParser (
  Time(..),
  parseTimes
) where

import Text.Regex.Posix
import qualified Data.Set as S
import Data.Maybe (catMaybes)
import Data.Aeson
import Data.Scientific

readYear :: String -> Int
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
data Time
  = Time Int
  | Range  Int Int -- start and end
  deriving (Show, Eq, Ord)

instance ToJSON Time where
  toJSON (Time yr) = Number $ scientific (toInteger yr) 0
  toJSON (Range yr yr') = object
    [ "start" .= (Number $ scientific (toInteger yr) 0)
    , "end" .= (Number $ scientific (toInteger yr') 0)
    ]
