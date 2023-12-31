import System.Random
import System.IO

--The datatype Tile consist of four constructors each working as it;s own type of tile e.g. Water for water tile.
data Tile = Desert (Maybe Int) | Water | Lava | Portal deriving (Show, Eq)

--defined the type position to determine the position of the player
type Position = (Int, Int)

--the Desert type defines the list of lists Tile which contains water, lava, portal and desert
type Desert = [[Tile]]


--the createDesert functions takes 7 arguments which is generated by the player input values and like how many lava tile will be there, how many water
--tile will be there and thus creates a desert map  to start the game. The probability of desert tile will depend on the value of input values of t, w, p, l.
createDesert :: Int -> Int -> Int -> Int -> Int -> Int -> Int -> Desert
createDesert seed width height t w p l = take height $ map (take width . map createTile . randomRs (0, 100) . mkStdGen) [seed..]
  where
    createTile n
      | n < w = Water
      | n < w + p = Portal
      | n < w + p + l = Lava
      | n < w + p + l + t = Desert (Just n)
      | otherwise = Desert Nothing

--the move function takes a tuple x and y and determines the next position of the player. It uses the four buttons W,A,S and D to move
move (x,y) 'W' = (x, y-1)
move (x,y) 'A' = (x-1, y)
move (x,y) 'S' = (x, y+1)
move (x,y) 'D' = (x+1, y)
move pos _ = pos

--Defines for what tile what value will be placed on the map, e.g. for water we used W, for Lava we used L etc.
displayTile :: Tile -> String
displayTile (Desert Nothing) = "D"
displayTile (Desert (Just _)) = "D"
displayTile Water = "W"
displayTile Lava = "L"
displayTile Portal = "P"

--with the displayDesert function the desert map is dislayed
displayDesert :: Desert -> Position -> IO ()
displayDesert desert (x,y) = do
  let rows = map (map displayTile) desert
  let row = rows !! y
  let newRow = take x row ++ ["X"] ++ drop (x+1) row
  let newRows = take y rows ++ [newRow] ++ drop (y+1) rows
  mapM_ putStrLn $ map unwords newRows


--this is the main gameLoop functio for which the game works. here it takes 4 arguments where pos defines the position of the player, desert represents the main desert where the 
-- game is run. Again, water and tresure represents the remaining water and shows the tressure as well.
gameLoop :: Desert -> Position -> Int -> Int -> IO ()
gameLoop desert pos@(x,y) water treasure = do
  displayDesert desert pos
  putStrLn $ "Current position of the player: " ++ show pos
  putStrLn $ "Water remaining: " ++ show water
  putStrLn $ "Treasure: " ++ show treasure

  --the following three variables waterDistance, desertDistance and portalDistance uses the minimum function to find the player's minimum distance with the water, desert and portal tiles.
  let waterDistance = minimum [distance pos p | p <- findTiles Water]
  let desertDistance = minimum [distance pos p | p <- findTiles (Desert Nothing)]
  let portalDistance = minimum [distance pos p | p <- findTiles Portal]
  putStrLn $ "Distance to the closest water: " ++ show waterDistance
  putStrLn $ "Distance to the closest desert: " ++ show desertDistance
  putStrLn $ "Distance to the closest portal: " ++ show portalDistance
  putStr "Enter direction (WASD) or Q to quit: "
  hFlush stdout
  dir <- getChar
  putStrLn ""
  if dir == 'Q'
    then putStrLn "Exiting game."
    else do
      let newPos@(nx,ny) = move pos dir
      case desert !! ny !! nx of
        Lava -> putStrLn "You fell into the lava. Game over."
        Portal -> putStrLn "Hoooorrrayyyy! You won"
        _ -> do
          let newWater = if desert !! ny !! nx == Water then water + 1 else water - 1
          let newTreasure = case desert !! ny !! nx of
                Desert (Just t) -> treasure + t
                _ -> treasure
          if newWater <= 0
            then putStrLn "You ran out of water. Game over."
            else gameLoop desert newPos newWater newTreasure
  where

    -- The following code can be used instead of the lazy version and that will work as the memory-free version. This also does computes the difference, but it uses "let" to avoid any memory leakage
    -- distance (x1, y1) (x2, y2) = let dx = abs (x1 - x2) 
      --                               dy = abs (y1 - y2)
        --                              in dx + dy


    --this is the lazy version. It only computes the difference and gets the value
    distance (a,b) (c,d) = abs (a-c) + abs (b-d)
    


    findTiles tile = [(x,y) | x <- [0..width-1], y <- [0..height-1], desert !! y !! x == tile]
    width = length (head desert)
    height = length desert


  

--this function is called to start the game. It takes many input parameters like the number of tresure, number of lava, water capacity in the game. It further calls the gameLoop function
-- to further play the game 
startGame :: IO ()
startGame = do
  --this defines the rows and columns of the game map
  putStr "Enter line of sight: "
  hFlush stdout
  s <- readLn
  --the user can define how much water can the player hold
  putStr "Enter the number for the maximum water capacity the explorer can carry: "
  hFlush stdout
  m <- readLn
  putStr "Enter the initial seed to randomly generate the map:"
  hFlush stdout
  g <- readLn
  --the user can determine the number of treasures in the game
  putStr "Enter the number of treasures you want in the game: "
  hFlush stdout
  t <- readLn
    --the user can determine the number of water Tile in the game
  putStr "Enter the amount of water you want in the game: "
  hFlush stdout
  w <- readLn
    --the user can determine the number of portals in the game
  putStr "Enter how many portals you want in the game: "
  hFlush stdout
  p <- readLn
   --the user can determine the number of lava tile in the game
  putStr "Enter the amount of lava in the game: "
  hFlush stdout
  l <- readLn
  if w + p + l >100 then do 
    putStrLn"Invalid parameters. Exiting game."
    else do 
        let desert = createDesert g s s t w p l 
        let initialWater = m 
        let initialTreasure =0 
        gameLoop desert (0,0) initialWater initialTreasure

        

-- Mishkat Haider Chowdhury
-- ID# 0594966