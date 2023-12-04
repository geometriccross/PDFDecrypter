module FilePathGet where

import System.FilePath

pathes :: FilePath -> [FilePath]
pathes path = getDirectoryContents path