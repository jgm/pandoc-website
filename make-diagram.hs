import Text.Pandoc
import Text.Pandoc.Class
import Data.List

main = do
  putStrLn "digraph Pandoc {"
  putStrLn "rankdir=LR;"
  putStrLn "ranksep=10;"
  putStrLn "bgcolor=\"white\";"
  let rs = [r | r <- map fst (readers :: [(String, Reader PandocIO)]) , r /= "native"]
  let ws = [w | w <- map fst (writers :: [(String, Writer PandocIO)]) , w /= "native"]
  putStrLn $ "{rank=same; " ++ unwords [r ++ "reader" | r <- rs] ++ ";}"
  -- putStrLn $ "{rank=same; " ++ unwords [w ++ "writer" | w <- ws] ++ ";}"
  putStrLn $ unlines [readernode r | r <- rs]
  putStrLn $ unlines [writernode w | w <- ws]
  putStrLn $ unlines $ [unwords [r ++ "reader", "->", w ++ "writer", " [color=\"gray\"]", ";"]
                           | r <- rs, w <- ws]
  putStrLn "}"

readernode r =
  r ++ "reader [label=" ++ r ++ ", fontsize=14, width=" ++ wid ++ ", height=" ++ hgt ++ "];"

writernode r =
  r ++ "writer [label=" ++ r ++ ", fontsize=14, width=" ++ wid ++ ", height=" ++ hgt ++ "];"

wid = "2"
hgt = "1"
