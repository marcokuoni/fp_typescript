module Main where

x :: Int
x = 3

-- Trying to "reassign" x
x = 4

main :: IO ()
main = print x
