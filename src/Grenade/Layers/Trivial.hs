{-# LANGUAGE DataKinds             #-}
{-# LANGUAGE DeriveAnyClass        #-}
{-# LANGUAGE DeriveGeneric         #-}
{-# LANGUAGE FlexibleInstances     #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies          #-}
{-# LANGUAGE TypeOperators         #-}
{-|
Module      : Grenade.Core.Trivial
Description : Trivial layer which perfoms no operations on the data
Copyright   : (c) Huw Campbell, 2016-2017
License     : BSD2
Stability   : experimental
-}
module Grenade.Layers.Trivial (
    Trivial (..)
  ) where

import           Control.DeepSeq (NFData (..))
import           Data.Serialize
import           GHC.Generics    (Generic)

import           Grenade.Core


-- | A Trivial layer.
--
--   This can be used to pass an unchanged value up one side of a
--   graph, for a Residual network for example.
data Trivial = Trivial
  deriving (Generic,NFData,Show)

instance Serialize Trivial where
  put _ = return ()
  get = return Trivial

instance UpdateLayer Trivial where
  type Gradient Trivial = ()
  runUpdate _ _ _ = Trivial

instance RandomLayer Trivial where
  createRandomWith _ _ = return Trivial

instance (a ~ b) => Layer Trivial a b where
  type Tape Trivial a b = ()
  runForwards _ a = ((), a)
  runBackwards _ _ y = ((), y)


-------------------- GNum instances --------------------

instance GNum Trivial where
  _ |* Trivial = Trivial
  _ |+ Trivial  = Trivial
  gFromRational _ = Trivial

