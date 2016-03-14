#lang racket
(require codemap/base)
(provide template-list)
(require (lib "template/objc"))
(begin
  (define (parse-template-g269 tree)
    (parameterize
     ((current-output-port (current-output-port))
      (temp-output-port (current-output-port))
      (current-node-filter #f)
      (current-node-maker (temp-node-maker))
      (current-output-info #f)
      (current-directory (temp-cur-directory)))
     (namespace-by-class-remark 'data)
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
        (preform-proc (output-file (format "dataset/~a.h" (class-name _))))
        (display #"#import <Foundation/Foundation.h>\n")
        (preform-proc (oc:out-import-linked-classes _))
        (display #"\n@interface ")
        (preform-proc (out (class-name _)))
        (display #" : ")
        (preform-proc (out (oc:super-class _)))
        (display #"\n")
        (begin
          (define (parse-template-g268 tree)
            (parameterize
             ((current-output-port (current-output-port))
              (temp-output-port (current-output-port))
              (current-node-filter #f)
              (current-node-maker (temp-node-maker))
              (current-output-info #f)
              (current-directory (temp-cur-directory)))
             (namespace (lambda (nd) (properties nd)))
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
                (preform-proc (let ((cmt (comment))) (when cmt (outln cmt))))
                (preform-proc
                 (outln
                  (format
                   "@property (nonatomic,~a) ~a ~a;"
                   (oc:property-stype _)
                   (oc:property-type _)
                   (property-name _))))
                (when (and (pair? nds) (pair? (cdr nds))) (parse (cdr nds)))))
             (close-port-ifneeded
              (current-output-port)
              (temp-output-port)
              #:closed-handler
              (lambda (out) ((output-info-close (current-output-info)) out)))))
          (define template-g268 (template '() parse-template-g268))
          (parse-template-g268
           (if (pair? (current-node)) (current-node) tree)))
        (display
         #"\n\n+ (instancetype)createWithJSONDict:(NSDictionary *)dict;\n- (void)resetWithJSONDict:(NSDictionary *)dict;\n\n@end\n")
        (when (and (pair? nds) (pair? (cdr nds))) (parse (cdr nds)))))
     (close-port-ifneeded
      (current-output-port)
      (temp-output-port)
      #:closed-handler
      (lambda (out) ((output-info-close (current-output-info)) out)))))
  (define template-g269 (template '() parse-template-g269)))
(begin
  (define (parse-template-g270 tree)
    (parameterize
     ((current-output-port (current-output-port))
      (temp-output-port (current-output-port))
      (current-node-filter #f)
      (current-node-maker (temp-node-maker))
      (current-output-info #f)
      (current-directory (temp-cur-directory)))
     (namespace-by-class-remark 'data)
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
        (preform-proc (output-file (format "dataset/~a.m" (class-name _))))
        (display #"#import \"")
        (preform-proc (out (class-name _)))
        (display #".h\"\n  \n@implementation ")
        (preform-proc (outln (class-name _)))
        (display
         #"+ (instancetype)createWithJSONDict:(NSDictionary *)dict\n{\n    ")
        (preform-proc (out (class-name _)))
        (display
         #" *obj = [[self alloc] init];\n    [obj resetWithJSONDict:dict];\n    return obj;\n}\n\n- (void)resetWithJSONDict:(NSDictionary *)dict\n{\n    ")
        (preform-proc
         (oc:properties-dict-mapping
          (properties _)
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
                  4)
                 (outln (format "[~a addObject:obj];" name) 4)
                 (outln "}")
                 name)
                ('date
                 (let ((date-type (attr-value node 'date)))
                   (cond
                    ((eq? 'DT14 date-type)
                     (format "[NSDate dateWithD14Text:~a]" dv))
                    (else (format "[NSDate dateWithUTS:~a]" dv)))))))
            (outln (format "self.~a = ~a;" name fmt)))))
        (display #"\n}\n\n@end\n\n")
        (when (and (pair? nds) (pair? (cdr nds))) (parse (cdr nds)))))
     (close-port-ifneeded
      (current-output-port)
      (temp-output-port)
      #:closed-handler
      (lambda (out) ((output-info-close (current-output-info)) out)))))
  (define template-g270 (template '() parse-template-g270)))
(define temp-node-maker (make-parameter (current-node-maker)))
(define temp-cur-directory (make-parameter (current-directory)))
(define template-list (list template-g269 template-g270))
