======
Avancé
======

Ce chapitre regroupe les sujets avancés dont la compréhension n'est pas requise pour ce cours.

Complément sur les variables initialisées
=========================================

Le fait de déclarer des variables dans en langage C implique que le
logiciel doit réaliser l'initialisation de ces variables au tout début
de son exécution. De fait, on peut remarquer deux choses. Il y a les
variables initialisées à la valeur zéro et les variables initialisées à
des valeurs différentes de zéro. Le compilateur regroupe en mémoire ces
variables en deux catégories et ajoute un bout de code au début de votre
application (qui est exécuté avant le *main*).

Ce code (que l'on n'a pas à écrire) effectue les opérations suivantes :

-  mise à zéro du bloc mémoire contenant les variables ayant été
   déclarées avec une valeur d'initialisation à zéro

-  recopie d'une zone mémoire contenant les valeurs initiales des
   variables ayant été déclarées avec une valeur d'initialisation
   différente de zéro vers la zone de ces mêmes variables.

Par ce fait, dès que l'exécution du logiciel est effectuée, on a, lors
de l'exécution du *main*, des variables correctement initialisées.

Binutils
========

Les outils binaires (`binutils <https://en.wikipedia.org/wiki/GNU_Binutils>`__) sont une collection de programmes installés avec un compilateur et permettant d'aider au développement et au déboguage. Certains de ces outils sont très pratiques mais nombreux sont les développeurs qui ne les connaissent pas.

``nm``
    Liste tous les symboles dans un fichier objet (binaire). Ce programme appliqué sur le programe hello world de l'introduction donne:

    .. code-block:: console

        $ nm a.out
        0000000000200dc8 d _DYNAMIC
        0000000000200fb8 d _GLOBAL_OFFSET_TABLE_
        00000000000006f0 R _IO_stdin_used
                        w _ITM_deregisterTMCloneTable
                        w _ITM_registerTMCloneTable

        ...

                        U __libc_start_main@@GLIBC_2.2.5
        0000000000201010 D _edata
        0000000000201018 B _end
        00000000000006e4 T _fini
        00000000000004f0 T _init
        0000000000000540 T _start

        ...

        000000000000064a T main
                         U printf@@GLIBC_2.2.5
        00000000000005b0 t register_tm_clones

    On observe notament que la fonciton ``printf`` est en provenance de la bibliothèque GLIBC 2.2.5, et qu'il y a une fonction ``main``.

``strings``
    Liste toutes les chaînes de caractères imprimables dans un fichier binaire. On observe tous les symboles de débug qui sont par défaut intégrés au fichier exécutable. On lit également la chaîne de caractère ``hello, world``. Attention donc à ne pas laisser les éventuels mots de passes ou numéro de license en clair dans un fichier binaire.

    .. code-block:: console

        $ strings a.out
        /lib64/ld-linux-x86-64.so.2
        libc.so.6
        printf

        ...

        AUATL
        []A\A]A^A_
        hello, world
        ;*3$"
        GCC: (Ubuntu 7.4.0-1ubuntu1~18.04.1) 7.4.0

        ...

        _IO_stdin_used
        __libc_csu_init
        __bss_start
        main
        __TMC_END__
        _ITM_registerTMCloneTable
        __cxa_finalize@@GLIBC_2.2.5
        .symtab
        .strtab

        ...

        .data
        .bss
        .comment

``size``
    Liste la taille des segments mémoire utilisés. Ici le programme représente 1517 bytes, les données initialisées 8 bytes, les données variables 600 bytes, soit une somme décimale de 2125 bytes ou ``84d`` bytes.

    .. code-block:: console

        $ size a.out
        text    data     bss     dec     hex filename
        1517     600       8    2125     84d a.out