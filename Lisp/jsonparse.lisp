;;;; -*- Mode: Lisp -*-



(defun jsonparse (JSONString)
  (cond ((not (stringp JSONString)) nil) 
        ((= (length JSONString) 0) nil)  
        (T (startParse (trimspace (concatenate 'list (trimWhiteSpace
						      JSONString)))))
	)
  )


(defun trimWhiteSpace (stringText)
  (if (not (stringp stringText)) nil)
  (string-trim '(#\Space
                 #\Linefeed
		 #\Return
                 #\Tab)
	       stringText)
  )


(defun parseFirst (String Char)
  (cond ((equal (first String) Char) T)
        (T nil)
	)
  )



(defun startParse (charList)
  (cond ((and (parseFirst charList #\{)
	      (parseFirst (trimspace (rest charList)) #\}))
	 (list 'jsonobj))
        ((parseFirst charList #\{)
	 (append (list 'jsonobj)
		 (car (parseMember (trimspace (rest charList)))) 
                 (checkEnd (rest (parseMember
				  (trimspace (rest charList)))))))

        ((and (parseFirst charList #\[)
              (parseFirst (trimspace (rest charList)) #\]))
	 (list 'jsonarray))
        ((parseFirst charList #\[)
	 (append (list 'jsonarray)
		 (car (parseElement (trimspace (rest charList))))
                 (checkEnd (rest (parseElement
				  (trimspace (rest charList)))))))
        ((T (syntaxError)))
        )
  )

(defun parseMember (charList)
  (cond ((null charList) (list))
        (T (let* ((coppia (pair charList))
		  )
	     (cond ((parseFirst (rest coppia) #\})
		    (cons (list (car coppia)) (rest (rest coppia))))
		   ((parseFirst (rest coppia) #\,)
                    (let ((membero
			   (parseMember (trimspace (rest (rest coppia)))))
                          )
		      (cons
		       (append (list (car coppia))
			       (car membero))
		       (rest membero))))
		   ((null (rest coppia)) (car coppia))
                   ((T (syntaxError)))
		   )))
	)
  )


(defun parseElement (charList)
  (cond ((null charList) (list))
        (T (let* ((valore (parseValue charList))) 
             (cond ((parseFirst (rest valore) #\])
		    (cons (list (car valore)) (rest (rest valore))))
                   ((parseFirst (rest valore) #\,) 
                    (let ((elementero
			   (parseElement (trimspace
					  (rest (rest valore))))))
                      (cons
		       (append (list (car valore))
			       (car elementero))
                       (rest elementero))))
                   ((T (syntaxError)))
                   )))
	)
  )

(defun pair (charList)       
  (let* ((stringa (parseStringBody (parseDQ charList) (list)))
         (valore (parseValue (parse2p (trimspace (rest stringa))))))
    (cons (list (concatenate 'string (car stringa)) (car valore))
	  (rest valore)))
  )


(defun checkEnd (charList)
  (cond ((null charList) charList)
        (T (syntaxError))
	)
  )    



(defun parseDQ (charList)
  (cond ((parseFirst charList #\") (rest charList))
	)
  )

(defun parseStringBody (charList Acc)
  (cond ((parseFirst charList #\") (cons  Acc (rest charList)))
        ((parseFirst charList #\\)
	 (parseStringBody (cdr (cdr charList)) 
                          (append Acc (list (second charList)))))
        ((not (null charList))
	 (parseStringBody (cdr charList)
			  (append Acc (list (car charList)))))
	)
  )



(defun parse2p (charList)
  (cond ((parseFirst charList #\:) (trimspace (rest charList)))
	)
  )



(defun parseValue (charList)

  (cond ((parseFirst charList #\")
	 (let ((stringo (parseStringBody (rest charList) (list)))) 
	   (cons (concatenate 'string (car stringo))
		 (trimspace (rest stringo)))))
	
        ((and (parseFirst charList #\{)
	      (parseFirst (trimspace (rest charList)) #\}))  
         (cons (list 'jsonobj) (trimspace (rest (rest charList)))))

        ((parseFirst charList #\{)
	 (let ((membro (parseMember (trimspace (rest charList)))))
           (cons (append (list 'jsonobj) (car membro))
                 (trimspace (rest membro)))))
	
        ((and (parseFirst charList #\[)
	      (parseFirst (trimspace (rest charList)) #\]))  
         (cons (list 'jsonarray) (trimspace (rest (rest charList)))))

        ((parseFirst charList #\[)
	 (let ((elemento (parseElement (trimspace (rest charList)))))
           (cons (append (list 'jsonarray) (car elemento))
                 (trimspace (rest elemento)))))
	
        ((or (parseFirst charList #\t) (parseFirst charList #\f)
	     (parseFirst charList #\n) (parseFirst charList #\T)
	     (parseFirst charList #\F) (parseFirst charList #\N)) 
         (cons (car (CTFN charList)) (trimspace (rest (CTFN charList)))))

        (T (cons (car (parseNumber charList))
		 (trimspace (cadr (parseNumber charList)))))
        )
  )


(defun trimspace (List)
  (cond ((parseFirst List #\Space) (trimspace (rest List)))
        ((parseFirst List #\Linefeed) (trimspace (rest List)))
        ((parseFirst List #\Tab) (trimspace (rest List)))
        ((parseFirst List #\Return) (trimspace (rest List)))
        (T List)))

(defun CTFN (charList)
  (cond ((and (parseFirst charList #\t)
	      (parseFirst (cdr charList) #\r)
	      (parseFirst (cddr charList) #\u) 
              (parseFirst (cdddr charList) #\e))
         (cons 'true (cddddr charList)))
        
	((and (parseFirst charList #\T)
	      (parseFirst (cdr charList) #\R)
	      (parseFirst (cddr charList) #\U) 
              (parseFirst (cdddr charList) #\E))
         (cons 'true (cddddr charList)))

        ((and (parseFirst charList #\f)
	      (parseFirst (cdr charList) #\a)
	      (parseFirst (cddr charList) #\l) 
              (parseFirst (cdddr charList) #\s)
	      (parseFirst (cddddr charList) #\e))
	 (cons 'false (cdr (cddddr charList))))

        ((and (parseFirst charList #\F)
	      (parseFirst (cdr charList) #\A)
	      (parseFirst (cddr charList) #\L) 
              (parseFirst (cdddr charList) #\S)
	      (parseFirst (cddddr charList) #\E))
	 (cons 'false (cdr (cddddr charList))))

        ((and (parseFirst charList #\n)
	      (parseFirst (cdr charList) #\u)
	      (parseFirst (cddr charList) #\l) 
              (parseFirst (cdddr charList) #\l))
	 (cons 'null (cddddr charList)))

        ((and (parseFirst charList #\N)
	      (parseFirst (cdr charList) #\U)
	      (parseFirst (cddr charList) #\L) 
              (parseFirst (cdddr charList) #\L))
	 (cons 'null (cddddr charList)))

        (T (syntaxError))
        )
  )





(defun jsonaccess (JSONParsed &rest Keys)
  (cond ((not (null Keys)) (access JSONParsed Keys))
        (T JSONParsed)))

(defun access (Struct Keys)
  (cond ((null Keys) Struct)
        ((not (listp Struct)) (keyAccessError))
        ((equal (car Struct) 'jsonobj)
	 (access (findFromString (cdr Struct) (car Keys)) (cdr Keys)))
        ((equal (car Struct) 'jsonarray)
	 (access (findValue (cdr Struct) (car Keys)) (cdr Keys)))
        (T (syntaxError))))

(defun findFromString (JSONObj Key)
  (cond ((null JSONObj) (keyObjectError))
        ((not (stringp Key)) (keyFormatError))
        ((equal (caar JSONObj) Key) (cadar JSONObj))
        (T (findFromString (cdr JSONObj) Key))))

(defun findValue (JSONArr Key)
  (cond ((null JSONArr) (keyNullArrayError))
        ((not (numberp Key)) (keyFormatError))
        ((>= Key (length JSONArr)) (outOfBoundError))
        ((= Key 0) (car JSONArr))
        (T (findValue (cdr JSONArr) (- Key 1)))))

;;; tutti i tipi di errori

(defun keyParameterError ()
  (error "no keys have been called"))

(defun keyNullArrayError ()
  (error "last array is null"))

(defun keyFormatError ()
  (error "keys not in the correct format"))

(defun keyObjectError ()
  (error "key not found in object"))

(defun keyAccessError ()
  (error "last element cannot be accessed"))

(defun outOfBoundError ()
  (error "index out of bound"))

(defun syntaxError ()
  (error "syntax error"))

(defun outOfBoundError ()
  (error "index out of bound"))

;;; verifica se è la fine

(defun checkFine (charlist)
  (cond ((null charList) (outOfBoundError))
        (T charList))) 


(defun parseinversoO (parselist)
  (cond ((equal (car parselist) 'jsonobj)
	 (append (list #\{)
		 (parseinversoO (rest parselist)) (list #\})))
	((equal (car parselist) 'jsonarray)
	 (append (list #\[)
		 (parseinversoA (rest parselist)) (list #\])))
	
	((stringp (car (rest (car  parselist))))
	 (append (list #\") (concatenate 'list (caar parselist))
		 (list #\" #\Space #\: #\Space #\") 
		 (concatenate 'list (car (rest (car parselist))))
		 (list #\") (checkVirgolaO (rest parselist))))
	
	((numberp (car (rest (car parselist))))
         (append (list #\") (concatenate 'list (caar parselist))
		 (list #\" #\Space #\: #\Space) 
		 (concatenate 'list
			      (format nil "~A"
				      (car (rest (car parselist)))))
		 (checkVirgolaO (rest parselist))))

        ((or (equal (rest (car parselist)) (list 'false))
	     (equal (rest (car parselist)) (list 'true))
	     (equal (rest (car parselist)) (list 'null)))
         (append (list #\") (concatenate 'list (caar parselist))
		 (list #\" #\Space #\: #\Space) 
		 (concatenate 'list (format nil "~A"
					    (car (rest (car parselist)))))
		 (checkVirgolaO (rest parselist))))

	((null (car parselist)) nil)
	(T (append (list #\") (concatenate 'list (caar parselist))
		   (list #\" #\Space  #\: #\Space)
		   (parseinversoO (car (rest (car parselist))))
		   (checkVirgolaO (rest parselist))))
	)
  )


(defun checkVirgolaO(List)
  (cond((null List) nil)
       (T (append (list #\, #\Space) (parseinversoO List)))
       )
  )

(defun parseinversoA (parselist) 
  (cond ((equal (car parselist) 'jsonarray)
	 (append (list #\[) (parseinversoA (rest parselist)) (list #\])))
	
	((equal (car parselist) 'jsonobj)
	 (append (list #\{) (parseinversoO (rest parselist)) (list #\})))

	((stringp (car parselist))
	 (append (list #\") (concatenate 'list (car parselist)) (list #\")
		 (checkVirgolaA (rest parselist))))

	((numberp (car parselist))
	 (append (concatenate 'list
			      (format nil "~A" (car parselist)))
		 (checkVirgolaA (rest parselist))))

        ((or (equal (list (car parselist)) (list 'false))
	     (equal (list (car parselist)) (list 'null))
             (equal (list (car  parselist)) (list 'true)))
	 (append (concatenate 'list
			      (format nil "~A" (car parselist)))
		 (checkVirgolaA (rest parselist))))
	
	((null (car parselist)) nil)
	(T (append (parseinversoA (car parselist))
		   (checkVirgolaA (rest parselist))))
	)
  )

(defun checkVirgolaA (List)
  (cond((null List) nil)
       (T (append (list #\, #\Space) (parseinversoA List)))
       )
  )

(defun parseInverso (List)
  (cond ((equal (car List) 'jsonobj)
	 (concatenate 'string (parseInversoO List)))
	
        ((equal (car List) 'jsonarray)
	 (concatenate 'string (parseInversoA List)))
        )
  )


(defun isFirst (charList char)
  (cond ((equal (car charList) char) T)
        (T nil)
	)
  )

(defun isDigit (char)
  (cond ((member char (list #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9)) T)
	)
  )

(defun isPositiveDigit (char)
  (cond ((and (not (equal char #\0)) (isDigit char)) T)
	)
  )

(defun isLowercaseEqual (a b)
  (cond ((null a) nil)
        ((equal (string-downcase (concatenate 'string (list a)))
		(concatenate 'string (list b))))
	)
  )

(defun listToString (rawList)
  (reduce (lambda (a b) (concatenate 'string a b)) rawList)
  )

(defun join (&rest args)
  (let ((stringList (mapcar (lambda (arg) (car arg)) args)))
    (listToString stringList))
  )

(defun syntaxError ()
  (error "syntax error")
  )

(defun stripWhitespace (string)
  (string-trim '(#\Space #\Linefeed #\Return #\Tab) string)
  )



(defun formatInput (inputString)
  (cond ((null inputString) '())
        (T (stripWhitespace (listToString inputString)))
	)
  )

(defun read-list-from (input-stream)
  (let ((e (read-line input-stream nil 'eof)))
    (unless (eq e 'eof)
      (cons e (read-list-from input-stream))))
  )



(defun jsondump (JSON filename)
  (with-open-file (out filename
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    (format out "~a" (parseInverso JSON)) filename)
  )


(defun jsonread (filename)
  (with-open-file (in filename
                      :direction :input
                      :if-does-not-exist :error)
    (jsonparse (formatInput (read-list-from in))))
  )


(defun parseNumber (charList)
  (let* ((minusSign (parseMinusSign charList))
         (integer (parseInteger (cadr minusSign)))
         (floatDecimal (parseFloatDecimal (cadr integer)))
         (exponent (parseExponent (cadr floatDecimal)))
         (numberString (join minusSign integer floatDecimal exponent)))
    (list (read-from-string numberString) (cadr exponent)))
  )




(defun parseMinusSign (charList)
  (cond ((isFirst charList #\-) (list "-" (cdr charList)))
        (T (list nil charList))
	)
  )

(defun parseSign (charList Acc)
  (cond ((isFirst charList #\+)
	 (parseExponentDigit (cdr charList) (append Acc (list #\+))))
        ((isFirst charList #\-)
	 (parseExponentDigit (cdr charList) (append Acc (list #\-))))
        (T (syntaxError))
	)
  )

(defun parseExponentDigit (charList Acc)
  (cond ((isDigit (car charList))
	 (parseDigit (cdr charList) (append Acc (list (car charList)))))
        (T (syntaxError))
	)
  )

(defun parseDigit (charList Acc)
  (cond ((isDigit (car charList))
	 (parseDigit (cdr charList) (append Acc (list (car charList)))))
        (T (list (concatenate 'string Acc) charList))
	)
  )

(defun parseInteger (charList)
  (cond ((isFirst charList #\0) (list "0" (cdr charList)))
        ((isPositiveDigit (car charList))
	 (parseDigit (cdr charList) (list (car charList))))
        (T (syntaxError))
	)
  )

(defun parseFloatDecimal (charList)
  (cond ((isFirst charList #\.) (parseDigit (cdr charList) (list #\.)))
	(T (list nil charList))
	)
  )

(defun parseExponent (charList)
  (cond ((isLowercaseEqual (car charList) #\e)
	 (parseSign (cdr charList) (list #\e)))
        (T (list nil charList))
	)
  )


;;;; end of file -- jsonparse.lisp

