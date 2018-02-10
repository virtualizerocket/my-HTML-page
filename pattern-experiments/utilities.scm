
;; utilties.scm
;; to put some tools here, so that I don't have to define them enywhere

;; the atom predicate, I don't understand why this is not given by default

(define (atom? p)
  (and (not (pair? p))
       (not (null? p))))

;; the shows utility, used for debugging

(define (shows . s)
  (cond ((null? s) (newline))
        (else (display (car s))
              (display #\tab)
              (apply shows (cdr s)))))

;; function compose tool

(define (compose f g . s)
  (if (null? s)
      (lambda (x) (f (g x)))
      (lambda (x)
        (f ((apply compose (cons g s)) x)))))

(define (take n ls)
  (if (= n 0)
      '()
      (cons (car ls)
            (take (- n 1) (cdr ls)))))
