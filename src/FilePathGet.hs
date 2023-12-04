module FilePathGet 
    ( createExplorer
    ) where

import System.FilePath
import System.Directory

data Explorer a = 
    File a | 
    Directory a [a] deriving (Eq, Show)

createExplorer :: FilePath -> Explorer FilePath
createExplorer path = 1