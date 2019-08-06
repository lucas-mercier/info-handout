================
Types composites
================

.. index:: struct

Structures
==========

Les structures sont des déclarations permettant de regrouper une liste de variables dans un même bloc mémoire et permettant de s'y référer à partir d'une référence commune. Historiquement le type ``struct`` a été dérivé de ``ALGOL 68``. Il est également utilisé en C++ et est similaire à une classe.

La structure suivante décrit un aggrégat de trois grandeurs scalaires formant un point tridimensionnel:

.. code-block:: c

    struct Point {
        double x;
        double y;
        double z;
    };

Cette structure peut être utilisée par la suite de la façon suivante:

.. code-block:: c

    double norm(struct point p) {
        return sqrt(p.x * p.x + p.y * p.y + p.z + p.z);
    }

    int main(void) {
        struct Point p = { .x = 12.54, .y = -8.12, .z = 0.68 };

        double n = norm(p);
    }

On comprends aisément que l'avantage des structures et le regroupement de variables. Une structure peut être la composition d'autres types composites:

.. code-block:: c

    struct Line {
        struct Point a;
        struct Point b;
    }

Alignement mémoire
------------------

Une structure est agencée en mémoire dans l'ordre de sa déclaration.

.. code-block:: c

    struct Line lines[2];

.. code-block:: text

    0x0000 line[0].a.x
    0x0004 line[0].a.y
    0x0008 line[0].a.z
    0x000C line[0].b.x
    0x0010 line[0].b.y
    0x0014 line[0].b.z
    0x0018 line[1].a.x
    0x001C line[1].a.y
    0x0020 line[1].a.z
    0x0024 line[1].b.x
    0x0028 line[1].b.y
    0x002C line[1].b.z

Néanmoins, le compilateur se réserve le droit d'optimiser l' `alignement mémoire <https://fr.wikipedia.org/wiki/Alignement_en_m%C3%A9moire>`__. Une architecture 32-bits aura plus de facilité à accéder à des grandeurs de 32 bits or, une structure composée de plusieurs entiers 8-bits demanderait au processeur un coût additionnel pour optimiser le stockage d'information. Aussi la structure suivante sera implémentée différemment par le compilateur:

.. code-block:: c

    struct NoAlign
    {
        int8_t c;
        int32_t d;
        int64_t i;
        int8_t a[3];
    };

Le compilateur, selon l'architecture donnée, va insérer des éléments de rembourrage (*padding*) pour forcer l'alignement mémoire et ainsi optimiser les lectures:

.. code-block:: c

    struct Align
    {
        int8_t c;
        int8_t __pad1[3]; // Inséré par le compilateur
        int32_t d;
        int64_t i;
        int8_t a[3];
        int8_t __pad2; // Inséré par le compilateur
    };

Notons que réagencer la structure initiale, peut éviter la perte d'espace mémoire. La structure suivante ne sera pas modifée par le compilateur.

.. code-block:: c

    struct Align
    {
        int32_t d;
        int64_t i;
        int8_t a[3];
        int8_t c;
    };

L'option ``-Wpadded`` de GCC permet lever une alerte lorsqu'une structure est alignée par le compilateur.

Structure anonyme
-----------------

Une structure peut être anonyme, c'est à dire qu'elle n'est pas associée à un nom. Cette forme de structure est généralement déconseillée mais elle peut être utilisée:

- Lorsqu'une structure n'est utilisée qu'une seule fois.
- Lorsqu'un type est généré à partir de cette structure (*typedef*).

Champs de bits
==============

Les champs de bits sont des structures dont une information supplémentaire est ajoutée: le nombre de bits utilisés.

Prenons l'exemple du `module I2C <http://www.ti.com/lit/ug/sprug03b/sprug03b.pdf>`__ du microcontrôleur TMS320F28335. Le registre ``I2CMDR`` décrit à la page 23 est un registre 16-bits qu'il conviendrait de décrire avec un champ de bits:

.. code-block::

    struct I2CMDR {
        int  bc  :3;
        bool fdf :1;
        bool stb :1;
        bool irs :1;
        bool dlb :1;
        bool rm  :1;
        bool xa  :1;
        bool trx :1;
        bool mst :1;
        bool stp :1;
        bool _reserved :1;
        bool stt  :1;
        bool free :1;
        bool nackmod :1;
    };

Activer le bit ``stp`` (bit numéro 12) devient une opération triviale:

.. code-block:: c

    struct I2CMDR i2cmdr;

    i2cmdr.stp = true;

Alors qu'elle demandrait une manipulation de bit sinon:

