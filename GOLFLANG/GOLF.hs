import qualified Graphics.UI.GLFW as K
import Graphics.Rendering.OpenGL.Raw
import Graphics.Rendering.GLU.Raw (gluPerspective)
import Control.Monad.IO.Class (liftIO)
import Control.Concurrent (threadDelay)
import Data.Bits ( (.|.) )
import System.Exit (exitWith, ExitCode(..))

import Util.Font
import Util.Shapes
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

drawScene (x,y,_) (CF Neutral p c) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glColor3f 0.8 0.8 0.8
  rect (-28) (-28) 58 10
  rect (-28) (-17) 28.5 47
  rect 1.5 (-17) 28.5 47
  glColor3f 0.9 0.9 0.9
  rect (-27) (-16) 15.5 10
  rect (-10.5) (-16) 10 10
  glColor3f 0.4 0.4 0.4
  rect (-27) (-5) 26.5 14
  glColor3f 1 1 1
  --drawCode c
  drawString (x*60-28,-(y*60-30)) ((show $ x) ++ "," ++ (show $ y)) 0.25

drawScene (_,_,_) (CF WordSelect _ _) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glColor3f 0.4 0 0.4
  rect (-30) (-30) 61 61
  --cover (0,0,20,20) (0.7,0.7,0.7) 0.1
  glColor3f 0 0 0
  drawString (-27,29.75) "add" 0.25

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

pressed = (==) K.MouseButtonState'Pressed

parseInput :: K.Window -> IO (GLfloat,GLfloat,Click)
parseInput win = do
  (x,y) <- minput win
  click <- K.getMouseButton win K.MouseButton'1
  rclic <- K.getMouseButton win K.MouseButton'2
  return (x,y,if pressed click then LeftC else if pressed rclic then RightC else None)

useInput :: CF -> (GLfloat,GLfloat,Click) -> CF
useInput (CF m p c) (x,y,cl) =
  CF m p c

--runGame win = runGame' win (0::Int)
runGame :: CF -> K.Window -> IO ()
runGame cf win = do
  q <- parseInput win
  let cf' = useInput cf q
  K.pollEvents
  drawScene q cf' win
  K.swapBuffers win
  runGame cf' win

main = do
  True <- K.init
  Just win <- K.createWindow 800 800 "őőőőő" Nothing Nothing
  let cf = CF Neutral 0 Useless
  K.makeContextCurrent (Just win)
  K.setWindowRefreshCallback win (Just (drawScene (0,0,None) cf))
  --K.setCharCallback win (Just (inChar ""))
  K.setFramebufferSizeCallback win (Just resizeScene)
  K.setWindowCloseCallback win (Just shutdown)
  initGL win
  runGame cf win


