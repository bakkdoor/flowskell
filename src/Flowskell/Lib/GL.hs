module Flowskell.Lib.GL where
import Graphics.Rendering.OpenGL hiding (Bool, Float)
import Control.Monad
import Control.Monad.Error
import Graphics.Rendering.GLU.Raw
import Graphics.Rendering.OpenGL.Raw.ARB.Compatibility (glPushMatrix, glPopMatrix)
import Graphics.UI.GLUT hiding (Bool, Float)
import Data.Time.Clock
import Data.Time.Calendar
import Data.Array

import Language.Scheme.Types

intToGLfloat :: Float -> GLfloat
intToGLfloat x = realToFrac x
togl = intToGLfloat . realToFrac

makeTeapot [] = do
    renderObject Solid (Teapot 1)
    return (Bool True)

doIdentity [] = loadIdentity >> return (Bool True)
doPush [] = glPushMatrix >> return (Bool True)
doPop [] = glPopMatrix >> return (Bool True)

doColor :: [LispVal] -> IO LispVal
doColor [Vector v] =
    let [Float r, Float g, Float b] = elems v in do
    setColor (realToFrac r) (realToFrac g) (realToFrac b)
    return (Bool True)

doTranslate :: [LispVal] -> IO LispVal
doTranslate [Vector v] =
    let [Float x, Float y, Float z] = elems v in do
    translate $ Vector3 (togl x) (togl y) (togl z)
    return (Bool True)

doScale :: [LispVal] -> IO LispVal
doScale [Float r] = do
    scale (togl r) (togl r) (togl r)
    return (Bool True)
doScale [Float x, Float y, Float z] = do
    scale (togl x) (togl y) (togl z)
    return (Bool True)

doRotate :: [LispVal] -> IO LispVal
doRotate [Float a, Vector v] = do
    let [Float x, Float y, Float z] = elems v in do
    rotate (togl a) $ Vector3 (togl x) (togl y) (togl z)
    return (Bool True)

n :: [Normal3 GLfloat]
n = [(Normal3 (-1.0) 0.0 0.0),
     (Normal3 0.0 1.0 0.0),
     (Normal3 1.0 0.0 0.0),
     (Normal3 0.0 (-1.0) 0.0),
     (Normal3 0.0 0.0 1.0),
     (Normal3 0.0 0.0 (-1.0))]

faces :: [[Vertex3 GLfloat]]
faces = [[(v 0), (v 1), (v 2), (v 3)],
         [(v 3), (v 2), (v 6), (v 7)],
         [(v 7), (v 6), (v 5), (v 4)],
         [(v 4), (v 5), (v 1), (v 0)],
         [(v 5), (v 6), (v 2), (v 1)],
         [(v 7), (v 4), (v 0), (v 3)]]

v :: Int -> Vertex3 GLfloat
v x = Vertex3 v0 v1 v2
    where v0
              | x == 0 || x == 1 || x == 2 || x == 3 = -1
              | x == 4 || x == 5 || x == 6 || x == 7 = 1
          v1
              | x == 0 || x == 1 || x == 4 || x == 5 = -1
              | x == 2 || x == 3 || x == 6 || x == 7 = 1
          v2
              | x == 0 || x == 3 || x == 4 || x == 7 = 1
              | x == 1 || x == 2 || x == 5 || x == 6 = -1

setColor r g b = do
    let c = (Color4 r g b 1 :: Color4 GLfloat)
    color (Color3 r g b :: Color3 GLfloat)
    materialDiffuse Front $= c
    materialAmbient Front $= c
    materialSpecular Front $= c

makeGrid :: [LispVal] -> IO LispVal
makeGrid [] = do
    setColor 1 1 1
    lineWidth $= 0.5
    mapM (\c -> do
        renderPrimitive Lines $ do
            vertex $ (Vertex3 (-c) (-1)  0 :: Vertex3 GLfloat)
            vertex $ (Vertex3 (-c)   1   0 :: Vertex3 GLfloat)
            vertex $ (Vertex3 ( c) (-1)  0 :: Vertex3 GLfloat)
            vertex $ (Vertex3 ( c)   1   0 :: Vertex3 GLfloat)
            vertex $ (Vertex3 (-1) (-c)  0 :: Vertex3 GLfloat)
            vertex $ (Vertex3   1  (-c)  0 :: Vertex3 GLfloat)
            vertex $ (Vertex3 (-1) ( c)  0 :: Vertex3 GLfloat)
            vertex $ (Vertex3   1  ( c)  0 :: Vertex3 GLfloat)
            ) [0,0.25,0.5,0.75]
    lineWidth $= 2.0
    renderPrimitive LineLoop $ do
        vertex $ (Vertex3 (-1) (-1)  0 :: Vertex3 GLfloat)
        vertex $ (Vertex3 (-1)   1   0 :: Vertex3 GLfloat)
        vertex $ (Vertex3   1    1   0 :: Vertex3 GLfloat)
        vertex $ (Vertex3   1  (-1)  0 :: Vertex3 GLfloat)
    setColor 1 0 0
    lineWidth $= 4.0
    mapM (\(x,y,z) -> do
        setColor x y z
        renderPrimitive Lines $ do
            vertex $ (Vertex3 0 0 0 :: Vertex3 GLfloat)
            vertex $ (Vertex3 x y z :: Vertex3 GLfloat)
            ) [(1,0,0),(0,1,0),(0,0,1)]
    return $ Bool True

makeCube :: [LispVal] -> IO LispVal
makeCube [] = let nfaces = zip n faces
          in do mapM (\(n, [v0, v1, v2, v3]) -> do
                        renderPrimitive Quads $ do
                          normal n
                          vertex v0
                          vertex v1
                          vertex v2
                          vertex v3) nfaces
                return $ Bool True

glIOPrimitives = [
                   ("make-cube", makeCube),
                   ("make-grid", makeGrid),
                   ("make-teapot", makeTeapot),

                   ("color", doColor),
                   ("scale", doScale),
                   ("translate", doTranslate),
                   ("rotate", doRotate),
                   ("identity", doIdentity),
                   ("push", doPush),
                   ("pop", doPop)
                 ]