.. code-block:: c

    int32_t i2cmdr;

    i2cmdr |= 1 << 12;

Notons que les champs de bits, ainsi que les structures seront déclarées différemment selon que l'architecture cible est *little-endian* ou *big-endian*.

Unions
======

Une `union <https://en.wikipedia.org/wiki/Union_type>`__ est une variable qui peut avoir plusieurs représentation d'un même contenu mémoire. Rappelez-vous, au :numref:`storage` nous nous demandions quelle était l'interprétation d'un contenu mémoire donné. Il est possible en C d'avoir toute les interprétations à la fois:

.. code-block:: c

    #include <stdint.h>
    #include <stdio.h>

    union Mixed
    {
        int32_t signed32;
        uint32_t unsigned32;
        int8_t signed8[4];
        int16_t signed16[2];
        float float32;
    };

    int main(void) {
        union Mixed m = {
            .signed8 = {0b11011011, 0b0100100, 0b01001001, 0b01000000}
        };

        printf(
            "int32_t\t%d\n"
            "uint32_t\t%u\n"
            "char\t%c, %c, %c, %c\n"
            "short\t%hu, %hu\n"
            "float\t%f\n",
            m.signed32,
            m.unsigned32,
            m.signed8[0], m.signed8[1], m.signed8[2], m.signed8[3],
            m.signed16[0], m.signed16[1],
            m.float32
        );
    }

Les unions sont très utilisées en combinaison avec des champs de bits. Pour reprendre l'exemple du champ de bit évoqué plus haut, on peut souhaiter accéder au registre soit sout la forme d'un entier 16-bits soit via chacuns de ses bits indépendaments.

.. code-block:: c

    union i2cmdr {
        struct {
            int  bc  :3;
            bool fdf :1;
            bool stb :1;
            bool irs :1;
            bool dlb :1;
            bool rm  :1;
            bool xa  :1;
            bool trx :1;
            bool mst :1;
            bool stp :1;
            bool _reserved :1;
            bool stt  :1;
            bool free :1;
            bool nackmod :1;
        } bits;
        uint16_t all;
    };

Nouveau type
============

Le mot clé ``typedef`` permet de déclarer un nouveau type. Il est particulièrement utilisé conjointement avec les structures et les unions afin de s'affranchir de la lourdeur d'écriture (préfixe ``struct``), et dans le but de cacher la complexité d'un type à l'utilisateur qui le manipule.

L'exemple suivant déclare un type ``Point`` et un prototype de fonction permettant l'addition de deux points.

.. code-block:: c

    typedef struct {
        double x;
        double y;
    } Point;

    Point add(Point a, Point b);

Compound Literals
=================

Naïvement traduit en *litéraux composés*, un *compound literal* est une méthode d'initialisation d'un type complexe.

Notons qu'un type composé ne peut pas être initialisé après sa déclaration. L'exemple suivante ne fonctionne pas:

.. code-block:: c

    int array[10];

    // Erreur: l'initialisation tardive n'est pas autorisée.
    array = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9};

Initialisation à zéro
---------------------

La notation particulière ``{0}`` est un `sucre syntaxique <https://fr.wikipedia.org/wiki/Sucre_syntaxique>`__ permettant l'initialisation complète d'une variable à zéro. Elle est nécessaire pour les variables locale car, nous verrons plus loin (c.f. :numref:`memory-management`) les variables globales sont placées dans le segment mémoire ``.bss`` et sont initialisées à zéro au démarrage du programme.

.. code-block:: c

    int array[10] = {0};

    Point point = {0};

Initialisation simple
---------------------

Lors d'une initialisation simple d'un tableau, la taille du tableau est optionnelle, l'exemple suivant comporte une redondance qui peut être souhaitée:

.. code-block:: c

    int array[4] = {1, 2, 3, 4};

Alternativement, et plus fréquemment, les chaines de caractères sont initialisées sans mentionner la taille du tableau:

.. code-block:: c

    char str[] = "Pulp Fiction";

Une structure peut être initialisée de la même manière:

.. code-block:: c

    struct Product {
        int weight; // Grams
        double price; // Swiss francs
        int category;
        char name[64];
    }

    struct Product apple = {321, 0.75, 24, "Pomme Golden"};

Initialisation ciblée
---------------------

Parfois, il est utile d'initialiser seulement certaines valeurs d'une structure, l'opérateur ``.`` peut être utilisé dans une structure et permet l'initialisation ciblée.

Dans l'exemple suivant, on initialise une variable ``banana`` avec un nom et une catégorie. Les autres champs seront initialisés à zéro s'il s'agit d'une variable globale.

