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

degrade :: GLfloat
degrade = 0.005

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

drawScene (x,y,_) (CF (Neutral False) p c) (Course (Ball (bx,by) v t _ 0 fn) st par cse) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glTranslatef (-bx) (-by) 0
  let x' = atan $ abs $ (1-y-0.5)/(x-0.5)
      --y' = asin $ (y-0.5)*2
  glColor3f 0.7 0 0.7
  glBegin gl_LINES
  glVertex3f 0 0 0
  glVertex3f ((if x-0.5<0 then negate else abs) (cos x')*50)
             ((if 1-y-0.5<0 then negate else abs) (sin x')*50) 0
  glEnd
  glColor3f 1 1 1
  ball bx by 0.5
  --drawCode c
  drawString (x*60-28,-(y*60-30)) ((show $ x) ++ "," ++ (show $ y)) 0.25
  drawString (-28+bx,-20+by) ("theta: " ++ (show t)) 0.25

drawScene _ (CF (Neutral True) _ _) (Course (Ball (bx,by) v t _ h _) st par cse) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glTranslatef (-bx) (-by) 0
  glColor3f 1 1 1
  ball bx by (h*0.01+0.5)
  drawString (-28+bx,-28+by) ("height: " ++ (show h)) 0.25
  drawString (-28+bx,-26+by) ("y: " ++ (show by)) 0.25
  drawString (-28+bx,-24+by) ("x: " ++ (show bx)) 0.25
  drawString (-28+bx,-22+by) ("v: " ++ (show v)) 0.25
  drawString (-28+bx,-20+by) ("theta: " ++ (show t)) 0.25

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

angle :: (GLfloat,GLfloat) -> GLfloat
angle (x,y) =
  {-(if x-0.5<0 then ((+) (pi/2)) else ret) . (if 1-y-0.5<0 then ((+) (pi/2)) else ret)-}
  (if x<0&&y<0 then ((+) pi) else if x<0 then ((+) pi)
   else if y<0 then ((+) (2*pi)) else ret)
  $ atan $ y/x
  where ret = (\x -> x)

pressed = (==) K.MouseButtonState'Pressed

parseInput :: K.Window -> IO (GLfloat,GLfloat,Click)
parseInput win = do
  (x,y) <- minput win
  click <- K.getMouseButton win K.MouseButton'1
  rclic <- K.getMouseButton win K.MouseButton'2
  return (x,y,if pressed click then LeftC else if pressed rclic then RightC else None)

useInput :: CF -> (GLfloat,GLfloat,Click) -> CF
useInput (CF m p c) (x,y,cl) =
  CF (if cl == LeftC then Neutral True else m) p c

integrity :: Course -> CF -> CF
integrity (Course (Ball _ 0 _ _ 0 _) _ _ _) (CF (Neutral True) p c) = CF (Neutral False) p c
integrity _ cf = cf

updateCourse :: CF -> Course -> Course
updateCourse (CF (Neutral True) _ _) (Course (Ball (x,y) v t ty 0.0 fn) st par cse) =
  Course (Ball (x+v*cos ty*cos t,y+v*cos ty*sin t) (let q = v-degrade in if q<0 then 0 else q)
               t ty 0 fn) st par cse
updateCourse (CF (Neutral True) _ _) (Course (Ball (x,y) v t ty h fn) st par cse) =
  Course (Ball (x+v*cos ty*cos t,y+v*cos ty*sin t) v t (ty-degrade)
         (let q = h+sin ty in if q<0 then 0 else q) fn)
         st par cse
updateCourse (CF (Neutral False) _ _) c = c

genBall :: CF -> (GLfloat,GLfloat,Click) -> Course -> Course
genBall (CF (Neutral False) _ _) (x,y,LeftC) (Course (Ball p v _ ty h fn) st par cse) =
  Course (Ball p 0.1 (angle (x-0.5,1-y-0.5)) (pi/4) (h+0.1*sin (pi/4)) fn) st par cse
genBall _ _ co = co

--runGame win = runGame' win (0::Int)
runGame :: CF -> Course -> K.Window -> IO ()
runGame cf co win = do
  q <- parseInput win
  let cf' = {-integrity co $ useInput cf q-} useInput (integrity co cf) q
      co' = updateCourse cf' $ genBall cf q co
  K.pollEvents
  drawScene q cf' co' win
  K.swapBuffers win
  runGame cf' co' win

main = do
  True <- K.init
  Just win <- K.createWindow 800 800 "őőőőő" Nothing Nothing
  let cf = CF (Neutral False) 0 Useless
      co = Course (Ball (0,0) 0.1 0 (pi/4) 0 (\x -> x)) 1 3 (Board 0 0 [])
  K.makeContextCurrent (Just win)
  K.setWindowRefreshCallback win (Just (drawScene (0,0,None) cf co))
  --K.setCharCallback win (Just (inChar ""))
  K.setFramebufferSizeCallback win (Just resizeScene)
  K.setWindowCloseCallback win (Just shutdown)
  initGL win
  runGame cf co win


