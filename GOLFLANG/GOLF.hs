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

stddev :: GLfloat
stddev = 10
curve x = -- from -30 to 30
  exp ((-(x)^2)/(2*stddev^2))/(stddev*sqrt(2*pi))
graph = map (((*) 30) . curve) [-30..30]

fns :: [(GLfloat -> GLfloat)]
fns = [sin,cos,(** 2),(* 2),(/ 2),sqrt]

cond :: [(Bool,a)] -> a
cond [(q,x)] = x
cond ((q,x):qs) = if q then x else cond qs

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

drawScene (x,y,_) (CF (Neutral False) p c) (Course (Ball _ (bx,by) v t _ 0 _ fn) st par cse) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glTranslatef (-bx) (-by) 0
  glColor3f 0.3 0 0.3
  rect (-12) (-12) 5 5
  let x' = angle (x-0.5,1-y-0.5)
      --y' = asin $ (y-0.5)*2
  glColor3f 0.7 0 0.7
  glBegin gl_LINES
  glVertex3f bx by 0
  glVertex3f (bx+(cos x')*50) (by+(sin x')*50) 0
  glEnd
  button (bx-28.5) (by-29) 19 5 "velocity" 0.3 (0.6,0.0,0.8)
  button (bx-9) (by-29) 19 5 "z-axis theta" 0.3 (0.6,0.0,0.8)
  button (bx+10.5) (by-29) 19 5 "f(x) =" 0.3 (0.6,0.0,0.8)
  glColor3f 1 1 1
  ball bx by 0.5
  drawString (x*60-28,-(y*60-30)) ((show $ x) ++ "," ++ (show $ y)) 0.25
  drawString (-28+bx,-22.5+by) ("stroke: " ++ (show st)) 0.25
  drawString (-28+bx,-20.5+by) ("par: " ++ (show par)) 0.25

drawScene _ (CF (Neutral True) _ _) (Course (Ball _ (bx,by) v t _ h _ _) st par cse) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glTranslatef (-bx) (-by) 0
  glColor3f 0.3 0 0.3
  rect (-12) (-12) 5 5
  rect (-208) (-208) 5 5
  glColor3f 1 1 1
  ball bx by (h*0.01+0.5)
  drawString (-28+bx,-28+by) ("height: " ++ (show h)) 0.25
  drawString (-28+bx,-26+by) ("y: " ++ (show by)) 0.25
  drawString (-28+bx,-24+by) ("x: " ++ (show bx)) 0.25
  drawString (-28+bx,-22+by) ("v: " ++ (show v)) 0.25
  drawString (-28+bx,-20+by) ("theta: " ++ (show t)) 0.25

drawScene _ (CF (VelSel n b) _ _) (Course (Ball _ _ v _ _ _ _ _) _ _ _) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glColor3f 0 0.6 0.6
  glBegin gl_POLYGON
  mapM_ (\(x,y) -> glVertex3f (x+1) (y*30-22) 0) (zip [-30..30] graph)
  glEnd
  glColor3f 1 1 1
  drawString (-28,-22.5) ("velocity: " ++ (show (if b then (graph!!n) else v))) 0.25
  drawString (-28,-20.5) ("max: " ++ (show $ graph!!29)) 0.25
  button (-9) (-29) 19 5 "stop" 0.3 (0.6,0.0,0.8)
  button 10.5 (-29) 19 5 "back" 0.3 (0.6,0.0,0.8)
  glColor3f 0.6 0.6 0
  glBegin gl_LINES
  glVertex3f ((fromIntegral n)-29) (-22) 0
  glVertex3f ((fromIntegral n)-29) 30 0
  glEnd

drawScene (x,y,_) (CF (TZSel _) _ _) (Course (Ball _ _ _ _ ty _ _ _) _ _ _) _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  glColor3f 0.3 0 0.3
  rect (-12) (-12) 5 5
  let x' = angle (x-0.5,1-y-0.5)
      --y' = asin $ (y-0.5)*2
  glColor3f 0 0.7 0.7
  glBegin gl_LINES
  glVertex3f 0 0 0
  glVertex3f ((cos x')*50) ((sin x')*50) 0
  glColor3f 0.7 0.7 0.0
  glVertex3f 0 0 0
  glVertex3f ((cos ty)*50) ((sin ty)*50) 0
  glEnd
  button 10.5 (-29) 19 5 "back" 0.3 (0.6,0.0,0.8)

drawScene _ (CF (Transit _) _ _) _ _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity

drawScene _ (CF (WordSelect) _ _) _ _ = do
  glClear $ fromIntegral $ gl_COLOR_BUFFER_BIT .|. gl_DEPTH_BUFFER_BIT
  glLoadIdentity
  glTranslatef (-1.0675) (-0.625) 0
  mapM_ (\(y,k) -> button (-29) y 20 5 k 0.3 (0.6,0.0,0.8))
        $ zip [25,20..(-5)] ["sin","cos","square","double","halve","sqrt"]

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
useInput (CF (Neutral False) p c) (x,y,cl) =
  CF (if cl == LeftC then if inHB (x,y) (Hitbox 0 0.917 0.33 0.083) then VelSel 0 False
                          else if inHB (x,y) (Hitbox 0.33 0.917 0.33 0.083) then TZSel 0
                          else if inHB (x,y) (Hitbox 0.67 0.917 0.33 0.083) then WordSelect else Neutral True else Neutral False) p c
