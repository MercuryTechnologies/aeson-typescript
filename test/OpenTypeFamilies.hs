{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeFamilyDependencies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -fno-warn-unused-top-binds #-}

module OpenTypeFamilies (tests) where

import Data.Aeson as A
import Data.Aeson.TypeScript.Recursive
import Data.Aeson.TypeScript.TH
import Data.Aeson.TypeScript.Types
import Data.Functor.Identity
import Data.Proxy
import Data.String.Interpolate
import qualified Data.Text as T
import Prelude hiding (Double)
import Test.Hspec
import TestBoilerplate


type family DeployEnvironment env = result | result -> env
type instance DeployEnvironment SingleNodeEnvironment = SingleDE
type instance DeployEnvironment K8SEnvironment = K8SDE
type instance DeployEnvironment T = ()
data UserT env f = User {
  _userUsername :: Columnar f T.Text
  , _userCreatedAt  :: Columnar f Int
  , _userDeployEnvironment  :: Columnar f (DeployEnvironment env)
  }
$(deriveTypeScript' A.defaultOptions ''UserT (defaultExtraTypeScriptOptions { typeFamiliesToMapToTypeScript = [''DeployEnvironment] }))

type family DeployEnvironment2 env = result | result -> env
type instance DeployEnvironment2 SingleNodeEnvironment = SingleDE
type instance DeployEnvironment2 K8SEnvironment = K8SDE
type instance DeployEnvironment2 T = ()
newtype Simple env = Simple (DeployEnvironment2 env)
$(deriveTypeScript' A.defaultOptions ''Simple (defaultExtraTypeScriptOptions { typeFamiliesToMapToTypeScript = [''DeployEnvironment2] }))

tests :: SpecWith ()
tests = describe "Open type families" $ do
  describe "simple newtype" $ do
    it [i|makes the declaration and types correctly|] $ do
      (getTypeScriptDeclarationsRecursively (Proxy :: Proxy (Simple T))) `shouldBe` ([
        TSInterfaceDeclaration "DeployEnvironment2" [] [
          TSField False "\"single_node_env\"" "\"single\""
          , TSField False "\"k8s_env\"" "\"k8s\""
          , TSField False "T" "void"
          ]
        , TSTypeAlternatives "ISimple" ["T extends keyof DeployEnvironment2"] ["DeployEnvironment2[T]"]
        , TSTypeAlternatives "Simple" ["T extends keyof DeployEnvironment2"] ["ISimple<T>"]
        ])

  describe "Complicated Beam-like user type" $ do
    it [i|makes the declaration and types correctly|] $ do
      (getTypeScriptDeclarations (Proxy :: Proxy (UserT T Identity))) `shouldBe` ([
        TSTypeAlternatives "UserT" ["T extends keyof DeployEnvironment"] ["IUser<T>"]
        , TSInterfaceDeclaration "IUser" ["T extends keyof DeployEnvironment"] [
            TSField False "_userUsername" "string"
            , TSField False "_userCreatedAt" "number"
            , TSField False "_userDeployEnvironment" "DeployEnvironment[T]"
            ]
        ])

    it [i|get the declarations recursively|] $ do
      (getTypeScriptDeclarationsRecursively (Proxy :: Proxy (UserT T Identity))) `shouldBe` ([
        TSInterfaceDeclaration "DeployEnvironment" [] [
          TSField False "\"single_node_env\"" "\"single\""
          , TSField False "\"k8s_env\"" "\"k8s\""
          , TSField False "T" "void"
          ]
        , TSInterfaceDeclaration "IUser" ["T extends keyof DeployEnvironment"] [
            TSField False "_userUsername" "string"
            , TSField False "_userCreatedAt" "number"
            , TSField False "_userDeployEnvironment" "DeployEnvironment[T]"
            ]
        , TSTypeAlternatives "UserT" ["T extends keyof DeployEnvironment"] ["IUser<T>"]
        ])

main :: IO ()
main = hspec tests
