import qualified Graphics.UI.GLFW as K
import Graphics.Rendering.OpenGL.Raw
import Graphics.Rendering.GLU.Raw (gluPerspective)
import Control.Monad.IO.Class (liftIO)
import Control.Concurrent (threadDelay)
import Data.Bits ( (.|.) )
import System.Exit (exitWith, ExitCode(..))
import System.Random

import Util.Font
import Util.Shapes
import Core.CodeFrame
import Core.MouseInput
import Core.Physics

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

drawScene (x,y,_) (CF (Neutral) p c) (Course (Ball (bx,by) v t 0) st par cse) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  let x' = atan $ abs $ (1-y-0.5)/(x-0.5)
      --y' = asin $ (y-0.5)*2
  glColor3f 0.7 0 0.7
  glBegin gl_LINES
  glVertex3f 0 0 0
  glVertex3f ((if x-0.5<0 then negate else abs) (cos x')*50)
             ((if 1-y-0.5<0 then negate else abs) (sin x')*50) 0
  glColor3f 1 1 1
  --drawCode c
  drawString (x*60-28,-(y*60-30)) ((show $ x) ++ "," ++ (show $ y)) 0.25

drawScene (_,_,_) (CF (WordSelect) _ _) _ _ = do
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
runGame :: CF -> Course -> K.Window -> IO ()
runGame cf co win = do
  q <- parseInput win
  let cf' = useInput cf q
  K.pollEvents
  drawScene q cf' co win
  K.swapBuffers win
  runGame cf' co win

main = do
  True <- K.init
  Just win <- K.createWindow 800 800 "őőőőő" Nothing Nothing
  let cf = CF (Neutral) 0 Useless
      co = Course (Ball (0,0) 10 0 0) 1 3 []
  K.makeContextCurrent (Just win)
  K.setWindowRefreshCallback win (Just (drawScene (0,0,None) cf co))
  --K.setCharCallback win (Just (inChar ""))
  K.setFramebufferSizeCallback win (Just resizeScene)
  K.setWindowCloseCallback win (Just shutdown)
  initGL win
  runGame cf co win


