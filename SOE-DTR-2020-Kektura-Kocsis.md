# SOE-DTR-2020-Kektura-Kocsis
## Bevezetés
Van egy 3 főből álló baráti társaság, akik név szerint Anna, Bence és Csabi. Mindhárman a Soproni Egyetem erdőmérnök szak hallgatói, akik arra az elhatározásra jutottak, hogy elég nekik a dendrológia, társulástan és becsléstan, folyamatosan csak tanulnak, szeretnének valamilyen szórakozási és mozgási lehetőséget a Szakestélyek és gyakorlatok kivételével, amit a saját maguk szórakoztatása végett tesznek. Így az a döntés született meg, hogy teljesítik közösen a Kéktúra útvonalat. Természetesen abban ők se hisznek, hogy a szorgalmi időszak közepén képesek lesznek egyedül végig csinálni a teljes távot, de úgy gondolják közösen mindenképpen teljesíteni tudják, még pedig 27 nap alatt. A vizsgák miatt nem ér rá egyik barát se minden nap, így erre is oda kell figyelniük ki mikor szabad. Abban megállapodtak, hogy egy szakaszt mindig csak egyikük sétálja le, de sose egyedül. Fontos, hogy a hallgatók vigyék a hírt, hogy ők Kéktúrát teljesítenek, így bárki csatlakozhat hozzájuk egy túraszakasz lesétálásához. (Reméljük a végére rengeteg új ismerősük lesz az Alma Materen belül.) Mindhárom barátnak van egy tolerancia szintje mennyit tud sétálni, Csabi szintje a legalacsonyabb, de még mindig a Kéktúráról beszélünk, így csak irigyelni tudjuk az ő teljesítését is. Valamint beszélhetünk arról is, hogy mennyit szeretnének túrázni, hogy biztosan mindannyian azt érezzék magukba, hogy beletettek mindent ebbe az elhatározásba. A 3 barátnak van egy olyan értéke is, hogy mennyit bír egyhuzamban egyszerre sétálni. Az eddigi túráik során azt is lejegyezték, ki milyen átlagsebességgel tesz meg egy km-t óránként, így összességében szeretnénk minimalizálni az időt, hogy mennyi idő alatt lehet teljesíteni az 1171,8 km-es távot. (Természetesen nem az a cél, hogy az ember végig fusson ezeken a szakaszokon, akár lehetne maximalizálni is az időt, hogy minél több időt töltsön el a 3 barát a szabadban.)

## Adatok

|          | Sebesség (km/h)| Tolerancia min (km)  | Tolerancia max (km) |
| -------- |:--------------:| :-------------------:|:-------------------:|
| Anna     | 3              | 350                  | 600                 |
| Bence    | 4              | 300                  | 600                 |
| Csabi    | 6.5            | 250                  | 300                 |


## Halmazok

A modellbe két halmaz található. Az egyikbe a 3 barát került bele, a másikba pedig a Kéktúra útvonalnak a szakaszai. A Szakaszok halmaz a megfelelő inicializáláshoz szükség van egy paraméterre is a szakaszSzam-ra, hogy egyszerűbben tudjuk megadni, hány szakaszunk van összesen.

``` ampl
set Baratok;

param szakaszSzam;
set Szakaszok:=1..szakaszSzam;
```

## Paraméterek

6+1 paraméttere van szükségem. A szakaszszámot az előbbiekben leírtam. A sebességben a 3 hallgató adja meg az átlagsebességét km/h-ba. A tolerancia max és min pedig megadja mennyit szeretnének sétálni km-be. A toleranciaEgyTav-ba kerül be, ki mennyit tud egyhuzamban sétálni, a hossz pedig a Kéktúra szakaszainak a hosszát adja meg km-be. Végül pedig a szabad, egy két dimenziós paraméter, hogy ki melyik nap ér rá.

```ampl
param sebesseg {Baratok};
param toleranciaMax {Baratok} integer;
param toleranciaMin {Baratok} integer;
param toleranciaEgyTav {Baratok} ;
param hossz {Szakaszok};
param szabad {Baratok, Szakaszok};
```

## Változó

Egy darab változóra van szükségem a modellhez, ami eldönti, hogy az adott szakaszt melyik barát fogja teljesíteni, ez binary értéket vesz fel.

```ampl
var setal{Baratok, Szakaszok}, binary;
```

## Korlátozások

Ebbe azt korlátozzuk le, hogy egy szakaszt a három barát közül csak az egyikük sétálja le.
```ampl
s.t. egySzakasztEgyEmber{sz in Szakaszok}:
	sum{b in Baratok} setal[b,sz] = 1;
```

A toleranciaSzintMaxnalKevesebb korlátozásba, nem engedjük meg, hogy valaki többet sétáljon, mint amennyit beállított magának tolerancia maximumnak.
```ampl
s.t. toleranciaSzintMaxnalKevesebb{b in Baratok}:
 	sum{sz in Szakaszok} setal[b,sz] *hossz[sz] <= toleranciaMax[b];
```

