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

La sintassi degli oggetti JSON in Prolog è:

Object = jsonobj(Members)
Object = jsonarray(Elements)

e ricorsivamente:

Members = [] or
Members = [Pair | MoreMembers]
Pair = (Attribute, Value)
Attribute = <string SWI Prolog>
Number = <numero Prolog>
Value = <string SWI Prolog> | Number | Object
Elements = [] or
Elements = [Value | MoreElements]


___________________________________________________________________________

Di seguito si riporta la descrizione delle funzioni più importanti
implementate nella parte Prolog del nostro progetto.
___________________________________________________________________________



jsonparse/2


Questo predicato risulta vero se il primo parametro costituito da una stringa
SWI Prolog o un atomo Prolog) può venire scorporato ricorsivamente con il
sottopredicato jsonparser/2 come il secondo parametro, ossia una stringa,
numero, o struttura di termini composti). Esso utilizza il predicato
tokenize_atom per convertire la stringa o l'atomo in una sequenza di parole,
numeri e segni di punteggiatura.



jsonaccess/3

Questo predicato risulta vero quando il terzo parametro è recuperabile
ricorsivamente seguendo la catena di campi presenti nel secondo
argomento (una lista) a partire da Jsonobj. Un campo rappresentato da N
(con N un numero maggiore o uguale a 0) corrisponde a un indice di un array
JSON.



jsonparser/2

Questo predicato viene chiamato da jsonparse/2: se il primo token della
sequenza passata come argomento è '{', analizza ricorsivamente il
contenuto dell'oggetto con members/3. Se invece il primo token della sequenza
è '[', invoca elements/3 in modo analogo per analizzare ricorsivamente il
contenuto dell'array.



jsondump/2

Questo predicato risulta vero se l’oggetto corrispondente al primo parametro
riesce ad essere scritto in sintassi JSON sul file avente come filename il
secondo argomento. Per fare ciò richiama il predicato rejson/2 se il primo
parametro è un oggetto, se si tratta di un array invece viene chiamato
rejsonA/2. Se il filename non esiste viene creato, mentre se esiste viene
sovrascritto.



members/3

Questo predicato verifica se il primo token della lista del primo
argomento è '"'. In questo caso viene composta nel secondo argomento una
struttura che include il corrente Pair con la stringa e il valore estratti
dai sottopredicati is_String/4 e is_Value/3 in sequenza. Successivamente viene
chiamato il predicato end/3 per analizzare ricorsivamente la sequenza restante.
Altrimenti, se il primo token è '}', viene restituito nel secondo argomento
una lista vuota.



elements/3

Questo predicato verifica se il primo token della lista del primo
argomento non è ']'. In questo caso viene composta nel secondo argomento una
struttura che include il corrente Element con il valore estratto
dal sottopredicato is_Value/3. Successivamente viene
chiamato il predicato fine/3 per analizzare ricorsivamente la sequenza
restante. Altrimenti, se il primo token è ']', viene restituito nel secondo
argomento una lista vuota.



end/3
	
Questo predicato serve per controllare la conclusione di un oggetto parsato.
In particolare, se è presente il token ',' all'inizio della lista passata
come primo parametro, viene chiamato members/3 per parsare ricorsivamente
altri Member.



fine/3
	
Questo predicato serve per controllare la conclusione di un array parsato.
In particolare, se è presente il token ',' all'inizio della lista passata
come primo parametro, viene chiamato elements/3 per parsare ricorsivamente
altri Value.



is_String/4

Questo predicato verifica che il primo argomento sia una String e in caso
affermativo la compatta ricorsivamente in una stringa Prolog.



is_Value/4

Questo predicato verifica che il primo argomento sia un Value e in caso
affermativo lo compatta ricorsivamente nel formato corrispondente.



ricerca/3

Questo predicato ricerca all'interno dell'oggetto passato nel primo argomento
il valore corrispondente alla chiave espressa dal secondo argomento.



ricercArray/3

Questo predicato ricerca all'interno dell'array passato nel primo argomento il
valore che corrisponde alla posizione specificata dall'indice espresso dal
secondo argomento.



rejson/2

Questo predicato viene chiamato da jsondump/2: prende come primo argomento il
corpo di un oggetto ed è verificato se riesce a ricostruire l'oggetto JSON in
sintassi originale ad esso corrispondente.



rejsonA/2

Questo predicato viene chiamato da jsondump/2: prende come primo argomento il
corpo di un array ed è verificato se riesce a ricostruire l'array JSON in
sintassi originale ad esso corrispondente.


___________________________________________________________________________

Si elencano qui sotto alcuni esempi che illustrano il comportamento
dei vari predicati.
___________________________________________________________________________



?- jsonparse('{"nome" : "Arthur", "cognome" : "Dent"}', O),
 jsonaccess(O, ["nome"], R).



O = jsonobj([(”nome”, ”Arthur”), (”cognome”, ”Dent”)])
R = ”Arthur”



?- jsonparse('{"nome": "Arthur", "cognome": "Dent"}', O),
 jsonaccess(O, "nome", R). % Notare le differenza.
O = jsonobj([(”nome”, ”Arthur”), (”cognome”, ”Dent”)])
R = ”Arthur”



?- jsonparse('{"nome" : "Zaphod",
 "heads" : ["Head1", "Head2"]}', % Attenzione al newline.
 Z),
 jsonaccess(Z, ["heads", 1], R).
Z = jsonobj([(”name”, ”Zaphod”), (”heads”, jsonarray([”Head1”, ”Head2”]))])
R = ”Head2”



?- jsonparse('{"nome" : "Zaphod",
 "arms" : ["Arm1", "Arm2", "Arm3"]}', % Attenzione al newline.
 Z),
 jsonaccess(Z, ["arms", 2], R).
Z = jsonobj([(”name”, ”Zaphod”), (”arms”,
	jsonarray([”Arm1”, ”Arm2”, ”Arm3”]))])
R = ”Arm3”



?- jsonparse(’[]’, X).
X = jsonarray([]).



?- jsonparse(’{}’, X).
X = jsonobj([]).



?- jsonparse(’[}’, X).
false



?- jsonparse(’[1, 2, 3]’, A), jsonaccess(A, [3], E).
false



?- jsonparse('{"nome" : "Arthur", "cognome" : "Dent"}',
 jsonobj([jsonarray(_) | _]).
false



?- jsonparse('{"nome" : "Arthur", "cognome" : "Dent"}',
 jsonobj([("nome", N) | _]).
N = ”Arthur”



?- jsonparse('{"nome" : "Arthur", "cognome" : "Dent"}', JSObj),
 jsonaccess(JSObj, ["cognome"], R),
R = ”Dent”



?- jsondump(jsonobj([/* stuff */]), ’foo.json’),
 jsonread(’foo.json’, JSON).
JSON = jsonobj([/* stuff */])


___________________________________________________________________________