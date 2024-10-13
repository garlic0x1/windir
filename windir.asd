(asdf:defsystem #:windir
  :depends-on (:alexandria :cl-collider)
  :components ((:file "package")
               (:file "windir")))
