module Data.Aeson.TypeScript.LegalNameSpec where

import Test.Hspec
import Data.List.NonEmpty (NonEmpty (..))
import Data.Aeson.TypeScript.LegalName

tests :: Spec
tests = describe "Data.Aeson.TypeScript.LegalName" $ do
  describe "checkIllegalNameChars" $ do
    describe "legal Haskell names" $ do
      it "allows an uppercase letter" $ do
        checkIllegalNameChars ('A' :| [])
          `shouldBe` Nothing
      it "allows an underscore" $ do
        checkIllegalNameChars ('_' :| "asdf")
          `shouldBe` Nothing
      it "reports that ' is illegal" $ do
        checkIllegalNameChars ('F' :| "oo'")
          `shouldBe` Just ('\'' :| [])
    describe "illegal Haskell names" $ do
      it "allows a $" $ do
        checkIllegalNameChars ('$' :| "asdf")
          `shouldBe` Nothing
