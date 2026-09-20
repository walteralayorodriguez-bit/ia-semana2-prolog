regla(1, [j], a).            % R1: J -> A
regla(2, [d], a).            % R2: D -> A
regla(3, [d,f], b).          % R3: D ^ F -> B
regla(4, [h,i,j], b).        % R4: H ^ I ^ J -> B
regla(5, [k,h], d).          % R5: K ^ H -> D
regla(6, [c,f], h).          % R6: C ^ F -> H
regla(7, [g,f,i], d).        % R7: G ^ F ^ I -> D
regla(8, [a,b,c], m).        % R8: A ^ B ^ C -> M
regla(9, [c], i).            % R9: C -> I

% Hechos iniciales de la red (los que no son consecuente de ninguna regla)
hechos_iniciales([c,f,g,j,k]).


% =====================================================================
% EJERCICIO 1: ENCADENAMIENTO HACIA DELANTE - solo criterio de prioridad
% =====================================================================
% Conjunto conflicto = reglas cuyos antecedentes ya estan en memoria
% y cuyo consecuente aun NO esta en memoria.
% Se elige y dispara SIEMPRE la de numero mas bajo (mayor prioridad).

conjunto_conflicto(Memoria, ConflictoOrdenado) :-
    findall(N,
        ( regla(N, Ant, Cons),
          \+ member(Cons, Memoria),
          forall(member(A, Ant), member(A, Memoria))
        ),
        Ns),
    sort(Ns, ConflictoOrdenado).   % sort/2 ordena ascendente y quita duplicados

encadenamiento_delante(MemoriaInicial, MemoriaFinal) :-
    format("~n=== EJERCICIO 1: Encadenamiento hacia delante (prioridad) ===~n"),
    format("Memoria inicial: ~w~n~n", [MemoriaInicial]),
    ciclo_delante(MemoriaInicial, MemoriaFinal).

ciclo_delante(Memoria, Memoria) :-
    conjunto_conflicto(Memoria, []),
    !,
    format(">> Conjunto conflicto vacio. Fin del proceso.~n"),
    format(">> Memoria final: ~w~n", [Memoria]).
ciclo_delante(Memoria, MemoriaFinal) :-
    conjunto_conflicto(Memoria, Conflicto),
    Conflicto = [Elegida|_],
    regla(Elegida, Ant, Cons),
    format("Conjunto conflicto: ~w~n", [Conflicto]),
    format("  -> Se dispara R~w (~w -> ~w) por prioridad~n~n", [Elegida, Ant, Cons]),
    ciclo_delante([Cons|Memoria], MemoriaFinal).


% =====================================================================
% EJERCICIO 2: ENCADENAMIENTO HACIA DELANTE - prioridad + refraccion
% =====================================================================
% Igual que el ejercicio 1, pero ademas se lleva una lista de reglas
% YA DISPARADAS y se excluyen del conjunto conflicto aunque sus
% antecedentes se sigan cumpliendo (principio de refraccion: una regla
% no se dispara dos veces con la misma memoria de trabajo).

conjunto_conflicto_refr(Memoria, Disparadas, ConflictoOrdenado) :-
    findall(N,
        ( regla(N, Ant, Cons),
          \+ member(Cons, Memoria),
          \+ member(N, Disparadas),
          forall(member(A, Ant), member(A, Memoria))
        ),
        Ns),
    sort(Ns, ConflictoOrdenado).

encadenamiento_delante_refraccion(MemoriaInicial, MemoriaFinal) :-
    format("~n=== EJERCICIO 2: Encadenamiento hacia delante (prioridad + refraccion) ===~n"),
    format("Memoria inicial: ~w~n~n", [MemoriaInicial]),
    ciclo_delante_refr(MemoriaInicial, [], MemoriaFinal).

ciclo_delante_refr(Memoria, Disparadas, Memoria) :-
    conjunto_conflicto_refr(Memoria, Disparadas, []),
    !,
    format(">> Conjunto conflicto vacio. Fin del proceso.~n"),
    format(">> Reglas disparadas: ~w~n", [Disparadas]),
    format(">> Memoria final: ~w~n", [Memoria]).
ciclo_delante_refr(Memoria, Disparadas, MemoriaFinal) :-
    conjunto_conflicto_refr(Memoria, Disparadas, Conflicto),
    Conflicto = [Elegida|_],
    regla(Elegida, Ant, Cons),
    format("Conjunto conflicto: ~w   (ya disparadas: ~w)~n", [Conflicto, Disparadas]),
    format("  -> Se dispara R~w (~w -> ~w)~n~n", [Elegida, Ant, Cons]),
    ciclo_delante_refr([Cons|Memoria], [Elegida|Disparadas], MemoriaFinal).


% =====================================================================
% EJERCICIO 3: ENCADENAMIENTO HACIA ATRAS - criterio de prioridad
% =====================================================================
% Parte de un OBJETIVO y busca, entre las reglas que lo concluyen,
% la de mayor prioridad (numero mas bajo). Sus antecedentes se
% convierten en subobjetivos, que se prueban recursivamente igual.
% Si un subobjetivo ya es un hecho conocido, se corta ahi.

probar(Objetivo, Memoria, _Nivel) :-
    member(Objetivo, Memoria),
    !,
    format("  ~w ya es un hecho conocido.~n", [Objetivo]).
probar(Objetivo, Memoria, Nivel) :-
    findall(N, regla(N, _, Objetivo), Ns),
    Ns \= [],
    sort(Ns, NsOrdenados),
    format("  Para probar ~w, candidatas por prioridad: ~w~n", [Objetivo, NsOrdenados]),
    member(N, NsOrdenados),
    regla(N, Ant, Objetivo),
    format("  Intentando R~w para ~w (necesita: ~w)~n", [N, Objetivo, Ant]),
    NivelSig is Nivel + 1,
    forall(member(A, Ant), probar(A, Memoria, NivelSig)),
    format("  >> R~w tuvo exito: ~w queda probado.~n", [N, Objetivo]),
    !.

encadenamiento_atras(Objetivo, HechosIniciales) :-
    format("~n=== EJERCICIO 3: Encadenamiento hacia atras (prioridad) ===~n"),
    format("Objetivo: ~w   Hechos conocidos: ~w~n~n", [Objetivo, HechosIniciales]),
    ( probar(Objetivo, HechosIniciales, 0)
    -> format("~n>> RESULTADO: ~w es VERDADERO.~n", [Objetivo])
    ;  format("~n>> RESULTADO: no se pudo probar ~w con los hechos dados.~n", [Objetivo])
    ).


% =====================================================================
% CONSULTAS DE EJEMPLO
% =====================================================================
% ?- hechos_iniciales(H), encadenamiento_delante(H, Final).
% ?- hechos_iniciales(H), encadenamiento_delante_refraccion(H, Final).
% ?- hechos_iniciales(H), encadenamiento_atras(m, H).