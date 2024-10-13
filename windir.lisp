(in-package #:windir)

(defparameter *beat* 3/4)
(defparameter *measure* (* 8 *beat*))

(defun list-repeat (list times)
  (labels ((recur (times acc)
             (if (= times 1)
                 acc
                 (recur (1- times) (concatenate 'list acc list)))))
    (recur times list)))

(defun drum-sample (pathname)
  (merge-pathnames (uiop:strcat "drum-samples/" pathname)
                   (asdf:system-source-directory :windir)))

(defmacro defdrum (name file)
  `(let ((buf (buffer-read-channel ,file :channels (list 0))))
     (defsynth ,name ()
       (out.ar 0 (play-buf.ar 1 buf 1 :act :free)))))

(defun load-synths ()
  (defdrum kick-3 (drum-sample "Kick-V04-Yamaha-16x16.wav"))
  (defdrum kick-4 (drum-sample "Kick-V04-Yamaha-16x16.wav"))
  (defdrum kick-5 (drum-sample "Kick-V05-Yamaha-16x16.wav"))
  (defdrum kick-6 (drum-sample "Kick-V06-Yamaha-16x16.wav"))
  (defdrum tom-1 (drum-sample "TOM10-V01-StarClassic-10x10.wav"))
  (defdrum tom-2 (drum-sample "TOM10-V02-StarClassic-10x10.wav"))
  (defdrum tom-3 (drum-sample "TOM10-V03-StarClassic-10x10.wav"))
  (defdrum tom-5 (drum-sample "TOM10-V05-StarClassic-10x10.wav"))
  (defdrum tom-6 (drum-sample "TOM10-V06-StarClassic-10x10.wav"))
  (defdrum tom-7 (drum-sample "TOM10-V07-StarClassic-10x10.wav"))
  (defdrum hihat-pdl-1 (drum-sample "HHats-PDL-V01-SABIAN-AAX.wav"))
  (defdrum hihat-pdl-2 (drum-sample "HHats-PDL-V02-SABIAN-AAX.wav"))
  (defdrum hihat-pdl-4 (drum-sample "HHats-PDL-V04-SABIAN-AAX.wav"))
  (defdrum hihat-pdl-5 (drum-sample "HHats-PDL-V05-SABIAN-AAX.wav"))

  (defsynth sine-swell ((note 60) (dur 4.0) (vol 0.5))
    (let* ((freq (midicps note))
           (env (env-gen.kr (env `(0 ,vol 0) (list (* dur 0.8) (* dur 0.2))) :act :free))
           (sig (lpf.ar (saw.ar freq env))))
      (out.ar 0 sig)))

  (defsynth sine-smooth ((note 60) (dur 4.0) (vol 0.5))
    (let* ((freq (midicps note))
           (env (env-gen.kr (env `(,vol ,vol ,vol) (list (/ dur 2) (/ dur 2))) :act :free))
           (sig (lpf.ar (saw.ar freq env))))
      (out.ar 0 sig)) )

  (defsynth saw-synth ((note 60) (dur 4.0) (vol 0.4))
    (let* ((env (env-gen.kr (env `(0 ,vol 0) (list (* dur .1) (* dur .9))) :act :free))
           (freq (midicps note))
           (sig (lpf.ar (saw.ar freq env) (* freq 2))))
      (out.ar 0 (list sig sig)))))

(defun drm (time &key synth beats (rhythm 1))
  (let ((local-beat *beat*))
    (at time
      (when (not (= 0 (car beats)))
        (synth synth))
      (when (cdr beats)
        (let ((next-time (+ time (* local-beat rhythm))))
          (callback next-time
                    #'drm
                    next-time
                    :synth synth
                    :beats (cdr beats)
                    :rhythm rhythm))))))

(defun mel (time &key synth melody (rhythm 1) (volume 0.5) (crescendo 0))
  (let ((local-beat *beat*))
    (at time
      (let* ((note (car melody))
             (dur (if (consp note) (* rhythm (second note)) rhythm)))
        (synth synth
               :note (if (consp note) (first note) note)
               :dur (* local-beat dur)
               :vol (if (consp note) (or (third note) volume) volume))
        (when (cdr melody)
          (let ((next-time (+ time (* local-beat dur))))
            (callback next-time
                      #'mel
                      next-time
                      :synth synth
                      :melody (cdr melody)
                      :rhythm rhythm
                      :volume (+ volume (/ (* dur crescendo) *measure*))
                      :crescendo crescendo)))))))

