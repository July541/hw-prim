{-# LANGUAGE BangPatterns      #-}
{-# LANGUAGE FlexibleInstances #-}

module HaskellWorks.Data.FromForeignRegion
  ( FromForeignRegion(..)
  , ForeignRegion
  , mmapFromForeignRegion
  ) where

import Data.Word
import Foreign.ForeignPtr

import qualified Data.ByteString          as BS
import qualified Data.ByteString.Internal as BSI
import qualified Data.Vector.Storable     as DVS
import qualified System.IO.MMap           as IO

type ForeignRegion = (ForeignPtr Word8, Int, Int)

-- | Class for datastructures that can be created from a foreign region
class FromForeignRegion a where
  -- | Create a value of type @a from a foreign region.
  fromForeignRegion :: ForeignRegion -> a

instance FromForeignRegion BS.ByteString where
  fromForeignRegion (fptr, offset, size) = BSI.fromForeignPtr (castForeignPtr fptr) offset size

instance FromForeignRegion (DVS.Vector Word8) where
  fromForeignRegion (fptr, offset, size) = DVS.unsafeFromForeignPtr (castForeignPtr fptr) offset size

instance FromForeignRegion (DVS.Vector Word16) where
  fromForeignRegion (fptr, offset, size) = DVS.unsafeFromForeignPtr (castForeignPtr fptr) offset ((size + 1) `div` 2)

instance FromForeignRegion (DVS.Vector Word32) where
  fromForeignRegion (fptr, offset, size) = DVS.unsafeFromForeignPtr (castForeignPtr fptr) offset ((size + 3) `div` 4)

instance FromForeignRegion (DVS.Vector Word64) where
  fromForeignRegion (fptr, offset, size) = DVS.unsafeFromForeignPtr (castForeignPtr fptr) offset ((size + 7) `div` 8)

mmapFromForeignRegion :: FromForeignRegion a => FilePath -> IO a
mmapFromForeignRegion filePath = do
  region <- IO.mmapFileForeignPtr filePath IO.ReadOnly Nothing
  let !bs = fromForeignRegion region
  return bs
