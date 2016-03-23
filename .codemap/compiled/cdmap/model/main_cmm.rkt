#lang racket
(require codemap/base)
(provide node-tree)
(import "cdmap/model/mutualIns.cmm")
(define node-list
  '(file (id 85c6b24d-d266-3b0e-b995-948eded8f2a1) (name "main.cmm")))
(when (pair? (current-templates))
  (for-each
   (lambda (temp)
     (parameterize
      ((current-output-port empty-output-port)
       (temp-output-port empty-output-port)
       (current-node-maker #f))
      (void ((template-parser temp) (current-nodes)))))
   (current-templates)))
(define node-tree
  (if (pair? (current-nodes))
    (filter-map
     (lambda (name)
       (spath-0 (current-nodes) (format "/file/[name='~a']" name)))
     (current-export-info))
    null))