.. code-block:: c

    struct Product banana = { .category = 33, .name = "Banane"};

**C99** restreint l'ordre dans lequel les éléments peuvent être initialisés. Ce dernier doit être l'ordre dans lequel les variables sont déclarées dans la structure.

L'initialisation ciblée est également possible avec un tableau:

.. code-block:: c

    int a[6] = { [1] = 12, 23, [4] = 98 };

Initialization à une valeur particulière
----------------------------------------

Cette écriture n'est pas normalisée **C99** mais est généralement compatible avec la majorité des compilateurs.

.. code-block:: c

    int array[1024] = { [ 0 ... 1023 ] = -1 };

En **C99**, il n'est pas possible d'initialiser un type composé à une valeur unique. La manière traditionelle reste la boucle itérative:

.. code-block:: c

    for (size_t i = 0; i < sizeof(array); i++)
        array[i] = -1;


Adresse d'un élément et initialisation avec un scanf
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

L'initialisation de la valeur d'un élément d'un tableau en utilisant la
fonction d'entrée formatée *scanf* est possible en prenant garde à
exprimer correctement l'adresse de l'élément.

La fonction *scanf* a besoin de l'adresse de l'élément à mettre à jour.
L'adresse de l'élément d'un tableau s'écrit simplement en mettant le
signe & devant l'élément.

Par exemple, la forme d'écriture :math:`\&tab[3]` désigne l'adresse du
4ème élément du tableau. On utilisera cette forme pour l'entrée
formatée.

.. code-block:: c

    scanf("%d", &tab[1]); // place l'entrée dans le second élément du tableau

L'adresse du premier élément du tableau notée :math:`\&tab[0]` peut
également s'écrire :math:`tab`. Il en découle une autre forme d'écriture
plus simple.

.. code-block:: c

    scanf("%d", tab+1); // place l'entrée dans le second élément du tableau

L'accès à des éléments dont l'indice dépasse la taille du tableau
engendre des effets de bords imprévisibles. La lecture de tels éléments
donne généralement des valeurs inattendues. L'écriture peut par contre
engendrer des problèmes plus graves comme la modification d'autres
variables ou des 'plantage' de votre application. Ces problèmes sont en
général difficiles à traiter, aussi il est important de bien vérifier
les valeurs des indices utilisées pour accéder aux éléments d'un
tableau.

Tableaux à plusieurs dimensions
-------------------------------

Les tableaux en langage C permettent également de définir un ensemble de
données du même type à l'aide d'une seule et même variable associée à
'n' indices pour l'accès, 'n' correspondant à la dimension du tableau.

Déclaration
~~~~~~~~~~~

On utilise le même principe que pour le tableau à une dimension mais en
mettant autant de paire de crochets qu'il y a de dimensions.

Règle d'écriture :

.. code-block:: c

    type identifiant[taille_dimension1][taille_dimension2]...;

Exemple de déclaration d'un tableau de 10 x 20 entiers nommé tab :

.. code-block:: c

    #define DIM1    10
    #define DIM2    20
    int tab[DIM1][DIM2];

Initialisation
~~~~~~~~~~~~~~

Un simple exemple montre la simplicité de mise en œuvre.

.. code-block:: c

    #define COLS    4 // 4 colones
    #define ROWS    3 // 3 lignes
    double matrice[ROWS][COLS] = {
      { 1.4, 2.3, 3.3, 5.4 }, // 1ère ligne
      { 3.4, 1.2, 8.6, 5.7 }, // 2nde ligne
      { 7.2, 8.1, 4.3, 3.9 }  // troisième ligne
    };

Accès aux éléments du tableau
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Comme pour les tableaux à une dimension, on lit ou modifie les valeurs
d'un élément en plaçant entre crochets les indices idoines.

.. code-block:: c

    x=matrice[2][3];    // lecture

    matrice[0][0]=0.1;  // modification

Si on désire accéder à l'adresse d'un élément, on utilisera le caractère
& devant le nom du tableau indicé ou une écriture plus légère utilisant
une référence sur le tableau.

.. code-block:: c

    scanf("%lf", &matrice[2][3]);   // ces deux lignes
    scanf("%lf", matrice+2*COLS+3); // sont équivalentes

Chaînes de caractères
---------------------

Définition
~~~~~~~~~~

Une chaîne de caractères est une suite de caractères formant un texte.
Dans sa représentation en mémoire, on trouve ainsi les caractères
composant la chaîne plus un dernier dont la valeur vaut zéro, indiquant
la fin de chaine.

