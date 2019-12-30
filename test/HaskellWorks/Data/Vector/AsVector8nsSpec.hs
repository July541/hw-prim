{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module HaskellWorks.Data.Vector.AsVector8nsSpec
  ( spec
  ) where

import HaskellWorks.Data.Vector.AsVector8
import HaskellWorks.Data.Vector.AsVector8ns
import HaskellWorks.Hspec.Hedgehog
import Hedgehog
import Test.Hspec

import qualified Data.ByteString      as BS
import qualified Data.Vector.Storable as DVS
import qualified Hedgehog.Gen         as G
import qualified Hedgehog.Range       as R

{-# ANN module ("HLint: ignore Redundant do" :: String) #-}

spec :: Spec
spec = describe "HaskellWorks.Data.Vector.AsVector8nsSpec" $ do
  it "Conversion of ByteString works 1" $ requireProperty $ do
    bss       <- forAll $ (BS.pack <$>) <$> G.list (R.linear 0 8) (G.list (R.linear 0 24) (G.word8 R.constantBounded))
    chunkSize <- forAll $ G.int (R.linear 1 4)
    mconcat (asVector8ns chunkSize [mconcat bss]) === mconcat (asVector8ns chunkSize bss)
    True === True
  it "Conversion of ByteString works 2" $ requireProperty $ do
    bss       <- forAll $ (BS.pack <$>) <$> G.list (R.linear 0 8) (G.list (R.linear 0 24) (G.word8 R.constantBounded))
    chunkSize <- forAll $ G.int (R.linear 1 4)
    let actual    = mconcat (asVector8ns chunkSize [mconcat bss])
    let expected  = mconcat (asVector8ns chunkSize bss)
    (reverse . dropWhile (== 0) . reverse) (DVS.toList actual) === (reverse . dropWhile (== 0) . reverse) (DVS.toList expected)
    True === True
  it "Conversion of ByteString works 3" $ requireProperty $ do
    bss <- forAll $ (BS.pack <$>) <$> G.list (R.linear 0 8) (G.list (R.linear 0 24) (G.word8 R.constantBounded))
    chunkSize <- forAll $ G.int (R.linear 1 4)
    let actual    = mconcat (asVector8ns chunkSize bss)
    let expected  = asVector8 (mconcat bss)
    (reverse . dropWhile (== 0) . reverse) (DVS.toList actual) === (reverse . dropWhile (== 0) . reverse) (DVS.toList expected)
    True === True
