{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE TypeOperators         #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE OverloadedStrings     #-}
{-# LANGUAGE RecordWildCards       #-}
{-# LANGUAGE MultiParamTypeClasses #-}
module Grenade.Layers.Dropout (
    Dropout (..)
  , randomDropout
  ) where

import           Control.DeepSeq
import           Control.Monad.Primitive (PrimBase, PrimState)
import           System.Random.MWC

import           GHC.Generics
import           Data.Aeson
import           Data.Serialize

import           GHC.TypeLits
import           Grenade.Core

-- Dropout layer help to reduce overfitting.
-- Idea here is that the vector is a shape of 1s and 0s, which we multiply the input by.
-- After backpropogation, we return a new matrix/vector, with different bits dropped out.
-- Double is the proportion to drop in each training iteration (like 1% or 5% would be
-- reasonable).
data Dropout = Dropout {
    dropoutRate :: Double
  , dropoutSeed :: Int
  } deriving (Generic, NFData, Show)


instance UpdateLayer Dropout where
  type Gradient Dropout = ()
  runUpdate _ x _ = x

instance RandomLayer Dropout where
  createRandomWith _ = randomDropout 0.95

randomDropout :: PrimBase m
              => Double -> Gen (PrimState m) -> m Dropout
randomDropout rate gen = Dropout rate <$> uniform gen

instance Serialize Dropout where
  put Dropout{..} = put dropoutRate >> put dropoutSeed
  get = Dropout <$> get <*> get

instance ToJSON Dropout where
  toJSON Dropout{..} =
    object [ "_type" .= String "Dropout"
           , "rate" .= dropoutRate
           , "seed" .= dropoutSeed
           ]

instance (KnownNat i) => Layer Dropout ('D1 i) ('D1 i) where
  type Tape Dropout ('D1 i) ('D1 i) = ()
  runForwards (Dropout _ _) (S1D x) = ((), S1D x)
  runBackwards (Dropout _ _) _ (S1D x) = ((),  S1D x)

-------------------- GNum instance --------------------

instance GNum Dropout where
  _ |* x = x
  _ |+ x = x
  gFromRational r = Dropout 0.95 (round r)

