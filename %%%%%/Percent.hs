import qualified Graphics.UI.GLFW as K
import Graphics.Rendering.OpenGL.Raw
import Graphics.Rendering.GLU.Raw (gluPerspective)
import Control.Monad.IO.Class (liftIO)
import Control.Concurrent (threadDelay)
import Data.Bits ( (.|.) )
import System.Exit (exitWith, ExitCode(..))

import Util.Assets

initGL win = do
  glShadeModel gl_SMOOTH
  glClearColor 0 0 0 0
  (w,h) <- K.getFramebufferSize win
  resizeScene win w h

resizeScene win w h = do
  glViewport 0 0 (fromIntegral w) (fromIntegral h)
  glMatrixMode gl_PROJECTION
  glLoadIdentity
  glOrtho (-30) 30 (-30) 30 (-30) 30
  glMatrixMode gl_MODELVIEW

drawScene (x,y,s) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glTranslatef (x*s) (y*s) 0
  {-glColor3f 1.0 0.5 0.5
  glBegin gl_POLYGON
  mapM_ (\(x,y) -> glVertex3f (s*x) (s*y) 0) [(0.4,0),(0.6,0),(1,0.4),(1,0.6),
                                              (0.6,1),(0.4,1),(0,0.6),(0,0.4)]
  glEnd
  glBegin gl_QUADS
  glColor3f 1 1 1
  drawRect (s*0.2) (s*0.45) (s*0.6) (s*0.1)
  drawRect (s*0.45) (s*0.2) (s*0.1) (s*0.6)
  glEnd-}
  opener 0 0 s

shutdown :: K.Window -> IO ()
shutdown win = do
  K.destroyWindow win
  K.terminate
  _ <- exitWith ExitSuccess
  return ()

isPressed :: K.KeyState -> Bool
isPressed K.KeyState'Pressed = True
isPressed K.KeyState'Repeating = True
isPressed _ = False

getInput :: K.Window -> IO (GLfloat, GLfloat,GLfloat)
getInput win = do
  x0 <- isPressed `fmap` K.getKey win K.Key'Left
  x1 <- isPressed `fmap` K.getKey win K.Key'Right
  y0 <- isPressed `fmap` K.getKey win K.Key'Down
  y1 <- isPressed `fmap` K.getKey win K.Key'Up
  s0 <- isPressed `fmap` K.getKey win K.Key'I
  s1 <- isPressed `fmap` K.getKey win K.Key'K
  let x0n = if x0 then -1 else 0
      x1n = if x1 then 1 else 0
      y0n = if y0 then -1 else 0
      y1n = if y1 then 1 else 0
      s0n = if s0 then 0.9 else 1
      s1n = if s1 then 1.1 else 1
  return (x0n + x1n, y0n + y1n, s0n * s1n)

parseInput :: (GLfloat,GLfloat,GLfloat) -> K.Window -> IO (GLfloat,GLfloat,GLfloat)
parseInput (x,y,s) win = do
  (x',y',s') <- liftIO $ getInput win
  return (x+x'*0.5/s,y+y'*0.5/s,s*s')

--runGame win = runGame' win (0::Int)
runGame nl win = do
  nl' <- parseInput nl win
  K.pollEvents
  drawScene nl' win
  K.swapBuffers win
  runGame nl' win

main = do
  True <- K.init
  Just win <- K.createWindow 800 800 "%%%%%" Nothing Nothing
  let nl = (0,0,1)
  K.makeContextCurrent (Just win)
  K.setWindowRefreshCallback win (Just (drawScene nl))
  K.setFramebufferSizeCallback win (Just resizeScene)
  K.setWindowCloseCallback win (Just shutdown)
  initGL win
  runGame nl win