A harmadik hasonló az előzőhez, hogy senki ne sétáljon kevesebbet, mint amit megadott a toleranciaMin paraméterbe.
```ampl
s.t. toleranciaSzintMinLehetseges {b in Baratok}:
 	sum{sz in Szakaszok} setal[b,sz] *hossz[sz] >= toleranciaMin[b];
```

Ez a korlátozás nem engedélyezi, hogy valaki olyan szakaszt teljesítsen, ami nagyobb, mint az általa megadott érték, amennyit bír egyszerre sétálni.
```ampl
s.t. NeTeljesitseHaNemBirja{b in Baratok, sz in Szakaszok: hossz[sz] > toleranciaEgyTav[b]}:
	setal[b,sz]=0;
```

A utolsó korlátozásban meg figyelembe vesszük, hogy ki mikor ér rá és csak akkor sétálhatja az adott távot, ha éppen rá ér az azon napon.
```ampl
s.t. akkorSetalunkHaRaerunk {b in Baratok, sz in Szakaszok: 1> szabad[b, sz]}:
	setal[b,sz]=0;
```

## Célfüggvény
A célfüggvényben minimalizáljuk, hogy mennyi idő alatt lehet teljesíteni a Kéktúra útvonalat.

```ampl
minimize OsszesenIdo:
	sum {sz in Szakaszok, b in Baratok} setal[b,sz] * (hossz[sz]/sebesseg[b]);
```


## Kiíratás

Készült egy kiíratás is, hogy sokkal olvashatóbbak legyenek a kiszámolt adatok.

```ampl
solve;
printf "\n";
for {sz in Szakaszok}
{
  printf " %d. szakasz - %.1f km:",sz, hossz[sz];
    for{b in Baratok:setal[b,sz]=1}
        printf "\t%s\t\n",b;
}

printf "\n";
for{b in Baratok}
{
    printf "%s\t%.1f km\t%d óra\n",b,sum{sz in Szakaszok} hossz[sz]*setal[b,sz], sum{sz in Szakaszok} hossz[sz]*setal[b,sz]*sebesseg[b];
}

printf "\nOsszido: %d óra\n", OsszesenIdo;
printf "\n";
```

## Adatok felvitele

```ampl
data;
set Baratok:=
Anna
Bence
Csabi
;

param szakaszSzam:=27;

param sebesseg := 
Anna 3
Bence 4
Csabi 6.5
;

param toleranciaMax:=
Anna 600
Bence 600
Csabi 300
;

param toleranciaMin:=
Anna 350
Bence 300
Csabi 250
;

param toleranciaEgyTav:=
Anna 70
Bence 50
Csabi 80
;

param hossz := 
1 71.4
2 72.5
3 45.4
4 27.3
5 17.2
6 47.6
7 22.7
8 41.5
9 59.1
10 56.3
11 67.7
12 18.6
13 22.5
14 14.2
15 22.8
16 24.7
17 41.1
18 60.1
19 74.1
20 25.4
21 26.5
22 18.1
23 62.6
24 63.1
25 69.7
26 54.4
27 45.2
;

param szabad: 	1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27:=
Anna 		1 1 1 1 1 0 0 0 1 1  1  1  1  1  1  1  0  1  1  1  1  1  1  1  1  0  1
Bence 		1 1 0 1 1 1 1 1 1 1  1  0  1  0  1  1  1  1  1  1  1  1  0  0  0  1  0
Csabi 		1 1 1 0 1 1 1 1 1 1  1  0  1  1  1  1  1  1  1  1  1  1  1  1  1  1  1
;

end;
```

## Egy általam összerakott példa

Következőkben lehet látni, hogy egy megoldást találtam ki, amibe tételezzük fel, mindegyik barát ráér az összes napon. Az egy távra való toleranciájukat figyelembe véve igyekeztem rendezni őket, de elsőkörben a Bence oszlopát feltölteni, mert neki a legalacsonyabb az egy távra jutó toleranciája. Addig töltöttem, míg el nem érte a minimum megtenni kívánt km-t. Majd következett ugyanígy Anna, majd Csabi. A megmaradt távokat Anna kapta, mert hogy neki a legjobb a sebesség értéke.
Ennek az ideje 302 óra.

