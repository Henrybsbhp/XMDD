#lang racket
(require codemap/base)
(provide template-list)
(require (lib "template/objc"))
(begin
  (define (parse-template-g80 tree)
    (parameterize
     ((current-output-port (current-output-port))
      (temp-output-port (current-output-port))
      (current-node-filter #f)
      (current-node-maker (temp-node-maker))
      (current-output-info #f)
      (current-directory (temp-cur-directory)))
     (namespace-by-class-remark 'op)
     (let parse ((nds
                  (if (current-node-filter)
                    ((current-node-filter) tree)
                    null)))
       (parameterize*
        ((current-node
          (cond
           ((not (pair? nds)) null)
           ((current-node-maker) ((current-node-maker) (car nds)))
           (else (car nds)))))
        (define _ (current-node))
        (preform-proc (output-file (format "netop/~aOp.h" (class-name _))))
        (display #"#import \"BaseOp.h\"\n")
        (preform-proc (oc:out-import-linked-classes _))
        (display #"\n@interface ")
        (preform-proc (out (format "~aOp" (class-name _))))
        (display #" : BaseOp\n\n")
        (begin
          (define (parse-template-g78 tree)
            (parameterize
             ((current-output-port (current-output-port))
              (temp-output-port (current-output-port))
              (current-node-filter #f)
              (current-node-maker (temp-node-maker))
              (current-output-info #f)
              (current-directory (temp-cur-directory)))
             (namespace (lambda (nd) (properties-by-remark nd 'req)))
             (let parse ((nds
                          (if (current-node-filter)
                            ((current-node-filter) tree)
                            null)))
               (parameterize*
                ((current-node
                  (cond
                   ((not (pair? nds)) null)
                   ((current-node-maker) ((current-node-maker) (car nds)))
                   (else (car nds)))))
                (define _ (current-node))
                (preform-proc
                 (when (pair? _)
                   (let ((cmt (comment))) (when cmt (outln cmt)))
                   (outln
                    (format
                     "@property (nonatomic,~a) ~a req_~a;"
                     (oc:property-stype _)
                     (oc:property-type _)
                     (property-name _)))))
                (when (and (pair? nds) (pair? (cdr nds))) (parse (cdr nds)))))
             (close-port-ifneeded
              (current-output-port)
              (temp-output-port)
              #:closed-handler
              (lambda (out) ((output-info-close (current-output-info)) out)))))
          (define template-g78 (template '() parse-template-g78))
          (parse-template-g78 (if (pair? (current-node)) (current-node) tree)))
        (display #"\n")
        (begin
          (define (parse-template-g79 tree)
            (parameterize
             ((current-output-port (current-output-port))
              (temp-output-port (current-output-port))
              (current-node-filter #f)
              (current-node-maker (temp-node-maker))
              (current-output-info #f)
              (current-directory (temp-cur-directory)))
             (namespace (lambda (nd) (properties-by-remark nd 'rsp)))
             (let parse ((nds
                          (if (current-node-filter)
                            ((current-node-filter) tree)
                            null)))
               (parameterize*
                ((current-node
                  (cond
                   ((not (pair? nds)) null)
                   ((current-node-maker) ((current-node-maker) (car nds)))
                   (else (car nds)))))
                (define _ (current-node))
                (preform-proc
                 (when (pair? _)
                   (let ((cmt (comment))) (when cmt (outln cmt)))
                   (outln
                    (format
                     "@property (nonatomic,~a) ~a rsp_~a;"
                     (oc:property-stype _)
                     (oc:property-type _)
                     (property-name _)))))
                (when (and (pair? nds) (pair? (cdr nds))) (parse (cdr nds)))))
             (close-port-ifneeded
              (current-output-port)
              (temp-output-port)
              #:closed-handler
              (lambda (out) ((output-info-close (current-output-info)) out)))))
          (define template-g79 (template '() parse-template-g79))
          (parse-template-g79 (if (pair? (current-node)) (current-node) tree)))
        (display #"\n\n@end\n")
        (when (and (pair? nds) (pair? (cdr nds))) (parse (cdr nds)))))
     (close-port-ifneeded
      (current-output-port)
      (temp-output-port)
      #:closed-handler
      (lambda (out) ((output-info-close (current-output-info)) out)))))
  (define template-g80 (template '() parse-template-g80)))
(begin
  (define (parse-template-g82 tree)
    (parameterize
     ((current-output-port (current-output-port))
      (temp-output-port (current-output-port))
      (current-node-filter #f)
      (current-node-maker (temp-node-maker))
      (current-output-info #f)
      (current-directory (temp-cur-directory)))
     (namespace-by-class-remark 'op)
     (let parse ((nds
                  (if (current-node-filter)
                    ((current-node-filter) tree)
                    null)))
       (parameterize*
        ((current-node
          (cond
           ((not (pair? nds)) null)
           ((current-node-maker) ((current-node-maker) (car nds)))
           (else (car nds)))))
        (define _ (current-node))
        (preform-proc (output-file (format "netop/~aOp.m" (class-name _))))
        (display #"#import \"")
        (preform-proc (out (class-name _)))
        (display #"Op.h\"\n\n@implementation ")
        (preform-proc (out (class-name _)))
        (display
         #"Op\n\n- (RACSignal *)rac_postRequest {\n    self.req_method = @\"")
        (preform-proc (out (attr-value _ 'path)))
        (display
         #"\";\n    NSMutableDictionary *params = [NSMutableDictionary dictionary];\n")
        (begin
          (define (parse-template-g81 tree)
            (parameterize
             ((current-output-port (current-output-port))
              (temp-output-port (current-output-port))
              (current-node-filter #f)
              (current-node-maker (temp-node-maker))
              (current-output-info #f)
              (current-directory (temp-cur-directory)))
             (namespace (lambda (nd) (properties-by-remark nd 'req)))
             (let parse ((nds
                          (if (current-node-filter)
                            ((current-node-filter) tree)
                            null)))
               (parameterize*
                ((current-node
                  (cond
                   ((not (pair? nds)) null)
                   ((current-node-maker) ((current-node-maker) (car nds)))
                   (else (car nds)))))
                (define _ (current-node))
                (display #"    ")
                (preform-proc
                 (when (pair? _)
                   (outln
                    (format
                     "[params safetySetObject:~a forKey:@\"~a\"];"
                     (if (oc:ns-value-type _)
                       (format "@(self.req_~a)" (property-name _))
                       (format "self.req_~a" (property-name _)))
                     (property-key _)))))
                (when (and (pair? nds) (pair? (cdr nds))) (parse (cdr nds)))))
             (close-port-ifneeded
              (current-output-port)
              (temp-output-port)
              #:closed-handler
              (lambda (out) ((output-info-close (current-output-info)) out)))))
          (define template-g81 (template '() parse-template-g81))
          (parse-template-g81 (if (pair? (current-node)) (current-node) tree)))
        (display
         #"\n    return [self rac_invokeWithRPCClient:gNetworkMgr.apiManager params:params security:")
        (preform-proc (out (if (attr-value "auth") "YES" "NO")))
        (display
         #"];\n}\n\n- (instancetype)parseResponseObject:(id)rspObj\n{\n    ")
        (preform-proc
         (when (pair? (properties-by-remark 'rsp))
           (outln "NSDictionary *dict = rspObj;")))
        (display #"    ")
        (preform-proc
         (oc:properties-dict-mapping
          (properties-by-remark _ 'rsp)
          (lambda (node k v)
            (define name (property-name node))
            (define dv (format "dict[@\"~a\"]" (property-key node)))
            (define fmt
              (case k
                ('object dv)
                ('value (format "[~a ~a]" dv v))
                ('class (format "[~a createWithJSONDict:dict]" v))
                ('array
                 (outln
                  (format "NSMutableArray *~a = [NSMutableArray array];" name))
                 (outln (format "for (NSDictionary *curDict in ~a) {" dv))
                 (outln
                  (format "~a *obj = [~a createWithJSONDict:curDict];" v v)
                  8)
                 (outln (format "[~a addObject:obj];" name) 8)
                 (outln "}")
                 name)
                ('date
                 (let ((date-type (attr-value node 'date)))
                   (cond
                    ((eq? 'DT14 date-type)
                     (format "[NSDate dateWithD14Text:~a]" dv))
                    ((eq? 'DT10 date-type)
                     (format "[NSDate dateWithD10Text:~a]" dv))
                    (else (format "[NSDate dateWithUTS:~a]" dv)))))))
            (outln (format "self.rsp_~a = ~a;" name fmt)))))
        (display #"\t\n    return self;\n}\n\n@end\n\n")
        (when (and (pair? nds) (pair? (cdr nds))) (parse (cdr nds)))))
     (close-port-ifneeded
      (current-output-port)
      (temp-output-port)
      #:closed-handler
      (lambda (out) ((output-info-close (current-output-info)) out)))))
  (define template-g82 (template '() parse-template-g82)))
(define temp-node-maker (make-parameter (current-node-maker)))
(define temp-cur-directory (make-parameter (current-directory)))
(define template-list (list template-g80 template-g82))