(defun melody-lines ()
  (a:random-elt
   (list
    `((mel :synth saw-synth
           :melody (60 55 60 63 67 63 60 63 62 58 53 58 60 55 60 63)
           :rhythm 1/2)
      (mel :synth sine-swell
           :melody (48 41 43 48)
           :rhythm 2))

    `((mel :synth saw-synth
           :melody (60 55 60 63 58 53 58 62 58 53 58 62 60 55 60 63)
           :rhythm 1/2)
      (mel :synth sine-swell
           :melody (48 46 43 48)
           :rhythm 2))

    `((mel :synth saw-synth
           :melody (55 60 55 63 62 58 53 62 63 58 67 63 65 62 58 53)
           :rhythm 1/2)
      (mel :synth sine-swell
           :melody ((84 4) (82 7) 75 (74 4))
           :rhythm 1/2)
      (mel :synth sine-swell
           :melody (48 46 39 46)
           :rhythm 2))

    `((mel :synth saw-synth
           :melody (0 60 63 67 0 58 62 65 0 63 67 70 0 58 62 65)
           :rhythm 1/2)
      (mel :synth sine-swell
           :melody ((84 2) (82 2) (87 3) 86))
      (mel :synth sine-swell
           :melody (48 46 39 46)
           :rhythm 2))

    `((mel :synth saw-synth
           :melody ,(concatenate
                     'list
                     '(60 67 0 63 67 0 63 67)
                     '(60 67 0 63 67 0 63 67)
                     '(59 67 0 62 67 0 62 67)
                     '(60 67 0 63 67 0 63 67)
                     '(60 67 0 63 67 0 63 67)
                     '(60 67 0 63 67 0 63 67)
                     '(59 67 0 62 67 0 62 67)
                     '(60 67 0 63 67 0 63 67))
           :rhythm 1/8
           :volume 0.35)
      (mel :synth sine-swell
           :melody ,(list-repeat '((84 2) 83 84) 2))
      (mel :synth saw-synth
           :melody ,(concatenate
                     'list
                     '(48 55 51 48 47 50 48 51)
                     '(48 55 51 48 47 50 48 51))
           :rhythm 1/2))

    `((mel :synth saw-synth
           :melody ,(concatenate
                     'list
                     '(63 70 0 67 70 0 67 70)
                     '(63 70 0 67 70 0 67 70)
                     '(62 68 0 65 68 0 65 68)
                     '(62 68 0 65 68 0 65 68)
                     '(60 67 0 63 67 0 63 67)
                     '(60 67 0 63 67 0 63 67)
                     '(59 67 0 62 67 0 62 67)
                     '(59 67 0 62 67 0 62 67))
           :rhythm 1/8
           :volume 0.40)
      (mel :synth sine-swell
           :melody (87 83 84 79)
           :rhythm 2)
      (mel :synth saw-synth
           :melody ,(concatenate
                     'list
                     '(51 58 55 51 50 56 53 50)
                     '(48 55 51 48 47 50 55 47))
           :rhythm 1/2))

    `((mel :synth saw-synth
           :melody ,(concatenate
                     'list
                     (list-repeat '(72 75 79 75) 4)
                     (list-repeat '(79 74 71 67) 2)
                     '(72 75 79 84)
                     '(75 79 84 87)
                     (list-repeat '(84 87 91 87) 4)
                     (list-repeat '(79 74 71 67) 2)
                     '(72 75 79 84)
                     '(75 79 84 87))
           :rhythm 1/8)
      (mel :synth sine-swell
           :melody ((48 2) 47 48 (48 2) 47 48)))

    `((mel :synth saw-synth
           :melody ,(concatenate
                     'list
                     '(75 79 82 0 79 82 79 75)
                     '(79 0 79 75 79 0 79 75)
                     '(74 77 82 0 77 82 77 74)
                     '(77 0 77 74 77 0 77 74)
                     '(72 75 79 0 75 79 75 72)
                     '(75 0 75 72 75 0 75 72)
                     '(71 74 79 0 74 79 74 71)
                     '(74 0 74 71 74 0 74 71))
           :rhythm 1/8)
      (mel :synth sine-swell
           :melody (70 67)
           :rhythm 4)
      (mel :synth sine-swell
           :melody (51 50 48 47)
           :rhythm 2))
    )))

(defun drum-lines ()
  (a:random-elt
   (list
    `((drm :synth kick-5
           :beats ,(list-repeat '(1) 32)
           :rhythm 1/4)
      (drm :synth tom-3
           :beats ,(list-repeat '(1) 8))
      (drm :synth hihat-pdl-5
           :beats ,(list-repeat '(0 0 0 1) 4)
           :rhythm 1/2))

    `((drm :synth tom-3
           :beats ,(list-repeat '(1 1 1 1 1 1 1 1) 2)
           :rhythm 1/2)
      (drm :synth tom-5
           :beats (0 1 0 1 0 1 0 1)))

    `((drm :synth tom-3
           :beats (1 1 1 1 1 1 1 1))
      (drm :synth tom-5
           :beats (0 1 0 1 0 1 0 1)))
    )))

(defun play-song (measures &optional (time (quant 1)))
  (dolist (line (melody-lines)) (apply (a:curry (car line) time) (cdr line)))
  (dolist (line (drum-lines)) (apply (a:curry (car line) time) (cdr line)))
  (let ((next-time (+ time *measure*)))
    (unless (= 1 measures)
      (callback next-time
                #'play-song
                (1- measures)
                next-time))))

(defun start-server ()
  (setf *s* (make-external-server "localhost" :port 48800))
  (server-boot *s*)
  (load-synths)
  (values))

(defun stop-server ()
  (server-quit *s*))
