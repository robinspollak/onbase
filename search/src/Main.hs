module Main where

main :: IO ()
main = putStrLn "hello, world"

data Filter
  = Year Int
  | Years Int Int -- start and end
  deriving (Show, Eq, Ord)
