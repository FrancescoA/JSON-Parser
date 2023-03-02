%%%% -*- Mode: Prolog -*-
%%%% jsonparse.pl


jsonparse(JSONString, Object) :-
    tokenize_atom(JSONString, J),
    jsonparser(J, Object).


jsonparser(['{' | Altro], jsonobj(O)) :-
    !,
    members(Altro, O, []).

jsonparser(['[' | Altro], jsonarray(O)) :-
    !,
    elements(Altro, O, []).

%%% members/3

members(['}'], [], []) :-
    !.

members(['}' | Acc], [], Acc) :-
    !.

members(['"' | Js], [(String ,Valore) | MoreMembers], Acc) :-
    is_String(Js, String, [':' | Jsns], []),
    is_Value(Jsns, Valore, Jsnp),
    end(Jsnp, MoreMembers, Acc).

%%% elements/3

elements([']'], [], []) :-
    !.

elements([']'| Acc], [], Acc) :-
    !.

elements(Js, [X | MoreElements], Acc) :-
    is_Value(Js, X, Jsns),
    !,
    fine(Jsns, MoreElements, Acc).

%%% is_String/4
%%% verifica che il primo argomento sia una stringa
%%% e la compatta in String
%%% con l'aiuto di un accumulatore, Acc
%%% il resto della lista senza la stringa la chiamo Jsns

%%% fine della stringa


is_String(['"' | Jsns], String, Jsns, Acc) :-
    !,
    reverse(Acc, Cca),
    atomics_to_string(Cca, String).

is_String(['\\', X | Js], String, Jsns, Acc) :-
    !,
    is_String(Js, String, Jsns, [X | Acc]).

is_String([X | Js], String, Jsns, Acc) :-
    atom(X),
    !,
    is_String(Js, String, Jsns, [X | Acc]).

is_String([X | Js], String, Jsns, Acc) :-
    number(X),
%    !,
    is_String(Js, String, Jsns, [X | Acc]).



%%% is_Value/3


is_Value([X | Js], X, Js) :-
    number(X),
    !.

is_Value(['"' | Js], String, Jsns) :-
    is_String(Js, String, Jsns, []).

is_Value(['true' | Jsns], 'true', Jsns).

is_Value(['false' | Jsns], 'false', Jsns).

is_Value(['null' | Jsns], 'null', Jsns).

is_Value(['{' | Js], jsonobj(O), Acc) :-
    members(Js, O, Acc).

is_Value(['[' | Js], jsonarray(O), Acc) :-
    elements(Js, O, Acc).

%%% end/3
%%% conclude i Members

end(['}'], [], []) :-
    !.

end(['}', ',' | Acc], [], [',' | Acc]) :-
    !.

end(['}' | Acc], [], Acc):-
    !.

end([',' | Altro], MoreMembers, Acc) :-
    members(Altro, MoreMembers, Acc).

%%% fine/3
%%% conclude gli Elements

fine([']', ',' | Acc], [], [',' | Acc]) :-
    !.

fine([']'], [], []) :-
    !.

fine([']' | Acc], [], Acc) :-
    !.

fine([',' | Altro], MoreElements, Acc) :-
    elements(Altro, MoreElements, Acc).


%%% jsonaccess/3

jsonaccess(jsonobj(Result), [], jsonobj(Result)) :-
    !.

jsonaccess(jsonobj(O), [Field], Result) :-
    ricerca(O, Field, Result),
    !.

jsonaccess(jsonobj(O), [Field | X], Result) :-
    ricerca(O, Field, Os),
    !,
    jsonaccess(Os, X, Result).

jsonaccess(jsonobj(O), Field, Result) :-
    ricerca(O, Field, Result).

jsonaccess(jsonarray(O), [Field], Result) :-
    number(Field),
    ricercArray(O, Field, Result),
    !.

jsonaccess(jsonarray(O), [Field | X], Result) :-
    number(Field),
    ricercArray(O, Field, Os),
    !,
    jsonaccess(Os, X, Result).



%%% ricerca/3
%%% ricerca il valore corrispondente al Field nei Members

ricerca([], _, _) :-
    !.

ricerca([(Field, Result) | Os], Field, Result) :-
    ricerca(Os, Field, Result),
    !.

ricerca([_ | Os], Field, Result) :-
    ricerca(Os, Field, Result),
    !.

%%% ricercArray/3
%%% ricerca il valore corrispondente al Field negli Elements

ricercArray([Result | _], 0, Result).

ricercArray([_ | Os], Field, Result) :-
    Field1 is Field - 1,
    ricercArray(Os, Field1, Result).


%%% jsonread/2
%%% apre il file FileName e ha successo se riesce
%%% a costruire un oggetto JSON.

jsonread(FileName, JSON) :-
    open(FileName, read, In),
    read_string(In, _, String),
    jsonparse(String, JSON),
    close(In).


