
:- discontiguous tiene_pelo/1.
:- discontiguous da_leche/1.
:- discontiguous come_carne/1.
:- discontiguous tiene_dientes_puntiagudos/1.
:- discontiguous tiene_garras/1.
:- discontiguous tiene_ojos_al_frente/1.
:- discontiguous color_leonado/1.
:- discontiguous tiene_manchas_oscuras/1.
:- discontiguous tiene_rayas_negras/1.
:- discontiguous tiene_pezunas/1.
:- discontiguous cuello_largo/1.
:- discontiguous piernas_largas/1.
:- discontiguous tiene_plumas/1.
:- discontiguous pone_huevos/1.
:- discontiguous color_blanco_negro/1.
:- discontiguous nada/1.
:- discontiguous vuela/1.
:- discontiguous vuela_bien/1.
:- discontiguous especie/2.

% ==========================================
% REGLAS (R1 - R16)
% ==========================================

mamifero(X) :- tiene_pelo(X).
mamifero(X) :- da_leche(X).

ave(X) :- tiene_plumas(X).
ave(X) :- vuela(X), pone_huevos(X).

carnivoro(X) :- come_carne(X).
carnivoro(X) :-
    tiene_dientes_puntiagudos(X),
    tiene_garras(X),
    tiene_ojos_al_frente(X).

ungulado(X) :- mamifero(X), tiene_pezunas(X).
ungulado(X) :- mamifero(X), rumia(X).

leopardo(X) :-
    mamifero(X), carnivoro(X),
    color_leonado(X), tiene_manchas_oscuras(X).

tigre(X) :-
    mamifero(X), carnivoro(X),
    color_leonado(X), tiene_rayas_negras(X).

jirafa(X) :-
    ungulado(X), cuello_largo(X),
    piernas_largas(X), tiene_manchas_oscuras(X).

cebra(X) :- ungulado(X), tiene_rayas_negras(X).

avestruz(X) :-
    ave(X), \+ vuela(X),
    cuello_largo(X), piernas_largas(X), color_blanco_negro(X).

pinguino(X) :-
    ave(X), \+ vuela(X),
    nada(X), color_blanco_negro(X).

albatros(X) :- ave(X), vuela_bien(X).

especie(Y, E) :- padre(X, Y), especie(X, E).

% ==========================================
% HECHOS: ROBBIE Y SUZIE
% ==========================================

es_animal(robbie).
tiene_manchas_oscuras(robbie).
come_carne(robbie).

tiene_plumas(suzie).
vuela_bien(suzie).


% =====================================================================
% TRAZADOR HACIA ATRAS (especifico, sin call/1 dinamico -> apto sandbox)
% =====================================================================

% ---------- mamifero ----------
trazar_mamifero(X) :-
    format("Objetivo: mamifero(~w)~n", [X]),
    (   tiene_pelo(X)
    ->  format("  R1: tiene_pelo(~w) es HECHO -> mamifero(~w) EXITO~n", [X,X])
    ;   da_leche(X)
    ->  format("  R2: da_leche(~w) es HECHO -> mamifero(~w) EXITO~n", [X,X])
    ;   format("  R1 necesita tiene_pelo(~w): no es un hecho conocido -> FALLA~n", [X]),
        format("  R2 necesita da_leche(~w): no es un hecho conocido -> FALLA~n", [X]),
        format("  >> FALLA: mamifero(~w) no se pudo probar~n", [X]),
        fail
    ).

% ---------- carnivoro ----------
trazar_carnivoro(X) :-
    format("Objetivo: carnivoro(~w)~n", [X]),
    (   come_carne(X)
    ->  format("  R5: come_carne(~w) es HECHO -> carnivoro(~w) EXITO~n", [X,X])
    ;   tiene_dientes_puntiagudos(X), tiene_garras(X), tiene_ojos_al_frente(X)
    ->  format("  R6: dientes+garras+ojos al frente cumplidos -> carnivoro(~w) EXITO~n", [X])
    ;   format("  R5 necesita come_carne(~w): FALLA~n", [X]),
        format("  R6 necesita dientes_puntiagudos+garras+ojos_al_frente: FALLA~n", []),
        format("  >> FALLA: carnivoro(~w) no se pudo probar~n", [X]),
        fail
    ).

% ---------- color_leonado / manchas_oscuras / vuela_bien (hechos simples) ----------
trazar_color_leonado(X) :-
    format("Objetivo: color_leonado(~w)~n", [X]),
    (   color_leonado(X)
    ->  format("  color_leonado(~w) es un HECHO conocido -> EXITO~n", [X])
    ;   format("  >> FALLA: color_leonado(~w) no es un hecho conocido~n", [X]),
        fail
    ).

trazar_manchas_oscuras(X) :-
    format("Objetivo: tiene_manchas_oscuras(~w)~n", [X]),
    (   tiene_manchas_oscuras(X)
    ->  format("  tiene_manchas_oscuras(~w) es un HECHO conocido -> EXITO~n", [X])
    ;   format("  >> FALLA: tiene_manchas_oscuras(~w) no es un hecho conocido~n", [X]),
        fail
    ).

trazar_vuela_bien(X) :-
    format("Objetivo: vuela_bien(~w)~n", [X]),
    (   vuela_bien(X)
    ->  format("  vuela_bien(~w) es un HECHO conocido -> EXITO~n", [X])
    ;   format("  >> FALLA: vuela_bien(~w) no es un hecho conocido~n", [X]),
        fail
    ).

% ---------- leopardo (R9) ----------
trazar_leopardo(X) :-
    format("~n=== ENCADENAMIENTO HACIA ATRAS: leopardo(~w) ===~n", [X]),
    format("Necesita: mamifero(~w), carnivoro(~w), color_leonado(~w), tiene_manchas_oscuras(~w)~n~n", [X,X,X,X]),
    (   trazar_mamifero(X),
        trazar_carnivoro(X),
        trazar_color_leonado(X),
        trazar_manchas_oscuras(X)
    ->  format("~n>> RESULTADO FINAL: leopardo(~w) es VERDADERO.~n", [X])
    ;   format("~n>> RESULTADO FINAL: no se pudo probar leopardo(~w).~n", [X])
    ).

% ---------- albatros (R15), para comparar un caso que SI tiene exito ----------
trazar_ave(X) :-
    format("Objetivo: ave(~w)~n", [X]),
    (   tiene_plumas(X)
    ->  format("  R3: tiene_plumas(~w) es HECHO -> ave(~w) EXITO~n", [X,X])
    ;   vuela(X), pone_huevos(X)
    ->  format("  R4: vuela+pone_huevos cumplidos -> ave(~w) EXITO~n", [X])
    ;   format("  >> FALLA: ave(~w) no se pudo probar~n", [X]),
        fail
    ).

trazar_albatros(X) :-
    format("~n=== ENCADENAMIENTO HACIA ATRAS: albatros(~w) ===~n", [X]),
    format("Necesita: ave(~w), vuela_bien(~w)~n~n", [X,X]),
    (   trazar_ave(X),
        trazar_vuela_bien(X)
    ->  format("~n>> RESULTADO FINAL: albatros(~w) es VERDADERO.~n", [X])
    ;   format("~n>> RESULTADO FINAL: no se pudo probar albatros(~w).~n", [X])
    ).


% ==========================================
% CONSULTAS DE EJEMPLO
% ==========================================
% ?- trazar_leopardo(robbie).
% ?- trazar_albatros(suzie).