| Szakaszok hossza  | Anna  | Bence  | Csabi |
| :---------------: |:-----:| :-----:|:-----:|
| 71,4              |       |        | 71,4  |
| 72,5              |       |        | 72,5  |
| 45,4              |       |  45,4  |       |
| 27,3              |       |  27,3  |       |
| 17,2              |       |  17,2  |       |
| 47,6              |       |  47,6  |       |
| 22,7              |       |  22,7  |       |
| 41,5              |       |  41,5  |       |
| 59,1              | 59,1  |        |       |
| 56,3              | 56,3  |        |       |
| 67,7              | 67,7  |        |       |
| 18,6              |       | 18,6   |       |
| 22,5              |       | 22,5   |       |
| 24,7              |       | 24,7   |       |
| 41,1              |       | 41,1   |       |
| 60,1              | 60,1  |        |       |
| 74,1              |       |        | 74,1  |
| 25,4              | 25,4  |        |       |
| 26,5              | 26,6  |        |       |
| 18,1              | 18,1  |        |       |
| 62,6              | 62,6  |        |       |
| 63,1              |       |        | 63,1  |
| 69,7              | 69,7  |        |       |
| 54,4              | 54,4  |        |       |
| 45,2              | 45,2  |        |       |
|Megtett táv:(km/fő)| 545,2 | 308,6  | 281,1 |
| Idő: (óra/fő)     | 181,7 | 77,1   | 43,2  |
|Összidő: (óra)     |       302  óra         |

## Optimális megoldás
Az optimális megoldás 311 óra. Látható is az out fájlba, hogy a rendszer nem egymás utáni szakaszokat rakott össze egy emberre, hanem tényleg megtalálva a legjobb időeredményt, figyelembe véve a sebességet, a tolerancia szintet, az egy táv toleranciáját, a szakaszok hosszát és hogy ki ér rá az adott napon. Látható, hogy az általam kitalált megoldásnál ez több óra, de akkor még nem vettem számításba, hogy ki mikor ér rá, így lehetséges az, hogy több időt kaptunk optimális megoldásban.

```ampl
Problem:    kektura
Rows:       62
Columns:    81 (81 integer, 81 binary)
Non-zeros:  352
Status:     INTEGER OPTIMAL
Objective:  OsszesenIdo = 311.0423077 (MINimum)
```

Láthatjuk, hogy Anna a tolerancia értékét majdnem elérve sétált 597,3 km-t. Bence a tolerancia értékéhez képest éppen csak teljesíteni tudja a minimumát, míg Csabi éppen a minimum és maximum távolságának a közepén helyezkedik el a 272,4 km-es távjával.

```ampl
Anna	597.3 km	199 óra
Bence	302.1 km	76 óra
Csabi	272.4 km	42 óra

Osszido: 311 óra
```

### Optimális megoldás, ha maximumra állítjuk a túra teljesítésének idejét
Érdekes látni, hogy Anna így is elég közel jár a maximum távjához. És reméltük, hogy Csabi akár el is éri a maximumát, de így is többet sétál, mint a minimum idő keresése során. Bence ugyanúgy éppen átlépi a minimum határértékét.

```ampl
Anna	547.8 km	183 óra
Bence	337.4 km	84 óra
Csabi	286.6 km	44 óra

Osszido: 317 óra
```

## Paraméter érzékenység tesztelése

A sebességet választottam ki, hogy vizsgálhassam a különböző értékek futtatása során. Látható az ábrán, hogy hány km-t tett meg az adott illető, adott sebesség mellett. Az első oszlopban mindenkinek az értékét 3-ra állítottam, hogyha mindenkinek azonos tempója lenne akkor milyen eredmény jött volna ki. Majd ezt követően különböző változatoknál néztem meg, milyen elosztásban teljesítenék a távot a barátok.

![alt text](https://github.com/kocsistimea/SOE-DTR-2020-Kektura-Kocsis/blob/patch-1/image.PNG "1.kép")

## Befejezés
Maga a Kéktúra ötlet onnan jött, hogy 2020. október 10-én volt a Kéktúrázás napja és 70 túraszakaszra osztották fel a teljes útvonalat és regisztrálás alapján egy csoportvezetővel lehetett teljesíteni a túrát. Az esemény különlegessége az volt, hogy minden csoportvezetőnél volt egy GPS és a túrázok mozgása látható volt a térképen és a nap végére kirajzolódott az országot átszelő kék vonal. Ezen a túrán jó magam is részt vettem, még pedig a 24-es túrán, ami Gántról Bodajkra ment el. Ez a táv 23.2 km volt, 380 m volt a szintemelkedés és körülbelül 6 óra alatt teljesítettük. Érdekes csapat jött össze, mert mindenki nagy túrázónak állította be magát, én meg félve mondtam, hogy sose sétáltam ennyit egyszerre, főleg nem ilyen tempóban. Rendesen húzott magával a csoport és a végére tényleg egy csapattá kovácsolódtunk össze, mert ilyen távolságnál, úgy gondolom már szükséges egymás segítsége. A túra végére a fejem búbjától a lábamig, majdnem mindenem fájt és kellett pár nap ahhoz, hogy kiheverjem az izomlázat, de most már visszagondolva nagyon büszke vagyok magamra, amiért sikerült teljesíteni ezt a távot. Azt nem mondanám, hogy még egyszer simán belevágnék egy 23 km-es távba, azért jó lenne építkezve eljutni oda, de egy 10-14 km-t már bármikor szívesen teljesítek. :)
