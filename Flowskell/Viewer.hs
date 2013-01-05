import Graphics.Rendering.OpenGL hiding (Bool, Float)
import Graphics.Rendering.OpenGL.GLU (perspective)
import Control.Monad
import Control.Monad.Error
import Graphics.Rendering.GLU.Raw
import Graphics.UI.GLUT hiding (Bool, Float)

import Language.Scheme.Core
import Language.Scheme.Types
import Language.Scheme.Parser
import Language.Scheme.Variables

import Flowskell.Lib.GL (glIOPrimitives)
import Flowskell.Lib.Random (randomIOPrimitives)
import Flowskell.Lib.Time (timeIOPrimitives)

primitives :: [ ((String, String), LispVal) ]
primitives = map (\(n, f) -> (("v", n), IOFunc $ makeThrowErrorFunc f)) other
                where makeThrowErrorFunc f obj = liftIO $ f obj
                      other = timeIOPrimitives ++ glIOPrimitives ++ randomIOPrimitives

main = let light0 = Light 0 in do
  (progname, [filename]) <- getArgsAndInitialize
  source <- readFile filename
  initialDisplayMode $= [DoubleBuffered, RGBMode, WithDepthBuffer]
  createWindow progname
  ambient light0 $= Color4 0.2 0.2 0.2 1
  diffuse light0 $= Color4 1 1 1 0.6
  position light0 $= Vertex4 0 0 3 0
  lightModelAmbient $= Color4 0.2 0.2 0.2 1
  lightModelLocalViewer $= Disabled
  materialShininess Front $= 0.0
  frontFace $= CW
  lighting $= Enabled
  light light0 $= Enabled
  autoNormal $= Enabled
  normalize $= Enabled
  depthFunc $= Just Less

  env <- primitiveBindings >>= flip extendEnv primitives

  let exprs = extractValue $ readExprList $ source in do
    forM exprs $ runIOThrows . liftM show . evalLisp env
    forM exprs $ putStrLn . show
  displayCallback $= display env
  idleCallback $= Just idle
  reshapeCallback $= Just reshape
  mainLoop

reshape s@(Size w h) = do
  viewport $= ((Position 0 0), s)
  matrixMode $= Projection
  loadIdentity
  let fov = 60
      near = 0.01
      far = 100
      aspect = (fromIntegral w) / (fromIntegral h)
  perspective fov aspect near far
  translate $ Vector3 0 0 (-1::GLfloat)
  matrixMode $= Modelview 0

display env = do
  clear [ColorBuffer, DepthBuffer]
  preservingMatrix $ evalString env "(every-frame)" >>= putStr
  swapBuffers

idle = do
  postRedisplay Nothing