useInput (CF (VelSel n b) p c) (x,y,cl) =
  CF (if cl == LeftC then if inHB (x,y) (Hitbox 0.33 0.917 0.33 0.083) then VelSel n True
                          else if inHB (x,y) (Hitbox 0.67 0.917 0.33 0.083) then Transit False else VelSel n b else VelSel n b)
  p c
useInput (CF (TZSel t) p c) (x,y,LeftC) = if inHB (x,y) (Hitbox 0.67 0.917 0.33 0.083)
                                          then CF (Transit False) p c else CF (TZSel t) p c
useInput (CF (WordSelect) p c) (x,y,LeftC) = if inHB (x,y) (Hitbox 0 0 0.33 0.583) then CF (Transit False) p c else CF (WordSelect) p c
useInput (CF (Transit b) p c) (_,_,None) = CF (Neutral b) p c
useInput cf _ = cf

integrity :: Course -> CF -> CF
integrity (Course (Ball _ _ 0 _ _ 0 _ _) _ _ _) (CF (Neutral True) p c) = CF (Neutral False) p c
integrity _ (CF (VelSel n False) p c) = CF (VelSel (mod (n+1) 60) False) p c
integrity _ cf = cf

updateCourse :: CF -> Course -> Course
updateCourse (CF (Neutral True) _ _) (Course (Ball p0 (x,y) v t ty 0.0 _ fn) st par cse) =
  Course (Ball p0 (x+v*cos ty*cos t,y+v*cos ty*sin t) (let q = v-degrade in if q<0 then 0 else q)
               t ty 0 0 fn) st par cse
updateCourse (CF (Neutral True) _ _) (Course (Ball (x0,y0) (x,y) v t ty h ti fn) st par cse) =
  Course (Ball (x0,y0) (x0+fn (ti/15)*sin t*cos ty+v*cos ty*cos t,y0-fn (ti/15)*cos t*cos ty+v*cos ty*sin t) v t ty
         (let q = h+sin (ty-degrade*ti) in if q<0 then 0 else q) (ti+1) fn)
         st par cse
updateCourse (CF (VelSel n True) _ _) (Course (Ball p0 (x,y) _ t ty _ ti fn) st par cse) =
  Course (Ball p0 (x,y) (graph!!n) t ty 0 ti fn) st par cse
updateCourse _ c = c

genBall :: CF -> (GLfloat,GLfloat,Click) -> Course -> Course
genBall (CF (Neutral False) _ _) (x,y,LeftC) (Course (Ball p0 p v _ ty h _ fn) st par cse) =
  Course (Ball p0 p v (angle (x-0.5,1-y-0.5)) ty (h+v*sin ty) 1 fn) (st+1) par cse
genBall (CF (Neutral True) _ _) _ (Course (Ball _ p 0 t ty 0 ti fn) st par cse) =
  Course (Ball p p 0 t ty 0 ti fn) st par cse
genBall (CF (TZSel _) _ _) (x,y,LeftC) (Course (Ball p0 p v t ty _ ti fn) st par cse) =
  if inHB (x,y) (Hitbox 0.67 0.917 0.33 0.083) then Course (Ball p0 p v t ty 0 ti fn) st par cse
  else Course (Ball p0 p v t (angle (x-0.5,1-y-0.5)) 0 ti fn) st par cse
genBall (CF (WordSelect) _ _) (x,y,LeftC) (Course (Ball p0 p v t ty _ ti fn) st par cse) =
  -- .583
  if inHB (x,y) (Hitbox 0 0 0.33 0.583)
  then Course (Ball p0 p v t ty 0 ti
        (cond [(y<0.097, sin . fn),
               (y<0.197, cos . fn),
               (y<0.292, (** 2) . fn),
               (y<0.389, (* 2) . fn),
               (y<0.486, (/ 2) . fn),
               (y<0.583, sqrt . fn)])) st par cse
  else Course (Ball p0 p v t ty 0 ti fn) st par cse
genBall _ _ co = co

debugCF (CF x _ _) = x
debugCo (Course (Ball _ _ _ _ _ _ _ fn) _ _ _) = fn

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
  let cf = CF (Neutral False) 0 X
      co = Course (Ball (0,0) (0,0) 0.1 0 (pi/4) 0 1 id) 0 3 (Board 0 0 [])
  K.makeContextCurrent (Just win)
  K.setWindowRefreshCallback win (Just (drawScene (0,0,None) cf co))
  --K.setCharCallback win (Just (inChar ""))
  K.setFramebufferSizeCallback win (Just resizeScene)
  K.setWindowCloseCallback win (Just shutdown)
  initGL win
  runGame cf co win