Exemple : la chaîne 'ABCD' qui comporte 4 caractères sera représentée en
mémoire par 5 valeurs : 'A', 'B', 'C', 'D', 0.

Déclaration
~~~~~~~~~~~

Pour déclarer une chaîne de caractères, on reprendra le concept de
tableau, associé au type 'char'.

.. code-block:: c

    char texte1[80]; // déclare un tableau de 80 caractères

Un tableau de N caractères ne pourra contenir un chaîne que de N-1
caractères car il faut garder un octet pour la valeur de fin de chaîne
zéro.

Initialisation
~~~~~~~~~~~~~~

L'initialisation est calquée sur celle des tableaux.

.. code-block:: c

    char texte1[]="Bonjour";
    char texte2[100]="ABCDEFG";
    char texte3[8]={'b','o','n','j','o','u','r','\0'};

Notez l'utilisation du caractère :math:`\backslash 0` pour la valeur
zéro afin de créer la fin de chaîne.

Il est possible également de définir et initialiser une chaîne de
caractère constante. Le contenu ne sera pas modifiable.

.. code-block:: c

    const char texte4[]="Chaine constante";

Espace mémoire occupé par une chaîne et taille affichée
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

L'espace en mémoire utilisé par une chaîne de caractère est donné par la
fonction *sizeof*. Elle retourne une valeur en octets.

.. code-block:: c

    char texte1[]="Bonjour";

    printf("espace utilise : %d octets", sizeof(texte1));   // affiche 8

Il ne faut pas confondre la valeur de l'espace mémoire occupée par la
chaîne et la taille de la chaîne affichée (délimité par le délimiteur de
fin de chaîne zéro).

