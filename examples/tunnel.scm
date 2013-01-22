; tail recursion test
(define cubes
  (lambda (n frac)
    (translate (vector 0.0 1.0 0.0))
    (color (hsv (* (- (+ n frac) (secs)) 25.0) 1.0 (/ n 60.0)))
    (push)
        (scale 0.5)
        (draw-cube)
    (pop)
    (push)
        (translate (vector 1.0 0.0 0.5))
        (rotate 45.0 (vector 0.0 1.0 0.0))
        (scale 0.5)
        (draw-cube)
    (pop)
    (push)
        (translate (vector -1.0 0.0 0.5))
        (rotate -45.0 (vector 0.0 1.0 0.0))
        (scale 0.5)
        (draw-cube)
    (pop)
    (if (> n 0) (cubes (- n 1) frac))
  )
)
(define init
  (lambda ()
    (scale 0.65)
    (translate (vector 0.0 -1.0 0.0))
    (rotate -80.0 x-axis)))
(define every-frame
  (lambda ()
    (init)
    (translate (vector 0.0 -1.0 0.0))
    (translate (vector 0.0 (- 0 (% (secs) 1.0)) 0.0))
    (cubes 30 (% (secs) 1.0))))