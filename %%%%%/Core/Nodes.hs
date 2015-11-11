module Core.Nodes (NodeType(..),Node(..),drawN) where

import Graphics.Rendering.OpenGL.Raw
import Util.Assets

data NodeType = Opener | Or deriving (Show,Eq)
data Node = Node { cs :: (GLfloat,GLfloat),
                   typ :: NodeType } deriving (Show,Eq)

drawN n s = if typ n == Opener then opener (fst $ cs n) (snd $ cs n) s
            else return ()
