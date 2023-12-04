import FilePathGet

import Test.HUnit

pathesTest = 
    TestCase (assertEqual "pathes" ["..",".","FIlePathGetTest.hs","FilePathGet.hs",".",".."] 
        (pathes "."))

main = do
    runTestTT pathesTest