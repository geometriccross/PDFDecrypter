module FilePathGetTest (createExplorerTest) where

import System.FilePath
import Test.HUnit

import FilePathGet

createExplorerTest = TestCase $ do
    explorer <- createExplorer "test"
    assertEqual "createExplorer" (Directory "test" ["FIlePathGetTest.hs"]) explorer