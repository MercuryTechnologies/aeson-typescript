
module Main where

import Test.Hspec

import qualified Formatting
import qualified Generic
import qualified HigherKind
import qualified ClosedTypeFamilies

import qualified ObjectWithSingleFieldNoTagSingleConstructors
import qualified ObjectWithSingleFieldTagSingleConstructors
import qualified TaggedObjectNoTagSingleConstructors
import qualified TaggedObjectTagSingleConstructors
import qualified TwoElemArrayNoTagSingleConstructors
import qualified TwoElemArrayTagSingleConstructors
import qualified UntaggedNoTagSingleConstructors
import qualified UntaggedTagSingleConstructors
import qualified OmitNothingFields
import qualified NoOmitNothingFields
import qualified UnwrapUnaryRecords
import qualified Data.Aeson.TypeScript.LegalNameSpec as LegalNameSpec


main :: IO ()
main = hspec $ parallel $ do
  Formatting.tests
  Generic.tests
  HigherKind.tests
  ClosedTypeFamilies.tests
  LegalNameSpec.tests

  ObjectWithSingleFieldTagSingleConstructors.tests
  ObjectWithSingleFieldNoTagSingleConstructors.tests
  TaggedObjectTagSingleConstructors.tests
  TaggedObjectNoTagSingleConstructors.tests
  TwoElemArrayTagSingleConstructors.tests
  TwoElemArrayNoTagSingleConstructors.tests
  UntaggedTagSingleConstructors.tests
  UntaggedNoTagSingleConstructors.tests
  OmitNothingFields.tests
  NoOmitNothingFields.allTests
  UnwrapUnaryRecords.allTests
