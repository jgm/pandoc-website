{-# LANGUAGE OverloadedStrings #-}
import Text.Pandoc
import Text.Pandoc.Class
import Data.List
import qualified Data.Text.IO as TIO
import qualified Data.Text as T

main = do
  TIO.putStrLn "digraph Pandoc {"
  TIO.putStrLn "rankdir=LR;"
  TIO.putStrLn "ranksep=10;"
  TIO.putStrLn "bgcolor=\"white\";"
  let rs = [r | r <- map fst (readers :: [(T.Text, Reader PandocIO)]) , r /= "native"]
  let ws = [w | w <- map fst (writers :: [(T.Text, Writer PandocIO)]) , w /= "native"]
  TIO.putStrLn $ "{rank=same; " <> T.unwords [r <> "reader" | r <- rs] <> ";}"
  -- TIO.putStrLn $ "{rank=same; " <> T.unwords [w <> "writer" | w <- ws] <> ";}"
  TIO.putStrLn $ T.unlines [readernode r | r <- rs]
  TIO.putStrLn $ T.unlines [writernode w | w <- ws]
  TIO.putStrLn $ T.unlines $ [T.unwords [r <> "reader", "->", w <> "writer", " [color=\"gray\"]", ";"]
                           | r <- rs, w <- ws]
  TIO.putStrLn "}"

readernode r =
  r <> "reader [label=" <> r <> ", fontsize=14, width=" <> wid <> ", height=" <> hgt <> "];"

writernode r =
  r <> "writer [label=" <> r <> ", fontsize=14, width=" <> wid <> ", height=" <> hgt <> "];"

wid = "2"
hgt = "1"
