import qualified Graphics.UI.GLFW as K
import Graphics.Rendering.OpenGL.Raw
import Graphics.Rendering.GLU.Raw (gluPerspective)
import Control.Monad.IO.Class (liftIO)
import Control.Concurrent (threadDelay)
import Data.Bits ( (.|.) )
import System.Exit (exitWith, ExitCode(..))

import Util.Font

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

drawScene (x,y) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glTranslatef (-x) (-y) 0
  glColor3f 1.0 0.5 0.5
  glBegin gl_POLYGON
  mapM_ (\(x,y) -> glVertex3f (x) (y) 0) [(0.4,0),(0.6,0),(1,0.4),(1,0.6),
                                          (0.6,1),(0.4,1),(0,0.6),(0,0.4)]
  glEnd
  --switchPath (0,0) DownLeft 5

  --drawLetter (0,0) 'a' 5
  --drawLetter (25,0) 'b' 5
  --drawLetter (40,0) 'c' 5
  drawString (0,0) "hello, world(s)." 0.25

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

getInput :: K.Window -> IO (GLfloat, GLfloat)
getInput win = do
  x0 <- isPressed `fmap` K.getKey win K.Key'Left
  x1 <- isPressed `fmap` K.getKey win K.Key'Right
  y0 <- isPressed `fmap` K.getKey win K.Key'Down
  y1 <- isPressed `fmap` K.getKey win K.Key'Up
  let x0n = if x0 then -1 else 0
      x1n = if x1 then 1 else 0
      y0n = if y0 then -1 else 0
      y1n = if y1 then 1 else 0
  return (x0n + x1n, y0n + y1n)

parseInput :: (GLfloat,GLfloat) -> K.Window -> IO (GLfloat,GLfloat)
parseInput (x,y) win = do
  (x',y') <- liftIO $ getInput win
  return (x+x'*0.5,y+y'*0.5)

--runGame win = runGame' win (0::Int)
runGame nl win = do
  nl' <- parseInput nl win
  K.pollEvents
  drawScene nl' win
  K.swapBuffers win
  runGame nl' win

main = do
  True <- K.init
  Just win <- K.createWindow 800 800 "őőőőő" Nothing Nothing
  let nl = (0,0)
  K.makeContextCurrent (Just win)
  K.setWindowRefreshCallback win (Just (drawScene nl))
  K.setFramebufferSizeCallback win (Just resizeScene)
  K.setWindowCloseCallback win (Just shutdown)
  initGL win
  runGame nl win


