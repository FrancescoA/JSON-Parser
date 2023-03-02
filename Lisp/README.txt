___________________________________________________________________________

Lo sviluppo di applicazioni web su Internet, ma non solo, richiede di
scambiare dati fra applicazioni eterogenee, ad esempio tra un client
web scritto in Javascript e un server, e viceversa. Uno standard per
lo scambio di dati molto diffuso è lo standard JavaScript Object
Notation, o JSON. Lo scopo di questo progetto è di realizzare due
librerie, una in Prolog e l’altra in Common Lisp, che costruiscano
delle strutture dati che rappresentino degli oggetti JSON a partire
dalla loro rappresentazione come stringhe.

La stringa in input va analizzata ricorsivamente per comporre una struttura
adeguata a memorizzarne le componenti. Si cerchi di costruire un parser
guidato dalla struttura ricorsiva del testo in input. 

La sintassi JSON è definita nel sito https://www.json.org.

___________________________________________________________________________


Dalla grammatica data, un oggetto JSON può essere scomposto ricorsivamente
nelle seguenti parti:

1. Object
2. Array
3. Value
4. String
5. Number

La sintassi degli oggetti JSON in Common Lisp è:

Object = '(' jsonobj members ')'
Object = '(' jsonarray elements ')'

e ricorsivamente:

members = pair*
pair = '('< attribute value ')'
attribute = <stringa Common Lisp>
number = <numero Common Lisp>
value = string | number | Object
elements = value*


___________________________________________________________________________

Di seguito si riporta la descrizione delle funzioni più importanti
implementate nella parte Lisp del nostro progetto.
___________________________________________________________________________



jsonparse

Questa funzione accetta in ingresso una stringa e produce una struttura simile
a quella illustrata per la realizzazione Prolog.



jsonaccess

Questa funzione accetta un oggetto JSON (rappresentato in Common Lisp, così
come prodotto dalla funzione jsonparse) e una serie di “campi”, recupera
l’oggetto corrispondente. Un campo rappresentato da N (con N un numero
maggiore o uguale a 0) rappresenta un indice di un array JSON. Se non viene
specificata alcuna chiave, viene restituito l'oggetto intero, in analogia al
comportamento richiesto in Prolog.



jsondump

Questa funzione scrive l’oggetto JSON sul file Filename in sintassi JSON
chiamando la funzione parseInverso. Se Filename non esiste viene creato,
mentre se esiste viene sovrascritto.



jsonread

Questa funzione apre il file filename ritorna un oggetto JSON chiamando
jsonparse oppure genera un errore. Se filename non la funzione genera un
errore.



startParse

questa funzione viene chiamata da jsonparse: se il primo carattere della
sequenza passata come parametro è '{', analizza ricorsivamente il contenuto
dell'oggetto invocando parseMember sulla restante sequenza. Se invece il primo
carattere della sequenza è '[', invoca parseElement in modo analogo per
analizzare ricorsivamente il contenuto dell'array.



parseMember

Parsa il primo pair con la funzione pair. Se il primo carattere della sequenza
restante è ',' analizza ricorsivamente altri Member dell'oggetto invocando
parseMember su di essa. Se invece il primo carattere della sequenza è '}',
termina l'analisi ricorsiva dell'oggetto corrente.



parseElement

Parsa il primo pair con la funzione parseValue. Se il primo carattere della
sequenza restante è ',' analizza ricorsivamente altri Element dell'array
invocando parseElement su di essa. Se invece il primo carattere della
sequenza è ']', termina l'analisi ricorsiva dell'array corrente.



parseValue

Se il primo carattere della sequenza del parametro è '"', analizza
ricorsivamente l'eventuale stringa. Se il primo carattere della sequenza
del parametro è '{', analizza ricorsivamente l'eventuale sottooggetto.
Se il primo carattere della sequenza del parametro è '[', analizza
ricorsivamente l'eventuale sottoarray. Se il primo carattere della sequenza
del parametro è 't', 'f' o 'n', analizza ricorsivamente l'eventuale
booleano o null. Altrimenti analizza ricorsivamente l'eventuale numero.



pair

Dalla sequenza passata come parametro estrae e converte nell'apposita
struttura un eventuale Pair.



parseStringBody

Dalla sequenza passata come parametro estrae il corpo di una eventuale String.



parseNumber

Dalla sequenza passata come parametro estrae un'eventuale Number.



CTFN

Dalla sequenza passata come parametro estrae un eventuale boolean (true,false)
oppure un null.



access

Questa funzione viene chiamata da jsonaccess: utilizzando tutte le chiavi e
controllando ad ogni chiamata la validità dei parametri, accede ricorsivamente
all'oggetto corrispondente richiamando findFromString o findValue in base al
caso.



findFromString

Questa funzione viene chiamata da access: se esiste e se è possibile farlo,
accede al valore che corrisponde alla stringa passata come primo parametro,
se valida.



findValue

Questa funzione viene chiamata da access: se esiste e se è possibile farlo,
accede al valore che corrisponde all'indice come primo parametro, se valido.



parseInverso

Questa funzione viene chiamata da jsondump: data la struttura di un oggetto
creata con jsonparse, ricostruisce l'oggetto JSON in sintassi originale ad
esso corrispondente invocando ricorsivamente la funzione parseInversoA nel
caso di un array e parseInversoO nel caso di un oggetto.


___________________________________________________________________________

Si elencano qui sotto alcuni esempi che illustrano il comportamento
delle varie funzioni.
___________________________________________________________________________



CL-prompt> (defparameter x (jsonparse "{\"nome\" : \"Arthur\",
 \"cognome\" : \"Dent\"}"))
X
;; Attenzione al newline!



CL-prompt> x
(JSONOBJ ("nome" "Arthur") ("cognome" "Dent"))



CL-prompt> (jsonaccess x "cognome")
"Dent"



CL-prompt> (jsonaccess (jsonparse
 "{\"name\" : \"Zaphod\",
 \"heads\" : [[\"Head1\"], [\"Head2\"]]}")
 "heads" 1 0)
"Head2"



CL-prompt> (jsonparse "[1, 2, 3]")
(JSONARRAY 1 2 3)



CL-prompt> (jsonparse "{}")
(JSONOBJ)



CL-prompt> (jsonparse "[]")
(JSONARRAY)



CL-prompt> (jsonparse "{]")
ERROR: syntax error



CL-prompt> (jsonaccess (jsonparse " [1, 2, 3] ") 3) ; Arrays are 0-based.
ERROR: …



CL-PROMPT> (jsonread (jsondump ’(jsonobj #| stuff |#) ”foo.json”))
(JSONOBJ #| stuff |#)


___________________________________________________________________________