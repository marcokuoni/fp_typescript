add :: (Num a) => a -> a
add x = x + 1

-- >>> add 4
-- 5
y = add 1

-- >>> 1+1
-- 2
--

test :: IO ()
test = do
    x <- getLine
    forM_ [0 .. 10] $ \n -> do
        print n

test2 :: State Int ()
test2 = do
    x <- return 3
    [0 .. 10] $ \n -> do
        set n
    get

-- >>> :t forM
