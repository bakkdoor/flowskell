; tail recursion test
(define cubes
  (lambda (n)
    (rotate (* (sin (secs)) 20) (vector 1.0 0.5 (cos (* (/ (secs) (+ n 1)) 10))))
    (translate (vector 0.0 (* (sin (secs)) 1.0) 0.0))
    (color (vector (+ (/ (sin (/ n 10.0)) 2.0) 0.5) (+ (/ (cos (/ (* (sin (secs)) n) 10.0)) 2.0) 0.5) 0.2))
    (make-cube)
    (if (> n 0) (cubes (- n 1)))
  )
)
(define init
  (lambda ()
    (scale 0.05)
    (translate (vector 0.0 -1.0 0.0))
    (rotate 90.0 z-axis)
    (rotate 45.0 y-axis)
    (rotate (modulo (/ (msecs) 10) 360) x-axis)))
(define every-frame
  (lambda ()
    (init)
    (cubes 50)))