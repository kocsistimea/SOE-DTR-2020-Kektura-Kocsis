set Baratok;

param szakaszSzam;
set Szakaszok:=1..szakaszSzam;

param sebesseg {Baratok};
param toleranciaMax {Baratok} integer;
param toleranciaMin {Baratok} integer;
param hossz {Szakaszok};

var setal{Baratok, Szakaszok}, binary;

s.t. egySzakasztEgyEmber{sz in Szakaszok}:
	sum{b in Baratok} setal[b,sz] = 1;

s.t. toleranciaSzintMaxnalKevesebb{b in Baratok}:
	sum{sz in Szakaszok} setal[b,sz] *hossz[sz] <= toleranciaMax[b];

s.t. toleranciaSzintMinLehetseges {b in Baratok}:
	sum{sz in Szakaszok} setal[b,sz] *hossz[sz] >= toleranciaMin[b];

minimize OsszesenIdo:
	sum {sz in Szakaszok, b in Baratok} setal[b,sz] * (hossz[sz]*sebesseg[b]);

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
end;
