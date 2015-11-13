module Core.Nodes (NodeType(..),Node(..),drawN) where

import Graphics.Rendering.OpenGL.Raw
import Util.Assets

data NodeType = Opener | Blank | Or deriving (Show,Eq)
data Node = Node { cs :: (GLfloat,GLfloat),
                   typ :: NodeType } deriving (Show,Eq)

drawN n s = case typ n of Opener -> opener (fst $ cs n) (snd $ cs n) s
                          Blank -> base (fst $ cs n) (snd $ cs n) s 1.0 0.5 0.5
                          _ -> return ()