.. code-block:: c

    char texte2[100]="Bonjour";

    printf("espace utilise : %d octets", sizeof(texte2);    // affiche 100
    printf("taille         : %d octets", strlen(texte2);    // affiche 7

La fonction *strlen* impose d'inclure le fichier de définition
*string.h*.

Affichage et saisie
~~~~~~~~~~~~~~~~~~~

L'affichage et la saisie se fait simplement en utilisant les fonctions
*printf* et *scanf*. Le *printf* affichera la chaîne passée en argument
jusqu'à ce qu'il rencontre le caractère zéro.

.. code-block:: c

    char texte1[]="Bonjour";

    printf("%s",texte1); // %s indique un format type chaîne de caractères
    printf(texte1);

Pour la saisie, on passera à la fonction scanf l'adresse de la chaîne,
représentée tout simplement par le nom de la chaîne.

.. code-block:: c

    char texte1[100];

    scanf("%s",texte1); // %s indique un format type chaîne de caractères

Attention toutefois lors de l'utilisation du scanf pour la saisie d'une
chaîne de caractères ! Le caractère 'espace' étant considéré par défaut
comme séparateur de champs par la fonction scanf, il n'est pas possible
de saisir une chaîne comportant plusieurs mots séparés par des espaces
en une seule fois. On ne peut saisir qu'un seul mot.

Pour la saisie d'une chaîne comportant plusieurs mots, on utilisera la
fonction *gets* dont le prototype est le suivant :

.. code-block:: c

    char *gets(char *buffer);

Cette fonction saisit la ligne entière jusqu'à ce qu'elle rencontre le
caractère de fin de ligne \\n et la place dans *buffer*. Elle renvoie
*buffer* en cas de succès, ou *NULL* sinon.

Exemple d'application :

.. code-block:: c

    int main() {

        char reference_article[80];

        printf("Reference article:");
        gets(reference_article);
        printf("Article choisi : %s\n", reference_article);

        return 0;
    }

Tableaux de chaînes de caractères
---------------------------------

Il est parfois utile de créer des tableaux de chaînes de caractères.
Deux déclarations sont possible et ont des impacts différents sur la
taille mémoire occupée.

Définitions des tableaux de chaînes de caractères
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

On définit un tableau de *n* chaînes de *x* caractères.

.. code-block:: c

    char chaine[4][10]; // un tableau de 4 chaînes de 10 caractères

On peut aussi définir la taille d'un tableau par initialisation avec des
chaînes de longueurs égales.

.. code-block:: c

    char types_composants[][20]= {

      "résistance",
      "condensateur",
      "self",
      "transistor",
      "diode"       // un tableau de 5 chaînes
    };              // chaque chaîne peut contenir 20 caractères
                    // taille en mémoire = 5x20 = 100 octets

En dernier lieu, il est possible de créer un tableau par initialisation
avec des chaînes de longueurs différentes.

.. code-block:: c

    char *types_composants[]=
    {
      "résistance",
      "condensateur",
      "self",
      "transistor",
      "diode"       // un tableau de 5 chaînes
    };              // chaque chaîne est de longueur différente
                    // taille en mémoire = 11+13+5+11+6=46 octets

Notez la déclaration avec une étoile devant le nom de la variable pour
indiquer au compilateur que l'on déclare un tableau de caractères.

Emumérations
============

Champs de bit
-------------

Il est parfois nécessaire de regrouper plusieurs informations dans un
type de données. Nous avons vu pour cela qu'il était possible d'utiliser
les structures.

Dans un contexte où la place mémoire disponible pour les données est
restreinte, on est amené à concentrer les informations. Pour cela, on
utilise les champs de bit.

D'un autre côté, lorsque l'on développe des logiciels ayant pour but de
communiquer avec des périphériques fonctionnant avec des registres, il
est courant qu'un registre contienne plusieurs informations. On
utilisera avantageusement les champs de bit pour y accéder.

Définition
~~~~~~~~~~

Un champs de bit est la réunion de plusieurs données identifiées chacune
par un nom et une taille définie par un nombre de bit. Ces informations
sont définies sous la forme d'une structure dont les données affectées à
des champs de bit sont du type entier.

Déclaration
~~~~~~~~~~~

On utilise la déclaration d'une structure en ajoutant la taille des
champs de bit.

.. code-block:: c

    typedef struct {

      int   valide:1;
      int   sens:1;
      int   vitesse:4;
      int   erreur:2;
      int   :1;
      int   consigne:4;

    } sRegistre;

Cette structure définit un type *sRegistre* qui contient 4 variables
rassemblées sous la forme d'un champs de bit. La variable 'valide' est
codée sur 1 bit, 'sens' sur un bit, 'vitesse' sur 4 bit ( valeurs
possibles de 0 à 15), 'erreur' sur de 2 bit (valeurs possibles de 0 à 3)
puis un bit non utilisé et enfin 'consigne' sur 4 bit. Autre exemple :
la représentation du type *float* :

.. code-block:: c

    typedef struct {

      unsigned int  mantisse:23,
                    exposant:8,
                    signe:1;

    } sFloat;

Notez la virgule après les champs mantisse et exposant, évitant de
répeter le type.

Utilisation
~~~~~~~~~~~

La lecture ou l'écriture des variables déclarées sous la forme de champs
de bit s'effectue comme pour les champs d'une structure.

.. code-block:: c

    sRegistre registre; // déclaration
    int csg;

    registre.vitesse=4; // initialise le champs vitesse à 4
    csg=registre.consigne;  // la consigne est placée dans csg

Énumérations
------------

Ce style d'écriture permet de définir un type de données contenant un
nombre fini de valeurs. Ces valeurs sont nommées textuellement et
définies numériquement dans le type énuméré.

Déclaration
~~~~~~~~~~~

On utilise une notation permettant de définir un nouveau type.

.. code-block:: c

    typedef enum {

      E_NOIR, // vaut zéro par défaut
      E_MARRON,
      E_ROUGE,
      E_ORANGE,
      E_JAUNE,
      E_VERT,
      E_BLEU,
      E_VIOLET,
      E_GRIS,
      E_BLANC

    } eCodeCouleurResistance;

Le type est apparenté à un entier (int). Sans autre précisions, la
première valeur vaut 0, la suivante 1, etc.

Il est possible de forcer les valeurs de la manière suivante :

.. code-block:: c

    typedef enum {

      E_M_NOIR=1,
      E_M_MARRON=10,
      E_M_ROUGE=100,
      E_M_ORANGE=1000

    } eMultiplicateurResistance;

ou encore :

.. code-block:: c

    typedef enum {

      E_M_NOIR=1,
      E_M_TRANSP,   // vaut 2
      E_M_ROUGE=100,
      E_M_ROSE,     // vaut 101
      E_M_ORANGE=1000

    } eMultiplicateurResistance;

Notez que le nom du type énuméré commence par le préfixe ``e`` pour
permettre, lors de la lecture du code, d'identifier facilement que c'est
un type énuméré.

Notez que chaque identificateur commence par le préfixe ``E_`` pour
permettre, lors de la lecture du code, d'identifier facilement que c'est
un élément de type énuméré.

Utilisation
~~~~~~~~~~~

La déclaration de variable de type énuméré s'effectue de la manière
standard (type nom\_de\_variable).

.. code-block:: c

    eeCodeCouleurResistance bague=E_ROUGE;
                        // déclaration et initialisation
                        // (bague vaut donc 2)
