module Onbase.DBTypes (
  Entity(..),
  entType,
  entName,
  entID,
  entities
) where

data Entity
  = Player { playerID :: String , nameFirst :: String , nameLast :: String }
  | Team { teamID :: String, teamName :: String }
  deriving (Eq, Ord)

instance Show Entity where
  show p@(Player {}) = "<player: " ++ playerID p ++ ">"
  show t@(Team {}) = "<team: " ++ teamID t ++ ">"

entType :: Entity -> String
entType (Player {}) = "player"
entType (Team {}) = "team"

entID :: Entity -> String
entID p@(Player {}) = playerID p
entID t@(Team {}) = teamID t

entName :: Entity -> String
entName p@(Player {}) = nameFirst p ++ " " ++ nameLast p
entName t@(Team {}) = teamName t

-- | Example list of entities.
entities :: [Entity]
entities =
  [ Player { playerID = "arod", nameFirst = "Alex", nameLast = "Rodriguez" }
  , Team { teamName = "New York Yankees", teamID = "nya" }
  ]