%%% jsondump/2

jsondump(jsonobj(O), FileName) :-
    rejson(O, W),
    atomics_to_string(['{' | W], Write),
    open(FileName, write, In),
    write(In, Write),
    close(In).

jsondump(jsonarray(O), FileName) :-
    rejsonA(O, W),
    atomics_to_string(['[' | W], Write),
    open(FileName, write, In),
    write(In, Write),
    close(In).


rejson([(X, Y)], ['"', X, '"', ' : ', Y, '}']) :-
    number(Y),
    !.

rejson([(X, jsonobj(Y))], ['"', X, '"', ' : ', '{',  NewYS, '}']) :-
    rejson(Y, NewY),
    !,
    atomics_to_string(NewY, NewYS).

rejson([(X, jsonarray(Y))], ['"', X, '"', ' : ', '[', NewYS, '}']) :-
    rejsonA(Y, NewY),
    !,
    atomics_to_string(NewY, NewYS).

rejson([(X, 'true')], ['"', X, '"', ' : ', 'true', '}']) :-
    !.

rejson([(X, 'false')], ['"', X, '"', ' : ', 'false', '}']) :-
    !.

rejson([(X, 'null')], ['"', X, '"', ' : ', 'null', '}']) :-
    !.

rejson([(X, Y)], ['"', X, '"', ' : ', '"', Y, '"', '}']) :-
    !.


rejson([(X, Y) | More], ['"', X, '"', ' : ', Y | Write]) :-
    number(Y),
    !,
    rejson(More, Write).

rejson([(X, jsonobj(Y)) | More],
       ['"', X, '"', ' : {', NewYS, ', ' | Write]) :-
    rejson(Y, NewY),
    !,
    atomics_to_string(NewY, NewYS),
    !,
    rejson(More, Write).

rejson([(X, jsonarray(Y)) | More],
       ['"', X, '"', ' : [', NewYS, ', ' | Write]) :-
    rejsonA(Y, NewY),
    !,
    atomics_to_string(NewY, NewYS),
    !,
    rejson(More, Write).

rejson([(X, 'true') | More],
       ['"', X, '"', ' : ', 'true', ', ' | Write]) :-
    More \= [],
    !,
    rejson(More, Write).

rejson([(X, 'false') | More],
       ['"', X, '"', ' : ', 'false', ', ' | Write]) :-
    More \= [],
    !,
    rejson(More, Write).

rejson([(X, 'null') | More],
       ['"', X, '"', ' : ', 'null', ', ' | Write]) :-
    More \= [],
    !,
    rejson(More, Write).

rejson([(X, Y) | More],
       ['"', X, '"', ' : ', '"', Y, '"', ', ' | Write]) :-
    More \= [],
    !,
    rejson(More, Write).

rejson([], ['}']) :-
    !.

rejsonA([], [']']) :-
    !.

rejsonA([X], [X | Write]) :-
    number(X),
    !,
    rejsonA([], Write).

rejsonA([jsonobj(X)], ['{', NewXS | Write]) :-
    rejson(X, NewX),
    !,
    atomics_to_string(NewX, NewXS),
    rejsonA([], Write).

rejsonA([jsonarray(X)], ['[', NewXS | Write]) :-
    rejsonA(X, NewX),
    !,
    atomics_to_string(NewX, NewXS),
    rejsonA([], Write).

rejsonA(['true'], ['true' | Write]) :-
    rejsonA([], Write),
    !.
rejsonA(['false'], ['false' | Write]) :-
    rejsonA([], Write),
    !.
rejsonA(['null'], ['null' | Write]) :-
    rejsonA([], Write),
    !.

rejsonA([X], ['"', X, '"' | Write]) :-
    rejsonA([], Write),
    !.

rejsonA([X | More], [X, ', ' | Write]) :-
    number(X),
    !,
    rejsonA(More, Write).

rejsonA([jsonobj(X) | More], ['{', NewXS, ', ' | Write]) :-
    rejson(X, NewX),
    !,
    atomics_to_string(NewX, NewXS),
    rejsonA(More, Write).

rejsonA([jsonarray(X) | More], ['[', NewXS, ', ' | Write]) :-
    rejsonA(X, NewX),
    !,
    atomics_to_string(NewX, NewXS),
    rejsonA(More, Write).

rejsonA(['true' | More], ['true, ' | Write]) :-
    rejsonA(More, Write),
    !.

rejsonA(['false' | More], ['false, ' | Write]) :-
    rejsonA(More, Write),
    !.

rejsonA(['null' | More], ['null, ' | Write]) :-
    rejsonA(More, Write),
    !.

rejsonA([X | More], ['"', X, '", ' | Write]) :-
    rejsonA(More, Write),
    !.

%%%% end of file - jsonparser.pl











