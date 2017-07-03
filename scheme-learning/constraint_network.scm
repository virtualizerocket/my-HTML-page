#lang r5rs

;; (load "memorize.scm")

(define (empty-value? v)
  (eq? v 'empty-value))

(define (make-connector)
  (let ((value 'empty-value)
        (contraints '()))
    (define (add-contraint! c)
      (set! contraints
            (cons c (contraints))))
    (define (set-value! new-value)
      (cond
        ((equal? value new-value) 'done)
        ((or (empty?) (avalible-all? contraints))
         (set! value new-value)
         (for-each
          (lambda (c)
            (update c))
          contraints))
        (else 'failed)))
    (define (get-value)
      value)
    (define (empty?)
      (eq? 'empty-value value))
    (define (forget-value!)
      (set! value 'empty-value))
    (define (dispatch m)
      (cond
        ((eq? m 'add-contraint!) add-contraint!)
        ((eq? m 'set-value!) set-value!)
        ((eq? m 'get-value) get-value)
        ((eq? m 'empty-connector?) empty?)
        ((eq? m 'forget-value!) forget-value!)
        (else (error "unknown message" m))))
    dispatch))

(define (add-contraint! c connector)
  ((connector 'add-contraint!) c))

(define (set-value! v connector)
  ((connector 'set-value!) v))

(define (get-value connector)
  ((connector 'get-value)))

(define (empty-connector? connector)
  ((connector 'empty-connector?)))

(define (has-value? connector)
  (not ((connector 'empty-connector?))))

(define (forget-value! connector)
  ((connector 'forget-value!)))


(define (avalible-all? contraints)
  (cond
    ((null? contraints) #t)
    ((avalible? (car contraints))
     (avalible-all? (cdr contraints)))
    (else #f)))

(define (multiplier a1 a2 product)
  (define (avalible?)
    (or (empty-connector? a1)
        (empty-connector? a2)
        (empty-connector? product)))
  (define (update)
    (cond
      ((empty-connector? a1)
       (if (and (has-value? a2)
                (has-value? product))
           (set-value! (/ (get-value product)
                          (get-value a2)))))
      ((empty-connector? a2)
       (if (and (has-value? a1)
                (has-value? product))
           (set-value! (/ (get-value product)
                          (get-value a1)))))
      ((empty-connector? product)
       (if (and (has-value? a1)
                (has-value? a2))
           (set-value! (* (get-value a1)
                          (get-value a2)))))
      (else
       (error "something wrong"))))
  (define (dispatch m)
    (cond
      ((eq? m 'avalible?) avalible?)
      ((eq? m 'update) update)
      (else (error "unknown message" m))))
  (add-contraint! dispatch a1)
  (add-contraint! dispatch a2)
  (add-contraint! dispatch product))

(define (adder a1 a2 summary)
  (define (avalible?)
    (or (empty-connector? a1)
        (empty-connector? a2)
        (empty-connector? summary)))
  (define (update)
    (cond
      ((empty-connector? a1)
       (if (and (has-value? a2)
                (has-value? summary))
           (set-value! (- (get-value summary)
                          (get-value a2)))))
      ((empty-connector? a2)
       (if (and (has-value? a1)
                (has-value? summary))
           (set-value! (- (get-value summary)
                          (get-value a1)))))
      ((empty-connector? summary)
       (if (and (has-value? a1)
                (has-value? a2))
           (set-value! (+ (get-value a1)
                          (get-value a2)))))
      (else
       (error "something wrong"))))
  (define (dispatch m)
    (cond
      ((eq? m 'avalible?) avalible?)
      ((eq? m 'update) update)
      (else (error "unknown message" m))))
  (add-contraint! dispatch a1)
  (add-contraint! dispatch a2)
  (add-contraint! dispatch summary))

(define (constant c connector)
  (define (avalible?)
    #f)
  (define (update)
    'done)
  (define (dispatch m)
    (cond
      ((eq? m 'avalible?) avalible?)
      ((eq? m 'update) update)
      (else (error "unknown message" m))))
  (set-value! c connector)
  (add-contraint! dispatch connector))

(define (avalible? thing)
  ((thing 'avalible)))

(define (update thing)
  ((thing 'update)))

(define error
  (lambda s
    (display "Error:")
    (newline)
    (for-each (lambda (u)
                (display u)
                (display " "))
              s)))

;; --------------------------------------


(define C (make-connector))
(define F (make-connector))
(celsius-fahrenheit-converter C F)
(probe "Celsius temprature:" C)
(probe "Fahrenheit temprature:" F)

(define (celsius-fahrenheit-converter c f)
  (let ((u (make-connector))
        (v (make-connector))
        (w (make-connector))
        (x (make-connector))
        (y (make-connector)))
    (multiplier c w u)
    (multiplier v x u)
    (adder v y f)
    (constant 9 w)
    (constant 5 x)
    (constant 32 y)
    'okay))
