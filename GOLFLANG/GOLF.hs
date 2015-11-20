import qualified Graphics.UI.GLFW as K
import Graphics.Rendering.OpenGL.Raw
import Graphics.Rendering.GLU.Raw (gluPerspective)
import Control.Monad.IO.Class (liftIO)
import Control.Concurrent (threadDelay)
import Data.Bits ( (.|.) )
import System.Exit (exitWith, ExitCode(..))

import Util.Font
import Core.CodeFrame
import Core.MouseInput

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

drawScene (x,y,_) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  --glTranslatef (-x) (-y) 0
  --drawString (x,-y) "hello, world(s)." 0.25
  drawString (x*60-28,-(y*60-30)) ((show x) ++ "," ++ (show y)) 0.25

shutdown :: K.Window -> IO ()
shutdown win = do
  K.destroyWindow win
  K.terminate
  _ <- exitWith ExitSuccess
  return ()

--inChar :: String -> K.Window -> Char -> IO ()
--inChar s _ c = putStrLn (show c)

isPressed :: K.KeyState -> Bool
isPressed K.KeyState'Pressed = True
isPressed K.KeyState'Repeating = False
isPressed _ = False

{-getInput :: K.Window -> IO (GLfloat, GLfloat)
getInput win = do
  x0 <- isPressed `fmap` K.getKey win K.Key'Left
  x1 <- isPressed `fmap` K.getKey win K.Key'Right
  y0 <- isPressed `fmap` K.getKey win K.Key'Down
  y1 <- isPressed `fmap` K.getKey win K.Key'Up
  let x0n = if x0 then -1 else 0
      x1n = if x1 then 1 else 0
      y0n = if y0 then -1 else 0
      y1n = if y1 then 1 else 0
  return (x0n + x1n, y0n + y1n)-}

{-getInput :: K.Window -> CF -> IO (Mode,Bool,Bool)
getInput win cf = do
  x0 <- isPressed `fmap` K.getKey win K.Key'Tab
  y0 <- isPressed `fmap` K.getKey win K.Key'Up
  y1 <- isPressed `fmap` K.getKey win K.Key'Down
  return (if x0 then WordSelect else Neutral,y0,y1)

parseInput :: K.Window -> CF -> IO CF
parseInput win (CF m p c) = do
  (menu,u,d) <- liftIO $ getInput win (CF m p c)
  return (CF menu (if u then p+1 else if d then p-1 else p) c)-}

pressed = (==) K.MouseButtonState'Pressed

parseInput :: K.Window -> IO (GLfloat,GLfloat,Click)
parseInput win = do
  (x,y) <- minput win
  click <- K.getMouseButton win K.MouseButton'1
  rclic <- K.getMouseButton win K.MouseButton'2
  return (x,y,if pressed click then LeftC else if pressed rclic then RightC else None)

--runGame win = runGame' win (0::Int)
runGame :: CF -> K.Window -> IO ()
runGame cf win = do
  q <- parseInput win
  K.pollEvents
  drawScene q win
  K.swapBuffers win
  runGame cf win

main = do
  True <- K.init
  Just win <- K.createWindow 800 800 "őőőőő" Nothing Nothing
  let cf = CF Neutral 0 Useless
  K.makeContextCurrent (Just win)
  K.setWindowRefreshCallback win (Just (drawScene (0,0,None)))
  --K.setCharCallback win (Just (inChar ""))
  K.setFramebufferSizeCallback win (Just resizeScene)
  K.setWindowCloseCallback win (Just shutdown)
  initGL win
  runGame cf win


