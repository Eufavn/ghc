-- !!! readFile test

import IO

source   = "readFile001.hs"
filename = "readFile001.out"

main = do
  s <- readFile source
  h <- openFile filename WriteMode
  hPutStrLn h s
  hClose h
  s <- readFile filename

  -- This open should fail, because the readFile hasn't been forced
  -- and the file is therefore still locked.  But GHC currently has a
  -- bug in that the openFile truncates the file before checking
  -- whether it was locked or not.
  --    r <- try (openFile filename WriteMode)
  --    print r

  putStrLn s

  -- should be able to open it for writing now, because we've forced the
  -- whole file.
  h <- openFile filename WriteMode

  print h
