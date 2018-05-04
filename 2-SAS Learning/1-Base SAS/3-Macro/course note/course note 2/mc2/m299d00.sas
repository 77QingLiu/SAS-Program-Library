 
/* STUDENTS: DO NOT EXECUTE THIS PROGRAM!     */
/*++++++++++++++++++++++++++++++++++++++++++++*/

/*++++++++++++++++++++++++++++++++++++++++++++*/
/* EXIT AND EXECUTE THE CRE8DATA.SAS PROGRAM */
/* TO SETUP YOUR COURSE DATA ENVIRONMENT     */
/*++++++++++++++++++++++++++++++++++++++++++++*/

/*++++++++++++++++++++++++++++++++++++++++++++*/
/* WARNING: DO NOT ALTER CODE BELOW THIS LINE */
/*++++++++++++++++++++++++++++++++++++++++++++*/
data ORION.BIZLIST;
   attrib company length=$4;
   attrib state length=$2;
   attrib adjustment length=$6;

   infile datalines dsd;
   input
      company
      state
      adjustment
   ;
datalines4;
AT&T,NC,10%OFF
AT&T,OR,3%CHG
AT&T,NE,8%OFF
ABC,NC,12%OFF
ABC,OR,5%OFF
ABC,NE,15%CHG
ACME,NC,10%OFF
ACME,OR,12%OFF
ACME,NE,10%CHG
;;;;
run;

data ORION.CLUB_MEMBERS;
   attrib Club_Code length=$3;
   attrib Customer_ID length=8 label='Customer ID';
   attrib Country length=$2 label='Country' format=$2. informat=$2.;
   attrib First_Name length=$11 label='First Name' format=$11. informat=$11.;
   attrib Last_Name length=$12 label='Last Name' format=$12. informat=$12.;
   attrib Birth_Date length=8 label='Birth Date' format=DATE9. informat=DATE9.;
   attrib Customer_Type length=$39 label='Customer Type' format=$39. informat=$39.;

   infile datalines dsd;
   input
      Club_Code
      Customer_ID
      Country:$2.
      First_Name:$11.
      Last_Name:$12.
      Birth_Date:BEST32.
      Customer_Type:$39.
   ;
datalines4;
ORL,4,US,James,Kvarniq,5291,Orion Club members low activity
GDM,5,US,Sandrina,Stephano,7129,Orion Club Gold members medium activity
GDM,9,DE,Cornelia,Krahl,5171,Orion Club Gold members medium activity
ORH,10,US,Karen,Ballinger,9057,Orion  Club members high activity
ORH,11,DE,Elke,Wallstab,5341,Orion  Club members high activity
ORM,12,US,David,Black,3389,Orion  Club members medium activity
GDL,13,DE,Markus,Sepke,10429,Orion Club Gold members low activity
INT,16,DE,Ulrich,Heyde,-7655,Internet/Catalog Customers
ORM,17,US,Jimmie,Evans,-1963,Orion  Club members medium activity
ORL,18,US,Tonie,Asmussen,-2159,Orion Club members low activity
GDH,19,DE,Oliver S.,Füßling,1514,Orion Club Gold members high activity
ORM,20,US,Michael,Dineley,-259,Orion  Club members medium activity
INT,23,US,Tulio,Devereaux,-3682,Internet/Catalog Customers
INT,24,US,Robyn,Klem,-213,Internet/Catalog Customers
INT,27,US,Cynthia,Mccluney,3392,Internet/Catalog Customers
INT,29,AU,Candy,Kinsey,-9308,Internet/Catalog Customers
GDM,31,US,Cynthia,Martinez,-147,Orion Club Gold members medium activity
ORM,33,DE,Rolf,Robak,-7616,Orion  Club members medium activity
ORL,34,US,Alvan,Goheen,8783,Orion Club members low activity
INT,36,US,Phenix,Hill,1553,Internet/Catalog Customers
GDH,39,US,Alphone,Greenwald,8972,Orion Club Gold members high activity
ORM,41,AU,Wendell,Summersby,1797,Orion  Club members medium activity
ORL,42,DE,Thomas,Leitmann,6979,Orion Club members low activity
GDL,45,US,Dianne,Patchin,7065,Orion Club Gold members low activity
GDH,49,US,Annmarie,Leveille,8963,Orion Club Gold members high activity
GDH,50,DE,Gert-Gunter,Mendler,-9481,Orion Club Gold members high activity
ORM,52,US,Yan,Kozlowski,3383,Orion  Club members medium activity
ORH,53,AU,Dericka,Pockran,-2021,Orion  Club members high activity
ORM,56,US,Roy,Siferd,-9465,Orion  Club members medium activity
ORM,60,US,Tedi,Lanzarone,3430,Orion  Club members medium activity
GDH,61,DE,Carsten,Maestrini,-5655,Orion Club Gold members high activity
GDM,63,US,James,Klisurich,3646,Orion Club Gold members medium activity
ORL,65,DE,Ines,Deisser,3488,Orion Club members low activity
ORL,69,US,Patricia,Bertolozzi,7072,Orion Club members low activity
GDM,71,US,Viola,Folsom,3553,Orion Club Gold members medium activity
ORL,75,US,Mikel,Spetz,8935,Orion Club members low activity
ORM,79,US,Najma,Hicks,9518,Orion  Club members medium activity
ORM,88,US,Attila,Gibbs,-316,Orion  Club members medium activity
ORH,89,US,Wynella,Lewis,-9226,Orion  Club members high activity
GDH,90,US,Kyndal,Hooks,1674,Orion Club Gold members high activity
ORL,92,US,Lendon,Celii,-5587,Orion Club members low activity
ORM,111,AU,Karolina,Dokter,5475,Orion  Club members medium activity
ORH,171,AU,Robert,Bowerman,5166,Orion  Club members high activity
ORL,183,AU,Duncan,Robertshawe,-5760,Orion Club members low activity
ORL,195,AU,Cosi,Rimmington,-5529,Orion Club members low activity
GDM,215,AU,Ramesh,Trentholme,-3882,Orion Club Gold members medium activity
ORH,544,TR,Avni,Argac,1601,Orion  Club members high activity
GDH,908,TR,Avni,Umran,7279,Orion Club Gold members high activity
ORL,928,TR,Bulent,Urfalioglu,3510,Orion Club members low activity
ORL,1033,TR,Selim,Okay,7226,Orion Club members low activity
ORL,1100,TR,Ahmet,Canko,1479,Orion Club members low activity
ORL,1684,TR,Carglar,Aydemir,5403,Orion Club members low activity
GDL,2550,ZA,Sanelisiwe,Collier,10415,Orion Club Gold members low activity
ORM,2618,ZA,Theunis,Brazier,-3938,Orion  Club members medium activity
ORH,2788,TR,Serdar,Yucel,-5843,Orion  Club members high activity
ORM,2806,ZA,Raedene,Van Den Berg,10486,Orion  Club members medium activity
GDH,3959,ZA,Rita,Lotz,1515,Orion Club Gold members high activity
GDL,11171,CA,Bill,Cuddy,9785,Orion Club Gold members low activity
INT,12386,IL,Avinoam,Zweig,-234,Internet/Catalog Customers
ORM,14104,IL,Avinoam,Zweig,1744,Orion  Club members medium activity
ORH,14703,IL,Eyal,Bloch,3554,Orion  Club members high activity
GDH,17023,CA,Susan,Krasowski,-176,Orion Club Gold members high activity
ORH,19444,IL,Avinoam,Zweig,-95,Orion  Club members high activity
GDH,19873,IL,Avinoam,Tuvia,8931,Orion Club Gold members high activity
ORM,26148,CA,Andreas,Rennie,-9298,Orion  Club members medium activity
ORH,46966,CA,Lauren,Krasowski,9793,Orion  Club members high activity
INT,54655,CA,Lauren,Marx,3517,Internet/Catalog Customers
ORL,70046,CA,Tommy,Mcdonald,-346,Orion Club members low activity
ORM,70059,CA,Colin,Byarley,-9477,Orion  Club members medium activity
ORM,70079,CA,Lera,Knott,9688,Orion  Club members medium activity
ORM,70100,CA,Wilma,Yeargan,8940,Orion  Club members medium activity
ORL,70108,CA,Patrick,Leach,-7567,Orion Club members low activity
ORL,70165,CA,Portia,Reynoso,1502,Orion Club members low activity
ORM,70187,CA,Soberina,Berent,9766,Orion  Club members medium activity
GDL,70201,CA,Angel,Borwick,3640,Orion Club Gold members low activity
ORM,70210,CA,Alex,Santinello,9608,Orion  Club members medium activity
ORH,70221,CA,Kenan,Talarr,1501,Orion  Club members high activity
;;;;
run;

data ORION.CONTINENT;
   attrib Continent_ID length=8 label='Continent ID';
   attrib Continent_Name length=$30 label='Continent Name';

   infile datalines dsd;
   input
      Continent_ID
      Continent_Name
   ;
datalines4;
91,North America
93,Europe
94,Africa
95,Asia
96,Australia/Pacific
;;;;
run;

data ORION.COUNTRY;
   attrib Country length=$2 label='Country Abbreviation';
   attrib Country_Name length=$30 label='Current Name of Country';
   attrib Population length=8 label='Population (approx.)' format=COMMA12.;
   attrib Country_ID length=8 label='Country ID';
   attrib Continent_ID length=8 label='Numeric Rep. for Continent';
   attrib Country_FormerName length=$30 label='Former Name of Country';

   infile datalines dsd;
   input
      Country
      Country_Name
      Population
      Country_ID
      Continent_ID
      Country_FormerName
   ;
datalines4;
AU,Australia,20000000,160,96,
CA,Canada,35000000,260,91,
DE,Germany,80000000,394,93,East/West Germany
IL,Israel,5000000,475,95,
TR,Turkey,70000000,905,95,
US,United States,280000000,926,91,
ZA,South Africa,43000000,801,94,
;;;;
run;

data ORION.CUSTOMER;
   attrib Customer_ID length=8 format=12.;
   attrib Country length=$2;
   attrib Gender length=$1;
   attrib Personal_ID length=$15;
   attrib Customer_Name length=$40;
   attrib Customer_FirstName length=$20;
   attrib Customer_LastName length=$30;
   attrib Birth_Date length=8 format=DATE9.;
   attrib Customer_Address length=$45;
   attrib Street_ID length=8 format=12.;
   attrib Street_Number length=$8;
   attrib Customer_Type_ID length=8 format=8.;
   attrib Continent_ID length=8;

   infile datalines dsd;
   input
      Customer_ID
      Country
      Gender
      Personal_ID
      Customer_Name
      Customer_FirstName
      Customer_LastName
      Birth_Date
      Customer_Address
      Street_ID
      Street_Number
      Customer_Type_ID
      Continent_ID
   ;
datalines4;
4,US,M,,James Kvarniq,James,Kvarniq,5291,4382 Gralyn Rd,9260106519,4382,1020,91
5,US,F,,Sandrina Stephano,Sandrina,Stephano,7129,6468 Cog Hill Ct,9260114570,6468,2020,91
9,DE,F,,Cornelia Krahl,Cornelia,Krahl,5171,Kallstadterstr. 9,3940106659,9,2020,93
10,US,F,,Karen Ballinger,Karen,Ballinger,9057,425 Bryant Estates Dr,9260129395,425,1040,91
11,DE,F,,Elke Wallstab,Elke,Wallstab,5341,Carl-Zeiss-Str. 15,3940108592,15,1040,93
12,US,M,,David Black,David,Black,3389,1068 Haithcock Rd,9260103713,1068,1030,91
13,DE,M,,Markus Sepke,Markus,Sepke,10429,Iese 1,3940105189,1,2010,93
16,DE,M,,Ulrich Heyde,Ulrich,Heyde,-7655,Oberstr. 61,3940105865,61,3010,93
17,US,M,,Jimmie Evans,Jimmie,Evans,-1963,391 Greywood Dr,9260123306,391,1030,91
18,US,M,,Tonie Asmussen,Tonie,Asmussen,-2159,117 Langtree Ln,9260112361,117,1020,91
19,DE,M,,Oliver S. Füßling,Oliver S.,Füßling,1514,Hechtsheimerstr. 18,3940106547,18,2030,93
20,US,M,,Michael Dineley,Michael,Dineley,-259,2187 Draycroft Pl,9260118934,2187,1030,91
23,US,M,,Tulio Devereaux,Tulio,Devereaux,-3682,1532 Ferdilah Ln,9260126679,1532,3010,91
24,US,F,,Robyn Klem,Robyn,Klem,-213,435 Cambrian Way,9260115784,435,3010,91
27,US,F,,Cynthia Mccluney,Cynthia,Mccluney,3392,188 Grassy Creek Pl,9260105670,188,3010,91
29,AU,F,,Candy Kinsey,Candy,Kinsey,-9308,21 Hotham Parade,1600103020,21,3010,96
31,US,F,,Cynthia Martinez,Cynthia,Martinez,-147,42 Arrowood Ln,9260128428,42,2020,91
33,DE,M,,Rolf Robak,Rolf,Robak,-7616,Münsterstraße 67,3940102376,67,1030,93
34,US,M,,Alvan Goheen,Alvan,Goheen,8783,844 Glen Eden Dr,9260111379,844,1020,91
36,US,M,,Phenix Hill,Phenix,Hill,1553,417 Halstead Cir,9260128237,417,3010,91
39,US,M,,Alphone Greenwald,Alphone,Greenwald,8972,4386 Hamrick Dr,9260123099,4386,2030,91
41,AU,M,,Wendell Summersby,Wendell,Summersby,1797,9 Angourie Court,1600101527,9,1030,96
42,DE,M,,Thomas Leitmann,Thomas,Leitmann,6979,Carl Von Linde Str. 13,3940109715,13,1020,93
45,US,F,,Dianne Patchin,Dianne,Patchin,7065,7818 Angier Rd,9260104847,7818,2010,91
49,US,F,,Annmarie Leveille,Annmarie,Leveille,8963,185 Birchford Ct,9260104510,185,2030,91
50,DE,M,,Gert-Gunter Mendler,Gert-Gunter,Mendler,-9481,Humboldtstr. 1,3940105781,1,2030,93
52,US,M,,Yan Kozlowski,Yan,Kozlowski,3383,1233 Hunters Crossing,9260116235,1233,1030,91
53,AU,F,,Dericka Pockran,Dericka,Pockran,-2021,131 Franklin St,1600103258,131,1040,96
56,US,M,,Roy Siferd,Roy,Siferd,-9465,334 Kingsmill Rd,9260111871,334,1030,91
60,US,F,,Tedi Lanzarone,Tedi,Lanzarone,3430,2429 Hunt Farms Ln,9260101262,2429,1030,91
61,DE,M,,Carsten Maestrini,Carsten,Maestrini,-5655,Münzstr. 28,3940108887,28,2030,93
63,US,M,,James Klisurich,James,Klisurich,3646,25 Briarforest Pl,9260125492,25,2020,91
65,DE,F,,Ines Deisser,Ines,Deisser,3488,Bahnweg 1,3940100176,1,1020,93
69,US,F,,Patricia Bertolozzi,Patricia,Bertolozzi,7072,4948 Dargan Hills Dr,9260116402,4948,1020,91
71,US,F,,Viola Folsom,Viola,Folsom,3553,290 Glenwood Ave,9260124130,290,2020,91
75,US,M,,Mikel Spetz,Mikel,Spetz,8935,101 Knoll Ridge Ln,9260108068,101,1020,91
79,US,F,,Najma Hicks,Najma,Hicks,9518,9658 Dinwiddie Ct,9260101874,9658,1030,91
88,US,M,,Attila Gibbs,Attila,Gibbs,-316,3815 Askham Dr,9260100179,3815,1030,91
89,US,F,,Wynella Lewis,Wynella,Lewis,-9226,2572 Glenharden Dr,9260116551,2572,1040,91
90,US,F,,Kyndal Hooks,Kyndal,Hooks,1674,252 Clay St,9260111614,252,2030,91
92,US,M,,Lendon Celii,Lendon,Celii,-5587,421 Blue Horizon Dr,9260117676,421,1020,91
111,AU,F,,Karolina Dokter,Karolina,Dokter,5475,28 Munibung Road,1600102072,28,1030,96
171,AU,M,,Robert Bowerman,Robert,Bowerman,5166,21 Parliament House c/- Senator t,1600101555,21,1040,96
183,AU,M,,Duncan Robertshawe,Duncan,Robertshawe,-5760,18 Fletcher Rd,1600100760,18,1020,96
195,AU,M,,Cosi Rimmington,Cosi,Rimmington,-5529,4 Burke Street Woolloongabba,1600101663,4,1020,96
215,AU,M,,Ramesh Trentholme,Ramesh,Trentholme,-3882,23 Benjamin Street,1600102721,23,2020,96
544,TR,M,,Avni Argac,Avni,Argac,1601,A Blok No: 1,9050100008,1,1040,95
908,TR,M,,Avni Umran,Avni,Umran,7279,Mayis Cad. Nova Baran Plaza Ka 11,9050100023,11,2030,95
928,TR,M,,Bulent Urfalioglu,Bulent,Urfalioglu,3510,Turkcell Plaza Mesrutiyet Cad. 142,9050100016,142,1020,95
1033,TR,M,,Selim Okay,Selim,Okay,7226,Fahrettin Kerim Gokay Cad. No. 24,9050100001,24,1020,95
1100,TR,M,,Ahmet Canko,Ahmet,Canko,1479,A Blok No: 1,9050100008,1,1020,95
1684,TR,M,,Carglar Aydemir,Carglar,Aydemir,5403,A Blok No: 1,9050100008,1,1020,95
2550,ZA,F,,Sanelisiwe Collier,Sanelisiwe,Collier,10415,Bryanston Drive 122,8010100009,122,2010,94
2618,ZA,M,,Theunis Brazier,Theunis,Brazier,-3938,Arnold Road 2,8010100125,2,1030,94
2788,TR,M,,Serdar Yucel,Serdar,Yucel,-5843,Fahrettin Kerim Gokay Cad. No. 30,9050100001,30,1040,95
2806,ZA,F,,Raedene Van Den Berg,Raedene,Van Den Berg,10486,Quinn Street 11,8010100089,11,1030,94
3959,ZA,F,,Rita Lotz,Rita,Lotz,1515,Moerbei Avenue 120,8010100151,120,2030,94
11171,CA,M,,Bill Cuddy,Bill,Cuddy,9785,69 chemin Martin,2600100032,69,2010,91
12386,IL,M,,Avinoam Zweig,Avinoam,Zweig,-234,Mivtza Kadesh St 16,4750100001,16,3010,95
14104,IL,M,,Avinoam Zweig,Avinoam,Zweig,1744,Mivtza Kadesh St 25,4750100001,25,1030,95
14703,IL,M,,Eyal Bloch,Eyal,Bloch,3554,Mivtza Boulevard 17,4750100002,17,1040,95
17023,CA,F,,Susan Krasowski,Susan,Krasowski,-176,837 rue Lajeunesse,2600100021,837,2030,91
19444,IL,M,,Avinoam Zweig,Avinoam,Zweig,-95,Mivtza Kadesh St 61,4750100001,61,1040,95
19873,IL,M,,Avinoam Tuvia,Avinoam,Tuvia,8931,Mivtza Kadesh St 18,4750100001,18,2030,95
26148,CA,M,,Andreas Rennie,Andreas,Rennie,-9298,41 Main St,2600100010,41,1030,91
46966,CA,F,,Lauren Krasowski,Lauren,Krasowski,9793,17 boul Wallberg,2600100011,17,1040,91
54655,CA,F,,Lauren Marx,Lauren,Marx,3517,512 Gregoire Dr,2600100013,512,3010,91
70046,CA,M,,Tommy Mcdonald,Tommy,Mcdonald,-346,818 rue Davis,2600100017,818,1020,91
70059,CA,M,,Colin Byarley,Colin,Byarley,-9477,580 Howe St,2600100047,580,1030,91
70079,CA,F,,Lera Knott,Lera,Knott,9688,304 Grand Lake Rd,2600100039,304,1030,91
70100,CA,F,,Wilma Yeargan,Wilma,Yeargan,8940,614 Route 199,2600100015,614,1030,91
70108,CA,M,,Patrick Leach,Patrick,Leach,-7567,1001 Burrard St,2600100046,1001,1020,91
70165,CA,F,,Portia Reynoso,Portia,Reynoso,1502,873 rue Bosse,2600100006,873,1020,91
70187,CA,F,,Soberina Berent,Soberina,Berent,9766,1835 boul Laure,2600100035,1835,1030,91
70201,CA,F,,Angel Borwick,Angel,Borwick,3640,319 122 Ave NW,2600100012,319,2010,91
70210,CA,M,,Alex Santinello,Alex,Santinello,9608,40 Route 199,2600100015,40,1030,91
70221,CA,M,,Kenan Talarr,Kenan,Talarr,1501,9 South Service Rd,2600100019,9,1040,91
;;;;
run;

data ORION.CUSTOMER_DIM;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Customer_Country length=$2 label='Customer Country';
   attrib Customer_Gender length=$1 label='Customer Gender';
   attrib Customer_Name length=$40 label='Customer Name';
   attrib Customer_FirstName length=$20 label='Customer First Name';
   attrib Customer_LastName length=$30 label='Customer Last Name';
   attrib Customer_BirthDate length=8 label='Customer Birth Date' format=DATE9.;
   attrib Customer_Age_Group length=$12 label='Customer Age Group';
   attrib Customer_Type length=$40 label='Customer Type Name';
   attrib Customer_Group length=$40 label='Customer Group Name';
   attrib Customer_Age length=8 label='Customer Age';

   infile datalines dsd;
   input
      Customer_ID
      Customer_Country
      Customer_Gender
      Customer_Name
      Customer_FirstName
      Customer_LastName
      Customer_BirthDate
      Customer_Age_Group
      Customer_Type
      Customer_Group
      Customer_Age
   ;
datalines4;
4,US,M,James Kvarniq,James,Kvarniq,5291,31-45 years,Orion Club members low activity,Orion Club members,33
5,US,F,Sandrina Stephano,Sandrina,Stephano,7129,15-30 years,Orion Club Gold members medium activity,Orion Club Gold members,28
9,DE,F,Cornelia Krahl,Cornelia,Krahl,5171,31-45 years,Orion Club Gold members medium activity,Orion Club Gold members,33
10,US,F,Karen Ballinger,Karen,Ballinger,9057,15-30 years,Orion  Club members high activity,Orion Club members,23
11,DE,F,Elke Wallstab,Elke,Wallstab,5341,31-45 years,Orion  Club members high activity,Orion Club members,33
12,US,M,David Black,David,Black,3389,31-45 years,Orion  Club members medium activity,Orion Club members,38
13,DE,M,Markus Sepke,Markus,Sepke,10429,15-30 years,Orion Club Gold members low activity,Orion Club Gold members,19
16,DE,M,Ulrich Heyde,Ulrich,Heyde,-7655,61-75 years,Internet/Catalog Customers,Internet/Catalog Customers,68
17,US,M,Jimmie Evans,Jimmie,Evans,-1963,46-60 years,Orion  Club members medium activity,Orion Club members,53
18,US,M,Tonie Asmussen,Tonie,Asmussen,-2159,46-60 years,Orion Club members low activity,Orion Club members,53
19,DE,M,Oliver S. Füßling,Oliver S.,Füßling,1514,31-45 years,Orion Club Gold members high activity,Orion Club Gold members,43
20,US,M,Michael Dineley,Michael,Dineley,-259,46-60 years,Orion  Club members medium activity,Orion Club members,48
23,US,M,Tulio Devereaux,Tulio,Devereaux,-3682,46-60 years,Internet/Catalog Customers,Internet/Catalog Customers,58
24,US,F,Robyn Klem,Robyn,Klem,-213,46-60 years,Internet/Catalog Customers,Internet/Catalog Customers,48
27,US,F,Cynthia Mccluney,Cynthia,Mccluney,3392,31-45 years,Internet/Catalog Customers,Internet/Catalog Customers,38
29,AU,F,Candy Kinsey,Candy,Kinsey,-9308,61-75 years,Internet/Catalog Customers,Internet/Catalog Customers,73
31,US,F,Cynthia Martinez,Cynthia,Martinez,-147,46-60 years,Orion Club Gold members medium activity,Orion Club Gold members,48
33,DE,M,Rolf Robak,Rolf,Robak,-7616,61-75 years,Orion  Club members medium activity,Orion Club members,68
34,US,M,Alvan Goheen,Alvan,Goheen,8783,15-30 years,Orion Club members low activity,Orion Club members,23
36,US,M,Phenix Hill,Phenix,Hill,1553,31-45 years,Internet/Catalog Customers,Internet/Catalog Customers,43
39,US,M,Alphone Greenwald,Alphone,Greenwald,8972,15-30 years,Orion Club Gold members high activity,Orion Club Gold members,23
41,AU,M,Wendell Summersby,Wendell,Summersby,1797,31-45 years,Orion  Club members medium activity,Orion Club members,43
42,DE,M,Thomas Leitmann,Thomas,Leitmann,6979,15-30 years,Orion Club members low activity,Orion Club members,28
45,US,F,Dianne Patchin,Dianne,Patchin,7065,15-30 years,Orion Club Gold members low activity,Orion Club Gold members,28
49,US,F,Annmarie Leveille,Annmarie,Leveille,8963,15-30 years,Orion Club Gold members high activity,Orion Club Gold members,23
50,DE,M,Gert-Gunter Mendler,Gert-Gunter,Mendler,-9481,61-75 years,Orion Club Gold members high activity,Orion Club Gold members,73
52,US,M,Yan Kozlowski,Yan,Kozlowski,3383,31-45 years,Orion  Club members medium activity,Orion Club members,38
53,AU,F,Dericka Pockran,Dericka,Pockran,-2021,46-60 years,Orion  Club members high activity,Orion Club members,53
56,US,M,Roy Siferd,Roy,Siferd,-9465,61-75 years,Orion  Club members medium activity,Orion Club members,73
60,US,F,Tedi Lanzarone,Tedi,Lanzarone,3430,31-45 years,Orion  Club members medium activity,Orion Club members,38
61,DE,M,Carsten Maestrini,Carsten,Maestrini,-5655,61-75 years,Orion Club Gold members high activity,Orion Club Gold members,63
63,US,M,James Klisurich,James,Klisurich,3646,31-45 years,Orion Club Gold members medium activity,Orion Club Gold members,38
65,DE,F,Ines Deisser,Ines,Deisser,3488,31-45 years,Orion Club members low activity,Orion Club members,38
69,US,F,Patricia Bertolozzi,Patricia,Bertolozzi,7072,15-30 years,Orion Club members low activity,Orion Club members,28
71,US,F,Viola Folsom,Viola,Folsom,3553,31-45 years,Orion Club Gold members medium activity,Orion Club Gold members,38
75,US,M,Mikel Spetz,Mikel,Spetz,8935,15-30 years,Orion Club members low activity,Orion Club members,23
79,US,F,Najma Hicks,Najma,Hicks,9518,15-30 years,Orion  Club members medium activity,Orion Club members,21
88,US,M,Attila Gibbs,Attila,Gibbs,-316,46-60 years,Orion  Club members medium activity,Orion Club members,48
89,US,F,Wynella Lewis,Wynella,Lewis,-9226,61-75 years,Orion  Club members high activity,Orion Club members,73
90,US,F,Kyndal Hooks,Kyndal,Hooks,1674,31-45 years,Orion Club Gold members high activity,Orion Club Gold members,43
92,US,M,Lendon Celii,Lendon,Celii,-5587,61-75 years,Orion Club members low activity,Orion Club members,63
111,AU,F,Karolina Dokter,Karolina,Dokter,5475,31-45 years,Orion  Club members medium activity,Orion Club members,33
171,AU,M,Robert Bowerman,Robert,Bowerman,5166,31-45 years,Orion  Club members high activity,Orion Club members,33
183,AU,M,Duncan Robertshawe,Duncan,Robertshawe,-5760,61-75 years,Orion Club members low activity,Orion Club members,63
195,AU,M,Cosi Rimmington,Cosi,Rimmington,-5529,61-75 years,Orion Club members low activity,Orion Club members,63
215,AU,M,Ramesh Trentholme,Ramesh,Trentholme,-3882,46-60 years,Orion Club Gold members medium activity,Orion Club Gold members,58
544,TR,M,Avni Argac,Avni,Argac,1601,31-45 years,Orion  Club members high activity,Orion Club members,43
908,TR,M,Avni Umran,Avni,Umran,7279,15-30 years,Orion Club Gold members high activity,Orion Club Gold members,28
928,TR,M,Bulent Urfalioglu,Bulent,Urfalioglu,3510,31-45 years,Orion Club members low activity,Orion Club members,38
1033,TR,M,Selim Okay,Selim,Okay,7226,15-30 years,Orion Club members low activity,Orion Club members,28
1100,TR,M,Ahmet Canko,Ahmet,Canko,1479,31-45 years,Orion Club members low activity,Orion Club members,43
1684,TR,M,Carglar Aydemir,Carglar,Aydemir,5403,31-45 years,Orion Club members low activity,Orion Club members,33
2550,ZA,F,Sanelisiwe Collier,Sanelisiwe,Collier,10415,15-30 years,Orion Club Gold members low activity,Orion Club Gold members,19
2618,ZA,M,Theunis Brazier,Theunis,Brazier,-3938,46-60 years,Orion  Club members medium activity,Orion Club members,58
2788,TR,M,Serdar Yucel,Serdar,Yucel,-5843,61-75 years,Orion  Club members high activity,Orion Club members,63
2806,ZA,F,Raedene Van Den Berg,Raedene,Van Den Berg,10486,15-30 years,Orion  Club members medium activity,Orion Club members,19
3959,ZA,F,Rita Lotz,Rita,Lotz,1515,31-45 years,Orion Club Gold members high activity,Orion Club Gold members,43
11171,CA,M,Bill Cuddy,Bill,Cuddy,9785,15-30 years,Orion Club Gold members low activity,Orion Club Gold members,21
12386,IL,M,Avinoam Zweig,Avinoam,Zweig,-234,46-60 years,Internet/Catalog Customers,Internet/Catalog Customers,48
14104,IL,M,Avinoam Zweig,Avinoam,Zweig,1744,31-45 years,Orion  Club members medium activity,Orion Club members,43
14703,IL,M,Eyal Bloch,Eyal,Bloch,3554,31-45 years,Orion  Club members high activity,Orion Club members,38
17023,CA,F,Susan Krasowski,Susan,Krasowski,-176,46-60 years,Orion Club Gold members high activity,Orion Club Gold members,48
19444,IL,M,Avinoam Zweig,Avinoam,Zweig,-95,46-60 years,Orion  Club members high activity,Orion Club members,48
19873,IL,M,Avinoam Tuvia,Avinoam,Tuvia,8931,15-30 years,Orion Club Gold members high activity,Orion Club Gold members,23
26148,CA,M,Andreas Rennie,Andreas,Rennie,-9298,61-75 years,Orion  Club members medium activity,Orion Club members,73
46966,CA,F,Lauren Krasowski,Lauren,Krasowski,9793,15-30 years,Orion  Club members high activity,Orion Club members,21
54655,CA,F,Lauren Marx,Lauren,Marx,3517,31-45 years,Internet/Catalog Customers,Internet/Catalog Customers,38
70046,CA,M,Tommy Mcdonald,Tommy,Mcdonald,-346,46-60 years,Orion Club members low activity,Orion Club members,48
70059,CA,M,Colin Byarley,Colin,Byarley,-9477,61-75 years,Orion  Club members medium activity,Orion Club members,73
70079,CA,F,Lera Knott,Lera,Knott,9688,15-30 years,Orion  Club members medium activity,Orion Club members,21
70100,CA,F,Wilma Yeargan,Wilma,Yeargan,8940,15-30 years,Orion  Club members medium activity,Orion Club members,23
70108,CA,M,Patrick Leach,Patrick,Leach,-7567,61-75 years,Orion Club members low activity,Orion Club members,68
70165,CA,F,Portia Reynoso,Portia,Reynoso,1502,31-45 years,Orion Club members low activity,Orion Club members,43
70187,CA,F,Soberina Berent,Soberina,Berent,9766,15-30 years,Orion  Club members medium activity,Orion Club members,21
70201,CA,F,Angel Borwick,Angel,Borwick,3640,31-45 years,Orion Club Gold members low activity,Orion Club Gold members,38
70210,CA,M,Alex Santinello,Alex,Santinello,9608,15-30 years,Orion  Club members medium activity,Orion Club members,21
70221,CA,M,Kenan Talarr,Kenan,Talarr,1501,31-45 years,Orion  Club members high activity,Orion Club members,43
;;;;
run;

data ORION.CUSTOMER_TYPE;
   attrib Customer_Type_ID length=8 label='Customer Type ID' format=12.;
   attrib Customer_Type length=$40 label='Customer Type Name';
   attrib Customer_Group_ID length=8 label='Customer Group ID' format=12.;
   attrib Customer_Group length=$40 label='Customer Group Name';

   infile datalines dsd;
   input
      Customer_Type_ID
      Customer_Type
      Customer_Group_ID
      Customer_Group
   ;
datalines4;
1010,Orion Club members inactive,10,Orion Club members
1020,Orion Club members low activity,10,Orion Club members
1030,Orion  Club members medium activity,10,Orion Club members
1040,Orion  Club members high activity,10,Orion Club members
2010,Orion Club Gold members low activity,20,Orion Club Gold members
2020,Orion Club Gold members medium activity,20,Orion Club Gold members
2030,Orion Club Gold members high activity,20,Orion Club Gold members
3010,Internet/Catalog Customers,30,Internet/Catalog Customers
;;;;
run;

data ORION.DAILY_SALES;
   attrib Product_ID length=$12 label='Product_ID' format=$12. informat=$12.;
   attrib Product_Name length=$44 label='Product_Name' format=$44. informat=$44.;
   attrib Total_Retail_Price length=8 label='Total_Retail_Price' format=DOLLAR21.2 informat=DOLLAR21.2;

   infile datalines dsd;
   input
      Product_ID:$12.
      Product_Name:$44.
      Total_Retail_Price:BEST32.
   ;
datalines4;
220200200024,Pro Fit Gel Gt 2030 Women's Running Shoes,178.5
220200100092,Big Guy Men's Air Terra Sebec Shoes,83
240200100043,Bretagne Performance Tg Men's Golf Shoes L.,282.4
220100700024,Armadillo Road Dmx Women's Running Shoes,99.7
220200300157,Hardcore Men's Street Shoes Large,220.2
240200100051,Bretagne Stabilites 2000 Goretex Shoes,420.9
220200100035,Big Guy Men's Air Deschutz Viii Shoes,125.2
220200100090,Big Guy Men's Air Terra Reach Shoes,177.2
220200200018,Lulu Men's Street Shoes,132.8
240200100052,Bretagne Stabilities Tg Men's Golf Shoes,99.7
220100700052,Trooper Ii Dmx-2x Men's Walking Shoes,106.1
220200300116,South Peak Men's Running Shoes,84.2
240100100433,Shoelace White 150 Cm,3
220200300079,Hilly Women's Crosstrainer Shoes,128.6
240200100052,Bretagne Stabilities Tg Men's Golf Shoes,199.4
240200100226,Rubby Men's Golf Shoes w/Goretex Plain Toe,183.9
220200200071,Twain Men's Exit Low 2000 Street Shoes,200.2
220100700042,"Power Women's Dmx Wide, Walking Shoes",171.2
210200400020,Kids Baby Edge Max Shoes,38
210200400070,Tony's Children's Deschutz (Bg) Shoes,41.6
220100400022,Ultra M803 Ng Men's Street Shoes,98.9
220100700022,Alexis Women's Classic Shoes,53.7
220100400023,Ultra W802 All Terrain Women's Shoes,187.2
220200300015,Men's Running Shoes Piedmmont,115
240200100226,Rubby Men's Golf Shoes w/Goretex Plain Toe,183.9
220100700024,Armadillo Road Dmx Women's Running Shoes,313.8
240200100053,Bretagne Stabilities Women's Golf Shoes,174.4
220200100129,Big Guy Men's International Triax Shoes,240
220100700027,Duration Women's Trainer Aerobic Shoes,119
220100700022,Alexis Women's Classic Shoes,170.7
220100700002,Dmx 10 Women's Aerobic Shoes,186.8
220200100035,Big Guy Men's Air Deschutz Viii Shoes,62.6
240100100434,Shoeshine Black,16.4
210201000198,South Peak Junior Training Shoes,120.2
220200200079,Twain Women's Expresso X-Hiking Shoes,285.8
220200300129,Torino Men's Leather Adventure Shoes,406
220200300082,Indoor Handbold Special Shoes,213
240200100225,Rubby Men's Golf Shoes w/Goretex,306.2
240200100227,Rubby Women's Golf Shoes w/Gore-Tex,323.8
220100700046,Tcp 6 Men's Running Shoes,305.8
220200100012,Atmosphere Shatter Mid Shoes,58.7
210201000199,Starlite Baby Shoes,124.2
240200100225,Rubby Men's Golf Shoes w/Goretex,306.2
220200100012,Atmosphere Shatter Mid Shoes,58.7
220200200014,Dubby Low Men's Street Shoes,90
220200200022,Pro Fit Gel Ds Trainer Women's Running Shoes,57.3
240100100434,Shoeshine Black,16.4
240200100053,Bretagne Stabilities Women's Golf Shoes,174.4
220200200036,Soft Astro Men's Running Shoes,120.4
220200200077,Twain Women's Exit Iii Mid Cd X-Hiking Shoes,277.6
220200100009,Atmosphere Imara Women's Running Shoes,126.8
220100700023,Armadillo Road Dmx Men's Running Shoes,73.99
240200100052,Bretagne Stabilities Tg Men's Golf Shoes,201.2
220200200018,Lulu Men's Street Shoes,199.2
220200300154,Hardcore Junior/Women's Street Shoes Large,256.2
220200100137,Big Guy Men's Multicourt Ii Shoes,50.3
240200100053,Bretagne Stabilities Women's Golf Shoes,87.2
220200200035,Soft Alta Plus Women's Indoor Shoes,101.5
;;;;
run;

data ORION.DISCOUNT;
   attrib Product_ID length=8 label='Product ID' format=12.;
   attrib Start_Date length=8 label='Start Date' format=DATE9.;
   attrib End_Date length=8 label='End Date' format=DATE9.;
   attrib Unit_Sales_Price length=8 label='Discount Retail Sales Price per Unit' format=DOLLAR13.2;
   attrib Discount length=8 label='Discount as Percent of Normal Retail Sales Price' format=PERCENT.;

   infile datalines dsd;
   input
      Product_ID
      Start_Date
      End_Date
      Unit_Sales_Price
      Discount
   ;
datalines4;
210100100027,17287,17317,17.99,0.7
210100100030,17379,17409,32.99,0.7
210100100033,17379,17409,161.99,0.7
210100100034,17379,17409,187.99,0.7
210100100035,17287,17317,172.99,0.7
210100100038,17348,17378,59.99,0.6
210100100039,17318,17409,21.99,0.7
210100100048,17379,17409,13.99,0.7
210100100049,17379,17409,10.99,0.7
210200100007,17501,17531,12.99,0.5
210200100010,17348,17378,26.99,0.6
210200100012,17379,17409,13.99,0.7
210200100014,17348,17378,21.99,0.6
210200100015,17379,17409,26.99,0.7
210200100016,17379,17409,22.99,0.7
210200200001,17348,17378,10.99,0.6
210200200020,17348,17378,10.99,0.6
210200200026,17348,17378,12.99,0.6
210200200028,17318,17347,17.99,0.6
210200200030,17379,17409,34.99,0.7
210200300012,17348,17378,11.99,0.6
210200300013,17501,17531,7.99,0.5
210200300025,17501,17531,22.99,0.5
210200300032,17501,17531,23.99,0.5
210200300046,17348,17378,36.99,0.6
210200300050,17318,17347,15.99,0.7
210200300057,17379,17409,23.99,0.7
210200300061,17501,17531,14.99,0.5
210200300094,17379,17409,13.99,0.7
210200400002,17501,17531,25.99,0.5
210200400007,17318,17347,26.99,0.7
210200400039,17501,17531,22.99,0.5
210200400051,17379,17409,29.99,0.7
210200400052,17348,17378,25.99,0.6
210200400092,17501,17531,31.99,0.5
210200400096,17318,17347,34.99,0.7
210200600006,17501,17531,10.99,0.5
210200600013,17348,17378,58.99,0.6
210200600017,17318,17347,25.99,0.7
210200600019,17318,17347,9.99,0.7
210200600024,17501,17531,26.99,0.5
210200600025,17379,17409,26.99,0.7
210200600026,17501,17531,18.99,0.5
210200600037,17318,17347,16.99,0.7
210200600060,17379,17409,36.99,0.7
210200600080,17379,17409,14.99,0.7
210200600086,17501,17531,19.99,0.5
210200600089,17318,17347,11.99,0.7
210200600095,17379,17409,25.99,0.7
210200600097,17348,17378,42.99,0.6
210200600098,17348,17378,17.99,0.6
210200600101,17501,17531,11.99,0.5
210200600103,17348,17378,16.99,0.6
210200600104,17348,17378,8.99,0.6
210200600123,17379,17409,5.99,0.7
210200600125,17379,17409,32.99,0.7
210200900008,17379,17409,23.99,0.7
210200900009,17501,17531,17.99,0.5
210200900024,17318,17409,13.99,0.7
210200900031,17318,17347,34.99,0.7
210200900038,17501,17531,10.99,0.5
210200900041,17379,17409,27.99,0.7
210200900051,17318,17347,31.99,0.7
210201000013,17379,17409,38.99,0.7
210201000016,17318,17347,32.99,0.7
210201000018,17501,17531,8.99,0.5
210201000020,17379,17409,24.99,0.7
210201000035,17348,17378,39.99,0.6
210201000053,17348,17378,28.99,0.6
210201000056,17318,17347,27.99,0.7
210201000078,17379,17409,36.99,0.7
210201000079,17348,17378,34.99,0.6
210201000080,17318,17347,78.99,0.7
210201000082,17501,17531,18.99,0.5
210201000095,17318,17409,47.99,0.7
210201000107,17318,17378,3.99,0.6
210201000115,17501,17531,5.99,0.5
210201000117,17379,17409,34.99,0.7
210201000120,17348,17378,13.99,0.6
210201000123,17348,17409,8.99,0.7
210201000123,17501,17531,6.99,0.5
210201000125,17379,17409,38.99,0.7
210201000125,17501,17531,27.99,0.5
210201000128,17318,17347,25.99,0.7
210201000132,17379,17409,16.99,0.7
210201000134,17318,17347,30.99,0.7
210201000138,17318,17347,48.99,0.7
210201000139,17348,17378,22.99,0.6
210201000139,17501,17531,19.99,0.5
210201000149,17318,17347,45.99,0.7
210201000156,17318,17347,24.99,0.7
210201000161,17318,17347,3.99,0.7
210201000169,17501,17531,14.99,0.5
210201000171,17348,17378,25.99,0.6
210201000184,17348,17378,28.99,0.6
210201000185,17379,17409,17.99,0.7
210201000188,17501,17531,18.99,0.5
210201000191,17348,17378,21.99,0.6
210201000204,17379,17409,27.99,0.7
210201000208,17501,17531,28.99,0.5
210201100006,17348,17378,46.99,0.6
220100100004,17318,17378,19.99,0.6
220100100018,17318,17347,10.99,0.7
220100100046,17348,17378,10.99,0.6
220100100052,17348,17378,16.99,0.6
220100100052,17501,17531,16.99,0.5
220100100076,17379,17409,25.99,0.7
220100100087,17348,17378,141.99,0.6
220100100106,17318,17347,67.99,0.7
220100100121,17379,17409,59.99,0.7
220100100141,17318,17347,57.99,0.7
220100100165,17501,17531,37.99,0.5
220100100167,17501,17531,10.99,0.5
220100100173,17348,17378,31.99,0.6
220100100179,17318,17347,42.99,0.7
220100100196,17501,17531,43.99,0.5
220100100210,17379,17409,28.99,0.7
220100100212,17318,17347,47.99,0.7
220100100218,17501,17531,22.99,0.5
220100100226,17318,17347,18.99,0.7
220100100245,17318,17347,21.99,0.7
220100100278,17318,17347,16.99,0.7
220100100284,17348,17378,51.99,0.6
220100100309,17348,17378,59.99,0.6
220100100326,17348,17378,104.99,0.6
220100100336,17379,17409,26.99,0.7
220100100340,17348,17378,25.99,0.6
220100100344,17318,17347,56.99,0.7
220100100349,17379,17409,52.99,0.7
220100100351,17348,17378,39.99,0.6
220100100351,17501,17531,37.99,0.5
220100100406,17318,17347,15.99,0.7
220100100411,17501,17531,36.99,0.5
220100100423,17348,17378,10.99,0.6
220100100431,17501,17531,34.99,0.5
220100100462,17379,17409,66.99,0.7
220100100470,17501,17531,64.99,0.5
220100100536,17348,17378,127.99,0.6
220100100555,17379,17409,34.99,0.7
220100100588,17348,17378,20.99,0.6
220100100593,17379,17409,103.99,0.7
220100100619,17501,17531,21.99,0.5
220100100626,17318,17347,25.99,0.7
220100100638,17379,17409,44.99,0.7
220100200006,17348,17378,27.99,0.6
220100200008,17501,17531,25.99,0.5
220100200011,17501,17531,33.99,0.5
220100200020,17348,17378,32.99,0.6
220100200020,17501,17531,27.99,0.5
220100200021,17379,17409,26.99,0.7
220100300041,17167,17197,123.99,0.6
220100400014,17379,17409,52.99,0.7
220100400015,17318,17347,51.99,0.7
220100400021,17501,17531,45.99,0.5
220100400027,17501,17531,51.99,0.5
220100500002,17379,17409,62.99,0.7
220100500016,17501,17531,103.99,0.5
220100700005,17348,17378,100.99,0.6
220100700013,17348,17378,47.99,0.6
220100700016,17318,17347,70.99,0.7
220100700023,17318,17347,73.99,0.7
220100700024,17348,17378,69.99,0.6
220100700033,17379,17409,40.99,0.7
220100700039,17501,17531,33.99,0.5
220100700047,17501,17531,69.99,0.5
220100700049,17379,17409,115.99,0.7
220100700049,17501,17531,87.99,0.5
220100800001,17379,17409,31.99,0.7
220100800008,17318,17347,32.99,0.7
220100800012,17318,17347,29.99,0.7
220100800015,17348,17378,36.99,0.6
220100800019,17318,17347,17.99,0.7
220100800035,17348,17378,21.99,0.6
220100800054,17318,17347,41.99,0.7
220100800063,17318,17347,26.99,0.7
220100800067,17348,17378,19.99,0.6
220100800069,17348,17378,22.99,0.6
220100800073,17379,17409,20.99,0.7
220100800075,17348,17378,29.99,0.6
220100800075,17501,17531,24.99,0.5
220100800080,17501,17531,17.99,0.5
220100800086,17379,17409,48.99,0.7
220100800089,17318,17347,36.99,0.7
220100800094,17379,17409,66.99,0.7
220100800098,17501,17531,27.99,0.5
220100900008,17501,17531,11.99,0.5
220100900016,17379,17409,58.99,0.7
220100900028,17348,17378,18.99,0.6
220100900032,17379,17409,97.99,0.7
220101000001,17379,17409,13.99,0.7
220101000004,17379,17409,36.99,0.7
220101100003,17348,17378,9.99,0.6
220101100035,17379,17409,8.99,0.7
220101100039,17379,17409,4.99,0.7
220101200001,17501,17531,29.99,0.5
220101200031,17318,17347,155.99,0.7
220101200035,17318,17347,63.99,0.7
220101200036,17379,17409,29.99,0.7
220101300001,17318,17347,22.99,0.6
220101300019,17318,17347,38.99,0.6
220101400019,17348,17378,61.99,0.6
220101400026,17379,17409,20.99,0.7
220101400029,17501,17531,2.99,0.5
220101400044,17348,17378,26.99,0.6
220101400045,17348,17378,20.99,0.6
220101400052,17348,17378,118.99,0.6
220101400071,17501,17531,12.99,0.5
220101400074,17318,17409,6.99,0.7
220101400082,17501,17531,19.99,0.5
220101400092,17348,17378,35.99,0.6
220101400101,17501,17531,13.99,0.5
220101400111,17379,17409,17.99,0.7
220101400137,17501,17531,32.99,0.5
220101400150,17348,17378,18.99,0.6
220101400173,17318,17347,12.99,0.7
220101400173,17501,17531,8.99,0.5
220101400183,17501,17531,45.99,0.5
220101400184,17501,17531,28.99,0.5
220101400187,17348,17378,33.99,0.6
220101400192,17379,17409,20.99,0.7
220101400200,17379,17409,20.99,0.7
220101400201,17379,17409,30.99,0.7
220101400203,17501,17531,20.99,0.5
220101400212,17379,17409,41.99,0.7
220101400213,17318,17347,50.99,0.7
220101400223,17501,17531,19.99,0.5
220101400232,17348,17378,21.99,0.6
220101400234,17318,17347,40.99,0.7
220101400234,17501,17531,29.99,0.5
220101400235,17501,17531,28.99,0.5
220101400249,17318,17347,60.99,0.7
220101400254,17501,17531,29.99,0.5
220101400262,17379,17409,68.99,0.7
220101400266,17501,17531,20.99,0.5
220101400272,17348,17409,30.99,0.7
220101400282,17348,17378,25.99,0.6
220101400284,17318,17347,36.99,0.7
220101400289,17501,17531,32.99,0.5
220101400304,17501,17531,9.99,0.5
220101400313,17348,17378,59.99,0.6
220101400316,17318,17347,21.99,0.7
220101400325,17501,17531,6.99,0.5
220101400331,17379,17409,34.99,0.7
220101400332,17318,17347,42.99,0.7
220101400338,17379,17409,26.99,0.7
220101400341,17501,17531,17.99,0.5
220101400366,17501,17531,42.99,0.5
220101400367,17501,17531,35.99,0.5
220101400373,17318,17347,39.99,0.7
220101400375,17348,17378,57.99,0.6
220101400379,17348,17378,25.99,0.6
220101400390,17348,17378,26.99,0.6
220101400399,17379,17409,47.99,0.7
220101400411,17379,17409,32.99,0.7
220101400426,17501,17531,67.99,0.5
220101400432,17501,17531,21.99,0.5
220101400434,17318,17347,34.99,0.7
220101500013,17379,17409,84.99,0.7
220200100003,17348,17378,21.99,0.6
220200100059,17348,17378,91.99,0.6
220200100077,17318,17347,71.99,0.7
220200100085,17379,17409,48.99,0.7
220200100113,17318,17347,100.99,0.7
220200100115,17348,17378,92.99,0.6
220200100151,17379,17409,33.99,0.7
220200100239,17379,17409,40.99,0.7
220200100247,17501,17531,34.99,0.7
220200200017,17348,17378,89.99,0.6
220200200020,17318,17347,134.99,0.7
220200200031,17501,17531,28.99,0.5
220200200055,17348,17378,114.99,0.6
220200200057,17501,17531,34.99,0.5
220200200059,17379,17409,98.99,0.7
220200200067,17501,17531,47.99,0.5
220200200070,17348,17378,80.99,0.6
220200300008,17348,17378,42.99,0.6
220200300012,17379,17409,63.99,0.7
220200300025,17348,17378,51.99,0.6
220200300027,17348,17378,40.99,0.6
220200300053,17318,17347,44.99,0.7
220200300064,17379,17409,106.99,0.7
220200300073,17379,17409,59.99,0.7
220200300073,17501,17531,43.99,0.5
220200300086,17379,17409,102.99,0.7
220200300087,17379,17409,82.99,0.7
220200300110,17348,17378,37.99,0.6
220200300117,17379,17409,72.99,0.7
220200300118,17348,17378,61.99,0.6
220200300137,17348,17378,60.99,0.6
220200300138,17318,17347,56.99,0.7
220200300138,17501,17531,40.99,0.5
220200300139,17348,17378,47.99,0.6
220200300144,17379,17409,60.99,0.7
220200300146,17379,17409,31.99,0.7
220200300146,17501,17531,24.99,0.5
220200300149,17318,17347,18.99,0.7
220200300152,17318,17409,63.99,0.7
220200300161,17379,17409,16.99,0.7
220200300162,17348,17378,28.99,0.6
220200300164,17348,17378,56.99,0.6
230100100004,17318,17347,90.99,0.6
230100100006,17318,17347,109.99,0.6
230100100006,17501,17531,91.99,0.5
230100100019,17198,17225,51.99,0.5
230100100024,17318,17347,29.99,0.6
230100100033,17167,17197,29.99,0.5
230100100039,17501,17531,31.99,0.5
230100100040,17501,17531,95.99,0.5
230100100043,17318,17347,51.99,0.6
230100100047,17501,17531,168.99,0.5
230100200011,17379,17409,124.99,0.7
230100200013,17501,17531,18.99,0.5
230100200023,17501,17531,129.99,0.5
230100200028,17379,17409,57.99,0.7
230100200032,17379,17409,111.99,0.7
230100200034,17318,17347,134.99,0.6
230100200059,17318,17347,26.99,0.6
230100200071,17287,17317,50.99,0.7
230100400001,17198,17225,10.99,0.5
230100400009,17198,17225,7.99,0.5
230100400020,17167,17197,8.99,0.5
230100400022,17198,17225,9.99,0.5
230100400026,17501,17531,11.99,0.5
230100400028,17501,17531,8.99,0.5
230100500019,17379,17409,10.99,0.7
230100500027,17379,17409,44.99,0.7
230100500031,17287,17378,64.99,0.6
230100500033,17287,17317,10.99,0.7
230100500040,17287,17317,8.99,0.7
230100500055,17318,17347,17.99,0.6
230100500061,17348,17378,12.99,0.6
230100500090,17287,17317,62.99,0.7
230100500093,17318,17347,85.99,0.6
230100600009,17348,17378,76.99,0.6
230100700001,17287,17317,23.99,0.7
240100100005,17501,17531,3.99,0.5
240100100015,17348,17378,52.99,0.6
240100100021,17318,17347,48.99,0.7
240100100028,17318,17347,2.99,0.7
240100100028,17501,17531,1.99,0.5
240100100037,17318,17347,62.99,0.7
240100100038,17318,17347,63.99,0.7
240100100042,17318,17347,81.99,0.7
240100100044,17318,17347,57.99,0.7
240100100047,17379,17409,47.99,0.7
240100100057,17379,17409,14.99,0.7
240100100062,17379,17409,14.99,0.7
240100100064,17318,17347,19.99,0.7
240100100065,17348,17378,25.99,0.6
240100100084,17379,17409,11.99,0.7
240100100096,17318,17347,14.99,0.7
240100100097,17318,17347,1.99,0.7
240100100097,17501,17531,0.99,0.5
240100100098,17318,17347,29.99,0.7
240100100104,17318,17347,32.99,0.7
240100100106,17348,17378,151.99,0.6
240100100110,17501,17531,91.99,0.5
240100100116,17501,17531,12.99,0.5
240100100124,17348,17378,21.99,0.6
240100100136,17318,17409,155.99,0.7
240100100156,17379,17409,18.99,0.7
240100100161,17348,17378,69.99,0.6
240100100164,17501,17531,1.99,0.5
240100100169,17501,17531,21.99,0.5
240100100171,17379,17409,5.99,0.7
240100100171,17501,17531,4.99,0.5
240100100177,17379,17409,72.99,0.7
240100100178,17501,17531,13.99,0.5
240100100179,17379,17409,59.99,0.7
240100100183,17501,17531,6.99,0.5
240100100194,17348,17378,25.99,0.6
240100100210,17318,17378,14.99,0.6
240100100211,17501,17531,21.99,0.5
240100100222,17348,17378,56.99,0.6
240100100225,17379,17409,4.99,0.7
240100100235,17348,17378,9.99,0.6
240100100239,17348,17378,8.99,0.6
240100100241,17318,17347,9.99,0.7
240100100243,17379,17409,7.99,0.7
240100100244,17379,17409,13.99,0.7
240100100246,17379,17409,17.99,0.7
240100100247,17348,17378,58.99,0.6
240100100248,17318,17347,10.99,0.7
240100100250,17318,17347,11.99,0.7
240100100254,17379,17409,12.99,0.7
240100100271,17318,17347,11.99,0.7
240100100272,17379,17409,10.99,0.7
240100100290,17348,17378,15.99,0.6
240100100293,17318,17347,14.99,0.7
240100100294,17348,17378,10.99,0.6
240100100299,17318,17347,139.99,0.7
240100100302,17501,17531,4.99,0.5
240100100306,17501,17531,4.99,0.5
240100100307,17379,17409,6.99,0.7
240100100315,17501,17531,6.99,0.5
240100100318,17318,17347,15.99,0.7
240100100319,17501,17531,12.99,0.5
240100100320,17501,17531,10.99,0.5
240100100340,17318,17347,82.99,0.7
240100100352,17379,17409,17.99,0.7
240100100359,17379,17409,9.99,0.7
240100100362,17348,17378,6.99,0.6
240100100366,17501,17531,9.99,0.5
240100100367,17348,17378,40.99,0.6
240100100368,17379,17409,37.99,0.7
240100100369,17379,17409,42.99,0.7
240100100370,17318,17378,5.99,0.6
240100100370,17501,17531,4.99,0.5
240100100371,17318,17347,22.99,0.7
240100100382,17379,17409,7.99,0.7
240100100390,17318,17347,10.99,0.7
240100100391,17379,17409,8.99,0.7
240100100397,17379,17409,16.99,0.7
240100100404,17348,17378,44.99,0.6
240100100409,17501,17531,21.99,0.5
240100100411,17318,17347,4.99,0.7
240100100414,17379,17409,19.99,0.7
240100100419,17379,17409,21.99,0.7
240100100422,17379,17409,16.99,0.7
240100100432,17379,17409,1.99,0.7
240100100445,17348,17378,51.99,0.6
240100100453,17348,17378,17.99,0.6
240100100479,17348,17378,5.99,0.6
240100100485,17501,17531,0.99,0.5
240100100494,17379,17409,8.99,0.7
240100100496,17379,17409,10.99,0.7
240100100507,17379,17409,34.99,0.7
240100100508,17501,17531,24.99,0.5
240100100516,17348,17378,17.99,0.6
240100100519,17348,17378,19.99,0.6
240100100538,17348,17378,6.99,0.6
240100100554,17348,17378,42.99,0.6
240100100557,17348,17378,50.99,0.6
240100100565,17348,17378,65.99,0.6
240100100586,17318,17347,18.99,0.7
240100100588,17501,17531,27.99,0.5
240100100601,17318,17347,46.99,0.7
240100100603,17501,17531,5.99,0.5
240100100617,17379,17409,4.99,0.7
240100100621,17348,17378,38.99,0.6
240100100623,17348,17378,11.99,0.6
240100100629,17348,17378,32.99,0.6
240100100636,17348,17378,16.99,0.6
240100100649,17379,17409,61.99,0.7
240100100653,17501,17531,34.99,0.5
240100100656,17348,17409,88.99,0.7
240100100657,17318,17347,58.99,0.7
240100100662,17501,17531,24.99,0.5
240100100685,17501,17531,14.99,0.5
240100100700,17501,17531,50.99,0.5
240100100709,17348,17378,32.99,0.6
240100100712,17379,17409,48.99,0.7
240100100713,17348,17378,40.99,0.6
240100100718,17348,17378,44.99,0.6
240100100722,17379,17409,34.99,0.7
240100100726,17318,17347,23.99,0.7
240100100728,17379,17409,14.99,0.7
240100100733,17318,17347,32.99,0.7
240100100739,17348,17378,83.99,0.6
240100100739,17501,17531,69.99,0.5
240100400001,17348,17378,108.99,0.5
240100400005,17257,17286,135.99,0.5
240100400015,17379,17409,200.99,0.7
240100400026,17318,17347,68.99,0.7
240100400028,17348,17378,9.99,0.5
240100400032,17318,17347,209.99,0.7
240100400042,17379,17409,47.99,0.7
240100400044,17348,17378,201.99,0.5
240100400046,17257,17286,199.99,0.5
240100400048,17257,17286,165.99,0.5
240100400051,17379,17409,4.99,0.7
240100400056,17379,17409,100.99,0.7
240100400068,17257,17286,101.99,0.5
240100400081,17348,17378,67.99,0.5
240100400085,17257,17286,36.99,0.5
240100400096,17348,17378,100.99,0.5
240100400127,17348,17378,102.99,0.5
240100400148,17318,17347,206.99,0.7
240200100003,17318,17378,118.99,0.6
240200100003,17348,17409,137.99,0.7
240200100008,17318,17347,24.99,0.6
240200100010,17348,17378,7.99,0.6
240200100016,17501,17531,21.99,0.7
240200100025,17287,17317,14.99,0.7
240200100035,17379,17409,9.99,0.7
240200100036,17287,17317,11.99,0.7
240200100040,17501,17531,15.99,0.7
240200100050,17501,17531,9.99,0.7
240200100062,17348,17378,9.99,0.6
240200100072,17318,17347,6.99,0.6
240200100073,17348,17378,14.99,0.6
240200100080,17379,17409,389.99,0.7
240200100090,17287,17317,10.99,0.7
240200100096,17287,17317,692.99,0.7
240200100102,17348,17378,9.99,0.6
240200100103,17287,17317,9.99,0.7
240200100103,17501,17531,9.99,0.7
240200100114,17501,17531,121.99,0.7
240200100121,17501,17531,98.99,0.7
240200100122,17318,17347,76.99,0.6
240200100123,17501,17531,166.99,0.7
240200100131,17318,17378,49.99,0.6
240200100137,17348,17378,5.99,0.6
240200100142,17348,17378,9.99,0.6
240200100143,17501,17531,13.99,0.7
240200100146,17287,17317,294.99,0.7
240200100146,17379,17409,294.99,0.7
240200100151,17287,17317,738.99,0.7
240200100156,17348,17378,15.99,0.6
240200100161,17287,17317,45.99,0.7
240200100166,17318,17409,44.99,0.7
240200100169,17287,17317,11.99,0.7
240200100171,17287,17317,2.99,0.7
240200100173,17287,17317,342.99,0.7
240200100176,17379,17409,460.99,0.7
240200100184,17348,17409,82.99,0.7
240200100188,17318,17347,23.99,0.6
240200100197,17348,17378,38.99,0.6
240200100201,17348,17378,35.99,0.6
240200100206,17318,17347,81.99,0.6
240200100218,17379,17409,39.99,0.7
240200100227,17318,17347,92.99,0.6
240200100230,17379,17409,10.99,0.7
240200100231,17348,17378,5.99,0.6
240200100237,17379,17409,62.99,0.7
240200200005,17348,17378,17.99,0.6
240200200010,17379,17409,104.99,0.7
240200200011,17379,17409,97.99,0.7
240200200013,17318,17347,301.99,0.6
240200200014,17318,17347,79.99,0.6
240200200016,17501,17531,92.99,0.7
240200200017,17379,17409,81.99,0.7
240200200023,17287,17317,45.99,0.7
240200200027,17287,17317,57.99,0.7
240200200033,17379,17409,58.99,0.7
240200200033,17501,17531,58.99,0.7
240200200034,17501,17531,12.99,0.7
240200200041,17348,17378,45.99,0.6
240200200048,17287,17317,32.99,0.7
240200200052,17348,17378,43.99,0.6
240200200067,17379,17409,201.99,0.7
240200200070,17379,17409,17.99,0.7
240200200084,17501,17531,57.99,0.7
240200200091,17287,17317,145.99,0.7
240300100008,17501,17531,3.99,0.5
240300100016,17167,17197,22.99,0.5
240300100019,17167,17197,13.99,0.5
240300100034,17167,17197,28.99,0.5
240300100034,17501,17531,28.99,0.5
240300100049,17501,17531,11.99,0.5
240300100057,17167,17197,20.99,0.5
240300200025,17167,17197,75.99,0.7
240300200025,17501,17531,54.99,0.5
240300200038,17501,17531,37.99,0.5
240300200047,17167,17197,34.99,0.7
240300200054,17167,17197,6.99,0.7
240300200056,17167,17197,87.99,0.7
240300200057,17501,17531,33.99,0.5
240300300012,17167,17197,17.99,0.5
240300300022,17167,17197,157.99,0.5
240300300024,17501,17531,30.99,0.5
240300300047,17501,17531,32.99,0.5
240300300058,17167,17197,242.99,0.5
240300300074,17501,17531,28.99,0.5
240300300083,17167,17197,12.99,0.5
240300300084,17167,17197,17.99,0.5
240300300087,17501,17531,36.99,0.5
240300300090,17501,17531,267.99,0.5
240300300092,17501,17531,128.99,0.5
240300300096,17167,17197,24.99,0.5
240300300111,17501,17531,42.99,0.5
240300300116,17501,17531,24.99,0.5
240400200028,17501,17531,166.99,0.7
240400200070,17379,17409,62.99,0.7
240400200075,17379,17409,44.99,0.7
240400200079,17379,17409,235.99,0.7
240400200081,17501,17531,240.99,0.7
240400300003,17348,17378,42.99,0.6
240400300004,17501,17531,60.99,0.7
240400300005,17257,17286,45.99,0.7
240400300006,17287,17347,23.99,0.6
240400300011,17257,17286,35.99,0.7
240400300012,17501,17531,51.99,0.7
240400300013,17257,17286,36.99,0.7
240400300022,17348,17378,24.99,0.6
240400300028,17501,17531,56.99,0.7
240400300038,17287,17317,23.99,0.6
240500100009,17501,17531,47.99,0.7
240500100011,17318,17347,28.99,0.7
240500100013,17501,17531,42.99,0.7
240500100015,17318,17347,41.99,0.7
240500100024,17379,17409,28.99,0.7
240500100031,17501,17531,41.99,0.7
240500100041,17501,17531,87.99,0.7
240500100043,17501,17531,21.99,0.7
240500100059,17348,17378,42.99,0.6
240500100061,17318,17347,58.99,0.7
240500200003,17318,17347,17.99,0.7
240500200018,17318,17347,31.99,0.7
240500200018,17501,17531,31.99,0.7
240500200022,17318,17347,24.99,0.7
240500200031,17318,17378,24.99,0.6
240500200032,17501,17531,40.99,0.7
240500200038,17318,17347,51.99,0.7
240500200050,17379,17409,40.99,0.7
240500200053,17501,17531,39.99,0.7
240500200058,17348,17378,13.99,0.6
240500200093,17348,17378,25.99,0.6
240500200094,17348,17378,43.99,0.6
240500200094,17501,17531,50.99,0.7
240500200098,17348,17378,27.99,0.6
240500200099,17501,17531,38.99,0.7
240500200113,17379,17409,33.99,0.7
240500200121,17379,17409,17.99,0.7
240500200127,17348,17378,25.99,0.6
240500200137,17318,17347,19.99,0.7
240500200142,17348,17409,5.99,0.7
240500200146,17348,17378,35.99,0.6
240500200147,17348,17378,37.99,0.6
240500200148,17501,17531,109.99,0.7
240500200149,17379,17409,210.99,0.7
240600100003,17348,17378,36.99,0.6
240600100004,17318,17347,31.99,0.5
240600100006,17348,17378,5.99,0.6
240600100011,17287,17317,29.99,0.7
240600100014,17287,17317,7.99,0.7
240600100021,17318,17347,36.99,0.5
240600100038,17318,17347,22.99,0.5
240600100044,17379,17409,6.99,0.7
240600100051,17318,17409,29.99,0.7
240600100052,17318,17347,23.99,0.5
240600100056,17287,17317,26.99,0.7
240600100059,17348,17378,2.99,0.6
240600100067,17318,17409,32.99,0.7
240600100068,17379,17409,42.99,0.7
240600100079,17379,17409,41.99,0.7
240600100087,17348,17378,26.99,0.6
240600100089,17318,17347,11.99,0.5
240600100100,17379,17409,42.99,0.7
240600100101,17287,17378,38.99,0.6
240600100106,17379,17409,39.99,0.7
240600100115,17379,17409,34.99,0.7
240600100123,17318,17347,30.99,0.5
240600100133,17287,17317,29.99,0.7
240600100137,17379,17409,16.99,0.7
240600100142,17287,17347,13.99,0.5
240600100148,17379,17409,16.99,0.7
240600100162,17379,17409,43.99,0.7
240600100172,17348,17378,14.99,0.6
240600100175,17318,17347,12.99,0.5
240600100191,17379,17409,25.99,0.7
240600100194,17318,17347,12.99,0.5
240600100196,17287,17317,43.99,0.7
240600100199,17348,17378,10.99,0.6
240600100204,17318,17347,17.99,0.5
240700100004,17318,17347,14.99,0.7
240700100009,17348,17378,17.99,0.6
240700100011,17348,17378,5.99,0.6
240700100017,17501,17531,9.99,0.6
240700200004,17501,17531,12.99,0.6
240700200005,17318,17347,15.99,0.7
240700200006,17318,17347,31.99,0.7
240700200007,17501,17531,12.99,0.6
240700200016,17379,17409,4.99,0.7
240700200018,17379,17409,6.99,0.7
240700400001,17379,17409,45.99,0.7
240700400002,17318,17347,26.99,0.7
240700400011,17287,17317,12.99,0.6
240700400016,17379,17409,54.99,0.7
240700400022,17318,17347,23.99,0.7
240700400025,17257,17286,28.99,0.7
240700400027,17501,17531,50.99,0.6
240700400028,17287,17317,26.99,0.6
240700400029,17379,17409,10.99,0.7
240700400030,17287,17317,14.99,0.6
240700400032,17318,17347,22.99,0.7
240700400034,17287,17317,9.99,0.6
240700400034,17379,17409,10.99,0.7
240800100014,17167,17197,182.99,0.5
240800100019,17501,17531,21.99,0.4
240800100039,17167,17197,52.99,0.5
240800100050,17167,17197,158.99,0.5
240800100053,17198,17225,128.99,0.4
240800100062,17167,17197,211.99,0.5
240800100081,17501,17531,107.99,0.4
240800100084,17198,17225,26.99,0.4
240800100099,17501,17531,11.99,0.4
240800200007,17198,17225,9.99,0.4
240800200009,17501,17531,41.99,0.4
240800200022,17167,17197,30.99,0.5
240800200032,17167,17197,27.99,0.5
240800200044,17198,17225,26.99,0.4
240800200045,17167,17225,31.99,0.4
240800200054,17167,17197,13.99,0.5
240800200056,17501,17531,28.99,0.4
240800200064,17501,17531,17.99,0.4
240800200065,17501,17531,17.99,0.4
;;;;
run;

data ORION.EMPLOYEE_PAYROLL;
   attrib Employee_ID length=8 format=12.;
   attrib Employee_Gender length=$1;
   attrib Salary length=8;
   attrib Birth_Date length=8;
   attrib Employee_Hire_Date length=8;
   attrib Employee_Term_Date length=8;
   attrib Marital_Status length=$1;
   attrib Dependents length=8;

   infile datalines dsd;
   input
      Employee_ID
      Employee_Gender
      Salary
      Birth_Date
      Employee_Hire_Date
      Employee_Term_Date
      Marital_Status
      Dependents
   ;
datalines4;
120101,M,163040,6074,15887,,S,0
120102,M,108255,3510,10744,,O,2
120103,M,87975,-3996,5114,,M,1
120104,F,46230,-2061,7671,,M,1
120105,F,27110,5468,14365,,S,0
120106,M,26960,-5487,5114,,M,2
120107,F,30475,-3997,5145,,M,2
120108,F,27660,8819,17014,,S,0
120109,F,26495,9845,17075,,M,3
120110,M,28615,-3694,7244,,M,1
120111,M,26895,-3814,5418,,M,3
120112,F,26550,3335,11139,,M,3
120113,F,26870,-5714,5114,,S,0
120114,F,31285,-5806,5114,,M,3
120115,M,26500,8894,16649,,M,2
120116,M,29250,-202,7336,,S,0
120117,M,31670,1715,9587,,O,1
120118,M,28090,-212,8948,,M,3
120119,M,30255,3642,13880,,M,1
120120,F,27645,-5719,5114,,M,3
120121,F,26600,-5630,5114,,M,1
120122,F,27475,-1984,6756,,S,0
120123,F,26190,1732,9405,16467,M,3
120124,M,26480,-233,6999,,M,1
120125,M,32040,-1852,6999,16283,M,2
120126,M,26780,10490,17014,,O,2
120127,F,28100,6943,14184,,M,2
120128,F,30890,9691,17106,,S,0
120129,M,30070,1787,9405,15795,S,0
120130,M,26955,9114,16922,,M,2
120131,M,26910,7207,15706,,S,0
120132,F,28525,-3923,6848,,S,0
120133,F,27440,9608,17075,,S,0
120134,M,28015,-3861,5114,16982,M,2
120135,M,32490,3313,13788,16191,M,3
120136,M,26605,7198,15737,,M,1
120137,F,29715,7010,16861,,S,0
120138,F,25795,7131,16983,,S,0
120139,F,26810,9726,17045,,S,0
120140,M,26970,10442,17075,,M,2
120141,F,27465,10298,16922,,M,1
120142,M,29695,9661,16983,,S,0
120143,M,26790,-229,8309,,S,1
120144,M,30265,9562,17075,,S,0
120145,M,26060,1482,9283,,O,0
120146,M,25985,-91,7518,16709,M,1
120147,F,26580,10245,17075,,M,3
120148,M,28480,-3762,6726,,S,0
120149,F,26390,5438,12054,,O,1
120150,M,29965,-2002,8248,16191,M,1
120151,F,26520,-5519,5114,,M,3
120152,M,26515,7060,16527,,M,1
120153,F,27260,7066,13880,16832,M,2
120154,F,30490,-5643,5114,,M,1
120155,F,29990,8878,16892,,M,1
120156,F,26445,10471,16861,,O,0
120157,M,27860,9548,17136,,S,0
120158,M,36605,1656,10043,16679,S,0
120159,F,30765,1515,9678,,M,1
120160,M,27115,-1940,5387,,M,1
120161,F,30785,10293,17075,,S,0
120162,M,27215,10475,16833,,M,3
120163,M,26735,1603,11323,,M,3
120164,F,27450,-36,8067,,M,2
120165,M,27050,8844,16861,,S,0
120166,M,30660,-5679,5114,17044,S,0
120167,F,25185,-2068,5145,16891,S,0
120168,F,25275,8849,17106,,M,1
120169,M,28135,8767,16922,,M,3
120170,M,28830,5169,11962,17105,S,0
120171,F,26205,8966,17045,,M,3
120172,M,28345,-5753,5114,,M,3
120173,M,26715,-2138,6361,16283,M,3
120174,F,26850,-5835,5114,16739,S,0
120175,M,25745,10457,17075,,S,0
120176,M,26095,9809,17106,,M,1
120177,F,28745,7034,13911,,S,0
120178,M,26165,-1865,5204,,M,3
120179,M,28510,5187,16071,16314,M,1
120180,M,26970,-2014,6909,,S,0
120181,F,27065,10559,17136,17256,S,0
120182,M,25020,9044,17136,17166,M,2
120183,M,26910,3540,17136,17166,M,1
120184,M,25820,-3683,17136,17286,O,2
120185,F,25080,5210,17136,17197,M,2
120186,F,26795,7048,17136,17347,O,1
120187,F,26665,9110,17136,17317,M,1
120188,F,26715,-2132,17136,17166,M,2
120189,M,25180,8950,17136,17256,S,0
120190,M,24100,9105,16376,16556,M,2
120191,F,24015,-349,15706,15886,S,0
120192,M,26185,8894,16588,16770,M,2
120193,M,24515,9106,16680,16860,S,0
120194,M,25985,9032,16468,16648,M,1
120195,F,24990,9125,16983,17166,S,0
120196,F,24025,8796,15706,15886,S,0
120197,F,25580,-1972,15706,15886,M,2
120198,F,28025,10247,17136,,M,1
120259,M,433800,1485,10836,,M,1
120260,F,207885,1797,9071,,M,2
120261,M,243190,3339,10074,,O,1
120262,M,268455,3581,10471,,M,2
120263,M,42605,1501,8674,16070,S,0
120264,F,37510,8788,17136,,S,0
120265,F,51950,-5567,5114,15705,M,3
120266,F,31750,3469,10683,,M,2
120267,F,28585,9649,15737,,M,1
120268,M,76105,5357,13635,,S,0
120269,F,52540,-5574,5114,16191,M,2
120270,M,48435,-2108,5114,,O,0
120271,F,43635,1679,9740,,M,1
120272,M,34390,-5770,5114,,S,0
120273,F,28455,9654,16861,,M,2
120274,F,26840,1469,12388,,O,0
120275,F,32195,-5,9040,,M,2
120276,M,28090,-5494,5114,15856,M,3
120277,F,32645,10455,16192,16587,S,0
120278,M,27685,9847,17014,,M,3
120279,F,32925,3580,13270,,S,0
120280,F,36930,1776,10348,15521,M,1
120656,F,42570,5141,14304,,O,0
120657,F,36110,1467,11262,,S,0
120658,M,42485,-1838,7702,,O,2
120659,M,161290,-3821,5114,,M,3
120660,M,61125,6731,16496,,S,0
120661,F,85495,-1861,8766,15886,M,3
120662,M,27045,10403,17106,,S,0
120663,F,56385,3372,13574,,S,0
120664,M,47605,-2143,5599,,M,3
120665,F,80070,5410,15400,,M,1
120666,M,64555,3460,11657,16191,S,0
120667,M,29980,7111,16833,,S,0
120668,M,47785,-3722,6909,,O,0
120669,M,36370,-5640,5114,,S,0
120670,M,65420,-5759,5114,15705,S,0
120671,M,40080,-2045,8432,,S,0
120672,M,60980,1698,11748,,M,1
120673,F,35935,-5666,5114,,S,0
120677,F,65555,3532,12085,,M,2
120678,F,40035,-4006,6695,15948,S,0
120679,F,46190,6155,15522,,M,3
120680,F,27295,3524,11443,,S,0
120681,M,30950,7163,16162,,M,2
120682,F,26760,3641,13240,,M,1
120683,F,36315,-1876,5114,15764,M,2
120684,F,26960,9826,17106,,S,0
120685,F,25130,8826,17106,,M,3
120686,F,26690,-5717,5114,,M,1
120687,F,26800,7084,16284,16467,O,0
120688,F,25905,-3659,5114,15583,S,0
120689,F,27780,7140,16983,,S,0
120690,F,25185,8782,16406,,S,0
120691,M,49240,-5586,5114,,S,0
120692,M,32485,-1866,8126,,M,2
120693,M,26625,-244,7091,,M,3
120694,F,27365,10455,16892,,O,1
120695,M,28180,1655,10774,17013,S,0
120696,M,26615,-1966,5173,16891,M,2
120697,F,29625,10405,16953,,O,0
120698,M,26160,-2055,6057,16495,O,0
120710,M,54840,5441,13880,,O,1
120711,F,59130,3435,12478,,O,0
120712,F,63640,-3855,5114,,S,0
120713,M,31630,-5791,5114,,M,3
120714,M,62625,5938,14123,,M,3
120715,F,28535,7102,16468,,M,3
120716,M,53015,5318,12266,,M,1
120717,M,30155,-2183,7883,,O,2
120718,M,29190,1650,11078,,S,0
120719,F,87420,3309,13180,,M,1
120720,M,46580,1588,11779,,M,2
120721,F,29870,-5550,5114,,M,3
120722,M,32460,-101,9405,,S,0
120723,F,33950,-3796,5114,,O,0
120724,M,63705,1487,11779,,S,0
120725,M,29970,7236,16223,16436,S,0
120726,F,27380,10409,17045,,M,1
120727,M,34925,1637,9648,,M,1
120728,F,35070,-1854,8036,,M,1
120729,F,31495,10320,15820,16702,M,3
120730,M,30195,1811,10501,,M,3
120731,M,34150,-292,8644,,O,1
120732,M,35870,-3792,5114,,M,1
120733,M,31760,1554,11262,,M,1
120734,M,34270,7055,16861,,S,1
120735,F,61985,-2028,6695,,S,0
120736,F,63985,1792,11596,,S,0
120737,F,63605,-279,10532,,M,2
120738,F,30025,-3831,5114,,S,0
120739,M,36970,9715,16922,,S,0
120740,F,35110,-3726,5114,15948,O,1
120741,F,36365,-5512,5114,,M,2
120742,M,31020,-5810,5114,,S,0
120743,F,34620,3319,13666,,S,0
120744,F,33490,10397,16253,16739,M,2
120745,F,31365,9682,16953,,M,1
120746,M,46090,5396,15431,,M,3
120747,F,43590,5284,12996,,M,2
120748,F,48380,6030,15765,,M,3
120749,M,26545,5376,13423,,S,0
120750,F,32675,-2034,6971,15371,M,2
120751,M,58200,1556,10440,,M,3
120752,M,30590,-2144,5691,15825,S,0
120753,M,47000,6010,12631,,S,0
120754,M,34760,10380,16922,,M,1
120755,F,36440,1697,8613,,M,3
120756,F,52295,5164,13331,,M,3
120757,M,38545,-5767,5114,16252,M,3
120758,M,34040,1756,11962,,S,0
120759,M,36230,1769,8401,,S,0
120760,F,53475,3293,12174,,S,0
120761,F,30960,9858,16983,,O,2
120762,M,30625,7245,16861,,M,2
120763,M,45100,-5545,5114,,O,1
120764,M,40450,5469,15675,,S,0
120765,F,51950,-1841,5114,,S,0
120766,F,53400,5422,15035,,M,1
120767,M,32965,1590,9952,,S,0
120768,M,44955,-1989,7944,16039,M,3
120769,M,47990,5257,13240,,S,0
120770,F,43930,1575,9952,15825,S,0
120771,F,36435,-1976,6179,,S,0
120772,M,27365,10325,17014,,S,0
120773,F,27370,-313,7761,,M,2
120774,F,45155,6834,15400,16740,M,3
120775,F,41580,3329,13454,,M,3
120776,M,32580,7203,15066,,S,0
120777,M,40955,3372,12539,,S,0
120778,F,43650,-1850,8797,,S,0
120779,F,43690,6121,13574,,S,0
120780,F,62995,3531,11596,,M,3
120781,F,32620,10249,16406,16801,M,3
120782,F,63915,5446,14396,,S,0
120783,M,42975,5467,13149,,S,0
120784,F,35715,7053,16315,,O,1
120785,F,48335,3308,12205,,O,2
120786,F,32650,-5767,5114,,S,0
120787,M,34000,3521,13149,,M,1
120788,M,33530,3451,12753,,O,1
120789,M,39330,1656,8370,15856,M,2
120790,F,53740,5454,12904,,S,0
120791,M,61115,1668,9770,,M,2
120792,F,54760,5922,13727,,M,2
120793,M,47155,3507,13301,,S,0
120794,F,51265,6939,15887,,S,0
120795,M,49105,3303,10440,15736,S,0
120796,M,47030,-2060,8460,,M,2
120797,F,43385,-1871,6544,,M,3
120798,F,80755,-192,9862,,O,1
120799,M,29070,7021,14184,,M,3
120800,M,80210,5467,13666,15736,S,0
120801,F,40040,5178,14426,,M,2
120802,F,65125,-3887,6575,16252,S,0
120803,M,43630,-2035,6575,,S,0
120804,M,55400,-5803,5114,,S,0
120805,M,58530,6752,14701,,M,3
120806,F,47285,5169,11719,,M,2
120807,F,43325,-18,8036,16314,S,0
120808,M,44425,1613,8918,,S,0
120809,F,47155,-5831,5114,,S,0
120810,M,58375,-1915,7365,,S,0
120811,M,43985,3556,12235,,S,0
120812,M,45810,5163,15188,,O,1
120813,M,50865,3544,12054,16070,S,0
120814,M,59140,-212,7183,,M,1
120815,M,31590,10588,16892,,M,2
120816,F,30485,3410,12266,,S,0
120992,F,26940,6987,14823,,S,0
120993,F,26260,3639,13574,,M,2
120994,F,31645,5280,12723,,S,0
120995,F,34850,8930,17014,,M,1
120996,M,32745,5315,15584,,M,3
120997,F,27420,5438,13393,,S,0
120998,F,26330,7279,16527,,M,1
120999,F,27215,-4,8857,,S,0
121000,M,48600,1485,12388,,M,2
121001,M,43615,-345,6453,,S,0
121002,F,26650,-1931,7274,16314,M,3
121003,M,26000,10352,16983,,S,0
121004,M,30895,-5629,5114,,S,0
121005,M,25020,8962,16102,,O,2
121006,M,26145,9781,16376,16740,M,2
121007,M,27290,1746,9893,,M,3
121008,M,27875,3471,12266,,M,1
121009,M,32955,7277,14457,,S,0
121010,M,25195,8992,16861,,S,0
121011,M,25735,-5774,5114,,S,0
121012,M,29575,9522,15949,16405,S,0
121013,M,26675,7057,14701,,S,0
121014,F,28510,5234,14457,,M,3
121015,M,26140,7286,14854,,S,0
121016,F,48075,5862,16315,,S,0
121017,M,29225,8771,16496,,S,0
121018,F,27560,-5842,5114,15825,M,2
121019,M,31320,9672,16223,16648,M,3
121020,F,31750,8819,15461,,M,1
121021,F,32985,5457,12478,,S,0
121022,M,32210,7240,15372,16314,S,0
121023,M,26010,1533,10713,16679,M,3
121024,M,26600,9030,16192,,M,2
121025,M,28295,-3735,5722,,S,0
121026,M,31515,9808,16892,,M,1
121027,M,26165,1586,10927,,M,3
121028,M,26585,10344,17106,,S,0
121029,M,27225,1817,10927,,M,2
121030,M,26745,7255,15007,,S,0
121031,M,28060,1651,9344,,M,3
121032,M,31335,10281,16861,,M,1
121033,F,29775,9806,16223,,M,3
121034,M,27110,10462,17167,,S,0
121035,M,26460,-5760,5114,,M,3
121036,F,25965,10426,15979,16740,O,1
121037,M,28310,5276,15400,,M,2
121038,M,25285,10270,17014,17198,S,0
121039,M,27460,-2038,7426,,M,2
121040,F,29525,-179,8340,,M,2
121041,F,26120,-5810,5114,,S,0
121042,M,28845,7033,14549,,M,2
121043,F,28225,3600,11748,,M,2
121044,M,25660,-1847,5691,,S,0
121045,F,28560,1625,12419,16130,M,2
121046,M,25845,9016,16983,17167,M,1
121047,F,25820,7269,17045,17226,M,2
121048,F,26560,8941,17045,17226,M,3
121049,F,26930,9541,17136,,M,3
121050,F,26080,9508,17136,,M,3
121051,F,26025,-3896,6879,,M,2
121052,M,26900,9505,17106,,S,0
121053,F,29955,-5578,5145,,M,2
121054,M,29805,-1876,6149,,S,0
121055,M,30185,10234,17014,,M,1
121056,F,28325,8952,15826,,O,1
121057,M,25125,-6,7640,,M,1
121058,M,26270,5306,15614,,M,2
121059,F,27425,-68,7761,16070,S,0
121060,F,28800,-5685,5114,,M,2
121061,M,29815,-1995,8948,,S,0
121062,F,30305,9067,17014,,M,3
121063,M,35990,7147,16649,,S,0
121064,M,25110,1488,11566,,M,1
121065,F,28040,9014,16892,,M,2
121066,F,27250,-5609,5114,16740,O,1
121067,F,31865,9514,16861,17045,S,0
121068,M,27550,3623,11932,,O,1
121069,M,26195,3365,11231,,M,1
121070,F,29385,9074,16833,,O,1
121071,M,28625,-113,6453,,M,2
121072,M,26105,6949,16315,16740,M,1
121073,M,27100,-3883,5114,,M,1
121074,M,26990,-306,10501,,S,0
121075,F,28395,-5487,5114,,M,3
121076,M,26685,1743,8401,16222,M,2
121077,M,28585,9014,17075,,S,0
121078,M,27485,-3897,6879,,M,1
121079,M,25770,5267,13819,,M,1
121080,M,32235,-342,10105,,S,0
121081,F,30235,-3931,5935,,M,2
121082,M,28510,-3832,6483,,M,3
121083,F,27245,-296,6999,,S,0
121084,M,22710,1689,11323,,M,3
121085,M,32235,9812,17167,,S,0
121086,M,26820,-5494,5114,,M,3
121087,F,28325,5454,14304,16891,M,3
121088,M,27240,10388,17167,,S,0
121089,M,28095,-1959,5295,17105,M,1
121090,F,26600,-2022,7336,,M,3
121091,M,27325,3337,10593,,M,2
121092,F,25680,5180,15553,,S,0
121093,M,27410,1660,12419,15886,M,2
121094,M,26555,-2185,6818,,S,0
121095,F,28010,3391,11504,,S,0
121096,M,26335,3425,12904,,S,0
121097,F,26830,5409,13057,,M,3
121098,M,27475,10308,16922,,S,0
121099,M,32725,7017,14731,,M,3
121100,M,28135,-3901,5935,,S,0
121101,F,25390,9736,17106,,O,1
121102,F,27115,7116,16953,,M,2
121103,M,27260,10345,17045,,S,0
121104,F,28315,1777,9587,15371,S,0
121105,F,29545,7068,15706,,S,0
121106,M,25880,3320,13180,,M,3
121107,F,31380,9610,16983,,M,1
121108,F,25930,10412,17106,17287,S,0
121109,M,26035,3596,11078,,M,1
121110,M,26370,-5740,17136,17166,M,1
121111,M,26885,-5646,17136,17286,S,0
121112,M,26855,9843,17136,17166,S,0
121113,F,27480,-2140,17136,17197,O,1
121114,F,26515,-5536,17136,17347,M,3
121115,M,26430,-322,17136,17286,S,0
121116,F,26670,1727,17136,17256,M,3
121117,F,26640,5190,17136,17166,S,0
121118,M,25725,6999,17136,17317,S,0
121119,M,25205,1768,17136,17225,M,3
121120,F,25020,5411,17136,17225,S,0
121121,F,25735,9560,17136,17317,S,0
121122,M,26265,9556,17136,17256,S,0
121123,M,26410,-5727,17136,17256,M,3
121124,M,26925,3333,17136,17166,S,0
121125,M,25315,5220,15706,15886,S,0
121126,M,26015,-1893,15706,15886,M,1
121127,F,25435,9742,16588,16770,M,2
121128,F,25405,5290,15706,15886,M,3
121129,M,30945,1582,15706,15886,S,0
121130,M,25255,8786,16102,16283,S,0
121131,M,25445,3468,15706,15886,M,2
121132,M,24390,-2153,15706,15886,M,1
121133,M,25405,7253,15706,15886,M,1
121134,M,25585,1644,15706,15886,S,0
121135,F,27010,-2034,5326,,S,0
121136,F,27460,5309,15675,16344,S,0
121137,M,27055,10244,16892,,O,0
121138,M,27265,-3959,5114,,M,1
121139,F,27700,-135,10043,,M,2
121140,M,26335,6962,15066,16832,S,0
121141,M,194885,-5674,5114,,S,0
121142,M,156065,3332,12174,,M,2
121143,M,95090,3617,13696,,M,3
121144,F,83505,1640,11627,,M,3
121145,M,84260,-3692,5935,,M,2
121146,F,29320,9839,16892,,M,1
121147,F,29145,3435,10105,,M,2
121148,M,52930,3288,13880,15736,M,1
;;;;
run;

data ORION.INVALID_CUSTOMER;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Country length=$2 label='Customer Country';
   attrib Gender length=$1 label='Customer Gender';
   attrib Personal_ID length=$15 label='Personal ID';
   attrib Customer_Name length=$40 label='Customer Name';
   attrib Customer_FirstName length=$20 label='Customer First Name';
   attrib Customer_LastName length=$30 label='Customer Last Name';
   attrib Birth_Date length=8 label='Customer Birth Date' format=DATE9.;
   attrib Customer_Address length=$45 label='Customer Address';
   attrib Street_ID length=8 label='Street ID' format=12.;
   attrib Street_Number length=$8 label='Street Number';
   attrib Customer_Type_ID length=8 label='Customer Type ID' format=8.;

   infile datalines dsd;
   input
      Customer_ID
      Country
      Gender
      Personal_ID
      Customer_Name
      Customer_FirstName
      Customer_LastName
      Birth_Date
      Customer_Address
      Street_ID
      Street_Number
      Customer_Type_ID
   ;
datalines4;
4,US,M,,James Kvarniq,James,Kvarniq,5291,4382 Gralyn Rd,9260106519,4382,1020
5,US,F,,Sandrina Stephano,Sandrina,Stephano,7129,6468 Cog Hill Ct,9260114570,6468,2020
9,DE,F,,Cornelia Krahl,Cornelia,Krahl,5171,Kallstadterstr. 9,3940106659,9,2020
10,US,F,,Karen Ballinger,Karen,Ballinger,9057,425 Bryant Estates Dr,9260129395,425,1040
11,DE,F,,Elke Wallstab,Elke,Wallstab,5341,Carl-Zeiss-Str. 15,3940108592,15,1040
12,US,M,,David Black,David,Black,3389,1068 Haithcock Rd,9260103713,1068,1030
13,DE,M,,Markus Sepke,Markus,Sepke,10429,Iese 1,3940105189,1,1022
16,DE,M,,Ulrich Heyde,Ulrich,Heyde,-7655,Oberstr. 61,3940105865,61,3010
17,US,M,,Jimmie Evans,Jimmie,Evans,-1963,391 Greywood Dr,9260123306,391,1030
18,US,M,,Tonie Asmussen,Tonie,Asmussen,-2159,117 Langtree Ln,9260112361,117,1020
19,DE,M,,Oliver S. Füßling,Oliver S.,Füßling,1514,Hechtsheimerstr. 18,3940106547,18,2030
20,US,M,,Michael Dineley,Michael,Dineley,-259,2187 Draycroft Pl,9260118934,2187,1030
23,US,M,,Tulio Devereaux,Tulio,Devereaux,-3682,1532 Ferdilah Ln,9260126679,1532,3010
24,US,F,,Robyn Klem,Robyn,Klem,-213,435 Cambrian Way,9260115784,435,3010
27,US,F,,Cynthia Mccluney,Cynthia,Mccluney,3392,188 Grassy Creek Pl,9260105670,188,9999
29,AU,F,,Candy Kinsey,Candy,Kinsey,-9308,21 Hotham Parade,1600103020,21,3010
31,US,F,,Cynthia Martinez,Cynthia,Martinez,-147,42 Arrowood Ln,9260128428,42,2020
33,DE,M,,Rolf Robak,Rolf,Robak,-7616,Münsterstraße 67,3940102376,67,1030
34,US,M,,Alvan Goheen,Alvan,Goheen,8783,844 Glen Eden Dr,9260111379,844,1020
36,US,M,,Phenix Hill,Phenix,Hill,1553,417 Halstead Cir,9260128237,417,3010
39,US,M,,Alphone Greenwald,Alphone,Greenwald,8972,4386 Hamrick Dr,9260123099,4386,2030
41,AU,M,,Wendell Summersby,Wendell,Summersby,1797,9 Angourie Court,1600101527,9,1030
42,DE,M,,Thomas Leitmann,Thomas,Leitmann,6979,Carl Von Linde Str. 13,3940109715,13,1020
45,US,F,,Dianne Patchin,Dianne,Patchin,7065,7818 Angier Rd,9260104847,7818,2010
49,US,F,,Annmarie Leveille,Annmarie,Leveille,8963,185 Birchford Ct,9260104510,185,2030
50,DE,M,,Gert-Gunter Mendler,Gert-Gunter,Mendler,-9481,Humboldtstr. 1,3940105781,1,2030
52,US,M,,Yan Kozlowski,Yan,Kozlowski,3383,1233 Hunters Crossing,9260116235,1233,1030
53,AU,F,,Dericka Pockran,Dericka,Pockran,-2021,131 Franklin St,1600103258,131,1040
56,US,M,,Roy Siferd,Roy,Siferd,-9465,334 Kingsmill Rd,9260111871,334,1030
60,US,F,,Tedi Lanzarone,Tedi,Lanzarone,3430,2429 Hunt Farms Ln,9260101262,2429,1030
61,DE,M,,Carsten Maestrini,Carsten,Maestrini,-5655,Münzstr. 28,3940108887,28,2030
63,US,M,,James Klisurich,James,Klisurich,3646,25 Briarforest Pl,9260125492,25,2020
65,DE,F,,Ines Deisser,Ines,Deisser,3488,Bahnweg 1,3940100176,1,1020
69,US,F,,Patricia Bertolozzi,Patricia,Bertolozzi,7072,4948 Dargan Hills Dr,9260116402,4948,1020
71,US,F,,Viola Folsom,Viola,Folsom,3553,290 Glenwood Ave,9260124130,290,2020
75,US,M,,Mikel Spetz,Mikel,Spetz,8935,101 Knoll Ridge Ln,9260108068,101,1020
79,US,F,,Najma Hicks,Najma,Hicks,9518,9658 Dinwiddie Ct,9260101874,9658,1030
88,US,M,,Attila Gibbs,Attila,Gibbs,-316,3815 Askham Dr,9260100179,3815,1030
89,US,F,,Wynella Lewis,Wynella,Lewis,-9226,2572 Glenharden Dr,9260116551,2572,1040
90,US,F,,Kyndal Hooks,Kyndal,Hooks,1674,252 Clay St,9260111614,252,2030
92,US,M,,Lendon Celii,Lendon,Celii,-5587,421 Blue Horizon Dr,9260117676,421,1020
111,AU,F,,Karolina Dokter,Karolina,Dokter,5475,28 Munibung Road,1600102072,28,1030
171,AU,M,,Robert Bowerman,Robert,Bowerman,5166,21 Parliament House c/- Senator t,1600101555,21,1040
183,AU,M,,Duncan Robertshawe,Duncan,Robertshawe,-5760,18 Fletcher Rd,1600100760,18,1020
195,AU,M,,Cosi Rimmington,Cosi,Rimmington,-5529,4 Burke Street Woolloongabba,1600101663,4,1020
215,AU,M,,Ramesh Trentholme,Ramesh,Trentholme,-3882,23 Benjamin Street,1600102721,23,2020
544,TR,M,,Avni Argac,Avni,Argac,1601,A Blok No: 1,9050100008,1,1040
908,TR,M,,Avni Umran,Avni,Umran,7279,Mayis Cad. Nova Baran Plaza Ka 11,9050100023,11,2030
928,TR,M,,Bulent Urfalioglu,Bulent,Urfalioglu,3510,Turkcell Plaza Mesrutiyet Cad. 142,9050100016,142,1020
1033,TR,M,,Selim Okay,Selim,Okay,7226,Fahrettin Kerim Gokay Cad. No. 24,9050100001,24,1020
1100,TR,M,,Ahmet Canko,Ahmet,Canko,1479,A Blok No: 1,9050100008,1,1020
1684,TR,M,,Carglar Aydemir,Carglar,Aydemir,5403,A Blok No: 1,9050100008,1,1020
2550,ZA,F,,Sanelisiwe Collier,Sanelisiwe,Collier,10415,Bryanston Drive 122,8010100009,122,2010
2618,ZA,M,,Theunis Brazier,Theunis,Brazier,-3938,Arnold Road 2,8010100125,2,1030
2788,TR,M,,Serdar Yucel,Serdar,Yucel,-5843,Fahrettin Kerim Gokay Cad. No. 30,9050100001,30,1040
2806,ZA,F,,Raedene Van Den Berg,Raedene,Van Den Berg,10486,Quinn Street 11,8010100089,11,1030
3959,ZA,F,,Rita Lotz,Rita,Lotz,1515,Moerbei Avenue 120,8010100151,120,2030
11171,CA,M,,Bill Cuddy,Bill,Cuddy,9785,69 chemin Martin,2600100032,69,2010
12386,IL,M,,Avinoam Zweig,Avinoam,Zweig,-234,Mivtza Kadesh St 16,4750100001,16,3010
14104,IL,M,,Avinoam Zweig,Avinoam,Zweig,1744,Mivtza Kadesh St 25,4750100001,25,1030
14703,IL,M,,Eyal Bloch,Eyal,Bloch,3554,Mivtza Boulevard 17,4750100002,17,4010
17023,CA,F,,Susan Krasowski,Susan,Krasowski,-176,837 rue Lajeunesse,2600100021,837,2030
19444,IL,M,,Avinoam Zweig,Avinoam,Zweig,-95,Mivtza Kadesh St 61,4750100001,61,1040
19873,IL,M,,Avinoam Tuvia,Avinoam,Tuvia,8931,Mivtza Kadesh St 18,4750100001,18,2030
26148,CA,M,,Andreas Rennie,Andreas,Rennie,-9298,41 Main St,2600100010,41,1030
46966,CA,F,,Lauren Krasowski,Lauren,Krasowski,9793,17 boul Wallberg,2600100011,17,1040
54655,CA,F,,Lauren Marx,Lauren,Marx,3517,512 Gregoire Dr,2600100013,512,9999
70046,CA,M,,Tommy Mcdonald,Tommy,Mcdonald,-346,818 rue Davis,2600100017,818,1020
70059,CA,M,,Colin Byarley,Colin,Byarley,-9477,580 Howe St,2600100047,580,1030
70079,CA,F,,Lera Knott,Lera,Knott,9688,304 Grand Lake Rd,2600100039,304,1030
70100,CA,F,,Wilma Yeargan,Wilma,Yeargan,8940,614 Route 199,2600100015,614,1030
70108,CA,M,,Patrick Leach,Patrick,Leach,-7567,1001 Burrard St,2600100046,1001,1020
70165,CA,F,,Portia Reynoso,Portia,Reynoso,1502,873 rue Bosse,2600100006,873,1020
70187,CA,F,,Soberina Berent,Soberina,Berent,9766,1835 boul Laure,2600100035,1835,1030
70201,CA,F,,Angel Borwick,Angel,Borwick,3640,319 122 Ave NW,2600100012,319,2010
70210,CA,M,,Alex Santinello,Alex,Santinello,9608,40 Route 199,2600100015,40,1030
70221,CA,M,,Kenan Talarr,Kenan,Talarr,1501,9 South Service Rd,2600100019,9,1040
;;;;
run;

data ORION.INVALID_CUSTOMER_DIM;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Customer_Country length=$2 label='Customer Country';
   attrib Customer_Gender length=$1 label='Customer Gender';
   attrib Customer_Name length=$40 label='Customer Name';
   attrib Customer_FirstName length=$20 label='Customer First Name';
   attrib Customer_LastName length=$30 label='Customer Last Name';
   attrib Customer_BirthDate length=8 label='Customer Birth Date' format=DATE9.;
   attrib Customer_Age_Group length=$12 label='Customer Age Group';
   attrib Customer_Type length=$40 label='Customer Type Name';
   attrib Customer_Group length=$40 label='Customer Group Name';
   attrib Customer_Age length=8 label='Customer Age';

   infile datalines dsd;
   input
      Customer_ID
      Customer_Country
      Customer_Gender
      Customer_Name
      Customer_FirstName
      Customer_LastName
      Customer_BirthDate
      Customer_Age_Group
      Customer_Type
      Customer_Group
      Customer_Age
   ;
datalines4;
4,US,M,James Kvarniq,James,Kvarniq,5291,31-45 years,Orion Club members low activity,Orion Club members,33
5,US,F,Sandrina Stephano,Sandrina,Stephano,7129,15-30 years,Orion Club Gold members medium activity,Orion Club Gold members,28
9,DE,F,Cornelia Krahl,Cornelia,Krahl,5171,31-45 years,Orion Club Gold members medium activity,Orion Club Gold members,33
10,UZ,F,Karen Ballinger,Karen,Ballinger,9057,15-30 years,Orion  Club members high activity,Orion Club members,23
11,DE,F,Elke Wallstab,Elke,Wallstab,5341,31-45 years,Orion  Club members high activity,Orion Club members,33
12,US,M,David Black,David,Black,3389,31-45 years,Orion  Club members medium activity,Orion Club members,38
13,DR,M,Markus Sepke,Markus,Sepke,10429,15-30 years,Orion Club Gold members low activity,Orion Club Gold members,19
16,DE,M,Ulrich Heyde,Ulrich,Heyde,-7655,61-75 years,Internet/Catalog Customers,Internet/Catalog Customers,68
17,US,M,Jimmie Evans,Jimmie,Evans,-1963,46-60 years,Orion  Club members medium activity,Orion Club members,53
18,US,M,Tonie Asmussen,Tonie,Asmussen,-2159,46-60 years,Orion Club members low activity,Orion Club members,53
19,DE,M,Oliver S. Füßling,Oliver S.,Füßling,1514,31-45 years,Orion Club Gold members high activity,Orion Club Gold members,43
20,ZZ,M,Michael Dineley,Michael,Dineley,-259,46-60 years,Orion  Club members medium activity,Orion Club members,48
23,US,M,Tulio Devereaux,Tulio,Devereaux,-3682,46-60 years,Internet/Catalog Customers,Internet/Catalog Customers,58
24,US,F,Robyn Klem,Robyn,Klem,-213,46-60 years,Internet/Catalog Customers,Internet/Catalog Customers,48
27,US,F,Cynthia Mccluney,Cynthia,Mccluney,3392,31-45 years,Internet/Catalog Customers,Internet/Catalog Customers,38
29,AU,F,Candy Kinsey,Candy,Kinsey,-9308,61-75 years,Internet/Catalog Customers,Internet/Catalog Customers,73
31,US,F,Cynthia Martinez,Cynthia,Martinez,-147,46-60 years,Orion Club Gold members medium activity,Orion Club Gold members,48
33,DE,M,Rolf Robak,Rolf,Robak,-7616,61-75 years,Orion  Club members medium activity,Orion Club members,68
34,US,M,Alvan Goheen,Alvan,Goheen,8783,15-30 years,Orion Club members low activity,Orion Club members,23
36,US,M,Phenix Hill,Phenix,Hill,1553,31-45 years,Internet/Catalog Customers,Internet/Catalog Customers,43
39,US,M,Alphone Greenwald,Alphone,Greenwald,8972,15-30 years,Orion Club Gold members high activity,Orion Club Gold members,23
41,AU,M,Wendell Summersby,Wendell,Summersby,1797,31-45 years,Orion  Club members medium activity,Orion Club members,43
42,DE,M,Thomas Leitmann,Thomas,Leitmann,6979,15-30 years,Orion Club members low activity,Orion Club members,28
45,US,F,Dianne Patchin,Dianne,Patchin,7065,15-30 years,Orion Club Gold members low activity,Orion Club Gold members,28
49,US,F,Annmarie Leveille,Annmarie,Leveille,8963,15-30 years,Orion Club Gold members high activity,Orion Club Gold members,23
50,DE,M,Gert-Gunter Mendler,Gert-Gunter,Mendler,-9481,61-75 years,Orion Club Gold members high activity,Orion Club Gold members,73
52,US,M,Yan Kozlowski,Yan,Kozlowski,3383,31-45 years,Orion  Club members medium activity,Orion Club members,38
53,AU,F,Dericka Pockran,Dericka,Pockran,-2021,46-60 years,Orion  Club members high activity,Orion Club members,53
56,US,M,Roy Siferd,Roy,Siferd,-9465,61-75 years,Orion  Club members medium activity,Orion Club members,73
60,US,F,Tedi Lanzarone,Tedi,Lanzarone,3430,31-45 years,Orion  Club members medium activity,Orion Club members,38
61,DE,M,Carsten Maestrini,Carsten,Maestrini,-5655,61-75 years,Orion Club Gold members high activity,Orion Club Gold members,63
63,US,M,James Klisurich,James,Klisurich,3646,31-45 years,Orion Club Gold members medium activity,Orion Club Gold members,38
65,DE,F,Ines Deisser,Ines,Deisser,3488,31-45 years,Orion Club members low activity,Orion Club members,38
69,US,F,Patricia Bertolozzi,Patricia,Bertolozzi,7072,15-30 years,Orion Club members low activity,Orion Club members,28
71,US,F,Viola Folsom,Viola,Folsom,3553,31-45 years,Orion Club Gold members medium activity,Orion Club Gold members,38
75,US,M,Mikel Spetz,Mikel,Spetz,8935,15-30 years,Orion Club members low activity,Orion Club members,23
79,US,F,Najma Hicks,Najma,Hicks,9518,15-30 years,Orion  Club members medium activity,Orion Club members,21
88,US,M,Attila Gibbs,Attila,Gibbs,-316,46-60 years,Orion  Club members medium activity,Orion Club members,48
89,US,F,Wynella Lewis,Wynella,Lewis,-9226,61-75 years,Orion  Club members high activity,Orion Club members,73
90,US,F,Kyndal Hooks,Kyndal,Hooks,1674,31-45 years,Orion Club Gold members high activity,Orion Club Gold members,43
92,US,M,Lendon Celii,Lendon,Celii,-5587,61-75 years,Orion Club members low activity,Orion Club members,63
111,AU,F,Karolina Dokter,Karolina,Dokter,5475,31-45 years,Orion  Club members medium activity,Orion Club members,33
171,AU,M,Robert Bowerman,Robert,Bowerman,5166,31-45 years,Orion  Club members high activity,Orion Club members,33
183,AU,M,Duncan Robertshawe,Duncan,Robertshawe,-5760,61-75 years,Orion Club members low activity,Orion Club members,63
195,AU,M,Cosi Rimmington,Cosi,Rimmington,-5529,61-75 years,Orion Club members low activity,Orion Club members,63
215,AU,M,Ramesh Trentholme,Ramesh,Trentholme,-3882,46-60 years,Orion Club Gold members medium activity,Orion Club Gold members,58
544,TR,M,Avni Argac,Avni,Argac,1601,31-45 years,Orion  Club members high activity,Orion Club members,43
908,TR,M,Avni Umran,Avni,Umran,7279,15-30 years,Orion Club Gold members high activity,Orion Club Gold members,28
928,TR,M,Bulent Urfalioglu,Bulent,Urfalioglu,3510,31-45 years,Orion Club members low activity,Orion Club members,38
1033,TT,M,Selim Okay,Selim,Okay,7226,15-30 years,Orion Club members low activity,Orion Club members,28
1100,TR,M,Ahmet Canko,Ahmet,Canko,1479,31-45 years,Orion Club members low activity,Orion Club members,43
1684,TR,M,Carglar Aydemir,Carglar,Aydemir,5403,31-45 years,Orion Club members low activity,Orion Club members,33
2550,ZA,F,Sanelisiwe Collier,Sanelisiwe,Collier,10415,15-30 years,Orion Club Gold members low activity,Orion Club Gold members,19
2618,ZA,M,Theunis Brazier,Theunis,Brazier,-3938,46-60 years,Orion  Club members medium activity,Orion Club members,58
2788,TR,M,Serdar Yucel,Serdar,Yucel,-5843,61-75 years,Orion  Club members high activity,Orion Club members,63
2806,ZA,F,Raedene Van Den Berg,Raedene,Van Den Berg,10486,15-30 years,Orion  Club members medium activity,Orion Club members,19
3959,ZA,F,Rita Lotz,Rita,Lotz,1515,31-45 years,Orion Club Gold members high activity,Orion Club Gold members,43
11171,CA,M,Bill Cuddy,Bill,Cuddy,9785,15-30 years,Orion Club Gold members low activity,Orion Club Gold members,21
12386,IL,M,Avinoam Zweig,Avinoam,Zweig,-234,46-60 years,Internet/Catalog Customers,Internet/Catalog Customers,48
14104,IL,M,Avinoam Zweig,Avinoam,Zweig,1744,31-45 years,Orion  Club members medium activity,Orion Club members,43
14703,IL,M,Eyal Bloch,Eyal,Bloch,3554,31-45 years,Orion  Club members high activity,Orion Club members,38
17023,CA,F,Susan Krasowski,Susan,Krasowski,-176,46-60 years,Orion Club Gold members high activity,Orion Club Gold members,48
19444,II,M,Avinoam Zweig,Avinoam,Zweig,-95,46-60 years,Orion  Club members high activity,Orion Club members,48
19873,IL,M,Avinoam Tuvia,Avinoam,Tuvia,8931,15-30 years,Orion Club Gold members high activity,Orion Club Gold members,23
26148,CA,M,Andreas Rennie,Andreas,Rennie,-9298,61-75 years,Orion  Club members medium activity,Orion Club members,73
46966,CA,F,Lauren Krasowski,Lauren,Krasowski,9793,15-30 years,Orion  Club members high activity,Orion Club members,21
54655,CA,F,Lauren Marx,Lauren,Marx,3517,31-45 years,Internet/Catalog Customers,Internet/Catalog Customers,38
70046,CA,M,Tommy Mcdonald,Tommy,Mcdonald,-346,46-60 years,Orion Club members low activity,Orion Club members,48
70059,CA,M,Colin Byarley,Colin,Byarley,-9477,61-75 years,Orion  Club members medium activity,Orion Club members,73
70079,CA,F,Lera Knott,Lera,Knott,9688,15-30 years,Orion  Club members medium activity,Orion Club members,21
70100,CA,F,Wilma Yeargan,Wilma,Yeargan,8940,15-30 years,Orion  Club members medium activity,Orion Club members,23
70108,CA,M,Patrick Leach,Patrick,Leach,-7567,61-75 years,Orion Club members low activity,Orion Club members,68
70165,CA,F,Portia Reynoso,Portia,Reynoso,1502,31-45 years,Orion Club members low activity,Orion Club members,43
70187,CA,F,Soberina Berent,Soberina,Berent,9766,15-30 years,Orion  Club members medium activity,Orion Club members,21
70201,CA,F,Angel Borwick,Angel,Borwick,3640,31-45 years,Orion Club Gold members low activity,Orion Club Gold members,38
70210,CA,M,Alex Santinello,Alex,Santinello,9608,15-30 years,Orion  Club members medium activity,Orion Club members,21
70221,CA,M,Kenan Talarr,Kenan,Talarr,1501,31-45 years,Orion  Club members high activity,Orion Club members,43
;;;;
run;

data ORION.INVALID_ORDERS03;
   attrib Order_ID length=8;
   attrib Order_Type length=8;
   attrib Order_Date length=8 format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Order_Date
   ;
datalines4;
1230058123,1,18638
1230080101,2,18642
1230106883,2,18647
1230147441,1,18655
1230315085,1,18685
1230333319,2,18688
1230338566,2,18689
1230371142,2,18695
1230404278,1,18701
1230440481,5,18708
1230450371,2,18710
1230453723,2,18710
1230455630,1,18711
1230478006,2,18714
1230498538,1,18718
1230500669,4,18719
1230503155,2,18719
1230591673,2,18735
1230591675,3,18735
1230591684,1,18735
1230619748,2,18741
1230642273,2,18745
1230657844,3,18748
1230690733,3,18754
1230699509,2,18755
1230700421,2,18755
1230738723,2,18762
1230744524,2,18763
1230745294,1,18763
1230754828,10,18765
1230771337,2,18768
1230778996,1,18770
1230793366,2,18772
1230804171,2,18774
1230825762,1,18778
1230841456,2,18781
1230841466,1,18781
1230885738,1,18789
1230912536,1,18794
1230931366,3,18798
1231002241,3,18811
1231008713,2,18812
1231014780,2,18812
1231023774,1,18815
1231035308,2,18817
1231071449,3,18823
1231077006,1,18824
1231094514,2,18828
1231135703,1,18835
1231169108,1,18841
1231176288,1,18843
1231188317,2,18845
1231194004,3,18845
1231204878,1,18847
1231206746,1,18848
1231227910,2,18852
1231231220,1,18852
1231259703,1,18857
1231270767,3,18859
1231292064,1,18863
1231305521,2,18866
1231305531,2,18866
1231314893,1,18867
1231316727,2,18867
1231317443,2,18868
1231341359,1,18872
1231392762,3,18881
1231414059,3,18885
1231453831,3,18893
1231468750,1,18895
1231500373,2,18901
1231501254,1,18901
1231522431,3,18905
1231544990,2,18909
1231614059,2,18922
1231619928,2,18923
1231653765,3,18929
1231657078,1,18929
1231663230,1,18930
1231734609,2,18943
1231734615,3,18943
1231757107,1,18947
1231773634,2,18950
1231780610,1,18951
1231842118,2,18962
1231858937,1,18965
1231861295,2,18966
1231891098,1,18971
1231896710,1,18972
1231898348,1,18973
1231908237,1,18975
1231928627,1,18978
1231930216,1,18979
1231936241,1,18980
1231950921,2,18982
1231952752,2,18983
1231953192,3,18983
1231956902,1,18983
1231976710,3,18987
1231982684,1,18988
1231986335,1,18989
1232003930,3,18992
1232007693,2,18992
1232007700,1,18992
;;;;
run;

data ORION.NO_ROWS;
   attrib Order_ID length=8;
   attrib Order_Type length=8;
   attrib Order_Date length=8 format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Order_Date
   ;
datalines4;
;;;;
run;


data ORION.ORDERS;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1230058123,1,121039,63,17177,17177
1230080101,2,99999999,5,17181,17185
1230106883,2,99999999,45,17186,17188
1230147441,1,120174,41,17194,17194
1230315085,1,120134,183,17224,17224
1230333319,2,99999999,79,17227,17228
1230338566,2,99999999,23,17228,17233
1230371142,2,99999999,45,17234,17236
1230404278,1,121059,56,17240,17240
1230440481,1,120149,183,17247,17247
1230450371,2,99999999,16,17249,17251
1230453723,2,99999999,79,17249,17250
1230455630,1,120134,183,17250,17250
1230478006,2,99999999,2788,17253,17255
1230498538,1,121066,20,17257,17257
1230500669,3,99999999,70046,17258,17259
1230503155,2,99999999,12386,17258,17259
1230591673,2,99999999,23,17274,17279
1230591675,3,99999999,36,17274,17276
1230591684,1,121045,79,17274,17274
1230619748,2,99999999,61,17280,17285
1230642273,2,99999999,13,17284,17289
1230657844,3,99999999,171,17287,17290
1230690733,3,99999999,11171,17293,17295
1230699509,2,99999999,14703,17294,17297
1230700421,2,99999999,79,17294,17295
1230738723,2,99999999,928,17301,17305
1230744524,2,99999999,19444,17302,17307
1230745294,1,121060,71,17302,17302
1230754828,1,121039,12,17304,17304
1230771337,2,99999999,544,17307,17308
1230778996,1,120148,111,17309,17309
1230793366,2,99999999,88,17311,17314
1230804171,2,99999999,23,17313,17318
1230825762,1,121064,71,17317,17317
1230841456,2,99999999,23,17320,17325
1230841466,1,121094,75,17320,17320
1230885738,1,121043,56,17328,17328
1230912536,1,121086,18,17333,17333
1230931366,3,99999999,17023,17337,17342
1231002241,3,99999999,171,17350,17353
1231008713,2,99999999,70108,17351,17352
1231014780,2,99999999,2806,17351,17355
1231023774,1,120145,215,17354,17354
1231035308,2,99999999,13,17356,17361
1231071449,3,99999999,36,17362,17364
1231077006,1,121064,12,17363,17363
1231094514,2,99999999,61,17367,17372
1231135703,1,121027,79,17374,17374
1231169108,1,121059,31,17380,17380
1231176288,1,120164,215,17382,17382
1231188317,2,99999999,111,17384,17386
1231194004,3,99999999,3959,17384,17385
1231204878,1,120732,71,17386,17386
1231206746,1,120134,215,17387,17387
1231227910,2,99999999,70187,17391,17396
1231231220,1,121040,20,17391,17391
1231259703,1,121045,45,17396,17396
1231270767,3,99999999,52,17398,17404
1231292064,1,121037,12,17402,17402
1231305521,2,99999999,16,17405,17413
1231305531,2,99999999,16,17405,17407
1231314893,1,121109,20,17406,17406
1231316727,2,99999999,2806,17406,17410
1231317443,2,99999999,61,17407,17412
1231341359,1,121057,71,17411,17411
1231392762,3,99999999,36,17420,17422
1231414059,3,99999999,36,17424,17426
1231453831,3,99999999,70046,17432,17433
1231468750,1,121044,52,17434,17439
1231500373,2,99999999,19444,17440,17445
1231501254,1,121043,88,17440,17440
1231522431,3,99999999,52,17444,17450
1231544990,2,99999999,14703,17448,17451
1231614059,2,99999999,70108,17461,17462
1231619928,2,99999999,61,17462,17467
1231653765,3,99999999,11,17468,17473
1231657078,1,121061,63,17468,17472
1231663230,1,121025,5,17469,17469
1231734609,2,99999999,544,17482,17483
1231734615,3,99999999,1033,17482,17486
1231757107,1,121037,17,17486,17486
1231773634,2,99999999,14703,17489,17492
1231780610,1,121025,71,17490,17490
1231842118,2,99999999,5,17501,17503
1231858937,1,121060,45,17504,17504
1231861295,2,99999999,70187,17505,17510
1231891098,1,121043,71,17510,17510
1231896710,1,120733,88,17511,17511
1231898348,1,120127,183,17512,17512
1231908237,1,120132,215,17514,17514
1231928627,1,121020,17,17517,17517
1231930216,1,120127,111,17518,17518
1231936241,1,120127,111,17519,17519
1231950921,2,99999999,5,17521,17523
1231952752,2,99999999,111,17522,17524
1231953192,3,99999999,70210,17522,17523
1231956902,1,121037,5,17522,17522
1231976710,3,99999999,19,17526,17530
1231982684,1,120158,183,17527,17527
1231986335,1,120148,195,17528,17528
1232003930,3,99999999,70046,17531,17532
1232007693,2,99999999,5,17531,17535
1232007700,1,121066,45,17531,17531
1232087464,1,120143,53,17544,17544
1232092527,1,121039,49,17544,17544
1232161564,1,121040,34,17554,17554
1232173841,3,99999999,2618,17556,17561
1232217725,2,99999999,89,17563,17566
1232240447,1,120150,195,17567,17567
1232241009,3,99999999,70046,17567,17568
1232307056,1,120148,171,17577,17577
1232311932,1,121039,20,17577,17577
1232331499,2,99999999,23,17580,17584
1232373481,2,99999999,13,17587,17590
1232410925,3,99999999,4,17593,17594
1232455720,1,121100,4,17600,17600
1232517885,3,99999999,70201,17610,17615
1232530384,3,99999999,4,17611,17612
1232530393,1,121037,49,17611,17611
1232554759,1,121068,92,17615,17615
1232590052,1,120160,195,17621,17621
1232601472,2,99999999,89,17622,17625
1232618023,2,99999999,54655,17625,17628
1232648239,1,121031,49,17629,17637
1232654929,3,99999999,4,17630,17631
1232672914,3,99999999,11171,17633,17635
1232698281,3,99999999,9,17637,17642
1232709099,1,121041,4,17638,17638
1232709115,1,121105,34,17638,17638
1232723799,3,99999999,41,17641,17645
1232728634,2,99999999,5,17641,17645
1232777080,1,120151,215,17649,17649
1232790793,1,120143,195,17651,17651
1232857157,2,99999999,45,17660,17664
1232889267,2,99999999,908,17665,17669
1232897220,1,121021,34,17666,17666
1232936635,2,99999999,544,17672,17673
1232946301,2,99999999,111,17674,17676
1232956741,3,99999999,52,17675,17676
1232972274,1,120145,171,17678,17678
1232985693,1,120122,183,17680,17680
1232998740,1,121109,4,17681,17681
1233003688,1,121025,34,17682,17682
1233049735,3,99999999,14104,17689,17692
1233066745,1,120148,215,17692,17692
1233078086,1,121060,49,17693,17693
1233092596,1,121054,12,17695,17695
1233131266,1,121084,45,17701,17701
1233166411,1,120121,171,17707,17707
1233167161,2,99999999,70187,17707,17712
1233243603,1,121109,49,17718,17718
1233248920,2,99999999,19444,17719,17724
1233270605,1,121029,75,17722,17722
1233280857,3,99999999,70059,17724,17728
1233315988,1,121053,5,17729,17729
1233378724,2,99999999,13,17739,17742
1233482761,1,121105,34,17754,17754
1233484749,3,99999999,2550,17754,17759
1233514453,3,99999999,70201,17759,17764
1233531965,1,120123,215,17762,17762
1233543560,3,99999999,4,17763,17764
1233545775,1,120134,41,17764,17764
1233545781,1,120150,215,17764,17764
1233597637,2,99999999,89,17771,17774
1233618453,1,120177,215,17775,17775
1233682051,2,99999999,5,17784,17788
1233689304,1,121053,49,17785,17785
1233837302,1,120148,195,17808,17808
1233895201,2,99999999,111,17817,17819
1233913196,2,99999999,544,17819,17820
1233920786,1,121030,34,17820,17820
1233920795,1,121135,52,17820,17820
1233920805,1,121064,52,17820,17820
1233998114,2,99999999,19873,17832,17839
1234033037,1,121039,92,17837,17837
1234092222,1,121069,75,17846,17846
1234133789,1,120123,195,17853,17853
1234186330,1,120121,53,17861,17861
1234198497,1,121035,49,17862,17862
1234235150,2,99999999,54655,17868,17871
1234247283,1,121042,49,17869,17869
1234255111,1,121135,17,17870,17870
1234279341,2,99999999,23,17874,17878
1234301319,1,121109,92,17877,17877
1234323012,3,99999999,70210,17881,17882
1234348668,1,121069,4,17884,17884
1234360543,1,121071,17,17886,17886
1234373539,1,121069,12,17888,17888
1234414529,1,120123,111,17895,17895
1234419240,1,121109,17,17895,17895
1234437760,1,120150,195,17899,17899
1234534069,3,99999999,36,17908,17911
1234537441,1,120121,183,17909,17909
1234538390,2,99999999,16,17909,17911
1234588648,2,99999999,16,17914,17916
1234659163,2,99999999,16,17921,17923
1234665265,2,99999999,63,17921,17922
1234709803,3,99999999,171,17926,17930
1234727966,1,120179,183,17928,17928
1234891576,3,99999999,70221,17944,17946
1234897732,1,121021,18,17944,17944
1234958242,2,99999999,24,17950,17955
1234972570,2,99999999,16,17952,17954
1235176942,3,99999999,11171,17971,17973
1235236723,1,120160,215,17977,17977
1235275513,1,121043,89,17980,17980
1235306679,1,120122,111,17984,17984
1235384426,1,121109,63,17991,17991
1235591214,2,99999999,16,18012,18014
1235611754,2,99999999,16,18014,18016
1235744141,2,99999999,16,18027,18029
1235830338,2,99999999,24,18035,18041
1235856852,1,120127,171,18038,18038
1235881915,3,99999999,36,18040,18043
1235913793,1,121040,49,18043,18043
1235926178,3,99999999,79,18044,18051
1235963427,2,99999999,12386,18048,18049
1236017640,1,120127,183,18054,18054
1236028541,3,99999999,9,18055,18060
1236055696,1,121136,10,18057,18057
1236066649,2,99999999,908,18058,18062
1236113431,3,99999999,36,18063,18066
1236128445,2,99999999,26148,18065,18067
1236128456,2,99999999,16,18065,18067
1236183578,2,99999999,23,18070,18075
1236216065,1,120131,41,18074,18074
1236349115,1,121051,92,18086,18086
1236369939,1,120123,111,18089,18089
1236483576,2,99999999,70108,18100,18111
1236673732,3,99999999,9,18119,18124
1236694462,3,99999999,70221,18121,18123
1236701935,1,121027,34,18121,18121
1236783056,1,120136,183,18130,18130
1236852196,1,120170,215,18137,18137
1236923123,3,99999999,3959,18143,18144
1236965430,3,99999999,70165,18148,18158
1237165927,3,99999999,79,18167,18178
1237218771,1,120143,111,18173,18173
1237272696,1,120124,195,18178,18178
1237327705,1,121043,10,18183,18183
1237331045,3,99999999,2618,18183,18188
1237370327,1,120145,41,18188,18188
1237450174,3,99999999,171,18196,18200
1237478988,2,99999999,908,18198,18202
1237507462,2,99999999,1100,18201,18203
1237517484,1,121081,79,18202,18202
1237664026,3,99999999,65,18217,18223
1237670443,2,99999999,10,18217,18222
1237695520,1,120190,53,18220,18220
1237751376,2,99999999,10,18225,18230
1237789102,1,121027,56,18229,18229
1237825036,3,99999999,9,18233,18238
1237890730,1,121041,5,18239,18239
1237894107,2,99999999,29,18240,18245
1237894966,2,99999999,70187,18240,18245
1237928021,2,99999999,23,18243,18248
1237974997,1,120158,41,18248,18248
1237989406,3,99999999,36,18249,18252
1238013821,3,99999999,46966,18252,18253
1238053337,3,99999999,9,18256,18261
1238161695,2,99999999,41,18268,18272
1238168538,1,121064,63,18268,18268
1238231237,1,121106,10,18276,18276
1238255107,1,121039,88,18279,18279
1238273927,1,120127,215,18282,18282
1238305578,3,99999999,70210,18286,18287
1238319276,1,121025,52,18287,18287
1238319281,1,121106,89,18287,18287
1238353296,1,120127,111,18292,18292
1238367238,1,121044,31,18293,18293
1238370259,3,99999999,19,18294,18299
1238377562,1,120151,41,18295,18295
1238393448,1,121073,10,18296,18296
1238426415,3,99999999,19,18301,18306
1238440880,1,121042,52,18302,18302
1238474357,2,99999999,50,18307,18308
1238510159,1,121054,71,18311,18311
1238553101,3,99999999,19,18317,18322
1238605995,1,121033,88,18323,18323
1238637449,1,121023,88,18327,18327
1238646479,1,121069,12,18328,18328
1238646484,1,121072,90,18328,18328
1238674844,1,120121,53,18332,18332
1238678581,1,121051,12,18332,18332
1238686430,1,121044,10,18333,18333
1238696385,2,99999999,2806,18334,18338
1238712056,1,120127,53,18337,18337
1238735750,1,120177,195,18340,18340
1238797437,2,99999999,928,18347,18351
1238805678,1,121024,52,18348,18348
1238805703,1,121039,89,18348,18348
1238812262,2,99999999,14703,18349,18352
1238846184,1,121056,88,18353,18353
1238856867,2,99999999,70187,18355,18360
1238870441,1,121105,39,18356,18356
1238872273,3,99999999,3959,18356,18358
1238910092,1,121042,89,18361,18361
1238928257,1,120172,215,18364,18364
1238968334,2,99999999,29,18369,18373
1238985782,2,99999999,29,18371,18375
1239003827,3,99999999,19,18373,18378
1239018454,3,99999999,70221,18375,18377
1239057268,1,121030,12,18379,18379
1239172417,2,99999999,29,18394,18398
1239179935,2,99999999,39,18394,18399
1239194032,1,121040,52,18396,18396
1239201604,1,121020,90,18397,18397
1239220388,2,99999999,29,18400,18404
1239226632,3,99999999,20,18400,18406
1239248786,1,121087,63,18403,18403
1239258470,1,120152,41,18405,18405
1239266107,1,120143,53,18406,18406
1239312711,1,121075,45,18411,18411
1239320891,2,99999999,1100,18412,18414
1239346133,1,121037,52,18415,18415
1239353855,1,120143,183,18417,18417
1239368476,1,121105,89,18418,18418
1239408849,1,121105,52,18423,18423
1239410348,2,99999999,29,18424,18428
1239416627,1,121036,88,18424,18424
1239418524,1,120127,195,18425,18425
1239442095,2,99999999,41,18428,18432
1239498112,3,99999999,17023,18435,18440
1239543223,1,121040,90,18440,18440
1239615368,1,121127,45,18449,18449
1239693951,1,121040,88,18459,18459
1239713046,2,99999999,16,18462,18463
1239735632,1,121073,71,18464,18464
1239744161,2,99999999,13,18466,18471
1239765451,1,121036,60,18468,18468
1239785436,3,99999999,65,18471,18477
1239821232,2,99999999,1684,18475,18478
1239823829,2,99999999,54655,18476,18479
1239836937,1,121090,12,18477,18477
1239874523,1,121042,12,18482,18482
1239932984,2,99999999,16,18490,18491
1239962634,1,120732,52,18493,18493
1239972644,2,99999999,53,18495,18497
1239994933,1,121060,90,18497,18497
1240051245,3,99999999,71,18504,18510
1240060066,1,121066,60,18505,18505
1240137702,2,99999999,544,18515,18516
1240173354,3,99999999,70165,18520,18521
1240187143,2,99999999,29,18522,18526
1240201886,1,121039,10,18523,18523
1240283215,1,121051,52,18533,18533
1240306942,1,121071,90,18536,18536
1240314947,2,99999999,908,18537,18541
1240314956,1,121074,17,18537,18537
1240355393,1,121063,10,18542,18542
1240379679,1,120733,63,18545,18545
1240387741,1,121140,89,18546,18546
1240430921,1,120153,183,18552,18552
1240446608,2,99999999,29,18554,18558
1240447572,2,99999999,50,18554,18555
1240461993,1,121036,10,18555,18555
1240485814,2,99999999,29,18559,18563
1240509842,1,121033,63,18561,18561
1240512744,2,99999999,50,18562,18563
1240549230,1,121061,89,18566,18566
1240568966,3,99999999,19,18569,18574
1240581932,1,120192,215,18571,18571
1240588370,2,99999999,2788,18571,18573
1240599396,2,99999999,16,18573,18574
1240604971,1,121071,63,18573,18573
1240613362,1,121069,20,18574,18574
1240692950,1,121086,88,18584,18584
1240782710,2,99999999,544,18595,18596
1240856801,2,99999999,544,18604,18605
1240870047,2,99999999,1100,18606,18608
1240886449,1,121030,52,18608,18608
1240903120,1,121044,52,18610,18610
1240961599,2,99999999,16,18618,18619
1241054779,3,99999999,24,18629,18632
1241063739,1,121135,89,18630,18631
1241066216,1,120134,171,18631,18631
1241086052,3,99999999,53,18633,18636
1241147641,1,120131,53,18640,18640
1241235281,1,120136,171,18650,18657
1241244297,1,120164,111,18651,18651
1241263172,3,99999999,3959,18652,18653
1241286432,3,99999999,27,18655,18660
1241298131,2,99999999,2806,18656,18666
1241359997,1,121043,12,18663,18663
1241371145,1,120124,171,18665,18665
1241390440,1,120131,41,18667,18667
1241461856,1,121042,18,18674,18675
1241561055,1,120127,171,18686,18686
1241623505,3,99999999,24,18692,18695
1241645664,2,99999999,70100,18695,18699
1241652707,3,99999999,27,18695,18700
1241686210,1,121040,10,18699,18705
1241715610,1,121106,92,18702,18702
1241731828,1,121025,31,18704,18704
1241789227,3,99999999,17023,18711,18716
1241895594,1,121051,56,18722,18726
1241909303,3,99999999,46966,18724,18725
1241930625,3,99999999,27,18726,18731
1241977403,1,120152,171,18732,18732
1242012259,1,121040,10,18735,18735
1242012269,1,121040,45,18735,18735
1242035131,1,120132,183,18738,18738
1242076538,3,99999999,31,18742,18746
1242130888,1,121086,92,18748,18748
1242140006,3,99999999,5,18749,18754
1242140009,2,99999999,90,18749,18751
1242149082,1,121032,90,18750,18750
1242159212,3,99999999,5,18751,18756
1242161468,3,99999999,2550,18751,18756
1242162201,3,99999999,46966,18752,18753
1242173926,3,99999999,1033,18753,18757
1242185055,1,120136,41,18755,18755
1242214574,3,99999999,70079,18758,18761
1242229985,1,120127,171,18760,18760
1242259863,2,99999999,70187,18763,18768
1242265757,1,121105,10,18763,18763
1242449327,3,99999999,27,18783,18788
1242458099,1,121071,10,18784,18784
1242467585,3,99999999,34,18785,18791
1242477751,3,99999999,31,18786,18790
1242493791,1,121056,5,18788,18788
1242502670,1,121067,31,18789,18789
1242515373,3,99999999,17023,18791,18796
1242534503,3,99999999,70165,18793,18800
1242557584,2,99999999,89,18795,18799
1242559569,1,120130,171,18796,18796
1242568696,2,99999999,2806,18796,18800
1242578860,2,99999999,70100,18798,18802
1242610991,1,121037,12,18801,18801
1242647539,1,121109,45,18805,18805
1242657273,1,121037,90,18806,18806
1242691897,2,99999999,90,18810,18812
1242736731,1,121107,10,18815,18815
1242773202,3,99999999,24,18819,18822
1242782701,3,99999999,27,18820,18825
1242827683,1,121105,10,18825,18825
1242836878,1,121027,10,18826,18826
1242838815,1,120195,41,18827,18827
1242848557,2,99999999,2806,18827,18831
1242923327,3,99999999,70165,18836,18837
1242938120,1,120124,171,18838,18838
1242977743,2,99999999,65,18842,18846
1243012144,2,99999999,2806,18845,18849
1243026971,1,120733,10,18847,18847
1243039354,1,120143,41,18849,18849
1243049938,3,99999999,53,18850,18853
1243110343,1,121032,10,18856,18856
1243127549,1,120159,171,18859,18859
1243152030,1,120734,45,18861,18862
1243152039,1,121089,90,18861,18861
1243165497,3,99999999,70201,18863,18868
1243198099,1,121061,10,18866,18866
1243227745,1,120141,171,18870,18880
1243269405,2,99999999,928,18874,18878
1243279343,3,99999999,27,18875,18880
1243290080,1,121057,31,18876,18876
1243290089,1,121065,45,18876,18876
1243315613,1,121026,5,18879,18879
1243398628,1,121051,12,18888,18888
1243417726,1,121029,69,18890,18890
1243462945,3,99999999,24,18895,18898
1243465031,1,120195,41,18896,18896
1243485097,3,99999999,11,18898,18902
1243515588,1,121024,89,18901,18901
1243568955,1,121060,31,18907,18907
1243643970,1,120138,171,18916,18916
1243644877,3,99999999,70079,18916,18919
1243661763,1,120124,41,18918,18918
1243670182,1,121065,69,18918,18918
1243680376,1,121061,31,18919,18919
1243797399,1,121053,10,18932,18932
1243799681,1,120128,41,18933,18933
1243815198,1,120732,10,18934,18934
1243817278,1,120127,171,18935,18935
1243887390,2,99999999,908,18942,18946
1243951648,1,121068,34,18949,18949
1243960910,1,121028,90,18950,18950
1243963366,1,120175,215,18951,18951
1243991721,1,120124,171,18954,18954
1243992813,2,99999999,70187,18954,18959
1244066194,2,99999999,2806,18961,18965
1244086685,3,99999999,14104,18964,18967
1244107612,1,121107,45,18966,18966
1244117101,1,121109,45,18967,18967
1244117109,1,121117,49,18967,18967
1244171290,1,121121,31,18973,18973
1244181114,1,121092,10,18974,18974
1244197366,1,121118,89,18976,18976
1244296274,1,121040,5,18987,18987
;;;;
run;

data ORION.ORDERS03;
   attrib Order_ID length=8;
   attrib Order_Type length=8;
   attrib Order_Date length=8 format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Order_Date
   ;
datalines4;
1230058123,1,18638
1230080101,2,18642
1230106883,2,18647
1230147441,1,18655
1230315085,1,18685
1230333319,2,18688
1230338566,2,18689
1230371142,2,18695
1230404278,1,18701
1230440481,1,18708
1230450371,2,18710
1230453723,2,18710
1230455630,1,18711
1230478006,2,18714
1230498538,1,18718
1230500669,3,18719
1230503155,2,18719
1230591673,2,18735
1230591675,3,18735
1230591684,1,18735
1230619748,2,18741
1230642273,2,18745
1230657844,3,18748
1230690733,3,18754
1230699509,2,18755
1230700421,2,18755
1230738723,2,18762
1230744524,2,18763
1230745294,1,18763
1230754828,1,18765
1230771337,2,18768
1230778996,1,18770
1230793366,2,18772
1230804171,2,18774
1230825762,1,18778
1230841456,2,18781
1230841466,1,18781
1230885738,1,18789
1230912536,1,18794
1230931366,3,18798
1231002241,3,18811
1231008713,2,18812
1231014780,2,18812
1231023774,1,18815
1231035308,2,18817
1231071449,3,18823
1231077006,1,18824
1231094514,2,18828
1231135703,1,18835
1231169108,1,18841
1231176288,1,18843
1231188317,2,18845
1231194004,3,18845
1231204878,1,18847
1231206746,1,18848
1231227910,2,18852
1231231220,1,18852
1231259703,1,18857
1231270767,3,18859
1231292064,1,18863
1231305521,2,18866
1231305531,2,18866
1231314893,1,18867
1231316727,2,18867
1231317443,2,18868
1231341359,1,18872
1231392762,3,18881
1231414059,3,18885
1231453831,3,18893
1231468750,1,18895
1231500373,2,18901
1231501254,1,18901
1231522431,3,18905
1231544990,2,18909
1231614059,2,18922
1231619928,2,18923
1231653765,3,18929
1231657078,1,18929
1231663230,1,18930
1231734609,2,18943
1231734615,3,18943
1231757107,1,18947
1231773634,2,18950
1231780610,1,18951
1231842118,2,18962
1231858937,1,18965
1231861295,2,18966
1231891098,1,18971
1231896710,1,18972
1231898348,1,18973
1231908237,1,18975
1231928627,1,18978
1231930216,1,18979
1231936241,1,18980
1231950921,2,18982
1231952752,2,18983
1231953192,3,18983
1231956902,1,18983
1231976710,3,18987
1231982684,1,18988
1231986335,1,18989
1232003930,3,18992
1232007693,2,18992
1232007700,1,18992
;;;;
run;

data ORION.ORDER_FACT;
   attrib Club_Code length=$3 label='Orion Club Code';
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Street_ID length=8 label='Street ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Product_ID length=8 label='Product ID' format=12.;
   attrib Quantity length=8 label='Quantity Ordered';
   attrib Total_Retail_Price length=8 label='Total Retail Price for This Product' format=DOLLAR13.2;
   attrib CostPrice_Per_Unit length=8 label='Cost Price Per Unit' format=DOLLAR13.2;
   attrib Discount length=8 label='Discount in percent of Normal Total Retail Price' format=PERCENT.;
   attrib Coupon_Code length=$5 label='Coupon Code';

   infile datalines dsd;
   input
      Club_Code
      Customer_ID
      Employee_ID
      Street_ID
      Order_Date
      Delivery_Date
      Order_ID
      Order_Type
      Product_ID
      Quantity
      Total_Retail_Price
      CostPrice_Per_Unit
      Discount
      Coupon_Code
   ;
datalines4;
GDM,63,121039,9260125492,17177,17177,1230058123,1,220101300017,1,16.5,7.45,,01M03
GDM,5,99999999,9260114570,17181,17185,1230080101,2,230100500026,1,247.5,109.55,,01M03
GDL,45,99999999,9260104847,17186,17188,1230106883,2,240600100080,1,28.3,8.55,,01M03
ORM,41,120174,1600101527,17194,17194,1230147441,1,240600100010,2,32,6.5,,01M03
ORL,183,120134,1600100760,17224,17224,1230315085,1,240200200039,3,63.6,8.8,,02M03
ORM,79,99999999,9260101874,17227,17228,1230333319,2,240100400005,1,234.6,115.95,,03M03
INT,23,99999999,9260126679,17228,17233,1230338566,2,240800200062,1,35.4,16.15,,03M03
INT,23,99999999,9260126679,17228,17233,1230338566,2,240800200063,2,73.8,16.85,,03M03
GDL,45,99999999,9260104847,17234,17236,1230371142,2,240500100004,2,127,28,,03M03
GDL,45,99999999,9260104847,17234,17236,1230371142,2,240500200003,1,23.2,11.1,,03M03
ORM,56,121059,9260111871,17240,17240,1230404278,1,220200300002,2,75,17.05,,03M03
ORL,183,120149,1600100760,17247,17247,1230440481,1,230100600005,1,129.8,63.2,,03M03
INT,16,99999999,3940105865,17249,17251,1230450371,2,230100600018,2,128.4,32.2,,03M03
ORM,79,99999999,9260101874,17249,17250,1230453723,2,240500200056,1,24.1,11.55,,03M03
ORL,183,120134,1600100760,17250,17250,1230455630,1,240200100233,2,91.8,22.45,,03M03
ORH,2788,99999999,9050100001,17253,17255,1230478006,2,230100100025,2,60.6,13.15,,03M03
ORM,20,121066,9260118934,17257,17257,1230498538,1,230100300006,1,68.5,34.35,,04M03
INT,12386,99999999,4750100001,17258,17259,1230503155,2,220101400310,1,31.8,14.2,,04M03
ORL,70046,99999999,2600100017,17258,17259,1230500669,3,240200100131,2,148.6,41.35,,04M03
INT,23,99999999,9260126679,17274,17279,1230591673,2,220200200024,3,178.5,32.25,,04M03
INT,36,99999999,9260128237,17274,17276,1230591675,3,240500100039,1,34.5,15.4,,04M03
ORM,79,121045,9260101874,17274,17274,1230591684,1,240200100076,4,1796,246.55,,04M03
GDH,61,99999999,3940108887,17280,17285,1230619748,2,220200100092,1,83,41.6,,04M03
GDH,61,99999999,3940108887,17280,17285,1230619748,2,220200300005,3,345,52.35,,04M03
GDL,13,99999999,3940105189,17284,17289,1230642273,2,230100500082,1,126.1,58.6,,04M03
ORH,171,99999999,1600101555,17287,17290,1230657844,3,240100100646,1,109.9,46.8,,05M03
GDL,11171,99999999,2600100032,17293,17295,1230690733,3,240200100043,2,282.4,69.4,,05M03
ORM,79,99999999,9260101874,17294,17295,1230700421,2,230100100006,1,176,74.55,,05M03
ORM,79,99999999,9260101874,17294,17295,1230700421,2,230100500045,2,2.6,0.6,,05M03
ORM,79,99999999,9260101874,17294,17295,1230700421,2,230100500068,2,3.4,0.8,,05M03
ORH,14703,99999999,4750100002,17294,17297,1230699509,2,220100100044,1,102.1,48.65,,05M03
ORH,14703,99999999,4750100002,17294,17297,1230699509,2,220100400005,1,81.3,40.75,,05M03
ORL,928,99999999,9050100016,17301,17305,1230738723,2,230100600026,2,237.2,59.4,,05M03
GDM,71,121060,9260124130,17302,17302,1230745294,1,220200100179,1,134.5,67.35,,05M03
ORH,19444,99999999,4750100001,17302,17307,1230744524,2,220100700024,1,99.7,47.45,,05M03
ORH,19444,99999999,4750100001,17302,17307,1230744524,2,220101000002,1,17.7,8,,05M03
ORM,12,121039,9260103713,17304,17304,1230754828,1,220100100272,3,68.4,11.5,,05M03
ORM,12,121039,9260103713,17304,17304,1230754828,1,220101400269,4,268,29.8,,05M03
ORH,544,99999999,9050100008,17307,17308,1230771337,2,230100500012,3,221.7,33.25,,05M03
ORM,111,120148,1600102072,17309,17309,1230778996,1,230100500096,1,35.5,17.25,,05M03
ORM,88,99999999,9260100179,17311,17314,1230793366,2,240400200097,3,1250.4,124.2,,05M03
INT,23,99999999,9260126679,17313,17318,1230804171,2,240500200073,3,148.5,20.65,,05M03
GDM,71,121064,9260124130,17317,17317,1230825762,1,230100500093,2,265.6,55.85,,05M03
INT,23,99999999,9260126679,17320,17325,1230841456,2,240700400024,2,127.2,33.15,,06M03
ORL,75,121094,9260108068,17320,17320,1230841466,1,240500100062,2,109.2,23.85,,06M03
ORL,75,121094,9260108068,17320,17320,1230841466,1,240500200130,2,56,11.7,,06M03
ORM,56,121043,9260111871,17328,17328,1230885738,1,220101300017,2,33,7.45,,06M03
ORM,56,121043,9260111871,17328,17328,1230885738,1,220101400098,3,97.2,14.85,,06M03
ORL,18,121086,9260112361,17333,17333,1230912536,1,240500200121,2,50.8,12.1,,06M03
GDH,17023,99999999,2600100021,17337,17342,1230931366,3,240200200007,2,166.8,8.35,,06M03
GDH,17023,99999999,2600100021,17337,17342,1230931366,3,240200200061,2,261.8,52.45,,06M03
ORH,171,99999999,1600101555,17350,17353,1231002241,3,220101200029,1,52.3,22.65,,07M03
ORM,2806,99999999,8010100089,17351,17355,1231014780,2,240100400043,4,1064,131.5,,07M03
ORL,70108,99999999,2600100046,17351,17352,1231008713,2,240200200039,2,42.4,8.8,,07M03
GDM,215,120145,1600102721,17354,17354,1231023774,1,230100500024,1,22.9,10.85,,07M03
GDM,215,120145,1600102721,17354,17354,1231023774,1,230100600015,1,78.2,39.2,,07M03
GDL,13,99999999,3940105189,17356,17361,1231035308,2,230100600023,2,146.8,36.8,,07M03
INT,36,99999999,9260128237,17362,17364,1231071449,3,240400200057,2,257,58.05,,07M03
INT,36,99999999,9260128237,17362,17364,1231071449,3,240400200066,2,27.6,6.3,,07M03
ORM,12,121064,9260103713,17363,17363,1231077006,1,230100500095,2,193.8,40,,07M03
GDH,61,99999999,3940108887,17367,17372,1231094514,2,230100500074,4,544,51.3,,07M03
GDH,61,99999999,3940108887,17367,17372,1231094514,2,230100600005,2,259.6,63.2,,07M03
ORM,79,121027,9260101874,17374,17374,1231135703,1,210200900004,2,92,16.05,,07M03
ORM,79,121027,9260101874,17374,17374,1231135703,1,210201000050,2,39,8.95,,07M03
GDM,31,121059,9260128428,17380,17380,1231169108,1,220200300157,3,220.2,36.65,,08M03
GDM,215,120164,1600102721,17382,17382,1231176288,1,240500200100,2,45.4,10.85,,08M03
ORM,111,99999999,1600102072,17384,17386,1231188317,2,220100900029,1,30.8,12.35,,08M03
GDH,3959,99999999,8010100151,17384,17385,1231194004,3,240100100610,2,122,27.55,,08M03
GDH,3959,99999999,8010100151,17384,17385,1231194004,3,240100400143,2,330,82.6,,08M03
GDM,71,120732,9260124130,17386,17386,1231204878,1,230100600017,2,111.4,27.95,,08M03
GDM,215,120134,1600102721,17387,17387,1231206746,1,240200100232,1,28.2,14.2,,08M03
ORM,20,121040,9260118934,17391,17391,1231231220,1,220101400306,2,145.2,33.1,,08M03
ORM,70187,99999999,2600100035,17391,17396,1231227910,2,240200200013,3,1266,42.2,,08M03
GDL,45,121045,9260104847,17396,17396,1231259703,1,240200100051,3,420.9,72,,08M03
ORM,52,99999999,9260116235,17398,17404,1231270767,3,230100600022,2,168.2,42.15,,08M03
ORM,12,121037,9260103713,17402,17402,1231292064,1,220101400060,3,96.3,14.7,,08M03
ORM,12,121037,9260103713,17402,17402,1231292064,1,220101400117,2,91.2,20.85,,08M03
INT,16,99999999,3940105865,17405,17413,1231305521,2,220200100035,2,125.2,31.4,,08M03
INT,16,99999999,3940105865,17405,17407,1231305531,2,220200100090,2,177.2,44.4,,08M03
ORM,20,121109,9260118934,17406,17406,1231314893,1,240700200024,2,32,6.35,,08M03
ORM,2806,99999999,8010100089,17406,17410,1231316727,2,240100400076,2,224.6,68.6,,08M03
ORM,2806,99999999,8010100089,17406,17410,1231316727,2,240100400143,2,330,82.6,,08M03
GDH,61,99999999,3940108887,17407,17412,1231317443,2,230100700002,2,440,135,,08M03
GDM,71,121057,9260124130,17411,17411,1231341359,1,220200200018,2,132.8,30.25,,09M03
INT,36,99999999,9260128237,17420,17422,1231392762,3,230100600023,2,146.8,36.8,,09M03
INT,36,99999999,9260128237,17424,17426,1231414059,3,240800200008,1,150.25,60.1,,09M03
ORL,70046,99999999,2600100017,17432,17433,1231453831,3,240200100052,1,99.7,51.4,,09M03
ORL,70046,99999999,2600100017,17432,17433,1231453831,3,240200200015,1,24,10.55,,09M03
ORM,52,121044,9260116235,17434,17439,1231468750,1,220100100153,1,50,25.1,,09M03
ORM,88,121043,9260100179,17440,17440,1231501254,1,220100700052,1,106.1,50.5,,10M03
ORH,19444,99999999,4750100001,17440,17445,1231500373,2,220101200006,1,52.2,20.95,,10M03
ORM,52,99999999,9260116235,17444,17450,1231522431,3,240100100065,1,34.7,13.8,,10M03
ORH,14703,99999999,4750100002,17448,17451,1231544990,2,220101400385,1,24.8,12.35,,10M03
ORL,70108,99999999,2600100046,17461,17462,1231614059,2,220101200020,1,55.9,24.2,,10M03
GDH,61,99999999,3940108887,17462,17467,1231619928,2,230100600036,1,103.2,50.4,,10M03
ORH,11,99999999,3940108592,17468,17473,1231653765,3,230100200047,1,72.7,35.2,,10M03
GDM,63,121061,9260125492,17468,17472,1231657078,1,220200300116,1,84.2,38.35,,10M03
GDM,5,121025,9260114570,17469,17469,1231663230,1,240100100433,1,3,1.15,,10M03
ORH,544,99999999,9050100008,17482,17483,1231734609,2,230100500091,1,191,80.45,,11M03
ORL,1033,99999999,9050100001,17482,17486,1231734615,3,230100600005,1,129.8,63.2,,11M03
ORM,17,121037,9260123306,17486,17486,1231757107,1,220100100568,1,84.1,42.15,,11M03
ORH,14703,99999999,4750100002,17489,17492,1231773634,2,220101400018,2,45.6,10.45,,11M03
GDM,71,121025,9260124130,17490,17490,1231780610,1,240100400080,1,219.9,109.9,,11M03
GDM,5,99999999,9260114570,17501,17503,1231842118,2,240700300002,2,43.98,7.25,,12M03
GDL,45,121060,9260104847,17504,17504,1231858937,1,220200300079,2,128.6,28.65,,12M03
ORM,70187,99999999,2600100035,17505,17510,1231861295,2,240200100154,2,53.2,11.95,,12M03
GDM,71,121043,9260124130,17510,17510,1231891098,1,220101400091,2,65.6,15,,12M03
ORM,88,120733,9260100179,17511,17511,1231896710,1,230100500087,1,93.8,39.05,,12M03
ORL,183,120127,1600100760,17512,17512,1231898348,1,220101400289,4,240.8,27.4,,12M03
GDM,215,120132,1600102721,17514,17514,1231908237,1,240200100180,2,243.2,62.9,,12M03
ORM,17,121020,9260123306,17517,17517,1231928627,1,240100400070,1,175.9,127.95,,12M03
ORM,111,120127,1600102072,17518,17518,1231930216,1,220100300008,4,342.8,34.35,,12M03
ORM,111,120127,1600102072,17519,17519,1231936241,1,220101400017,2,22.2,5,,12M03
GDM,5,99999999,9260114570,17521,17523,1231950921,2,230100500093,2,265.6,55.85,,12M03
GDM,5,99999999,9260114570,17521,17523,1231950921,2,230100600030,1,86.3,41.4,,12M03
GDM,5,121037,9260114570,17522,17522,1231956902,1,220101400276,2,136.8,31.2,,12M03
ORM,111,99999999,1600102072,17522,17524,1231952752,2,220100100298,2,105.8,26.55,,12M03
ORM,70210,99999999,2600100015,17522,17523,1231953192,3,240200100052,2,199.4,51.4,,12M03
GDH,19,99999999,3940106547,17526,17530,1231976710,3,240300100020,4,56.4,6.05,,12M03
GDH,19,99999999,3940106547,17526,17530,1231976710,3,240300100032,2,1200.2,300,,12M03
ORL,183,120158,1600100760,17527,17527,1231982684,1,240400300033,3,107.1,14.35,,12M03
ORL,195,120148,1600101663,17528,17528,1231986335,1,230100500008,1,38,16.8,,12M03
GDM,5,99999999,9260114570,17531,17535,1232007693,2,240100400044,1,353.6,174.75,,12M03
GDM,5,99999999,9260114570,17531,17535,1232007693,2,240100400049,1,421.2,212.95,,12M03
GDL,45,121066,9260104847,17531,17531,1232007700,1,230100100045,2,249.6,53.6,,12M03
GDL,45,121066,9260104847,17531,17531,1232007700,1,230100200019,2,398.2,95.65,,12M03
GDL,45,121066,9260104847,17531,17531,1232007700,1,230100500056,1,8,3.5,,12M03
ORL,70046,99999999,2600100017,17531,17532,1232003930,3,240200100124,2,49,12.35,,12M03
GDH,49,121039,9260104510,17544,17544,1232092527,1,220100200004,1,6.5,2.6,,01M04
GDH,49,121039,9260104510,17544,17544,1232092527,1,220100900006,1,88.4,35.45,,01M04
GDH,49,121039,9260104510,17544,17544,1232092527,1,220101400150,1,28.2,12.9,,01M04
ORH,53,120143,1600103258,17544,17544,1232087464,1,230100600022,4,336.4,42.15,,01M04
ORL,34,121040,9260111379,17554,17554,1232161564,1,220100100197,1,101.3,50.75,,01M04
ORM,2618,99999999,8010100125,17556,17561,1232173841,3,240100100581,1,28,11.55,,01M04
ORM,2618,99999999,8010100125,17556,17561,1232173841,3,240100400147,1,248.3,122.75,,01M04
ORH,89,99999999,9260116551,17563,17566,1232217725,2,230100100062,2,283.4,61,,02M04
ORL,195,120150,1600101663,17567,17567,1232240447,1,230100200059,2,77.6,16.65,,02M04
ORL,70046,99999999,2600100017,17567,17568,1232241009,3,240200200039,1,22.2,9.2,,02M04
ORM,20,121039,9260118934,17577,17577,1232311932,1,220100300025,2,206,42.4,,02M04
ORH,171,120148,1600101555,17577,17577,1232307056,1,230100500081,2,146,30.35,,02M04
INT,23,99999999,9260126679,17580,17584,1232331499,2,230100100051,2,369.8,78.15,,02M04
GDL,13,99999999,3940105189,17587,17590,1232373481,2,220200100229,1,165.5,82.85,,02M04
ORL,4,99999999,9260106519,17593,17594,1232410925,3,240800200030,1,47.7,18.8,,03M04
ORL,4,121100,9260106519,17600,17600,1232455720,1,240600100017,1,53,23.25,,03M04
GDL,70201,99999999,2600100012,17610,17615,1232517885,3,240200100226,1,183.9,86.65,,03M04
ORL,4,99999999,9260106519,17611,17612,1232530384,3,240700200019,1,16.9,8.6,,03M04
GDH,49,121037,9260104510,17611,17611,1232530393,1,220100100125,1,33.4,16.8,,03M04
GDH,49,121037,9260104510,17611,17611,1232530393,1,220100100513,1,63.9,32.05,,03M04
GDH,49,121037,9260104510,17611,17611,1232530393,1,220100300019,1,35.6,16.7,,03M04
ORL,92,121068,9260117676,17615,17615,1232554759,1,230100600022,1,84.1,42.15,,03M04
ORL,195,120160,1600101663,17621,17621,1232590052,1,240400300013,1,51.8,21.6,,03M04
ORL,195,120160,1600101663,17621,17621,1232590052,1,240400300035,1,19.1,7.7,,03M04
ORH,89,99999999,9260116551,17622,17625,1232601472,2,230100500094,2,173.2,34.1,,03M04
INT,54655,99999999,2600100013,17625,17628,1232618023,2,240200100183,1,95.7,47.95,,04M04
GDH,49,121031,9260104510,17629,17637,1232648239,1,210201000126,1,6.5,2.3,,04M04
ORL,4,99999999,9260106519,17630,17631,1232654929,3,240500100017,4,214,23.75,,04M04
ORL,4,99999999,9260106519,17630,17631,1232654929,3,240500100029,1,58.9,26.1,,04M04
GDL,11171,99999999,2600100032,17633,17635,1232672914,3,240200100101,2,38.8,10.2,,04M04
GDL,11171,99999999,2600100032,17633,17635,1232672914,3,240200200011,2,271.4,13,,04M04
GDM,9,99999999,3940106659,17637,17642,1232698281,3,230100600035,1,29.4,14.15,,04M04
ORL,4,121041,9260106519,17638,17638,1232709099,1,220101400145,1,16.7,7.75,,04M04
ORL,34,121105,9260111379,17638,17638,1232709115,1,240700100001,3,70.8,12.3,,04M04
GDM,5,99999999,9260114570,17641,17645,1232728634,2,240100100403,1,168.7,76.55,,04M04
ORM,41,99999999,1600101527,17641,17645,1232723799,3,210200600112,1,21.8,9.25,,04M04
GDM,215,120151,1600102721,17649,17649,1232777080,1,230100500012,1,73.9,33.25,,04M04
GDM,215,120151,1600102721,17649,17649,1232777080,1,230100600023,1,73.4,36.8,,04M04
ORL,195,120143,1600101663,17651,17651,1232790793,1,230100200074,1,50.1,24.5,,04M04
GDL,45,99999999,9260104847,17660,17664,1232857157,2,230100600030,2,172.6,41.4,,05M04
GDH,908,99999999,9050100023,17665,17669,1232889267,2,230100200054,3,407.4,61.8,,05M04
ORL,34,121021,9260111379,17666,17666,1232897220,1,240100400129,3,712.2,111,,05M04
ORH,544,99999999,9050100008,17672,17673,1232936635,2,230100600030,2,172.6,41.4,,05M04
ORM,111,99999999,1600102072,17674,17676,1232946301,2,220101400061,2,102,23.3,,05M04
ORM,52,99999999,9260116235,17675,17676,1232956741,3,230100500008,2,76,16.8,,05M04
ORH,171,120145,1600101555,17678,17678,1232972274,1,230100200054,1,135.8,61.8,,05M04
ORH,171,120145,1600101555,17678,17678,1232972274,1,230100500056,1,8,3.5,,05M04
ORL,183,120122,1600100760,17680,17680,1232985693,1,240100100186,1,273,122.8,,05M04
ORL,4,121109,9260106519,17681,17681,1232998740,1,240700100011,3,80.97,10.23,,05M04
ORL,34,121025,9260111379,17682,17682,1233003688,1,240100100535,1,28.6,12.95,,05M04
ORM,14104,99999999,4750100001,17689,17692,1233049735,3,220101400216,2,48.8,11.2,,06M04
GDM,215,120148,1600102721,17692,17692,1233066745,1,230100600022,1,84.1,42.15,,06M04
GDH,49,121060,9260104510,17693,17693,1233078086,1,220200200071,2,200.2,43.5,,06M04
ORM,12,121054,9260103713,17695,17695,1233092596,1,240300100048,1,15.5,6.7,,06M04
GDL,45,121084,9260104847,17701,17701,1233131266,1,240400300039,2,39.2,7.9,,06M04
ORH,171,120121,1600101555,17707,17707,1233166411,1,240100100734,1,10.1,4.15,,06M04
ORM,70187,99999999,2600100035,17707,17712,1233167161,2,240200100095,2,237,52.55,,06M04
GDH,49,121109,9260104510,17718,17718,1233243603,1,240700200004,2,8.4,2.2,,07M04
ORH,19444,99999999,4750100001,17719,17724,1233248920,2,220100700042,2,171.2,36.35,,07M04
ORH,19444,99999999,4750100001,17719,17724,1233248920,2,220101400387,3,37.8,5.85,,07M04
ORL,75,121029,9260108068,17722,17722,1233270605,1,210200600085,2,75.2,17,,07M04
ORM,70059,99999999,2600100047,17724,17728,1233280857,3,220100100609,3,173.7,29.05,,07M04
GDM,5,121053,9260114570,17729,17729,1233315988,1,240300200018,1,87.2,39.7,,07M04
GDM,5,121053,9260114570,17729,17729,1233315988,1,240300300071,1,138,60.1,,07M04
GDL,13,99999999,3940105189,17739,17742,1233378724,2,240300100046,1,14.1,6.9,,07M04
ORL,34,121105,9260111379,17754,17754,1233482761,1,240700200021,2,38.8,10.35,,08M04
GDL,2550,99999999,8010100009,17754,17759,1233484749,3,240100400098,2,503.6,125.85,,08M04
GDL,2550,99999999,8010100009,17754,17759,1233484749,3,240100400136,3,272.7,45.4,,08M04
GDL,70201,99999999,2600100012,17759,17764,1233514453,3,240200200060,3,553.5,73.85,,08M04
GDM,215,120123,1600102721,17762,17762,1233531965,1,240100400112,1,114,54.8,,08M04
ORL,4,99999999,9260106519,17763,17764,1233543560,3,240500200083,3,201.9,28,,08M04
ORM,41,120134,1600101527,17764,17764,1233545775,1,240200100007,2,49.4,11.8,,08M04
ORM,41,120134,1600101527,17764,17764,1233545775,1,240200100020,1,189.6,100.6,,08M04
GDM,215,120150,1600102721,17764,17764,1233545781,1,230100500020,1,6.2,2.85,,08M04
ORH,89,99999999,9260116551,17771,17774,1233597637,2,240700400002,2,67.2,14.65,,08M04
GDM,215,120177,1600102721,17775,17775,1233618453,1,240700400020,1,73.4,38.25,,08M04
GDM,5,99999999,9260114570,17784,17788,1233682051,2,240100100676,1,43.4,18.65,,09M04
GDH,49,121053,9260104510,17785,17785,1233689304,1,240300300070,3,1514.4,229.65,,09M04
ORL,195,120148,1600101663,17808,17808,1233837302,1,230100500026,4,990,109.55,,10M04
ORL,195,120148,1600101663,17808,17808,1233837302,1,230100600036,3,309.6,50.4,,10M04
ORM,111,99999999,1600102072,17817,17819,1233895201,2,220100100371,1,25.6,12.9,,10M04
ORM,111,99999999,1600102072,17817,17819,1233895201,2,220101400238,2,113.8,25.95,,10M04
ORH,544,99999999,9050100008,17819,17820,1233913196,2,230100400012,1,29.3,11.75,,10M04
ORL,34,121030,9260111379,17820,17820,1233920786,1,210200400020,1,38,19.1,,10M04
ORL,34,121030,9260111379,17820,17820,1233920786,1,210200400070,1,41.6,20.9,,10M04
ORM,52,121135,9260116235,17820,17820,1233920795,1,240800200010,1,120.4,48.1,,10M04
ORM,52,121064,9260116235,17820,17820,1233920805,1,230100500056,1,8,3.5,,10M04
GDH,19873,99999999,4750100001,17832,17839,1233998114,2,220100100101,1,59.7,29.95,,10M04
GDH,19873,99999999,4750100001,17832,17839,1233998114,2,220100400022,1,98.9,47.7,,10M04
ORL,92,121039,9260117676,17837,17837,1234033037,1,220100700022,1,53.7,22.75,,11M04
ORL,75,121069,9260108068,17846,17846,1234092222,1,230100500023,1,7.2,3.1,,11M04
ORL,195,120123,1600101663,17853,17853,1234133789,1,240100400046,1,328.3,165.95,,11M04
ORH,53,120121,1600103258,17861,17861,1234186330,1,240100400095,1,200.1,97.75,,11M04
GDH,49,121035,9260104510,17862,17862,1234198497,1,210200100017,1,39,17.35,,11M04
INT,54655,99999999,2600100013,17868,17871,1234235150,2,240200200060,2,369,73.85,,12M04
GDH,49,121042,9260104510,17869,17869,1234247283,1,220100400023,2,187.2,40.75,,12M04
ORM,17,121135,9260123306,17870,17870,1234255111,1,240800100039,3,257.4,39.9,,12M04
INT,23,99999999,9260126679,17874,17878,1234279341,2,230100500092,1,116.7,48.6,,12M04
ORL,92,121109,9260117676,17877,17877,1234301319,1,240700200010,4,105.6,10.1,,12M04
ORM,70210,99999999,2600100015,17881,17882,1234323012,3,240200100098,2,29.2,6.75,,12M04
ORM,70210,99999999,2600100015,17881,17882,1234323012,3,240200100101,2,39,10.3,,12M04
ORM,70210,99999999,2600100015,17881,17882,1234323012,3,240200200035,2,196,39.3,,12M04
ORL,4,121069,9260106519,17884,17884,1234348668,1,230100100053,2,92.6,20.9,,12M04
ORM,17,121071,9260123306,17886,17886,1234360543,1,230100100033,2,110.2,25.4,,12M04
ORM,12,121069,9260103713,17888,17888,1234373539,1,230100100013,2,226.2,58.9,,12M04
ORM,17,121109,9260123306,17895,17895,1234419240,1,240700100013,5,119.95,9.75,,12M04
ORM,111,120123,1600102072,17895,17895,1234414529,1,240100100654,2,90.4,18.15,,12M04
ORM,111,120123,1600102072,17895,17895,1234414529,1,240100400136,2,181.8,45.4,,12M04
ORL,195,120150,1600101663,17899,17899,1234437760,1,230100600028,2,193.4,48.45,,01M05
INT,36,99999999,9260128237,17908,17911,1234534069,3,240800100026,4,525.2,58.55,,01M05
INT,16,99999999,3940105865,17909,17911,1234538390,2,220200300015,1,115,52.4,,01M05
ORL,183,120121,1600100760,17909,17909,1234537441,1,240100200001,1,16,6.35,,01M05
INT,16,99999999,3940105865,17914,17916,1234588648,2,230100500101,1,138.7,62.5,,01M05
INT,16,99999999,3940105865,17914,17916,1234588648,2,230100600024,1,76.1,38.15,,01M05
INT,16,99999999,3940105865,17921,17923,1234659163,2,230100700008,1,504.2,245.8,,01M05
GDM,63,99999999,9260125492,17921,17922,1234665265,2,240100100063,2,48.4,9.75,,01M05
ORH,171,99999999,1600101555,17926,17930,1234709803,3,220100100304,2,122.6,30.75,,01M05
ORL,183,120179,1600100760,17928,17928,1234727966,1,240700400004,1,13.2,5.95,,01M05
ORL,18,121021,9260112361,17944,17944,1234897732,1,240100100672,1,197.9,84.9,,02M05
ORH,70221,99999999,2600100019,17944,17946,1234891576,3,240200100226,1,183.9,86.65,,02M05
INT,24,99999999,9260115784,17950,17955,1234958242,2,230100500016,1,11.9,5.4,,02M05
INT,16,99999999,3940105865,17952,17954,1234972570,2,230100200048,1,68.7,34.45,,02M05
GDL,11171,99999999,2600100032,17971,17973,1235176942,3,240200100021,1,2.7,1.2,,03M05
GDL,11171,99999999,2600100032,17971,17973,1235176942,3,240200100246,1,16.2,7.9,,03M05
GDM,215,120160,1600102721,17977,17977,1235236723,1,240400200094,1,254.2,115.6,,03M05
ORH,89,121043,9260116551,17980,17980,1235275513,1,220100100241,1,29.7,14.95,,03M05
ORM,111,120122,1600102072,17984,17984,1235306679,1,240100200014,1,55.4,22.8,,03M05
GDM,63,121109,9260125492,17991,17991,1235384426,1,240700100012,1,21.99,9.1,,04M05
INT,16,99999999,3940105865,18012,18014,1235591214,2,240400200022,1,93.4,38.95,,04M05
INT,16,99999999,3940105865,18012,18014,1235591214,2,240400200036,1,55.5,25.1,,04M05
INT,16,99999999,3940105865,18014,18016,1235611754,2,240400300033,2,71.4,14.35,,04M05
INT,16,99999999,3940105865,18014,18016,1235611754,2,240400300035,2,38.2,7.7,,04M05
INT,16,99999999,3940105865,18027,18029,1235744141,2,230100500081,2,146,30.35,,05M05
INT,16,99999999,3940105865,18027,18029,1235744141,2,230100700009,3,1687.5,287.1,,05M05
INT,24,99999999,9260115784,18035,18041,1235830338,2,220200100202,1,92,46.1,,05M05
INT,24,99999999,9260115784,18035,18041,1235830338,2,220200200073,1,145.9,66.35,,05M05
ORH,171,120127,1600101555,18038,18038,1235856852,1,220100100019,1,27.7,13.95,,05M05
ORH,171,120127,1600101555,18038,18038,1235856852,1,220101400152,1,13.1,5.9,,05M05
INT,36,99999999,9260128237,18040,18043,1235881915,3,240700400004,2,26.4,5.95,,05M05
GDH,49,121040,9260104510,18043,18043,1235913793,1,220101200025,1,26.7,11.6,,05M05
ORM,79,99999999,9260101874,18044,18051,1235926178,3,210200200022,2,36,7.05,,05M05
INT,12386,99999999,4750100001,18048,18049,1235963427,2,220100700024,3,313.8,49.8,,05M05
INT,12386,99999999,4750100001,18048,18049,1235963427,2,220100900029,1,31.4,12.55,,05M05
ORL,183,120127,1600100760,18054,18054,1236017640,1,220101400092,1,57.7,25.7,,06M05
GDM,9,99999999,3940106659,18055,18060,1236028541,3,230100500056,2,16,3.5,,06M05
ORH,10,121136,9260129395,18057,18057,1236055696,1,240800100041,1,292.5,121.75,,06M05
GDH,908,99999999,9050100023,18058,18062,1236066649,2,230100300010,1,46.7,18.75,,06M05
INT,36,99999999,9260128237,18063,18066,1236113431,3,230100200066,2,25.8,5.45,,06M05
INT,16,99999999,3940105865,18065,18067,1236128456,2,230100500006,2,16.8,3.45,,06M05
INT,16,99999999,3940105865,18065,18067,1236128456,2,230100600016,2,154,38.6,,06M05
ORM,26148,99999999,2600100010,18065,18067,1236128445,2,240200100053,2,174.4,44.95,,06M05
INT,23,99999999,9260126679,18070,18075,1236183578,2,240500100026,2,110.4,24.5,,06M05
INT,23,99999999,9260126679,18070,18075,1236183578,2,240500200007,3,28.5,4.55,,06M05
ORM,41,120131,1600101527,18074,18074,1236216065,1,240200100118,1,175.5,89.55,,06M05
ORL,92,121051,9260117676,18086,18086,1236349115,1,240200100221,4,396,49.6,,07M05
ORL,92,121051,9260117676,18086,18086,1236349115,1,240200200024,2,250.8,12.5,,07M05
ORM,111,120123,1600102072,18089,18089,1236369939,1,240100100365,1,191.6,87.4,,07M05
ORM,111,120123,1600102072,18089,18089,1236369939,1,240100400037,1,231,113.65,,07M05
ORL,70108,99999999,2600100046,18100,18111,1236483576,2,240200200071,4,74.8,10,,07M05
GDM,9,99999999,3940106659,18119,18124,1236673732,3,230100700008,3,1542.6,250.7,,08M05
GDM,9,99999999,3940106659,18119,18124,1236673732,3,230100700011,2,550.2,113.45,,08M05
ORL,34,121027,9260111379,18121,18121,1236701935,1,210200300052,2,43.8,11.05,,08M05
ORH,70221,99999999,2600100019,18121,18123,1236694462,3,240200100056,2,82.4,19.9,,08M05
ORL,183,120136,1600100760,18130,18130,1236783056,1,240300200058,2,183.6,41.7,,08M05
ORL,183,120136,1600100760,18130,18130,1236783056,1,240300300090,3,1561.8,237.05,,08M05
GDM,215,120170,1600102721,18137,18137,1236852196,1,240600100016,1,55.3,21.9,,08M05
GDH,3959,99999999,8010100151,18143,18144,1236923123,3,240100100031,1,3.7,1.3,,09M05
ORL,70165,99999999,2600100006,18148,18158,1236965430,3,240200100050,2,27,6.65,,09M05
ORM,79,99999999,9260101874,18167,18178,1237165927,3,240500100057,2,76.8,17.1,,09M05
ORM,111,120143,1600102072,18173,18173,1237218771,1,230100500072,1,26.1,11.9,,10M05
ORL,195,120124,1600101663,18178,18178,1237272696,1,240100400069,2,186.6,39.95,,10M05
ORL,195,120124,1600101663,18178,18178,1237272696,1,240100400142,2,338.8,84.85,,10M05
ORH,10,121043,9260129395,18183,18183,1237327705,1,220100100298,1,52.9,26.55,,10M05
ORH,10,121043,9260129395,18183,18183,1237327705,1,220100100617,1,37.3,18.75,,10M05
ORM,2618,99999999,8010100125,18183,18188,1237331045,3,240100100366,1,16.3,7.8,,10M05
ORM,41,120145,1600101527,18188,18188,1237370327,1,230100600031,1,88.5,42.45,,10M05
ORH,171,99999999,1600101555,18196,18200,1237450174,3,220100800001,2,77.2,18.35,,10M05
ORH,171,99999999,1600101555,18196,18200,1237450174,3,220101400349,1,11.9,4.8,,10M05
GDH,908,99999999,9050100023,18198,18202,1237478988,2,230100200004,1,99.9,50.05,,10M05
ORL,1100,99999999,9050100008,18201,18203,1237507462,2,230100400025,3,51,6.6,,10M05
ORL,1100,99999999,9050100008,18201,18203,1237507462,2,230100700009,1,568.1,289.95,,10M05
ORM,79,121081,9260101874,18202,18202,1237517484,1,240400300013,1,54.3,22.6,,11M05
ORH,10,99999999,9260129395,18217,18222,1237670443,2,240800200034,1,74.8,34,,11M05
ORL,65,99999999,3940100176,18217,18223,1237664026,3,230100200004,1,99.9,50.05,,11M05
ORH,53,120190,1600103258,18220,18220,1237695520,1,220200100129,3,240,39.45,,11M05
ORH,10,99999999,9260129395,18225,18230,1237751376,2,240100400043,1,279.3,138.1,,11M05
ORM,56,121027,9260111871,18229,18229,1237789102,1,210200300007,1,50.4,25.3,,11M05
GDM,9,99999999,3940106659,18233,18238,1237825036,3,240400300039,2,39.2,7.9,,12M05
GDM,5,121041,9260114570,18239,18239,1237890730,1,220101400265,2,74.2,16.55,,12M05
GDM,5,121041,9260114570,18239,18239,1237890730,1,220101400387,4,50.4,5.85,,12M05
INT,29,99999999,1600103020,18240,18245,1237894107,2,220100700027,2,119,29.85,,12M05
ORM,70187,99999999,2600100035,18240,18245,1237894966,2,240200100050,2,19.98,6.65,0.3,12M05
INT,23,99999999,9260126679,18243,18248,1237928021,2,240800100074,3,949.8,126.7,,12M05
INT,23,99999999,9260126679,18243,18248,1237928021,2,240800200037,3,164.4,23.75,,12M05
ORM,41,120158,1600101527,18248,18248,1237974997,1,240400300013,3,162.9,22.6,,12M05
INT,36,99999999,9260128237,18249,18252,1237989406,3,230100100018,2,318.2,67.4,,12M05
ORH,46966,99999999,2600100011,18252,18253,1238013821,3,240200200026,3,312,41.65,,12M05
GDM,9,99999999,3940106659,18256,18261,1238053337,3,230100700008,1,514.2,250.7,,12M05
ORM,41,99999999,1600101527,18268,18272,1238161695,2,240100100477,2,17,3.3,,01M06
GDM,63,121064,9260125492,18268,18268,1238168538,1,230100200073,1,46.9,20.2,,01M06
ORH,10,121106,9260129395,18276,18276,1238231237,1,240700200021,1,19.6,10.55,,01M06
ORM,88,121039,9260100179,18279,18279,1238255107,1,220100100581,1,38.7,19.45,,01M06
GDM,215,120127,1600102721,18282,18282,1238273927,1,220100700022,3,170.7,24.1,,01M06
ORM,70210,99999999,2600100015,18286,18287,1238305578,3,240200100246,1,16.2,7.9,,01M06
ORM,52,121025,9260116235,18287,18287,1238319276,1,240100100305,1,8.9,4.1,,01M06
ORH,89,121106,9260116551,18287,18287,1238319281,1,240700100007,1,22.85,9.3,,01M06
ORM,111,120127,1600102072,18292,18292,1238353296,1,220101300001,2,67.2,14.95,,01M06
ORM,111,120127,1600102072,18292,18292,1238353296,1,220101400138,3,140.1,23.45,,01M06
GDM,31,121044,9260128428,18293,18293,1238367238,1,220100800001,1,38.6,18.35,,01M06
GDH,19,99999999,3940106547,18294,18299,1238370259,3,230100600028,1,96.7,48.45,,02M06
ORM,41,120151,1600101527,18295,18295,1238377562,1,230100600016,2,154,38.6,,02M06
ORH,10,121073,9260129395,18296,18296,1238393448,1,230100500094,1,86.6,34.1,,02M06
GDH,19,99999999,3940106547,18301,18306,1238426415,3,230100700011,1,283.3,116.85,,02M06
ORM,52,121042,9260116235,18302,18302,1238440880,1,220100100530,1,52.2,26.2,,02M06
GDH,50,99999999,3940105781,18307,18308,1238474357,2,230100700011,2,566.6,116.85,,02M06
GDM,71,121054,9260124130,18311,18311,1238510159,1,240300200009,1,48.7,18.15,,02M06
GDM,71,121054,9260124130,18311,18311,1238510159,1,240300300024,1,54.1,23,,02M06
GDH,19,99999999,3940106547,18317,18322,1238553101,3,240400200091,1,217,90.4,,02M06
ORM,88,121033,9260100179,18323,18323,1238605995,1,210201100004,1,47.9,20.9,,03M06
ORM,88,121023,9260100179,18327,18327,1238637449,1,240100400151,1,419,209.45,,03M06
ORM,12,121069,9260103713,18328,18328,1238646479,1,230100200043,1,56.7,27.25,,03M06
GDH,90,121072,9260111614,18328,18328,1238646484,1,230100300013,1,24.8,5,,03M06
ORM,12,121051,9260103713,18332,18332,1238678581,1,240200100181,1,109.3,56.6,,03M06
ORM,12,121051,9260103713,18332,18332,1238678581,1,240200200080,2,187.6,9.4,,03M06
ORH,53,120121,1600103258,18332,18332,1238674844,1,240100100508,1,48.3,19.25,,03M06
ORH,10,121044,9260129395,18333,18333,1238686430,1,220101400201,1,40.6,18.05,,03M06
ORM,2806,99999999,8010100089,18334,18338,1238696385,2,240100100312,2,36.2,7.7,,03M06
ORH,53,120127,1600103258,18337,18337,1238712056,1,220100100185,1,97.6,48.9,,03M06
ORH,53,120127,1600103258,18337,18337,1238712056,1,220100700002,1,186.8,89.1,,03M06
ORL,195,120177,1600101663,18340,18340,1238735750,1,240700400020,2,155.6,40.5,,03M06
ORL,928,99999999,9050100016,18347,18351,1238797437,2,230100100063,2,767.8,176.05,,03M06
ORM,52,121024,9260116235,18348,18348,1238805678,1,240100100714,1,92.8,39.85,,03M06
ORM,52,121024,9260116235,18348,18348,1238805678,1,240100400006,1,229.1,113.25,,03M06
ORH,89,121039,9260116551,18348,18348,1238805703,1,220101400285,1,59.4,27.05,,03M06
ORH,14703,99999999,4750100002,18349,18352,1238812262,2,220100100309,1,96.3,48.25,,03M06
ORH,14703,99999999,4750100002,18349,18352,1238812262,2,220101400373,1,51.8,23.65,,03M06
ORM,88,121056,9260100179,18353,18353,1238846184,1,220200100035,1,62.6,31.4,,04M06
ORM,70187,99999999,2600100035,18355,18360,1238856867,2,220101000002,1,17.7,8,,04M06
GDH,39,121105,9260123099,18356,18356,1238870441,1,240700200007,1,5.1,2.2,,04M06
GDH,3959,99999999,8010100151,18356,18358,1238872273,3,240100100434,1,16.4,8.05,,04M06
ORH,89,121042,9260116551,18361,18361,1238910092,1,220100100309,2,192.6,48.25,,04M06
ORH,89,121042,9260116551,18361,18361,1238910092,1,220101400363,2,78,16.95,,04M06
GDM,215,120172,1600102721,18364,18364,1238928257,1,240600100181,1,37.4,16.3,,04M06
INT,29,99999999,1600103020,18369,18373,1238968334,2,220100100025,1,17.4,8.8,,04M06
INT,29,99999999,1600103020,18371,18375,1238985782,2,240100100703,1,79.9,34.3,,04M06
GDH,19,99999999,3940106547,18373,18378,1239003827,3,230100600016,1,77,38.6,,04M06
ORH,70221,99999999,2600100019,18375,18377,1239018454,3,240200100073,1,22.3,12.6,,04M06
ORH,70221,99999999,2600100019,18375,18377,1239018454,3,240200200068,1,313.8,159.15,,04M06
ORM,12,121030,9260103713,18379,18379,1239057268,1,210200500006,2,48,11.95,,04M06
INT,29,99999999,1600103020,18394,18398,1239172417,2,240100100148,2,51.6,10.95,,05M06
GDH,39,99999999,9260123099,18394,18399,1239179935,2,240700300002,1,21.99,7.25,,05M06
ORM,52,121040,9260116235,18396,18396,1239194032,1,220100100192,1,27.4,13.8,,05M06
GDH,90,121020,9260111614,18397,18397,1239201604,1,240100400129,3,712.2,111,,05M06
ORM,20,99999999,9260118934,18400,18406,1239226632,3,220200100190,3,190.5,29.95,,05M06
INT,29,99999999,1600103020,18400,18404,1239220388,2,240100100184,1,190.4,88.8,,05M06
GDM,63,121087,9260125492,18403,18403,1239248786,1,240500100015,3,174.3,25.8,,05M06
GDM,63,121087,9260125492,18403,18403,1239248786,1,240500200093,1,41.7,19.75,,05M06
ORM,41,120152,1600101527,18405,18405,1239258470,1,240400200003,1,6.2,3,,05M06
ORH,53,120143,1600103258,18406,18406,1239266107,1,230100600038,1,112.5,54.95,,05M06
GDL,45,121075,9260104847,18411,18411,1239312711,1,230100600016,3,231,38.6,,05M06
GDL,45,121075,9260104847,18411,18411,1239312711,1,230100700011,3,849.9,116.85,,05M06
ORL,1100,99999999,9050100008,18412,18414,1239320891,2,230100200006,3,279.3,46.65,,05M06
ORM,52,121037,9260116235,18415,18415,1239346133,1,220100100273,3,116.4,19.5,,06M06
ORM,52,121037,9260116235,18415,18415,1239346133,1,220100300042,1,208.6,84.35,,06M06
ORL,183,120143,1600100760,18417,18417,1239353855,1,230100500066,1,12.7,6.1,,06M06
ORH,89,121105,9260116551,18418,18418,1239368476,1,240700100012,3,65.97,9.1,,06M06
ORM,52,121105,9260116235,18423,18423,1239408849,1,240700100017,2,53.2,11.4,,06M06
INT,29,99999999,1600103020,18424,18428,1239410348,2,220100800071,1,32.8,15.7,,06M06
ORM,88,121036,9260100179,18424,18424,1239416627,1,220100800040,2,248.2,59.05,,06M06
ORL,195,120127,1600101663,18425,18425,1239418524,1,220100100536,2,408.8,102.3,,06M06
ORM,41,99999999,1600101527,18428,18432,1239442095,2,210201000198,2,120.2,26.8,,06M06
GDH,17023,99999999,2600100021,18435,18440,1239498112,3,240200200044,2,97.8,19.6,,06M06
GDH,90,121040,9260111614,18440,18440,1239543223,1,220100100635,2,172.8,43.3,,06M06
GDH,90,121040,9260111614,18440,18440,1239543223,1,220101300012,2,38.6,8.75,,06M06
GDL,45,121127,9260104847,18449,18449,1239615368,1,240800200002,1,178.875,71.55,,07M06
ORM,88,121040,9260100179,18459,18459,1239693951,1,220100900035,2,83.6,19.45,,07M06
INT,16,99999999,3940105865,18462,18463,1239713046,2,230100500058,4,66.8,7.25,,07M06
INT,16,99999999,3940105865,18462,18463,1239713046,2,230100500082,2,252.2,58.6,,07M06
INT,16,99999999,3940105865,18462,18463,1239713046,2,230100600031,2,177,42.45,,07M06
GDM,71,121073,9260124130,18464,18464,1239735632,1,230100700009,2,1136.2,289.95,,07M06
GDL,13,99999999,3940105189,18466,18471,1239744161,2,240400200003,1,6.2,3,,07M06
GDL,13,99999999,3940105189,18466,18471,1239744161,2,240400300035,2,38.2,7.7,,07M06
ORM,60,121036,9260101262,18468,18468,1239765451,1,220101400004,2,211.4,48.15,,07M06
ORM,60,121036,9260101262,18468,18468,1239765451,1,220101400148,2,21,4.75,,07M06
ORL,65,99999999,3940100176,18471,18477,1239785436,3,230100600031,4,354,42.45,,07M06
ORL,1684,99999999,9050100008,18475,18478,1239821232,2,230100500013,2,18.8,4.75,,08M06
INT,54655,99999999,2600100013,18476,18479,1239823829,2,240200200081,2,214.6,10.75,,08M06
ORM,12,121090,9260103713,18477,18477,1239836937,1,240500100043,2,52.4,8.85,,08M06
ORM,12,121042,9260103713,18482,18482,1239874523,1,220101400047,2,48.4,11.1,,08M06
INT,16,99999999,3940105865,18490,18491,1239932984,2,220200200079,2,285.8,64.85,,08M06
INT,16,99999999,3940105865,18490,18491,1239932984,2,220200300129,5,406,37.05,,08M06
ORM,52,120732,9260116235,18493,18493,1239962634,1,230100500080,2,50,12.2,,08M06
ORH,53,99999999,1600103258,18495,18497,1239972644,2,220101400237,1,102.9,46.9,,08M06
GDH,90,121060,9260111614,18497,18497,1239994933,1,220200300082,3,213,32.3,,08M06
GDM,71,99999999,9260124130,18504,18510,1240051245,3,230100100028,1,250.9,104.2,,08M06
GDM,71,99999999,9260124130,18504,18510,1240051245,3,230100200022,3,359.1,56.9,,08M06
ORM,60,121066,9260101262,18505,18505,1240060066,1,230100100062,1,141.7,61,,08M06
ORH,544,99999999,9050100008,18515,18516,1240137702,2,230100300023,1,36,15,,09M06
ORL,70165,99999999,2600100006,18520,18521,1240173354,3,240200100225,2,306.2,77.85,,09M06
INT,29,99999999,1600103020,18522,18526,1240187143,2,240100400100,1,154.6,116.6,,09M06
ORH,10,121039,9260129395,18523,18523,1240201886,1,220101400339,1,32.3,14.75,,09M06
ORM,52,121051,9260116235,18533,18533,1240283215,1,240200100118,1,175.5,89.55,,09M06
ORM,52,121051,9260116235,18533,18533,1240283215,1,240200100164,2,112.2,28.15,,09M06
ORM,52,121051,9260116235,18533,18533,1240283215,1,240200100227,2,323.8,75.9,,09M06
GDH,90,121071,9260111614,18536,18536,1240306942,1,230100500056,1,8,3.5,,10M06
GDH,90,121071,9260111614,18536,18536,1240306942,1,230100600018,1,64.2,32.2,,10M06
ORM,17,121074,9260123306,18537,18537,1240314956,1,230100500094,1,86.6,34.1,,10M06
GDH,908,99999999,9050100023,18537,18541,1240314947,2,230100600028,1,96.7,48.45,,10M06
ORH,10,121063,9260129395,18542,18542,1240355393,1,230100600022,1,84.1,42.15,,10M06
GDM,63,120733,9260125492,18545,18545,1240379679,1,230100200004,1,99.9,50.05,,10M06
GDM,63,120733,9260125492,18545,18545,1240379679,1,230100500077,1,173,72.75,,10M06
ORH,89,121140,9260116551,18546,18546,1240387741,1,240800200020,1,187.2,85.15,,10M06
ORL,183,120153,1600100760,18552,18552,1240430921,1,240400200093,1,155.8,64.95,,10M06
INT,29,99999999,1600103020,18554,18558,1240446608,2,220100100553,1,35,17.6,,10M06
INT,29,99999999,1600103020,18554,18558,1240446608,2,220100700046,2,305.8,72.9,,10M06
GDH,50,99999999,3940105781,18554,18555,1240447572,2,230100200056,1,270,125.65,,10M06
ORH,10,121036,9260129395,18555,18555,1240461993,1,220100300020,1,11.3,4.55,,10M06
ORH,10,121036,9260129395,18555,18555,1240461993,1,220100800009,1,52.5,24.95,,10M06
ORH,10,121036,9260129395,18555,18555,1240461993,1,220101400276,1,68.4,31.2,,10M06
INT,29,99999999,1600103020,18559,18563,1240485814,2,220101400290,1,74.8,34.1,,10M06
GDM,63,121033,9260125492,18561,18561,1240509842,1,210200500007,1,39.4,17.8,,10M06
GDH,50,99999999,3940105781,18562,18563,1240512744,2,240300100046,2,28.8,7.05,,10M06
ORH,89,121061,9260116551,18566,18566,1240549230,1,220200100012,1,58.7,28.25,,10M06
GDH,19,99999999,3940106547,18569,18574,1240568966,3,220200100226,1,133.2,66.7,,11M06
GDM,215,120192,1600102721,18571,18571,1240581932,1,210201000199,3,124.2,18.85,,11M06
ORH,2788,99999999,9050100001,18571,18573,1240588370,2,230100500082,1,126.1,58.6,,11M06
INT,16,99999999,3940105865,18573,18574,1240599396,2,230100700002,1,220,135,,11M06
INT,16,99999999,3940105865,18573,18574,1240599396,2,230100700004,1,360,199,,11M06
GDM,63,121071,9260125492,18573,18573,1240604971,1,230100600030,1,86.3,41.4,,11M06
ORM,20,121069,9260118934,18574,18574,1240613362,1,230100100017,1,175.3,74.95,,11M06
ORM,88,121086,9260100179,18584,18584,1240692950,1,240500100039,1,34.5,15.4,,11M06
ORH,544,99999999,9050100008,18595,18596,1240782710,2,230100500066,1,12.7,6.1,,11M06
ORH,544,99999999,9050100008,18595,18596,1240782710,2,230100600005,1,129.8,63.2,,11M06
ORH,544,99999999,9050100008,18604,18605,1240856801,2,230100600028,2,193.4,48.45,,12M06
ORH,544,99999999,9050100008,18604,18605,1240856801,2,230100600039,1,124.7,59.65,,12M06
ORL,1100,99999999,9050100008,18606,18608,1240870047,2,230100100015,2,213.8,45.5,,12M06
ORM,52,121030,9260116235,18608,18608,1240886449,1,210200200023,1,19.8,8.25,,12M06
ORM,52,121044,9260116235,18610,18610,1240903120,1,220100100592,2,62.2,15.65,,12M06
ORM,52,121044,9260116235,18610,18610,1240903120,1,220100100629,4,213.2,26.75,,12M06
INT,16,99999999,3940105865,18618,18619,1240961599,2,230100200025,4,1103.6,125.25,,12M06
INT,16,99999999,3940105865,18618,18619,1240961599,2,230100600015,1,78.2,39.2,,12M06
INT,24,99999999,9260115784,18629,18632,1241054779,3,240800200021,2,195.6,42.45,,01M07
ORH,89,121135,9260116551,18630,18631,1241063739,1,240800200035,6,160.8,12.15,,01M07
ORH,171,120134,1600101555,18631,18631,1241066216,1,240200100225,2,306.2,77.85,,01M07
ORH,53,99999999,1600103258,18633,18636,1241086052,3,210200500002,3,37.8,5.7,,01M07
ORH,53,120131,1600103258,18640,18640,1241147641,1,240200200091,2,362.6,72.6,,01M07
ORH,171,120136,1600101555,18650,18657,1241235281,1,240300100001,1,72.6,36.25,,01M07
ORM,111,120164,1600102072,18651,18651,1241244297,1,240500100041,2,258.2,51.7,,01M07
ORM,111,120164,1600102072,18651,18651,1241244297,1,240500200042,2,81.2,19.35,,01M07
ORM,111,120164,1600102072,18651,18651,1241244297,1,240500200101,3,358.2,49.75,,01M07
GDH,3959,99999999,8010100151,18652,18653,1241263172,3,240100400004,1,102.4,51.15,,01M07
GDH,3959,99999999,8010100151,18652,18653,1241263172,3,240100400062,1,113.2,54,,01M07
INT,27,99999999,9260105670,18655,18660,1241286432,3,240800200009,2,174.4,34.9,,01M07
ORM,2806,99999999,8010100089,18656,18666,1241298131,2,240100400058,1,37.4,29.65,,01M07
ORM,12,121043,9260103713,18663,18663,1241359997,1,220100100105,1,117.6,58.9,,02M07
ORH,171,120124,1600101555,18665,18665,1241371145,1,240100400046,2,656.6,165.95,,02M07
ORH,171,120124,1600101555,18665,18665,1241371145,1,240100400085,2,129,30.95,,02M07
ORM,41,120131,1600101527,18667,18667,1241390440,1,240200100046,2,36.2,9.15,,02M07
ORL,18,121042,9260112361,18674,18675,1241461856,1,220100100523,1,29.4,14.8,,02M07
ORH,171,120127,1600101555,18686,18686,1241561055,1,220101400088,5,192,17.5,,02M07
INT,24,99999999,9260115784,18692,18695,1241623505,3,240700400017,1,46.9,21.95,,03M07
INT,27,99999999,9260105670,18695,18700,1241652707,3,240700400017,3,140.7,21.95,,03M07
ORM,70100,99999999,2600100015,18695,18699,1241645664,2,240200200020,1,150.1,14,,03M07
ORH,10,121040,9260129395,18699,18705,1241686210,1,220100100235,1,32.6,16.4,,03M07
ORL,92,121106,9260117676,18702,18702,1241715610,1,240700200019,1,16.9,8.6,,03M07
GDM,31,121025,9260128428,18704,18704,1241731828,1,240100100410,1,22.7,10.4,,03M07
GDM,31,121025,9260128428,18704,18704,1241731828,1,240100100665,1,41.5,17.25,,03M07
GDH,17023,99999999,2600100021,18711,18716,1241789227,3,240200100211,1,121,60.65,,03M07
ORM,56,121051,9260111871,18722,18726,1241895594,1,240200100034,2,24.4,4.45,,04M07
ORM,56,121051,9260111871,18722,18726,1241895594,1,240200100050,1,13.5,6.65,,04M07
ORH,46966,99999999,2600100011,18724,18725,1241909303,3,240200200081,1,107.3,10.75,,04M07
INT,27,99999999,9260105670,18726,18731,1241930625,3,220200100012,1,58.7,28.25,,04M07
INT,27,99999999,9260105670,18726,18731,1241930625,3,220200100171,1,56.3,31.05,,04M07
INT,27,99999999,9260105670,18726,18731,1241930625,3,220200200014,1,90,40.9,,04M07
ORH,171,120152,1600101555,18732,18732,1241977403,1,240400300035,1,19.1,7.7,,04M07
ORH,10,121040,9260129395,18735,18735,1242012259,1,220100300037,2,231.6,48.7,,04M07
ORH,10,121040,9260129395,18735,18735,1242012259,1,220101400032,2,19.2,4.85,,04M07
GDL,45,121040,9260104847,18735,18735,1242012269,1,220100300019,4,142.4,16.7,,04M07
GDL,45,121040,9260104847,18735,18735,1242012269,1,220101400216,3,73.8,11.3,,04M07
ORL,183,120132,1600100760,18738,18738,1242035131,1,240200200061,1,147.1,58.85,,04M07
GDM,31,99999999,9260128428,18742,18746,1242076538,3,220200200022,1,57.3,33.9,,04M07
ORL,92,121086,9260117676,18748,18748,1242130888,1,240500100017,3,160.5,23.75,,05M07
GDM,5,99999999,9260114570,18749,18754,1242140006,3,240100100159,1,31.4,13.9,,05M07
GDH,90,99999999,9260111614,18749,18751,1242140009,2,240100100434,1,16.4,8.05,,05M07
GDH,90,99999999,9260111614,18749,18751,1242140009,2,240100400128,1,192.4,89.9,,05M07
GDH,90,121032,9260111614,18750,18750,1242149082,1,210200300006,1,14.3,7.7,,05M07
GDH,90,121032,9260111614,18750,18750,1242149082,1,210200900033,4,56.8,6.45,,05M07
GDM,5,99999999,9260114570,18751,18756,1242159212,3,230100200029,2,446.6,101.65,,05M07
GDL,2550,99999999,8010100009,18751,18756,1242161468,3,240100100232,3,9.6,1.3,,05M07
GDL,2550,99999999,8010100009,18751,18756,1242161468,3,240100400080,1,222,110.95,,05M07
ORH,46966,99999999,2600100011,18752,18753,1242162201,3,240200100053,2,174.4,44.95,,05M07
ORL,1033,99999999,9050100001,18753,18757,1242173926,3,230100600026,3,355.8,59.4,,05M07
ORM,41,120136,1600101527,18755,18755,1242185055,1,240300100049,1,19.9,8.9,,05M07
ORM,70079,99999999,2600100039,18758,18761,1242214574,3,240200100230,2,29.4,6.65,,05M07
ORH,171,120127,1600101555,18760,18760,1242229985,1,220100100189,2,189.4,47.45,,05M07
ORH,10,121105,9260129395,18763,18763,1242265757,1,240700100004,3,79.8,13.75,,05M07
ORM,70187,99999999,2600100035,18763,18768,1242259863,2,240200100157,2,706.2,196.15,,05M07
INT,27,99999999,9260105670,18783,18788,1242449327,3,240100100679,2,91.6,19.5,,06M07
ORH,10,121071,9260129395,18784,18784,1242458099,1,230100400007,1,12.2,4.9,,06M07
ORL,34,99999999,9260111379,18785,18791,1242467585,3,240100100690,2,403,86.1,,06M07
ORL,34,99999999,9260111379,18785,18791,1242467585,3,240100100737,5,239.5,20.65,,06M07
GDM,31,99999999,9260128428,18786,18790,1242477751,3,220200200036,2,120.4,27.4,,06M07
GDM,31,99999999,9260128428,18786,18790,1242477751,3,220200200077,2,277.6,63.15,,06M07
GDM,5,121056,9260114570,18788,18788,1242493791,1,220200100009,2,126.8,30.5,,06M07
GDM,31,121067,9260128428,18789,18789,1242502670,1,230100500056,2,16,3.5,,06M07
GDM,31,121067,9260128428,18789,18789,1242502670,1,230100500087,2,195,40.55,,06M07
GDH,17023,99999999,2600100021,18791,18796,1242515373,3,240200100057,4,168,20.25,,06M07
ORL,70165,99999999,2600100006,18793,18800,1242534503,3,240200100118,4,702,89.55,,06M07
ORH,89,99999999,9260116551,18795,18799,1242557584,2,240500200083,2,134.6,28,,06M07
ORH,171,120130,1600101555,18796,18796,1242559569,1,220100700023,1,73.99,44.25,0.3,06M07
ORM,2806,99999999,8010100089,18796,18800,1242568696,2,240100100029,2,239,51.7,,06M07
ORM,2806,99999999,8010100089,18796,18800,1242568696,2,240100400098,3,755.4,125.85,,06M07
ORM,70100,99999999,2600100015,18798,18802,1242578860,2,240200100173,4,1937.2,247.7,,06M07
ORM,12,121037,9260103713,18801,18801,1242610991,1,220101400047,2,48.4,11.1,,06M07
GDL,45,121109,9260104847,18805,18805,1242647539,1,240700200009,2,56,11.35,,06M07
GDH,90,121037,9260111614,18806,18806,1242657273,1,220100100410,3,33.6,5.7,,06M07
GDH,90,99999999,9260111614,18810,18812,1242691897,2,240500100062,2,110.2,24.05,,07M07
ORH,10,121107,9260129395,18815,18815,1242736731,1,240700200010,3,80.7,10.3,,07M07
INT,24,99999999,9260115784,18819,18822,1242773202,3,240600100185,2,70.2,15.6,,07M07
INT,27,99999999,9260105670,18820,18825,1242782701,3,240500200081,3,403.5,56.05,,07M07
ORH,10,121105,9260129395,18825,18825,1242827683,1,240700300002,1,21.99,7.25,,07M07
ORH,10,121027,9260129395,18826,18826,1242836878,1,210201000067,2,60.6,13.5,,07M07
ORM,41,120195,1600101527,18827,18827,1242838815,1,210200500007,1,39.4,17.8,,07M07
ORM,41,120195,1600101527,18827,18827,1242838815,1,210200600056,1,50.4,22.75,,07M07
ORM,2806,99999999,8010100089,18827,18831,1242848557,2,240100100312,3,54.3,7.7,,07M07
ORL,70165,99999999,2600100006,18836,18837,1242923327,3,240200100081,2,16.6,3.65,,07M07
ORH,171,120124,1600101555,18838,18838,1242938120,1,240100200004,1,35.2,14.8,,07M07
ORL,65,99999999,3940100176,18842,18846,1242977743,2,240400200012,2,351.4,75.95,,08M07
ORM,2806,99999999,8010100089,18845,18849,1243012144,2,240100100615,2,25.8,5.45,,08M07
ORM,2806,99999999,8010100089,18845,18849,1243012144,2,240100400083,2,219,54.7,,08M07
ORH,10,120733,9260129395,18847,18847,1243026971,1,230100500082,2,252.2,58.6,,08M07
ORM,41,120143,1600101527,18849,18849,1243039354,1,230100600003,1,17.6,7.75,,08M07
ORH,53,99999999,1600103258,18850,18853,1243049938,3,220100300001,2,180.4,38.3,,08M07
ORH,10,121032,9260129395,18856,18856,1243110343,1,210200600067,2,134,28.9,,08M07
ORH,10,121032,9260129395,18856,18856,1243110343,1,210200900038,3,60.9,9.3,,08M07
ORH,171,120159,1600101555,18859,18859,1243127549,1,240400300035,1,19.1,7.7,,08M07
GDL,45,120734,9260104847,18861,18862,1243152030,1,230100400010,1,40.2,16.85,,08M07
GDH,90,121089,9260111614,18861,18861,1243152039,1,240500200003,2,47.6,11.4,,08M07
GDL,70201,99999999,2600100012,18863,18868,1243165497,3,240200100052,2,201.2,51.9,,08M07
GDL,70201,99999999,2600100012,18863,18868,1243165497,3,240200100116,3,658.5,124.9,,08M07
GDL,70201,99999999,2600100012,18863,18868,1243165497,3,240200100207,2,215.8,53.35,,08M07
ORH,10,121061,9260129395,18866,18866,1243198099,1,220200200018,3,199.2,30.25,,08M07
ORH,10,121061,9260129395,18866,18866,1243198099,1,220200300154,3,256.2,39.8,,08M07
ORH,171,120141,1600101555,18870,18880,1243227745,1,230100500004,2,6.4,1.35,,08M07
ORL,928,99999999,9050100016,18874,18878,1243269405,2,230100600030,1,86.3,41.4,,09M07
INT,27,99999999,9260105670,18875,18880,1243279343,3,240500200082,2,78.4,16.45,,09M07
GDM,31,121057,9260128428,18876,18876,1243290080,1,220200100137,1,50.3,25.25,,09M07
GDL,45,121065,9260104847,18876,18876,1243290089,1,230100600015,1,78.2,39.2,,09M07
GDM,5,121026,9260114570,18879,18879,1243315613,1,210200500016,1,52.5,22.25,,09M07
ORM,12,121051,9260103713,18888,18888,1243398628,1,240200100053,1,87.2,44.95,,09M07
ORL,69,121029,9260116402,18890,18890,1243417726,1,210200700016,1,23.5,9.2,,09M07
INT,24,99999999,9260115784,18895,18898,1243462945,3,240600100102,1,46.1,19.7,,09M07
ORM,41,120195,1600101527,18896,18896,1243465031,1,210200600067,2,134,28.9,,09M07
ORH,11,99999999,3940108592,18898,18902,1243485097,3,220200100002,2,78.2,19.65,,09M07
ORH,89,121024,9260116551,18901,18901,1243515588,1,240100400098,1,251.8,125.85,,10M07
ORH,89,121024,9260116551,18901,18901,1243515588,1,240100400125,1,114.2,44.6,,10M07
GDM,31,121060,9260128428,18907,18907,1243568955,1,220200300096,1,172.5,78.5,,10M07
ORH,171,120138,1600101555,18916,18916,1243643970,1,220200200035,1,101.5,46.25,,10M07
ORM,70079,99999999,2600100039,18916,18919,1243644877,3,240200100098,1,14.6,6.75,,10M07
ORM,41,120124,1600101527,18918,18918,1243661763,1,240100100463,2,29.4,6.05,,10M07
ORL,69,121065,9260116402,18918,18918,1243670182,1,230100500004,1,3.2,1.35,,10M07
GDM,31,121061,9260128428,18919,18919,1243680376,1,220200100190,1,63.5,29.95,,10M07
ORH,10,121053,9260129395,18932,18932,1243797399,1,240300100028,2,1066.4,251.35,,11M07
ORH,10,121053,9260129395,18932,18932,1243797399,1,240300300065,1,321.5,146.35,,11M07
ORM,41,120128,1600101527,18933,18933,1243799681,1,220100100354,1,17,8.45,,11M07
ORM,41,120128,1600101527,18933,18933,1243799681,1,220100800096,3,222.3,35.3,,11M07
ORH,10,120732,9260129395,18934,18934,1243815198,1,230100500092,4,471.2,49.05,,11M07
ORH,10,120732,9260129395,18934,18934,1243815198,1,230100500096,1,35.5,17.25,,11M07
ORH,171,120127,1600101555,18935,18935,1243817278,1,220101400328,1,19,8.85,,11M07
GDH,908,99999999,9050100023,18942,18946,1243887390,2,230100700008,1,519.3,253.2,,11M07
ORL,34,121068,9260111379,18949,18949,1243951648,1,230100600030,1,86.3,41.4,,11M07
GDH,90,121028,9260111614,18950,18950,1243960910,1,210200100009,2,69.4,15.5,,11M07
GDM,215,120175,1600102721,18951,18951,1243963366,1,240600100080,2,60.8,9.2,,11M07
ORH,171,120124,1600101555,18954,18954,1243991721,1,240100100354,1,29.9,14.3,,11M07
ORM,70187,99999999,2600100035,18954,18959,1243992813,2,220100100421,1,8.2,4.15,,11M07
ORM,2806,99999999,8010100089,18961,18965,1244066194,2,240100100159,1,31.4,13.9,,11M07
ORM,2806,99999999,8010100089,18961,18965,1244066194,2,240100100605,3,144.6,20.75,,11M07
ORM,14104,99999999,4750100001,18964,18967,1244086685,3,220100100516,2,80.4,20.2,,12M07
ORM,14104,99999999,4750100001,18964,18967,1244086685,3,220100100631,2,114.2,28.65,,12M07
GDL,45,121107,9260104847,18966,18966,1244107612,1,240700100001,5,118,12.3,,12M07
GDL,45,121107,9260104847,18966,18966,1244107612,1,240700400031,2,126,31.6,,12M07
GDL,45,121109,9260104847,18967,18967,1244117101,1,240700100007,2,45.7,9.3,,12M07
GDL,45,121109,9260104847,18967,18967,1244117101,1,240700100017,2,19.98,11.4,0.4,12M07
GDH,49,121117,9260104510,18967,18967,1244117109,1,240700400003,2,24.8,5.6,,12M07
GDM,31,121121,9260128428,18973,18973,1244171290,1,240800100042,3,760.8,105.3,,12M07
ORH,10,121092,9260129395,18974,18974,1244181114,1,240500200016,3,95.1,14.5,,12M07
ORH,10,121092,9260129395,18974,18974,1244181114,1,240500200122,2,48.2,11.5,,12M07
ORH,89,121118,9260116551,18976,18976,1244197366,1,240700200018,4,75.2,10.3,,12M07
GDM,5,121040,9260114570,18987,18987,1244296274,1,220101400130,2,33.8,5.7,,12M07
;;;;
run;

data ORION.ORDER_TYPE_LOOKUP;
   attrib Order_Type length=8;

   infile datalines dsd;
   input
      Order_Type
   ;
datalines4;
1
2
3
;;;;
run;

data ORION.PRODLIST;
   attrib Product_ID length=8 label='Product ID' format=12.;
   attrib Product_Line length=$20 label='Product Line';
   attrib Product_Category length=$25 label='Product Category';
   attrib Product_Group length=$25 label='Product Group';
   attrib Product_Name length=$45 label='Product Name';
   attrib Supplier_Country length=$2 label='Supplier Country';
   attrib Supplier_Name length=$30 label='Supplier Name';
   attrib Supplier_ID length=8 label='Supplier ID' format=12.;

   infile datalines dsd;
   input
      Product_ID
      Product_Line
      Product_Category
      Product_Group
      Product_Name
      Supplier_Country
      Supplier_Name
      Supplier_ID
   ;
datalines4;
210200100009,Children,Children Sports,"A-Team, Kids","Kids Sweat Round Neck,Large Logo",US,A Team Sports,3298
210200100017,Children,Children Sports,"A-Team, Kids",Sweatshirt Children's O-Neck,US,A Team Sports,3298
210200200022,Children,Children Sports,"Bathing Suits, Kids",Sunfit Slow Swimming Trunks,US,Nautlius SportsWear Inc,6153
210200200023,Children,Children Sports,"Bathing Suits, Kids",Sunfit Stockton Swimming Trunks Jr.,US,Nautlius SportsWear Inc,6153
210200300006,Children,Children Sports,"Eclipse, Kid's Clothes",Fleece Cuff Pant Kid'S,US,Eclipse Inc,1303
210200300007,Children,Children Sports,"Eclipse, Kid's Clothes",Hsc Dutch Player Shirt Junior,US,Eclipse Inc,1303
210200300052,Children,Children Sports,"Eclipse, Kid's Clothes",Tony's Cut & Sew T-Shirt,US,Eclipse Inc,1303
210200400020,Children,Children Sports,"Eclipse, Kid's Shoes",Kids Baby Edge Max Shoes,US,Eclipse Inc,1303
210200400070,Children,Children Sports,"Eclipse, Kid's Shoes",Tony's Children's Deschutz (Bg) Shoes,US,Eclipse Inc,1303
210200500002,Children,Children Sports,"Lucky Guy, Kids",Children's Mitten,US,AllSeasons Outdoor Clothing,772
210200500006,Children,Children Sports,"Lucky Guy, Kids","Rain Suit, Plain w/backpack Jacket",US,AllSeasons Outdoor Clothing,772
210200500007,Children,Children Sports,"Lucky Guy, Kids",Bozeman Rain & Storm Set,US,AllSeasons Outdoor Clothing,772
210200500016,Children,Children Sports,"Lucky Guy, Kids",Teen Profleece w/Zipper,US,AllSeasons Outdoor Clothing,772
210200600056,Children,Children Sports,"N.D. Gear, Kids",Butch T-Shirt with V-Neck,ES,Luna sastreria S.A.,4742
210200600067,Children,Children Sports,"N.D. Gear, Kids",Children's Knit Sweater,ES,Luna sastreria S.A.,4742
210200600085,Children,Children Sports,"N.D. Gear, Kids",Gordon Children's Tracking Pants,ES,Luna sastreria S.A.,4742
210200600112,Children,Children Sports,"N.D. Gear, Kids",O'my Children's T-Shirt with Logo,ES,Luna sastreria S.A.,4742
210200700016,Children,Children Sports,"Olssons, Kids",Strap Pants BBO,ES,Sportico,798
210200900004,Children,Children Sports,"Osprey, Kids",Kid Basic Tracking Suit,US,Triple Sportswear Inc,3664
210200900033,Children,Children Sports,"Osprey, Kids",Osprey France Nylon Shorts,US,Triple Sportswear Inc,3664
210200900038,Children,Children Sports,"Osprey, Kids",Osprey Girl's Tights,US,Triple Sportswear Inc,3664
210201000050,Children,Children Sports,Tracker Kid's Clothes,Kid Children's T-Shirt,US,3Top Sports,2963
210201000067,Children,Children Sports,Tracker Kid's Clothes,Logo Coord.Children's Sweatshirt,US,3Top Sports,2963
210201000126,Children,Children Sports,Tracker Kid's Clothes,Toddler Footwear Socks with Knobs,US,3Top Sports,2963
210201000198,Children,Children Sports,Tracker Kid's Clothes,South Peak Junior Training Shoes,US,3Top Sports,2963
210201000199,Children,Children Sports,Tracker Kid's Clothes,Starlite Baby Shoes,US,3Top Sports,2963
210201100004,Children,Children Sports,"Ypsilon, Kids",Ypsilon Children's Sweat w/Big Logo,FR,Ypsilon S.A.,14624
220100100019,Clothes&Shoes,Clothes,Eclipse Clothing,Fit Racing Cap,US,Eclipse Inc,1303
220100100025,Clothes&Shoes,Clothes,Eclipse Clothing,Knit Hat,US,Eclipse Inc,1303
220100100044,Clothes&Shoes,Clothes,Eclipse Clothing,Sports glasses Satin Alumin.,US,Eclipse Inc,1303
220100100101,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Chaser Poplin Pants,US,Eclipse Inc,1303
220100100105,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Clima Fit Jacket,US,Eclipse Inc,1303
220100100125,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Dri Fit Singlet,US,Eclipse Inc,1303
220100100153,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Fresh Soft Nylon Pants,US,Eclipse Inc,1303
220100100185,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Micro Fiber Full Zip Jacket,US,Eclipse Inc,1303
220100100189,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Micro Fibre Jacket,US,Eclipse Inc,1303
220100100192,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Micro Fibre Shorts XXL,US,Eclipse Inc,1303
220100100197,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Mid Layer Jacket,US,Eclipse Inc,1303
220100100235,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Running Shorts Dri.Fit,US,Eclipse Inc,1303
220100100241,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Santos Shorts Dri Fit,US,Eclipse Inc,1303
220100100272,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's T-Shirt,US,Eclipse Inc,1303
220100100273,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's T-Shirt Dri Fit,US,Eclipse Inc,1303
220100100298,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Twill Pants Golf,US,Eclipse Inc,1303
220100100304,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Victory Peach Poplin Pants,US,Eclipse Inc,1303
220100100309,Clothes&Shoes,Clothes,Eclipse Clothing,Big Guy Men's Woven Warm Up,US,Eclipse Inc,1303
220100100354,Clothes&Shoes,Clothes,Eclipse Clothing,Insu F.I.T Basic,US,Eclipse Inc,1303
220100100371,Clothes&Shoes,Clothes,Eclipse Clothing,Northern Fleece Scarf,US,Eclipse Inc,1303
220100100410,Clothes&Shoes,Clothes,Eclipse Clothing,Toto Tube Socks,US,Eclipse Inc,1303
220100100421,Clothes&Shoes,Clothes,Eclipse Clothing,Trois-fit Running Qtr Socks (Non-Cush),US,Eclipse Inc,1303
220100100513,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Deception Dress,US,Eclipse Inc,1303
220100100516,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Dri Fit Airborne Top,US,Eclipse Inc,1303
220100100523,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Dri-Fit Scoop Neck Bra,US,Eclipse Inc,1303
220100100530,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Emblished Work-Out Pants,US,Eclipse Inc,1303
220100100536,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Foxhole Jacket,US,Eclipse Inc,1303
220100100553,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Short Top Dri Fit,US,Eclipse Inc,1303
220100100568,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Micro Fibre Anorak,US,Eclipse Inc,1303
220100100581,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Out & Sew Airborn Top,US,Eclipse Inc,1303
220100100592,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Short Tights,US,Eclipse Inc,1303
220100100609,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Sweatshirt w/Hood,US,Eclipse Inc,1303
220100100617,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's T-Shirt w/Hood,US,Eclipse Inc,1303
220100100629,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Winter Tights,US,Eclipse Inc,1303
220100100631,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Work Out Pants Dri Fit,US,Eclipse Inc,1303
220100100635,Clothes&Shoes,Clothes,Eclipse Clothing,Woman's Woven Warm Up,US,Eclipse Inc,1303
220100200004,Clothes&Shoes,Clothes,Green Tomato,Green Lime Atletic Socks,US,Green Lime Sports Inc,18139
220100300001,Clothes&Shoes,Clothes,Knitwear,Fleece Jacket Compass,US,AllSeasons Outdoor Clothing,772
220100300008,Clothes&Shoes,Clothes,Knitwear,Dp Roller High-necked Knit,US,Mayday Inc,4646
220100300019,Clothes&Shoes,Clothes,Knitwear,Instyle Pullover Mid w/Small Zipper,US,AllSeasons Outdoor Clothing,772
220100300020,Clothes&Shoes,Clothes,Knitwear,Instyle T-Shirt,US,AllSeasons Outdoor Clothing,772
220100300025,Clothes&Shoes,Clothes,Knitwear,Lucky Knitwear Wool Sweater,US,AllSeasons Outdoor Clothing,772
220100300037,Clothes&Shoes,Clothes,Knitwear,Mayday Resque Fleece Pullover,US,Mayday Inc,4646
220100300042,Clothes&Shoes,Clothes,Knitwear,Truls Polar Fleece Cardigan,NO,Truls Sporting Goods,12869
220100400005,Clothes&Shoes,Clothes,LSF,Big Guy Men's Air Force 1 Sc,US,Eclipse Inc,1303
220100400022,Clothes&Shoes,Clothes,LSF,Ultra M803 Ng Men's Street Shoes,US,Ultra Sporting Goods Inc,5503
220100400023,Clothes&Shoes,Clothes,LSF,Ultra W802 All Terrain Women's Shoes,US,Ultra Sporting Goods Inc,5503
220100700002,Clothes&Shoes,Clothes,Orion,Dmx 10 Women's Aerobic Shoes,CA,Fuller Trading Co.,16733
220100700022,Clothes&Shoes,Clothes,Orion,Alexis Women's Classic Shoes,CA,Fuller Trading Co.,16733
220100700023,Clothes&Shoes,Clothes,Orion,Armadillo Road Dmx Men's Running Shoes,CA,Fuller Trading Co.,16733
220100700024,Clothes&Shoes,Clothes,Orion,Armadillo Road Dmx Women's Running Shoes,CA,Fuller Trading Co.,16733
220100700027,Clothes&Shoes,Clothes,Orion,Duration Women's Trainer Aerobic Shoes,CA,Fuller Trading Co.,16733
220100700042,Clothes&Shoes,Clothes,Orion,"Power Women's Dmx Wide, Walking Shoes",CA,Fuller Trading Co.,16733
220100700046,Clothes&Shoes,Clothes,Orion,Tcp 6 Men's Running Shoes,CA,Fuller Trading Co.,16733
220100700052,Clothes&Shoes,Clothes,Orion,Trooper Ii Dmx-2x Men's Walking Shoes,CA,Fuller Trading Co.,16733
220100800001,Clothes&Shoes,Clothes,Orion Clothing,Bra Top Wom.Fitn.Cl,CA,Fuller Trading Co.,16733
220100800009,Clothes&Shoes,Clothes,Orion Clothing,Peacock Pants,CA,Fuller Trading Co.,16733
220100800040,Clothes&Shoes,Clothes,Orion Clothing,Mick's Men's Cl.Tracksuit,CA,Fuller Trading Co.,16733
220100800071,Clothes&Shoes,Clothes,Orion Clothing,Tx Tribe Tank Top,CA,Fuller Trading Co.,16733
220100800096,Clothes&Shoes,Clothes,Orion Clothing,Zx Women's Dance Pants,CA,Fuller Trading Co.,16733
220100900006,Clothes&Shoes,Clothes,Osprey,Osprey Cabri Micro Suit,US,Triple Sportswear Inc,3664
220100900029,Clothes&Shoes,Clothes,Osprey,Osprey Men's King T-Shirt w/Small Logo,US,Triple Sportswear Inc,3664
220100900035,Clothes&Shoes,Clothes,Osprey,Osprey Shadow Indoor,US,Triple Sportswear Inc,3664
220101000002,Clothes&Shoes,Clothes,Shorts,Carribian Women's Jersey Shorts,US,A Team Sports,3298
220101200006,Clothes&Shoes,Clothes,Street Wear,Anthony Bork Maggan 3/4 Long Pique,US,Mayday Inc,4646
220101200020,Clothes&Shoes,Clothes,Street Wear,Tyfoon Flex Shorts,AU,Typhoon Clothing,11427
220101200025,Clothes&Shoes,Clothes,Street Wear,Tyfoon Ketch T-Shirt,AU,Typhoon Clothing,11427
220101200029,Clothes&Shoes,Clothes,Street Wear,Tyfoon Oliver Sweatshirt,AU,Typhoon Clothing,11427
220101300001,Clothes&Shoes,Clothes,T-Shirts,"T-Shirt, Short-sleeved, Big Logo",US,A Team Sports,3298
220101300012,Clothes&Shoes,Clothes,T-Shirts,Men's T-Shirt Small Logo,US,A Team Sports,3298
220101300017,Clothes&Shoes,Clothes,T-Shirts,Toncot Beefy-T Emb T-Shirt,US,A Team Sports,3298
220101400004,Clothes&Shoes,Clothes,Tracker Clothes,Badminton Cotton,US,3Top Sports,2963
220101400017,Clothes&Shoes,Clothes,Tracker Clothes,Men's Cap,US,3Top Sports,2963
220101400018,Clothes&Shoes,Clothes,Tracker Clothes,Men's Running Tee Short Sleeves,US,3Top Sports,2963
220101400032,Clothes&Shoes,Clothes,Tracker Clothes,Socks Wmns'Fitness,US,Eclipse Inc,1303
220101400047,Clothes&Shoes,Clothes,Tracker Clothes,Swimming Trunks Struc,US,3Top Sports,2963
220101400060,Clothes&Shoes,Clothes,Tracker Clothes,2bwet 3 Cb Swimming Trunks,US,3Top Sports,2963
220101400061,Clothes&Shoes,Clothes,Tracker Clothes,2bwet 3 Solid Bikini,US,3Top Sports,2963
220101400088,Clothes&Shoes,Clothes,Tracker Clothes,Casual Genuine Polo-Shirt,US,3Top Sports,2963
220101400091,Clothes&Shoes,Clothes,Tracker Clothes,Casual Genuine Tee,US,3Top Sports,2963
220101400092,Clothes&Shoes,Clothes,Tracker Clothes,Casual Logo Men's Sweatshirt,US,3Top Sports,2963
220101400098,Clothes&Shoes,Clothes,Tracker Clothes,Casual Sport Shorts,US,3Top Sports,2963
220101400117,Clothes&Shoes,Clothes,Tracker Clothes,Casual.st.polo Long-sleeved Polo-shirt,US,3Top Sports,2963
220101400130,Clothes&Shoes,Clothes,Tracker Clothes,Comp. Women's Sleeveless Polo,US,3Top Sports,2963
220101400138,Clothes&Shoes,Clothes,Tracker Clothes,Dima 2-Layer Men's Suit,US,3Top Sports,2963
220101400145,Clothes&Shoes,Clothes,Tracker Clothes,Essence.baseball Cap,US,3Top Sports,2963
220101400148,Clothes&Shoes,Clothes,Tracker Clothes,Essence.cap Men's Bag,US,3Top Sports,2963
220101400150,Clothes&Shoes,Clothes,Tracker Clothes,Essential Suit 2 Swim Suit,US,3Top Sports,2963
220101400152,Clothes&Shoes,Clothes,Tracker Clothes,Essential Trunk 2 Swimming Trunks,US,3Top Sports,2963
220101400201,Clothes&Shoes,Clothes,Tracker Clothes,Kaitum Women's Swim Suit,US,3Top Sports,2963
220101400216,Clothes&Shoes,Clothes,Tracker Clothes,Mm Daypouch Shoulder Bag,US,3Top Sports,2963
220101400237,Clothes&Shoes,Clothes,Tracker Clothes,Mns.jacket Jacket,US,3Top Sports,2963
220101400238,Clothes&Shoes,Clothes,Tracker Clothes,Mns.long Tights,US,3Top Sports,2963
220101400265,Clothes&Shoes,Clothes,Tracker Clothes,Ottis Pes Men's Pants,US,3Top Sports,2963
220101400269,Clothes&Shoes,Clothes,Tracker Clothes,Outfit Women's Shirt,US,3Top Sports,2963
220101400276,Clothes&Shoes,Clothes,Tracker Clothes,Pine Sweat with Hood,US,3Top Sports,2963
220101400285,Clothes&Shoes,Clothes,Tracker Clothes,Quali Jacket with Hood,US,3Top Sports,2963
220101400289,Clothes&Shoes,Clothes,Tracker Clothes,Quali Sweatpant,US,3Top Sports,2963
220101400290,Clothes&Shoes,Clothes,Tracker Clothes,Quali Sweatshirt,US,3Top Sports,2963
220101400306,Clothes&Shoes,Clothes,Tracker Clothes,Sherpa Pes Shiny Cotton,US,3Top Sports,2963
220101400310,Clothes&Shoes,Clothes,Tracker Clothes,Short Women's Tights,US,3Top Sports,2963
220101400328,Clothes&Shoes,Clothes,Tracker Clothes,Stars Swim Suit,US,3Top Sports,2963
220101400339,Clothes&Shoes,Clothes,Tracker Clothes,Tims Shorts,US,3Top Sports,2963
220101400349,Clothes&Shoes,Clothes,Tracker Clothes,Tracker Fitness Stockings,US,3Top Sports,2963
220101400363,Clothes&Shoes,Clothes,Tracker Clothes,Brafit Swim Tights,ES,Luna sastreria S.A.,4742
220101400373,Clothes&Shoes,Clothes,Tracker Clothes,Jogging Pants  Men's Tracking Pants w/Small L,GB,Greenline Sports Ltd,14682
220101400385,Clothes&Shoes,Clothes,Tracker Clothes,N.d.gear Basic T-Shirt,GB,Greenline Sports Ltd,14682
220101400387,Clothes&Shoes,Clothes,Tracker Clothes,N.d.gear Cap,GB,Greenline Sports Ltd,14682
220200100002,Clothes&Shoes,Shoes,Eclipse Shoes,Cnv Plus Men's Off Court Tennis,US,Eclipse Inc,1303
220200100009,Clothes&Shoes,Shoes,Eclipse Shoes,Atmosphere Imara Women's Running Shoes,US,Eclipse Inc,1303
220200100012,Clothes&Shoes,Shoes,Eclipse Shoes,Atmosphere Shatter Mid Shoes,US,Eclipse Inc,1303
220200100035,Clothes&Shoes,Shoes,Eclipse Shoes,Big Guy Men's Air Deschutz Viii Shoes,US,Eclipse Inc,1303
220200100090,Clothes&Shoes,Shoes,Eclipse Shoes,Big Guy Men's Air Terra Reach Shoes,US,Eclipse Inc,1303
220200100092,Clothes&Shoes,Shoes,Eclipse Shoes,Big Guy Men's Air Terra Sebec Shoes,US,Eclipse Inc,1303
220200100129,Clothes&Shoes,Shoes,Eclipse Shoes,Big Guy Men's International Triax Shoes,US,Eclipse Inc,1303
220200100137,Clothes&Shoes,Shoes,Eclipse Shoes,Big Guy Men's Multicourt Ii Shoes,US,Eclipse Inc,1303
220200100171,Clothes&Shoes,Shoes,Eclipse Shoes,Woman's Air Amend Mid,US,Eclipse Inc,1303
220200100179,Clothes&Shoes,Shoes,Eclipse Shoes,Woman's Air Converge Triax X,US,Eclipse Inc,1303
220200100190,Clothes&Shoes,Shoes,Eclipse Shoes,Woman's Air Imara,US,Eclipse Inc,1303
220200100202,Clothes&Shoes,Shoes,Eclipse Shoes,Woman's Air Rasp Suede,US,Eclipse Inc,1303
220200100226,Clothes&Shoes,Shoes,Eclipse Shoes,Woman's Air Zoom Drive,US,Eclipse Inc,1303
220200100229,Clothes&Shoes,Shoes,Eclipse Shoes,Woman's Air Zoom Sterling,US,Eclipse Inc,1303
220200200014,Clothes&Shoes,Shoes,Shoes,Dubby Low Men's Street Shoes,SE,Petterson AB,109
220200200018,Clothes&Shoes,Shoes,Shoes,Lulu Men's Street Shoes,SE,Petterson AB,109
220200200022,Clothes&Shoes,Shoes,Shoes,Pro Fit Gel Ds Trainer Women's Running Shoes,US,Pro Sportswear Inc,1747
220200200024,Clothes&Shoes,Shoes,Shoes,Pro Fit Gel Gt 2030 Women's Running Shoes,US,Pro Sportswear Inc,1747
220200200035,Clothes&Shoes,Shoes,Shoes,Soft Alta Plus Women's Indoor Shoes,US,Pro Sportswear Inc,1747
220200200036,Clothes&Shoes,Shoes,Shoes,Soft Astro Men's Running Shoes,US,Pro Sportswear Inc,1747
220200200071,Clothes&Shoes,Shoes,Shoes,Twain Men's Exit Low 2000 Street Shoes,US,Twain Inc,13198
220200200073,Clothes&Shoes,Shoes,Shoes,Twain Stf6 Gtx M Men's Trekking Boot,US,Twain Inc,13198
220200200077,Clothes&Shoes,Shoes,Shoes,Twain Women's Exit Iii Mid Cd X-Hiking Shoes,US,Twain Inc,13198
220200200079,Clothes&Shoes,Shoes,Shoes,Twain Women's Expresso X-Hiking Shoes,US,Twain Inc,13198
220200300002,Clothes&Shoes,Shoes,Tracker Shoes,Pytossage Bathing Sandal,US,3Top Sports,2963
220200300005,Clothes&Shoes,Shoes,Tracker Shoes,Liga Football Boot,US,3Top Sports,2963
220200300015,Clothes&Shoes,Shoes,Tracker Shoes,Men's Running Shoes Piedmmont,US,3Top Sports,2963
220200300079,Clothes&Shoes,Shoes,Tracker Shoes,Hilly Women's Crosstrainer Shoes,US,3Top Sports,2963
220200300082,Clothes&Shoes,Shoes,Tracker Shoes,Indoor Handbold Special Shoes,US,3Top Sports,2963
220200300096,Clothes&Shoes,Shoes,Tracker Shoes,Mns.raptor Precision Sg Football,US,3Top Sports,2963
220200300116,Clothes&Shoes,Shoes,Tracker Shoes,South Peak Men's Running Shoes,US,3Top Sports,2963
220200300129,Clothes&Shoes,Shoes,Tracker Shoes,Torino Men's Leather Adventure Shoes,US,3Top Sports,2963
220200300154,Clothes&Shoes,Shoes,Tracker Shoes,Hardcore Junior/Women's Street Shoes Large,GB,Greenline Sports Ltd,14682
220200300157,Clothes&Shoes,Shoes,Tracker Shoes,Hardcore Men's Street Shoes Large,GB,Greenline Sports Ltd,14682
230100100006,Outdoors,Outdoors,Anoraks & Parkas,Jacket Nome,ES,Luna sastreria S.A.,4742
230100100013,Outdoors,Outdoors,Anoraks & Parkas,Jacket with Removable Fleece,US,AllSeasons Outdoor Clothing,772
230100100015,Outdoors,Outdoors,Anoraks & Parkas,Men's Jacket Caians,NO,Scandinavian Clothing A/S,50
230100100017,Outdoors,Outdoors,Anoraks & Parkas,Men's Jacket Rem,NO,Scandinavian Clothing A/S,50
230100100018,Outdoors,Outdoors,Anoraks & Parkas,Men's Jacket Sandy,ES,Luna sastreria S.A.,4742
230100100025,Outdoors,Outdoors,Anoraks & Parkas,Women's Shorts,NO,Scandinavian Clothing A/S,50
230100100028,Outdoors,Outdoors,Anoraks & Parkas,4men Men's Polar Down Jacket,US,AllSeasons Outdoor Clothing,772
230100100033,Outdoors,Outdoors,Anoraks & Parkas,Big Guy Men's Packable Hiking Shorts,US,Miller Trading Inc,15218
230100100045,Outdoors,Outdoors,Anoraks & Parkas,Duwall Pants,US,AllSeasons Outdoor Clothing,772
230100100051,Outdoors,Outdoors,Anoraks & Parkas,Lucky Voss Jacket,US,AllSeasons Outdoor Clothing,772
230100100053,Outdoors,Outdoors,Anoraks & Parkas,Monster Men's Pants with Zipper,NO,Scandinavian Clothing A/S,50
230100100062,Outdoors,Outdoors,Anoraks & Parkas,Topper Pants,US,AllSeasons Outdoor Clothing,772
230100100063,Outdoors,Outdoors,Anoraks & Parkas,Tx Peak Parka,US,Miller Trading Inc,15218
230100200004,Outdoors,Outdoors,Backpacks,Black/Black,DK,Top Sports,755
230100200006,Outdoors,Outdoors,Backpacks,X-Large Bottlegreen/Black,DK,Top Sports,755
230100200019,Outdoors,Outdoors,Backpacks,Commanche Women's 6000 Q Backpack. Bark,DK,Top Sports,755
230100200022,Outdoors,Outdoors,Backpacks,Expedition Camp Duffle Medium Backpack,US,Miller Trading Inc,15218
230100200025,Outdoors,Outdoors,Backpacks,Feelgood 55-75 Litre Black Women's Backpack,AU,Toto Outdoor Gear,10692
230100200029,Outdoors,Outdoors,Backpacks,Jaguar 50-75 Liter Blue Women's Backpack,AU,Toto Outdoor Gear,10692
230100200043,Outdoors,Outdoors,Backpacks,Medium Black/Bark Backpack,DK,Top Sports,755
230100200047,Outdoors,Outdoors,Backpacks,Medium Gold Black/Gold Backpack,DK,Top Sports,755
230100200048,Outdoors,Outdoors,Backpacks,Medium Olive Olive/Black Backpack,DK,Top Sports,755
230100200054,Outdoors,Outdoors,Backpacks,Trekker 65 Royal Men's Backpack,AU,Toto Outdoor Gear,10692
230100200056,Outdoors,Outdoors,Backpacks,Victor Grey/Olive Women's Backpack,DK,Top Sports,755
230100200059,Outdoors,Outdoors,Backpacks,Deer Backpack,ES,Luna sastreria S.A.,4742
230100200066,Outdoors,Outdoors,Backpacks,Deer Waist Bag,ES,Luna sastreria S.A.,4742
230100200073,Outdoors,Outdoors,Backpacks,Hammock Sports Bag,ES,Luna sastreria S.A.,4742
230100200074,Outdoors,Outdoors,Backpacks,Sioux Men's Backpack 26 Litre.,US,Miller Trading Inc,15218
230100300006,Outdoors,Outdoors,Gloves & Mittens,Gloves Le Fly Mitten,PT,Magnifico Sports,1684
230100300010,Outdoors,Outdoors,Gloves & Mittens,Massif Dual Gloves,FR,Massif S.A.,13199
230100300013,Outdoors,Outdoors,Gloves & Mittens,Montana Adult Gloves,SE,Svensson Trading AB,6355
230100300023,Outdoors,Outdoors,Gloves & Mittens,Scania Unisex Gloves,SE,Svensson Trading AB,6355
230100400007,Outdoors,Outdoors,Knitted Accessories,Breaker Commandos Cap,DK,Norsok A/S,4793
230100400010,Outdoors,Outdoors,Knitted Accessories,Breaker Frozen Husky Hat,DK,Norsok A/S,4793
230100400012,Outdoors,Outdoors,Knitted Accessories,Breaker Russia Cap,DK,Norsok A/S,4793
230100400025,Outdoors,Outdoors,Knitted Accessories,Mayday Serious Headband,US,Mayday Inc,4646
230100500004,Outdoors,Outdoors,Outdoor Gear,"Backpack Flag, 6,5x9 Cm.",GB,Prime Sports Ltd,316
230100500006,Outdoors,Outdoors,Outdoor Gear,Collapsible Water Can,GB,Prime Sports Ltd,316
230100500008,Outdoors,Outdoors,Outdoor Gear,Dome Tent Monodome Alu,GB,Prime Sports Ltd,316
230100500012,Outdoors,Outdoors,Outdoor Gear,Inflatable 3.5,GB,Prime Sports Ltd,316
230100500013,Outdoors,Outdoors,Outdoor Gear,Lamp with Battery Box,GB,Prime Sports Ltd,316
230100500016,Outdoors,Outdoors,Outdoor Gear,"Money Purse, Black",DK,Top Sports,755
230100500020,Outdoors,Outdoors,Outdoor Gear,Pocket Light with Crypton Bulb,GB,Prime Sports Ltd,316
230100500023,Outdoors,Outdoors,Outdoor Gear,Proofing Spray,GB,Prime Sports Ltd,316
230100500024,Outdoors,Outdoors,Outdoor Gear,"Small Belt Bag, Black",DK,Top Sports,755
230100500026,Outdoors,Outdoors,Outdoor Gear,Trekking Tent,GB,Prime Sports Ltd,316
230100500045,Outdoors,Outdoors,Outdoor Gear,Cup Picnic Mug 25 Cl.,GB,Prime Sports Ltd,316
230100500056,Outdoors,Outdoors,Outdoor Gear,Knife,US,KN Outdoor Trading Inc,4718
230100500058,Outdoors,Outdoors,Outdoor Gear,Mattress with 5 channels 196x72,GB,Prime Sports Ltd,316
230100500066,Outdoors,Outdoors,Outdoor Gear,Outback Spirits Kitchen,GB,Prime Sports Ltd,316
230100500068,Outdoors,Outdoors,Outdoor Gear,Plate Picnic Deep,GB,Prime Sports Ltd,316
230100500072,Outdoors,Outdoors,Outdoor Gear,Single Full Box Madras honeycomb-weave,GB,Prime Sports Ltd,316
230100500074,Outdoors,Outdoors,Outdoor Gear,"Tent Milano Tent,4 Persons, about 4.8",GB,Prime Sports Ltd,316
230100500077,Outdoors,Outdoors,Outdoor Gear,Jl Legacy Curig I.A.Jacket,US,AllSeasons Outdoor Clothing,772
230100500080,Outdoors,Outdoors,Outdoor Gear,Jl Rainlight Essential Pants,US,AllSeasons Outdoor Clothing,772
230100500081,Outdoors,Outdoors,Outdoor Gear,Lucky Tech Classic Rain Pants,US,AllSeasons Outdoor Clothing,772
230100500082,Outdoors,Outdoors,Outdoor Gear,Lucky Tech Intergal Wp/B Rain Pants,US,AllSeasons Outdoor Clothing,772
230100500087,Outdoors,Outdoors,Outdoor Gear,Mayday Qd Zip Pants,US,Mayday Inc,4646
230100500091,Outdoors,Outdoors,Outdoor Gear,Mayday Soul Ht Jacket,US,Mayday Inc,4646
230100500092,Outdoors,Outdoors,Outdoor Gear,Mayday Sports Pullover,US,Mayday Inc,4646
230100500093,Outdoors,Outdoors,Outdoor Gear,Mayday W'S Sports Pullover,US,Mayday Inc,4646
230100500094,Outdoors,Outdoors,Outdoor Gear,"Men's Pants, Basic",US,Mayday Inc,4646
230100500095,Outdoors,Outdoors,Outdoor Gear,Men's Sports Pullover,US,Mayday Inc,4646
230100500096,Outdoors,Outdoors,Outdoor Gear,Rain Jacket,US,AllSeasons Outdoor Clothing,772
230100500101,Outdoors,Outdoors,Outdoor Gear,Ultra Ht Lightning Set,US,AllSeasons Outdoor Clothing,772
230100600003,Outdoors,Outdoors,Sleepingbags,"Sheet Sleeping Bag, Red",GB,Outback Outfitters Ltd,16422
230100600005,Outdoors,Outdoors,Sleepingbags,"Basic 10, Left , Yellow/Black",DK,Top Sports,755
230100600015,Outdoors,Outdoors,Sleepingbags,"Expedition Zero,Medium,Left,Charcoal",DK,Top Sports,755
230100600016,Outdoors,Outdoors,Sleepingbags,"Expedition Zero,Medium,Right,Charcoal",DK,Top Sports,755
230100600017,Outdoors,Outdoors,Sleepingbags,"Expedition Zero,Small,Left,Charcoal",DK,Top Sports,755
230100600018,Outdoors,Outdoors,Sleepingbags,"Expedition Zero,Small,Right,Charcoal",DK,Top Sports,755
230100600022,Outdoors,Outdoors,Sleepingbags,"Expedition10,Medium,Right,Blue Ribbon",DK,Top Sports,755
230100600023,Outdoors,Outdoors,Sleepingbags,"Expedition 10,Small,Left,Blue Ribbon",DK,Top Sports,755
230100600024,Outdoors,Outdoors,Sleepingbags,"Expedition 10,Small,Right,Blue Ribbon",DK,Top Sports,755
230100600026,Outdoors,Outdoors,Sleepingbags,"Expedition 20,Large,Right,Forestgreen",DK,Top Sports,755
230100600028,Outdoors,Outdoors,Sleepingbags,"Expedition 20,Medium,Right,Forestgreen",DK,Top Sports,755
230100600030,Outdoors,Outdoors,Sleepingbags,"Outback Sleeping Bag, Large,Left,Blue/Black",DK,Top Sports,755
230100600031,Outdoors,Outdoors,Sleepingbags,"Outback Sleeping Bag, Large,Right, Blue/Black",DK,Top Sports,755
230100600035,Outdoors,Outdoors,Sleepingbags,"Polar Bear Sleeping mat, Olive Green",GB,Outback Outfitters Ltd,16422
230100600036,Outdoors,Outdoors,Sleepingbags,Tent Summer 195 Twin Sleeping Bag,GB,Outback Outfitters Ltd,16422
230100600038,Outdoors,Outdoors,Sleepingbags,Tipee Summer Sleeping Bag,GB,Outback Outfitters Ltd,16422
230100600039,Outdoors,Outdoors,Sleepingbags,Tipee Twin Blue/Orange,GB,Outback Outfitters Ltd,16422
230100700002,Outdoors,Outdoors,Tents,Comfort Shelter,GB,Outback Outfitters Ltd,16422
230100700004,Outdoors,Outdoors,Tents,Expedition Dome 3,GB,Outback Outfitters Ltd,16422
230100700008,Outdoors,Outdoors,Tents,Family Holiday 4,SE,Petterson AB,109
230100700009,Outdoors,Outdoors,Tents,Family Holiday 6,SE,Petterson AB,109
230100700011,Outdoors,Outdoors,Tents,Hurricane 4,SE,Petterson AB,109
240100100029,Sports,Assorted Sports Articles,Assorted Sports articles,Buzz Saw,CA,CrystalClear Optics Inc,16814
240100100031,Sports,Assorted Sports Articles,Assorted Sports articles,Capsy Hood,US,Nautlius SportsWear Inc,6153
240100100063,Sports,Assorted Sports Articles,Assorted Sports articles,Grey Met.,CA,CrystalClear Optics Inc,16814
240100100065,Sports,Assorted Sports Articles,Assorted Sports articles,Grey,CA,CrystalClear Optics Inc,16814
240100100148,Sports,Assorted Sports Articles,Assorted Sports articles,Wood Box for 6 Balls,GB,Royal Darts Ltd,4514
240100100159,Sports,Assorted Sports Articles,Assorted Sports articles,A-team Smoothsport Bra,US,A Team Sports,3298
240100100184,Sports,Assorted Sports Articles,Assorted Sports articles,Barret 2.12 Men's Softboot,US,Roll-Over Inc,3815
240100100186,Sports,Assorted Sports Articles,Assorted Sports articles,Barret 3.1 Women's Softboot,US,Roll-Over Inc,3815
240100100232,Sports,Assorted Sports Articles,Assorted Sports articles,Dartsharpener Key ring,GB,Royal Darts Ltd,4514
240100100305,Sports,Assorted Sports Articles,Assorted Sports articles,Hiclass Mundo 78a 36x72mm Pink-Swirl,US,Roll-Over Inc,3815
240100100312,Sports,Assorted Sports Articles,Assorted Sports articles,Hot Mini Backboard Bulls,NL,Van Dammeren International,2995
240100100354,Sports,Assorted Sports Articles,Assorted Sports articles,Mk Splinter 66 5m 88a Pea.,PT,Magnifico Sports,1684
240100100365,Sports,Assorted Sports Articles,Assorted Sports articles,Northern Coach,GB,EA Sports Limited,12283
240100100366,Sports,Assorted Sports Articles,Assorted Sports articles,Northern Liquid Belt with Bottle,GB,EA Sports Limited,12283
240100100403,Sports,Assorted Sports Articles,Assorted Sports articles,Proskater Viablade Tx Women's Fitness,US,Roll-Over Inc,3815
240100100410,Sports,Assorted Sports Articles,Assorted Sports articles,Prosoccer  Club Football 4/32 (Replica) Synth,US,Teamsports Inc,5810
240100100433,Sports,Assorted Sports Articles,Assorted Sports articles,Shoelace White 150 Cm,US,Teamsports Inc,5810
240100100434,Sports,Assorted Sports Articles,Assorted Sports articles,Shoeshine Black,CA,CrystalClear Optics Inc,16814
240100100463,Sports,Assorted Sports Articles,Assorted Sports articles,Sparkle Spray Orange,CA,CrystalClear Optics Inc,16814
240100100477,Sports,Assorted Sports Articles,Assorted Sports articles,Stout Brass 18 Gram,GB,Royal Darts Ltd,4514
240100100508,Sports,Assorted Sports Articles,Assorted Sports articles,Top Elite Kit Small,US,Roll-Over Inc,3815
240100100535,Sports,Assorted Sports Articles,Assorted Sports articles,Victor 76 76mm Optics Blue,PT,Magnifico Sports,1684
240100100581,Sports,Assorted Sports Articles,Assorted Sports articles,Eliza T-Shirt,ES,Luna sastreria S.A.,4742
240100100605,Sports,Assorted Sports Articles,Assorted Sports articles,Fred T-Shirt,ES,Luna sastreria S.A.,4742
240100100610,Sports,Assorted Sports Articles,Assorted Sports articles,Goodtime Bag,ES,Luna sastreria S.A.,4742
240100100615,Sports,Assorted Sports Articles,Assorted Sports articles,Goodtime Toilet Bag,ES,Luna sastreria S.A.,4742
240100100646,Sports,Assorted Sports Articles,Assorted Sports articles,Lyon Men's Jacket,ES,Luna sastreria S.A.,4742
240100100654,Sports,Assorted Sports Articles,Assorted Sports articles,Montevideo Men's Shorts,ES,Luna sastreria S.A.,4742
240100100665,Sports,Assorted Sports Articles,Assorted Sports articles,Pool Shorts,ES,Luna sastreria S.A.,4742
240100100672,Sports,Assorted Sports Articles,Assorted Sports articles,Ribstop Jacket,ES,Luna sastreria S.A.,4742
240100100676,Sports,Assorted Sports Articles,Assorted Sports articles,Roth T-Shirt,ES,Luna sastreria S.A.,4742
240100100679,Sports,Assorted Sports Articles,Assorted Sports articles,Saturn Big Bag,ES,Luna sastreria S.A.,4742
240100100690,Sports,Assorted Sports Articles,Assorted Sports articles,Shirt Termir,ES,Luna sastreria S.A.,4742
240100100703,Sports,Assorted Sports Articles,Assorted Sports articles,Stream Sweatshirt with Tube,ES,Luna sastreria S.A.,4742
240100100714,Sports,Assorted Sports Articles,Assorted Sports articles,Tybor Sweatshirt with Hood,ES,Luna sastreria S.A.,4742
240100100734,Sports,Assorted Sports Articles,Assorted Sports articles,Wyoming Men's Socks,ES,Luna sastreria S.A.,4742
240100100737,Sports,Assorted Sports Articles,Assorted Sports articles,Wyoming Men's T-Shirt with V-Neck,ES,Luna sastreria S.A.,4742
240100200001,Sports,Assorted Sports Articles,Darts,Aim4it 16 Gram Softtip Pil,GB,Royal Darts Ltd,4514
240100200004,Sports,Assorted Sports Articles,Darts,Aim4it 80% Tungsten 22 Gram,GB,Royal Darts Ltd,4514
240100200014,Sports,Assorted Sports Articles,Darts,Pacific 95% 23 Gram,GB,Royal Darts Ltd,4514
240100400004,Sports,Assorted Sports Articles,Skates,Children's Roller Skates,PT,Magnifico Sports,1684
240100400005,Sports,Assorted Sports Articles,Skates,Cool Fit Men's Roller Skates,US,Twain Inc,13198
240100400006,Sports,Assorted Sports Articles,Skates,Cool Fit Women's Roller Skates,US,Twain Inc,13198
240100400037,Sports,Assorted Sports Articles,Skates,N.d.gear Roller Skates Ff80 80 millimetre78a,PT,Magnifico Sports,1684
240100400043,Sports,Assorted Sports Articles,Skates,Perfect Fit Men's  Roller Skates,US,Twain Inc,13198
240100400044,Sports,Assorted Sports Articles,Skates,Perfect Fit Men's Roller Skates,US,Twain Inc,13198
240100400046,Sports,Assorted Sports Articles,Skates,Perfect Fit Men's Stunt Skates,US,Twain Inc,13198
240100400049,Sports,Assorted Sports Articles,Skates,Perfect Fit Women's Roller Skates Custom,US,Twain Inc,13198
240100400058,Sports,Assorted Sports Articles,Skates,Pro-roll Hot Rod Roller Skates,PT,Magnifico Sports,1684
240100400062,Sports,Assorted Sports Articles,Skates,Pro-roll Lazer Roller Skates,PT,Magnifico Sports,1684
240100400069,Sports,Assorted Sports Articles,Skates,Pro-roll Panga Roller Skates,PT,Magnifico Sports,1684
240100400070,Sports,Assorted Sports Articles,Skates,Pro-roll Sabotage-Rp  Roller Skates,PT,Magnifico Sports,1684
240100400076,Sports,Assorted Sports Articles,Skates,Pro-roll Sq9 80-76mm/78a Roller Skates,PT,Magnifico Sports,1684
240100400080,Sports,Assorted Sports Articles,Skates,Proskater Kitalpha Gamma Roller Skates,US,Roll-Over Inc,3815
240100400083,Sports,Assorted Sports Articles,Skates,Proskater Viablade S Roller Skates,US,Roll-Over Inc,3815
240100400085,Sports,Assorted Sports Articles,Skates,Proskater W-500 Jr.Roller Skates,US,Roll-Over Inc,3815
240100400095,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Control Xi Adult,PT,Magnifico Sports,1684
240100400098,Sports,Assorted Sports Articles,Skates,Rollerskate  Roller Skates Ex9 76mm/78a Biofl,PT,Magnifico Sports,1684
240100400100,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Gretzky Mvp S.B.S,PT,Magnifico Sports,1684
240100400112,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Panga 72mm/78a,PT,Magnifico Sports,1684
240100400125,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Sq5 76mm/78a,PT,Magnifico Sports,1684
240100400128,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Sq7-Ls 76mm/78a,PT,Magnifico Sports,1684
240100400129,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Sq9 80-76mm/78a,PT,Magnifico Sports,1684
240100400136,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Xpander,PT,Magnifico Sports,1684
240100400142,Sports,Assorted Sports Articles,Skates,Twain Ac7/Ft7 Men's Roller Skates,US,Twain Inc,13198
240100400143,Sports,Assorted Sports Articles,Skates,Twain Ac7/Ft7 Women's Roller Skates,US,Twain Inc,13198
240100400147,Sports,Assorted Sports Articles,Skates,Twain Tr7 Men's Roller Skates,US,Twain Inc,13198
240100400151,Sports,Assorted Sports Articles,Skates,Weston F4 Men's Hockey Skates,US,Roll-Over Inc,3815
240200100007,Sports,Golf,Golf,Ball Bag,NL,Van Dammeren International,2995
240200100020,Sports,Golf,Golf,Red/White/Black Staff 9 Bag,GB,GrandSlam Sporting Goods Ltd,17832
240200100021,Sports,Golf,Golf,Tee Holder,NL,Van Dammeren International,2995
240200100034,Sports,Golf,Golf,Bb Softspikes - Xp 22-pack,GB,TeeTime Ltd,15938
240200100043,Sports,Golf,Golf,Bretagne Performance Tg Men's Golf Shoes L.,NL,Van Dammeren International,2995
240200100046,Sports,Golf,Golf,"Bretagne Soft-Tech Men's Glove, left",NL,Van Dammeren International,2995
240200100050,Sports,Golf,Golf,"Bretagne St2 Men's Golf Glove, left",NL,Van Dammeren International,2995
240200100051,Sports,Golf,Golf,Bretagne Stabilites 2000 Goretex Shoes,NL,Van Dammeren International,2995
240200100052,Sports,Golf,Golf,Bretagne Stabilities Tg Men's Golf Shoes,NL,Van Dammeren International,2995
240200100053,Sports,Golf,Golf,Bretagne Stabilities Women's Golf Shoes,NL,Van Dammeren International,2995
240200100056,Sports,Golf,Golf,Carolina,US,Carolina Sports,3808
240200100057,Sports,Golf,Golf,Carolina II,US,Carolina Sports,3808
240200100073,Sports,Golf,Golf,Donald Plush Headcover,GB,TeeTime Ltd,15938
240200100076,Sports,Golf,Golf,Expert Men's Firesole Driver,US,Twain Inc,13198
240200100081,Sports,Golf,Golf,Extreme Distance 90 3-pack,US,Carolina Sports,3808
240200100095,Sports,Golf,Golf,Grandslam Staff Fs Copper Insert Putter,GB,GrandSlam Sporting Goods Ltd,17832
240200100098,Sports,Golf,Golf,Grandslam Staff Grip Llh Golf Gloves,US,Carolina Sports,3808
240200100101,Sports,Golf,Golf,Grandslam Staff Tour Mhl Golf Gloves,US,Carolina Sports,3808
240200100116,Sports,Golf,Golf,Hi-fly Intimidator Ti R80/10,NL,Van Dammeren International,2995
240200100118,Sports,Golf,Golf,Hi-fly Intrepid Stand 8  Black,NL,Van Dammeren International,2995
240200100124,Sports,Golf,Golf,Hi-fly Staff Towel Blue/Black,NL,Van Dammeren International,2995
240200100131,Sports,Golf,Golf,Hi-fly Tour Advance Flex Steel,NL,Van Dammeren International,2995
240200100154,Sports,Golf,Golf,"Men's.m Men's Winter Gloves, Medium",NL,Van Dammeren International,2995
240200100157,Sports,Golf,Golf,Normal Standard,GB,TeeTime Ltd,15938
240200100164,Sports,Golf,Golf,Precision Jack 309 Lh Balata,GB,GrandSlam Sporting Goods Ltd,17832
240200100173,Sports,Golf,Golf,Proplay Executive Bi-Metal Graphite,NL,Van Dammeren International,2995
240200100180,Sports,Golf,Golf,Proplay Men's Tour Force Lp 7-Wood,NL,Van Dammeren International,2995
240200100181,Sports,Golf,Golf,Proplay Men's Tour Force Lp Driver,NL,Van Dammeren International,2995
240200100183,Sports,Golf,Golf,Proplay Men's Tour Force Ti 5w,NL,Van Dammeren International,2995
240200100207,Sports,Golf,Golf,Proplay Stand Black,NL,Van Dammeren International,2995
240200100211,Sports,Golf,Golf,Proplay Women's Tour Force 7w,NL,Van Dammeren International,2995
240200100221,Sports,Golf,Golf,Rosefinch Cart 8 1/2  Black,NL,Van Dammeren International,2995
240200100225,Sports,Golf,Golf,Rubby Men's Golf Shoes w/Goretex,ES,Rubby Zapatos S.A.,4168
240200100226,Sports,Golf,Golf,Rubby Men's Golf Shoes w/Goretex Plain Toe,ES,Rubby Zapatos S.A.,4168
240200100227,Sports,Golf,Golf,Rubby Women's Golf Shoes w/Gore-Tex,ES,Rubby Zapatos S.A.,4168
240200100230,Sports,Golf,Golf,Score Counter Scoreboard De Luxe,NL,Van Dammeren International,2995
240200100232,Sports,Golf,Golf,Tee18 Ascot Chipper,NL,Van Dammeren International,2995
240200100233,Sports,Golf,Golf,Tee18 Troon 7  Black,NL,Van Dammeren International,2995
240200100246,Sports,Golf,Golf,"White 90,Top.Flite Strata Tour 3-pack",NL,Van Dammeren International,2995
240200200007,Sports,Golf,Golf Clothes,Golf Polo(1/400),US,Mike Schaeffer Inc,7511
240200200011,Sports,Golf,Golf Clothes,Golf Windstopper,US,Mike Schaeffer Inc,7511
240200200013,Sports,Golf,Golf Clothes,Master Golf Rain Suit,US,Mike Schaeffer Inc,7511
240200200015,Sports,Golf,Golf Clothes,Tek Cap,US,Twain Inc,13198
240200200020,Sports,Golf,Golf Clothes,Big Boss Houston Pants,US,Mike Schaeffer Inc,7511
240200200024,Sports,Golf,Golf Clothes,Bogie Golf Fleece with small Zipper,US,Mike Schaeffer Inc,7511
240200200026,Sports,Golf,Golf Clothes,Eagle 5 Pocket Pants with Stretch,US,HighPoint Trading,10225
240200200035,Sports,Golf,Golf Clothes,Eagle Pants with Cross Pocket,US,HighPoint Trading,10225
240200200039,Sports,Golf,Golf Clothes,Eagle Plain Cap,US,HighPoint Trading,10225
240200200044,Sports,Golf,Golf Clothes,Eagle Polo-Shirt Interlock,US,HighPoint Trading,10225
240200200060,Sports,Golf,Golf Clothes,Eagle Windstopper Knit Neck,US,HighPoint Trading,10225
240200200061,Sports,Golf,Golf Clothes,Eagle Windstopper Sweat Neck,US,HighPoint Trading,10225
240200200068,Sports,Golf,Golf Clothes,Hi-fly Staff Rain Suit,NL,Van Dammeren International,2995
240200200071,Sports,Golf,Golf Clothes,Hi-fly Strata Cap Offwhite/Green,NL,Van Dammeren International,2995
240200200080,Sports,Golf,Golf Clothes,Release Golf Sweatshirt w/Logo(1/100),US,Mike Schaeffer Inc,7511
240200200081,Sports,Golf,Golf Clothes,Top (1/100),US,Mike Schaeffer Inc,7511
240200200091,Sports,Golf,Golf Clothes,Wind Proof Windstopper Merino/Acryl,US,HighPoint Trading,10225
240300100001,Sports,Indoor Sports,Fitness,Abdomen Shaper,NL,TrimSport B.V.,16542
240300100020,Sports,Indoor Sports,Fitness,Fitness Dumbbell Foam 0.90,NL,TrimSport B.V.,16542
240300100028,Sports,Indoor Sports,Fitness,Letour Heart Bike,NL,TrimSport B.V.,16542
240300100032,Sports,Indoor Sports,Fitness,Letour Trimag Bike,NL,TrimSport B.V.,16542
240300100046,Sports,Indoor Sports,Fitness,Weight  5.0 Kg,NL,TrimSport B.V.,16542
240300100048,Sports,Indoor Sports,Fitness,Wrist Weight 1.10 Kg,NL,TrimSport B.V.,16542
240300100049,Sports,Indoor Sports,Fitness,Wrist Weight  2.25 Kg,NL,TrimSport B.V.,16542
240300200009,Sports,Indoor Sports,Gymnastic Clothing,Blues Jazz Pants Suplex,ES,Sportico,798
240300200018,Sports,Indoor Sports,Gymnastic Clothing,Cougar Fleece Jacket with Zipper,US,SD Sporting Goods Inc,13710
240300200058,Sports,Indoor Sports,Gymnastic Clothing,Cougar Windbreaker Vest,US,SD Sporting Goods Inc,13710
240300300024,Sports,Indoor Sports,Top Trim,Men's Summer Shorts,US,Top Sports Inc,14648
240300300065,Sports,Indoor Sports,Top Trim,Top Men's Goretex Ski Pants,US,Top Sports Inc,14648
240300300070,Sports,Indoor Sports,Top Trim,Top Men's R&D Ultimate Jacket,US,Top Sports Inc,14648
240300300071,Sports,Indoor Sports,Top Trim,Top Men's Retro T-Neck,US,Top Sports Inc,14648
240300300090,Sports,Indoor Sports,Top Trim,Top R&D Long Jacket,US,Top Sports Inc,14648
240400200003,Sports,Racket Sports,Racket Sports,Bat 5-Ply,US,Carolina Sports,3808
240400200012,Sports,Racket Sports,Racket Sports,Sledgehammer 120 Ph Black,GB,GrandSlam Sporting Goods Ltd,17832
240400200022,Sports,Racket Sports,Racket Sports,Aftm 95 Vf Long Bg-65 White,GB,British Sports Ltd,1280
240400200036,Sports,Racket Sports,Racket Sports,Bag  Tit.Weekend,FR,Le Blanc S.A.,13079
240400200057,Sports,Racket Sports,Racket Sports,Grandslam Ultra Power Tennisketcher,GB,GrandSlam Sporting Goods Ltd,17832
240400200066,Sports,Racket Sports,Racket Sports,"Memhis 350,Yellow Medium, 6-pack tube",GB,British Sports Ltd,1280
240400200091,Sports,Racket Sports,Racket Sports,Smasher Rd Ti 70 Tennis Racket,GB,British Sports Ltd,1280
240400200093,Sports,Racket Sports,Racket Sports,Smasher Super Rq Ti 350 Tennis Racket,GB,British Sports Ltd,1280
240400200094,Sports,Racket Sports,Racket Sports,Smasher Super Rq Ti 700 Long Tennis,GB,British Sports Ltd,1280
240400200097,Sports,Racket Sports,Racket Sports,Smasher Tg 70 Tennis String Roll,GB,British Sports Ltd,1280
240400300013,Sports,Racket Sports,Tennis,Anthony Women's Tennis Cable Vest,US,Mayday Inc,4646
240400300033,Sports,Racket Sports,Tennis,Smasher Polo-Shirt w/V-Neck,GB,British Sports Ltd,1280
240400300035,Sports,Racket Sports,Tennis,Smasher Shorts,GB,British Sports Ltd,1280
240400300039,Sports,Racket Sports,Tennis,Smasher Tights,GB,British Sports Ltd,1280
240500100004,Sports,Running - Jogging,Jogging,Pants N,ES,Luna sastreria S.A.,4742
240500100015,Sports,Running - Jogging,Jogging,A-team Pants Taffeta,US,A Team Sports,3298
240500100017,Sports,Running - Jogging,Jogging,"A-team Sweat Round Neck, Small Logo",US,A Team Sports,3298
240500100026,Sports,Running - Jogging,Jogging,"Men's Sweat Pants without Rib, Small Logo",US,A Team Sports,3298
240500100029,Sports,Running - Jogging,Jogging,Men's Sweatshirt w/Hood Big Logo,US,A Team Sports,3298
240500100039,Sports,Running - Jogging,Jogging,Sweatshirt Women's Sweatshirt with O-Neck,US,A Team Sports,3298
240500100041,Sports,Running - Jogging,Jogging,Triffy Jacket,NL,Triffy B.V.,13314
240500100043,Sports,Running - Jogging,Jogging,Triffy Logo T-Shirt with V-Neck,NL,Triffy B.V.,13314
240500100057,Sports,Running - Jogging,Jogging,"Woman Sweat with Round Neck, Big Logo",US,A Team Sports,3298
240500100062,Sports,Running - Jogging,Jogging,Ypsilon Men's Sweatshirt w/Piping,FR,Ypsilon S.A.,14624
240500200003,Sports,Running - Jogging,Running Clothes,Men's Singlet,BE,Force Sports,5922
240500200007,Sports,Running - Jogging,Running Clothes,Running Gloves,BE,Force Sports,5922
240500200016,Sports,Running - Jogging,Running Clothes,T-Shirt,US,3Top Sports,2963
240500200042,Sports,Running - Jogging,Running Clothes,Bike.Pants Short Biking Pants,BE,Force Sports,5922
240500200056,Sports,Running - Jogging,Running Clothes,Breath-brief Long Underpants XXL,BE,Force Sports,5922
240500200073,Sports,Running - Jogging,Running Clothes,Force Classic Men's Jacket,BE,Force Sports,5922
240500200081,Sports,Running - Jogging,Running Clothes,Force Micro Men's Suit,BE,Force Sports,5922
240500200082,Sports,Running - Jogging,Running Clothes,Force Short Sprinter Men's Tights,BE,Force Sports,5922
240500200083,Sports,Running - Jogging,Running Clothes,Force Technical Jacket w/Coolmax,BE,Force Sports,5922
240500200093,Sports,Running - Jogging,Running Clothes,Maxrun Running Tights,BE,Force Sports,5922
240500200100,Sports,Running - Jogging,Running Clothes,Original Running Pants,BE,Force Sports,5922
240500200101,Sports,Running - Jogging,Running Clothes,Polar Jacket,BE,Force Sports,5922
240500200121,Sports,Running - Jogging,Running Clothes,Stout Running Shorts,BE,Force Sports,5922
240500200122,Sports,Running - Jogging,Running Clothes,Stout Running Shorts Micro,BE,Force Sports,5922
240500200130,Sports,Running - Jogging,Running Clothes,Topline Delphi Race Shorts,BE,Force Sports,5922
240600100010,Sports,Swim Sports,Bathing Suits,"Goggles, Assorted Colours",US,Nautlius SportsWear Inc,6153
240600100016,Sports,Swim Sports,Bathing Suits,Swim Suit Fabulo,US,Nautlius SportsWear Inc,6153
240600100017,Sports,Swim Sports,Bathing Suits,Swim Suit Laurel,ES,Luna sastreria S.A.,4742
240600100080,Sports,Swim Sports,Bathing Suits,Sharky Swimming Trunks,US,Dolphin Sportswear Inc,16292
240600100102,Sports,Swim Sports,Bathing Suits,Sunfit Luffa Bikini,US,Nautlius SportsWear Inc,6153
240600100181,Sports,Swim Sports,Bathing Suits,Milan Swimming Trunks,ES,Luna sastreria S.A.,4742
240600100185,Sports,Swim Sports,Bathing Suits,Pew Swimming Trunks,ES,Luna sastreria S.A.,4742
240700100001,Sports,Team Sports,American Football,Armour L,US,A Team Sports,3298
240700100004,Sports,Team Sports,American Football,Armour XL,US,A Team Sports,3298
240700100007,Sports,Team Sports,American Football,Football - Helmet M,US,A Team Sports,3298
240700100011,Sports,Team Sports,American Football,Football - Helmet Pro XL,US,A Team Sports,3298
240700100012,Sports,Team Sports,American Football,Football - Helmet S,US,A Team Sports,3298
240700100013,Sports,Team Sports,American Football,Football - Helmet XL,US,A Team Sports,3298
240700100017,Sports,Team Sports,American Football,Football Super Bowl,US,Carolina Sports,3808
240700200004,Sports,Team Sports,Baseball,Baseball Orange Small,US,Top Sports Inc,14648
240700200007,Sports,Team Sports,Baseball,Baseball White Small,US,Top Sports Inc,14648
240700200009,Sports,Team Sports,Baseball,Bat - Home Run M,US,Miller Trading Inc,15218
240700200010,Sports,Team Sports,Baseball,Bat - Home Run S,US,Miller Trading Inc,15218
240700200018,Sports,Team Sports,Baseball,Helmet L,US,Miller Trading Inc,15218
240700200019,Sports,Team Sports,Baseball,Helmet M,US,Miller Trading Inc,15218
240700200021,Sports,Team Sports,Baseball,Helmet XL,US,Miller Trading Inc,15218
240700200024,Sports,Team Sports,Baseball,Bat - Large,US,Miller Trading Inc,15218
240700300002,Sports,Team Sports,Basket Ball,Basket Ball Pro,US,HighPoint Trading,10225
240700400002,Sports,Team Sports,Soccer,Stephens Shirt,US,Teamsports Inc,5810
240700400003,Sports,Team Sports,Soccer,Red Cap,GB,SportsFan Products Ltd,6071
240700400004,Sports,Team Sports,Soccer,Red Scarf,GB,SportsFan Products Ltd,6071
240700400017,Sports,Team Sports,Soccer,Fga Home Shorts,US,Fga Sports Inc,14593
240700400020,Sports,Team Sports,Soccer,Norwood Player Shirt,US,Fga Sports Inc,14593
240700400024,Sports,Team Sports,Soccer,Prosoccer Away Shirt,US,Fga Sports Inc,14593
240700400031,Sports,Team Sports,Soccer,Soccer Fan Football Player Shirt,GB,SportsFan Products Ltd,6071
240800100026,Sports,Winter Sports,Ski Dress,Additive Women's Ski Pants Vent Air,NO,Scandinavian Clothing A/S,50
240800100039,Sports,Winter Sports,Ski Dress,Garbo Fleece Jacket,US,Miller Trading Inc,15218
240800100041,Sports,Winter Sports,Ski Dress,Helmsdale Ski Jacket,US,AllSeasons Outdoor Clothing,772
240800100042,Sports,Winter Sports,Ski Dress,Helmsdale Ski Pants,US,AllSeasons Outdoor Clothing,772
240800100074,Sports,Winter Sports,Ski Dress,Mayday Soul Pro New Tech Ski Jacket,US,Mayday Inc,4646
240800200002,Sports,Winter Sports,Winter Sports,Massif Bandit Ski Parcel Axial,FR,Massif S.A.,13199
240800200008,Sports,Winter Sports,Winter Sports,"Twain X-Scream 7.9 Ski,Sq 750 Dri",US,Twain Inc,13198
240800200009,Sports,Winter Sports,Winter Sports,Amber Cc,CA,CrystalClear Optics Inc,16814
240800200010,Sports,Winter Sports,Winter Sports,Black Morphe,CA,CrystalClear Optics Inc,16814
240800200020,Sports,Winter Sports,Winter Sports,"C.A.M.,Bone",CA,CrystalClear Optics Inc,16814
240800200021,Sports,Winter Sports,Winter Sports,Cayenne Red,CA,CrystalClear Optics Inc,16814
240800200030,Sports,Winter Sports,Winter Sports,"Ii Pmt,Bone",CA,CrystalClear Optics Inc,16814
240800200034,Sports,Winter Sports,Winter Sports,"Regulator,Stopsign",CA,CrystalClear Optics Inc,16814
240800200035,Sports,Winter Sports,Winter Sports,Shine Black PRO,CA,CrystalClear Optics Inc,16814
240800200037,Sports,Winter Sports,Winter Sports,Coolman Pro 01 Neon Yellow,US,Twain Inc,13198
240800200062,Sports,Winter Sports,Winter Sports,Top Equipe 07 Green,US,Twain Inc,13198
240800200063,Sports,Winter Sports,Winter Sports,Top Equipe 99 Black,US,Twain Inc,13198
;;;;
run;

data ORION.PRODUCTS;
   attrib category length=$24 label='Category' format=$24. informat=$24.;
   attrib Name length=$45 label='Name' format=$45. informat=$45.;
   attrib Division length=$13;

   infile datalines dsd;
   input
      category:$24.
      Name:$45.
      Division
   ;
datalines4;
Assorted Sports Articles,Buzz Saw,Sports
Assorted Sports Articles,Capsy Hood,Sports
Assorted Sports Articles,Grey Met.,Sports
Assorted Sports Articles,Grey,Sports
Assorted Sports Articles,Wood Box for 6 Balls,Sports
Assorted Sports Articles,A-team Smoothsport Bra,Sports
Assorted Sports Articles,Barret 2.12 Men's Softboot,Sports
Assorted Sports Articles,Barret 3.1 Women's Softboot,Sports
Assorted Sports Articles,Dartsharpener Key ring,Sports
Assorted Sports Articles,Hiclass Mundo 78a 36x72mm Pink-Swirl,Sports
Assorted Sports Articles,Hot Mini Backboard Bulls,Sports
Assorted Sports Articles,Mk Splinter 66 5m 88a Pea.,Sports
Assorted Sports Articles,Northern Coach,Sports
Assorted Sports Articles,Northern Liquid Belt with Bottle,Sports
Assorted Sports Articles,Proskater Viablade Tx Women's Fitness,Sports
Assorted Sports Articles,Prosoccer  Club Football 4/32 (Replica) Synth,Sports
Assorted Sports Articles,Shoelace White 150 Cm,Sports
Assorted Sports Articles,Shoeshine Black,Sports
Assorted Sports Articles,Sparkle Spray Orange,Sports
Assorted Sports Articles,Stout Brass 18 Gram,Sports
Assorted Sports Articles,Top Elite Kit Small,Sports
Assorted Sports Articles,Victor 76 76mm Optics Blue,Sports
Assorted Sports Articles,Eliza T-Shirt,Sports
Assorted Sports Articles,Fred T-Shirt,Sports
Assorted Sports Articles,Goodtime Bag,Sports
Assorted Sports Articles,Goodtime Toilet Bag,Sports
Assorted Sports Articles,Lyon Men's Jacket,Sports
Assorted Sports Articles,Montevideo Men's Shorts,Sports
Assorted Sports Articles,Pool Shorts,Sports
Assorted Sports Articles,Ribstop Jacket,Sports
Assorted Sports Articles,Roth T-Shirt,Sports
Assorted Sports Articles,Saturn Big Bag,Sports
Assorted Sports Articles,Shirt Termir,Sports
Assorted Sports Articles,Stream Sweatshirt with Tube,Sports
Assorted Sports Articles,Tybor Sweatshirt with Hood,Sports
Assorted Sports Articles,Wyoming Men's Socks,Sports
Assorted Sports Articles,Wyoming Men's T-Shirt with V-Neck,Sports
Assorted Sports Articles,Aim4it 16 Gram Softtip Pil,Sports
Assorted Sports Articles,Aim4it 80% Tungsten 22 Gram,Sports
Assorted Sports Articles,Pacific 95% 23 Gram,Sports
Assorted Sports Articles,Children's Roller Skates,Sports
Assorted Sports Articles,Cool Fit Men's Roller Skates,Sports
Assorted Sports Articles,Cool Fit Women's Roller Skates,Sports
Assorted Sports Articles,N.d.gear Roller Skates Ff80 80 millimetre78a,Sports
Assorted Sports Articles,Perfect Fit Men's  Roller Skates,Sports
Assorted Sports Articles,Perfect Fit Men's Roller Skates,Sports
Assorted Sports Articles,Perfect Fit Men's Stunt Skates,Sports
Assorted Sports Articles,Perfect Fit Women's Roller Skates Custom,Sports
Assorted Sports Articles,Pro-roll Hot Rod Roller Skates,Sports
Assorted Sports Articles,Pro-roll Lazer Roller Skates,Sports
Assorted Sports Articles,Pro-roll Panga Roller Skates,Sports
Assorted Sports Articles,Pro-roll Sabotage-Rp  Roller Skates,Sports
Assorted Sports Articles,Pro-roll Sq9 80-76mm/78a Roller Skates,Sports
Assorted Sports Articles,Proskater Kitalpha Gamma Roller Skates,Sports
Assorted Sports Articles,Proskater Viablade S Roller Skates,Sports
Assorted Sports Articles,Proskater W-500 Jr.Roller Skates,Sports
Assorted Sports Articles,Rollerskate Roller Skates Control Xi Adult,Sports
Assorted Sports Articles,Rollerskate  Roller Skates Ex9 76mm/78a Biofl,Sports
Assorted Sports Articles,Rollerskate Roller Skates Gretzky Mvp S.B.S,Sports
Assorted Sports Articles,Rollerskate Roller Skates Panga 72mm/78a,Sports
Assorted Sports Articles,Rollerskate Roller Skates Sq5 76mm/78a,Sports
Assorted Sports Articles,Rollerskate Roller Skates Sq7-Ls 76mm/78a,Sports
Assorted Sports Articles,Rollerskate Roller Skates Sq9 80-76mm/78a,Sports
Assorted Sports Articles,Rollerskate Roller Skates Xpander,Sports
Assorted Sports Articles,Twain Ac7/Ft7 Men's Roller Skates,Sports
Assorted Sports Articles,Twain Ac7/Ft7 Women's Roller Skates,Sports
Assorted Sports Articles,Twain Tr7 Men's Roller Skates,Sports
Assorted Sports Articles,Weston F4 Men's Hockey Skates,Sports
Clothes,Fit Racing Cap,Clothes&Shoes
Clothes,Knit Hat,Clothes&Shoes
Clothes,Sports glasses Satin Alumin.,Clothes&Shoes
Clothes,Big Guy Men's Chaser Poplin Pants,Clothes&Shoes
Clothes,Big Guy Men's Clima Fit Jacket,Clothes&Shoes
Clothes,Big Guy Men's Dri Fit Singlet,Clothes&Shoes
Clothes,Big Guy Men's Fresh Soft Nylon Pants,Clothes&Shoes
Clothes,Big Guy Men's Micro Fiber Full Zip Jacket,Clothes&Shoes
Clothes,Big Guy Men's Micro Fibre Jacket,Clothes&Shoes
Clothes,Big Guy Men's Micro Fibre Shorts XXL,Clothes&Shoes
Clothes,Big Guy Men's Mid Layer Jacket,Clothes&Shoes
Clothes,Big Guy Men's Running Shorts Dri.Fit,Clothes&Shoes
Clothes,Big Guy Men's Santos Shorts Dri Fit,Clothes&Shoes
Clothes,Big Guy Men's T-Shirt,Clothes&Shoes
Clothes,Big Guy Men's T-Shirt Dri Fit,Clothes&Shoes
Clothes,Big Guy Men's Twill Pants Golf,Clothes&Shoes
Clothes,Big Guy Men's Victory Peach Poplin Pants,Clothes&Shoes
Clothes,Big Guy Men's Woven Warm Up,Clothes&Shoes
Clothes,Insu F.I.T Basic,Clothes&Shoes
Clothes,Northern Fleece Scarf,Clothes&Shoes
Clothes,Toto Tube Socks,Clothes&Shoes
Clothes,Trois-fit Running Qtr Socks (Non-Cush),Clothes&Shoes
Clothes,Woman's Deception Dress,Clothes&Shoes
Clothes,Woman's Dri Fit Airborne Top,Clothes&Shoes
Clothes,Woman's Dri-Fit Scoop Neck Bra,Clothes&Shoes
Clothes,Woman's Emblished Work-Out Pants,Clothes&Shoes
Clothes,Woman's Foxhole Jacket,Clothes&Shoes
Clothes,Woman's Short Top Dri Fit,Clothes&Shoes
Clothes,Woman's Micro Fibre Anorak,Clothes&Shoes
Clothes,Woman's Out & Sew Airborn Top,Clothes&Shoes
Clothes,Woman's Short Tights,Clothes&Shoes
Clothes,Woman's Sweatshirt w/Hood,Clothes&Shoes
Clothes,Woman's T-Shirt w/Hood,Clothes&Shoes
Clothes,Woman's Winter Tights,Clothes&Shoes
Clothes,Woman's Work Out Pants Dri Fit,Clothes&Shoes
Clothes,Woman's Woven Warm Up,Clothes&Shoes
Clothes,Green Lime Atletic Socks,Clothes&Shoes
Clothes,Fleece Jacket Compass,Clothes&Shoes
Clothes,Dp Roller High-necked Knit,Clothes&Shoes
Clothes,Instyle Pullover Mid w/Small Zipper,Clothes&Shoes
Clothes,Instyle T-Shirt,Clothes&Shoes
Clothes,Lucky Knitwear Wool Sweater,Clothes&Shoes
Clothes,Mayday Resque Fleece Pullover,Clothes&Shoes
Clothes,Truls Polar Fleece Cardigan,Clothes&Shoes
Clothes,Big Guy Men's Air Force 1 Sc,Clothes&Shoes
Clothes,Ultra M803 Ng Men's Street Shoes,Clothes&Shoes
Clothes,Ultra W802 All Terrain Women's Shoes,Clothes&Shoes
Clothes,Dmx 10 Women's Aerobic Shoes,Clothes&Shoes
Clothes,Alexis Women's Classic Shoes,Clothes&Shoes
Clothes,Armadillo Road Dmx Men's Running Shoes,Clothes&Shoes
Clothes,Armadillo Road Dmx Women's Running Shoes,Clothes&Shoes
Clothes,Duration Women's Trainer Aerobic Shoes,Clothes&Shoes
Clothes,"Power Women's Dmx Wide, Walking Shoes",Clothes&Shoes
Clothes,Tcp 6 Men's Running Shoes,Clothes&Shoes
Clothes,Trooper Ii Dmx-2x Men's Walking Shoes,Clothes&Shoes
Clothes,Bra Top Wom.Fitn.Cl,Clothes&Shoes
Clothes,Peacock Pants,Clothes&Shoes
Clothes,Mick's Men's Cl.Tracksuit,Clothes&Shoes
Clothes,Tx Tribe Tank Top,Clothes&Shoes
Clothes,Zx Women's Dance Pants,Clothes&Shoes
Clothes,Osprey Cabri Micro Suit,Clothes&Shoes
Clothes,Osprey Men's King T-Shirt w/Small Logo,Clothes&Shoes
Clothes,Osprey Shadow Indoor,Clothes&Shoes
Clothes,Carribian Women's Jersey Shorts,Clothes&Shoes
Clothes,Anthony Bork Maggan 3/4 Long Pique,Clothes&Shoes
Clothes,Tyfoon Flex Shorts,Clothes&Shoes
Clothes,Tyfoon Ketch T-Shirt,Clothes&Shoes
Clothes,Tyfoon Oliver Sweatshirt,Clothes&Shoes
Clothes,"T-Shirt, Short-sleeved, Big Logo",Clothes&Shoes
Clothes,Men's T-Shirt Small Logo,Clothes&Shoes
Clothes,Toncot Beefy-T Emb T-Shirt,Clothes&Shoes
Clothes,Badminton Cotton,Clothes&Shoes
Clothes,Men's Cap,Clothes&Shoes
Clothes,Men's Running Tee Short Sleeves,Clothes&Shoes
Clothes,Socks Wmns'Fitness,Clothes&Shoes
Clothes,Swimming Trunks Struc,Clothes&Shoes
Clothes,2bwet 3 Cb Swimming Trunks,Clothes&Shoes
Clothes,2bwet 3 Solid Bikini,Clothes&Shoes
Clothes,Casual Genuine Polo-Shirt,Clothes&Shoes
Clothes,Casual Genuine Tee,Clothes&Shoes
Clothes,Casual Logo Men's Sweatshirt,Clothes&Shoes
Clothes,Casual Sport Shorts,Clothes&Shoes
Clothes,Casual.st.polo Long-sleeved Polo-shirt,Clothes&Shoes
Clothes,Comp. Women's Sleeveless Polo,Clothes&Shoes
Clothes,Dima 2-Layer Men's Suit,Clothes&Shoes
Clothes,Essence.baseball Cap,Clothes&Shoes
Clothes,Essence.cap Men's Bag,Clothes&Shoes
Clothes,Essential Suit 2 Swim Suit,Clothes&Shoes
Clothes,Essential Trunk 2 Swimming Trunks,Clothes&Shoes
Clothes,Kaitum Women's Swim Suit,Clothes&Shoes
Clothes,Mm Daypouch Shoulder Bag,Clothes&Shoes
Clothes,Mns.jacket Jacket,Clothes&Shoes
Clothes,Mns.long Tights,Clothes&Shoes
Clothes,Ottis Pes Men's Pants,Clothes&Shoes
Clothes,Outfit Women's Shirt,Clothes&Shoes
Clothes,Pine Sweat with Hood,Clothes&Shoes
Clothes,Quali Jacket with Hood,Clothes&Shoes
Clothes,Quali Sweatpant,Clothes&Shoes
Clothes,Quali Sweatshirt,Clothes&Shoes
Clothes,Sherpa Pes Shiny Cotton,Clothes&Shoes
Clothes,Short Women's Tights,Clothes&Shoes
Clothes,Stars Swim Suit,Clothes&Shoes
Clothes,Tims Shorts,Clothes&Shoes
Clothes,Tracker Fitness Stockings,Clothes&Shoes
Clothes,Brafit Swim Tights,Clothes&Shoes
Clothes,Jogging Pants  Men's Tracking Pants w/Small L,Clothes&Shoes
Clothes,N.d.gear Basic T-Shirt,Clothes&Shoes
Clothes,N.d.gear Cap,Clothes&Shoes
Golf,Ball Bag,Sports
Golf,Red/White/Black Staff 9 Bag,Sports
Golf,Tee Holder,Sports
Golf,Bb Softspikes - Xp 22-pack,Sports
Golf,Bretagne Performance Tg Men's Golf Shoes L.,Sports
Golf,"Bretagne Soft-Tech Men's Glove, left",Sports
Golf,"Bretagne St2 Men's Golf Glove, left",Sports
Golf,Bretagne Stabilites 2000 Goretex Shoes,Sports
Golf,Bretagne Stabilities Tg Men's Golf Shoes,Sports
Golf,Bretagne Stabilities Women's Golf Shoes,Sports
Golf,Carolina,Sports
Golf,Carolina II,Sports
Golf,Donald Plush Headcover,Sports
Golf,Expert Men's Firesole Driver,Sports
Golf,Extreme Distance 90 3-pack,Sports
Golf,Grandslam Staff Fs Copper Insert Putter,Sports
Golf,Grandslam Staff Grip Llh Golf Gloves,Sports
Golf,Grandslam Staff Tour Mhl Golf Gloves,Sports
Golf,Hi-fly Intimidator Ti R80/10,Sports
Golf,Hi-fly Intrepid Stand 8  Black,Sports
Golf,Hi-fly Staff Towel Blue/Black,Sports
Golf,Hi-fly Tour Advance Flex Steel,Sports
Golf,"Men's.m Men's Winter Gloves, Medium",Sports
Golf,Normal Standard,Sports
Golf,Precision Jack 309 Lh Balata,Sports
Golf,Proplay Executive Bi-Metal Graphite,Sports
Golf,Proplay Men's Tour Force Lp 7-Wood,Sports
Golf,Proplay Men's Tour Force Lp Driver,Sports
Golf,Proplay Men's Tour Force Ti 5w,Sports
Golf,Proplay Stand Black,Sports
Golf,Proplay Women's Tour Force 7w,Sports
Golf,Rosefinch Cart 8 1/2  Black,Sports
Golf,Rubby Men's Golf Shoes w/Goretex,Sports
Golf,Rubby Men's Golf Shoes w/Goretex Plain Toe,Sports
Golf,Rubby Women's Golf Shoes w/Gore-Tex,Sports
Golf,Score Counter Scoreboard De Luxe,Sports
Golf,Tee18 Ascot Chipper,Sports
Golf,Tee18 Troon 7  Black,Sports
Golf,"White 90,Top.Flite Strata Tour 3-pack",Sports
Golf,Golf Polo(1/400),Sports
Golf,Golf Windstopper,Sports
Golf,Master Golf Rain Suit,Sports
Golf,Tek Cap,Sports
Golf,Big Boss Houston Pants,Sports
Golf,Bogie Golf Fleece with small Zipper,Sports
Golf,Eagle 5 Pocket Pants with Stretch,Sports
Golf,Eagle Pants with Cross Pocket,Sports
Golf,Eagle Plain Cap,Sports
Golf,Eagle Polo-Shirt Interlock,Sports
Golf,Eagle Windstopper Knit Neck,Sports
Golf,Eagle Windstopper Sweat Neck,Sports
Golf,Hi-fly Staff Rain Suit,Sports
Golf,Hi-fly Strata Cap Offwhite/Green,Sports
Golf,Release Golf Sweatshirt w/Logo(1/100),Sports
Golf,Top (1/100),Sports
Golf,Wind Proof Windstopper Merino/Acryl,Sports
Indoor Sports,Abdomen Shaper,Sports
Indoor Sports,Fitness Dumbbell Foam 0.90,Sports
Indoor Sports,Letour Heart Bike,Sports
Indoor Sports,Letour Trimag Bike,Sports
Indoor Sports,Weight  5.0 Kg,Sports
Indoor Sports,Wrist Weight 1.10 Kg,Sports
Indoor Sports,Wrist Weight  2.25 Kg,Sports
Indoor Sports,Blues Jazz Pants Suplex,Sports
Indoor Sports,Cougar Fleece Jacket with Zipper,Sports
Indoor Sports,Cougar Windbreaker Vest,Sports
Indoor Sports,Men's Summer Shorts,Sports
Indoor Sports,Top Men's Goretex Ski Pants,Sports
Indoor Sports,Top Men's R&D Ultimate Jacket,Sports
Indoor Sports,Top Men's Retro T-Neck,Sports
Indoor Sports,Top R&D Long Jacket,Sports
Racket Sports,Bat 5-Ply,Sports
Racket Sports,Sledgehammer 120 Ph Black,Sports
Racket Sports,Aftm 95 Vf Long Bg-65 White,Sports
Racket Sports,Bag  Tit.Weekend,Sports
Racket Sports,Grandslam Ultra Power Tennisketcher,Sports
Racket Sports,"Memhis 350,Yellow Medium, 6-pack tube",Sports
Racket Sports,Smasher Rd Ti 70 Tennis Racket,Sports
Racket Sports,Smasher Super Rq Ti 350 Tennis Racket,Sports
Racket Sports,Smasher Super Rq Ti 700 Long Tennis,Sports
Racket Sports,Smasher Tg 70 Tennis String Roll,Sports
Racket Sports,Anthony Women's Tennis Cable Vest,Sports
Racket Sports,Smasher Polo-Shirt w/V-Neck,Sports
Racket Sports,Smasher Shorts,Sports
Racket Sports,Smasher Tights,Sports
Running - Jogging,Pants N,Sports
Running - Jogging,A-team Pants Taffeta,Sports
Running - Jogging,"A-team Sweat Round Neck, Small Logo",Sports
Running - Jogging,"Men's Sweat Pants without Rib, Small Logo",Sports
Running - Jogging,Men's Sweatshirt w/Hood Big Logo,Sports
Running - Jogging,Sweatshirt Women's Sweatshirt with O-Neck,Sports
Running - Jogging,Triffy Jacket,Sports
Running - Jogging,Triffy Logo T-Shirt with V-Neck,Sports
Running - Jogging,"Woman Sweat with Round Neck, Big Logo",Sports
Running - Jogging,Ypsilon Men's Sweatshirt w/Piping,Sports
Running - Jogging,Men's Singlet,Sports
Running - Jogging,Running Gloves,Sports
Running - Jogging,T-Shirt,Sports
Running - Jogging,Bike.Pants Short Biking Pants,Sports
Running - Jogging,Breath-brief Long Underpants XXL,Sports
Running - Jogging,Force Classic Men's Jacket,Sports
Running - Jogging,Force Micro Men's Suit,Sports
Running - Jogging,Force Short Sprinter Men's Tights,Sports
Running - Jogging,Force Technical Jacket w/Coolmax,Sports
Running - Jogging,Maxrun Running Tights,Sports
Running - Jogging,Original Running Pants,Sports
Running - Jogging,Polar Jacket,Sports
Running - Jogging,Stout Running Shorts,Sports
Running - Jogging,Stout Running Shorts Micro,Sports
Running - Jogging,Topline Delphi Race Shorts,Sports
Shoes,Cnv Plus Men's Off Court Tennis,Clothes&Shoes
Shoes,Atmosphere Imara Women's Running Shoes,Clothes&Shoes
Shoes,Atmosphere Shatter Mid Shoes,Clothes&Shoes
Shoes,Big Guy Men's Air Deschutz Viii Shoes,Clothes&Shoes
Shoes,Big Guy Men's Air Terra Reach Shoes,Clothes&Shoes
Shoes,Big Guy Men's Air Terra Sebec Shoes,Clothes&Shoes
Shoes,Big Guy Men's International Triax Shoes,Clothes&Shoes
Shoes,Big Guy Men's Multicourt Ii Shoes,Clothes&Shoes
Shoes,Woman's Air Amend Mid,Clothes&Shoes
Shoes,Woman's Air Converge Triax X,Clothes&Shoes
Shoes,Woman's Air Imara,Clothes&Shoes
Shoes,Woman's Air Rasp Suede,Clothes&Shoes
Shoes,Woman's Air Zoom Drive,Clothes&Shoes
Shoes,Woman's Air Zoom Sterling,Clothes&Shoes
Shoes,Dubby Low Men's Street Shoes,Clothes&Shoes
Shoes,Lulu Men's Street Shoes,Clothes&Shoes
Shoes,Pro Fit Gel Ds Trainer Women's Running Shoes,Clothes&Shoes
Shoes,Pro Fit Gel Gt 2030 Women's Running Shoes,Clothes&Shoes
Shoes,Soft Alta Plus Women's Indoor Shoes,Clothes&Shoes
Shoes,Soft Astro Men's Running Shoes,Clothes&Shoes
Shoes,Twain Men's Exit Low 2000 Street Shoes,Clothes&Shoes
Shoes,Twain Stf6 Gtx M Men's Trekking Boot,Clothes&Shoes
Shoes,Twain Women's Exit Iii Mid Cd X-Hiking Shoes,Clothes&Shoes
Shoes,Twain Women's Expresso X-Hiking Shoes,Clothes&Shoes
Shoes,Pytossage Bathing Sandal,Clothes&Shoes
Shoes,Liga Football Boot,Clothes&Shoes
Shoes,Men's Running Shoes Piedmmont,Clothes&Shoes
Shoes,Hilly Women's Crosstrainer Shoes,Clothes&Shoes
Shoes,Indoor Handbold Special Shoes,Clothes&Shoes
Shoes,Mns.raptor Precision Sg Football,Clothes&Shoes
Shoes,South Peak Men's Running Shoes,Clothes&Shoes
Shoes,Torino Men's Leather Adventure Shoes,Clothes&Shoes
Shoes,Hardcore Junior/Women's Street Shoes Large,Clothes&Shoes
Shoes,Hardcore Men's Street Shoes Large,Clothes&Shoes
Swim Sports,"Goggles, Assorted Colours",Sports
Swim Sports,Swim Suit Fabulo,Sports
Swim Sports,Swim Suit Laurel,Sports
Swim Sports,Sharky Swimming Trunks,Sports
Swim Sports,Sunfit Luffa Bikini,Sports
Swim Sports,Milan Swimming Trunks,Sports
Swim Sports,Pew Swimming Trunks,Sports
Team Sports,Armour L,Sports
Team Sports,Armour XL,Sports
Team Sports,Football - Helmet M,Sports
Team Sports,Football - Helmet Pro XL,Sports
Team Sports,Football - Helmet S,Sports
Team Sports,Football - Helmet XL,Sports
Team Sports,Football Super Bowl,Sports
Team Sports,Baseball Orange Small,Sports
Team Sports,Baseball White Small,Sports
Team Sports,Bat - Home Run M,Sports
Team Sports,Bat - Home Run S,Sports
Team Sports,Helmet L,Sports
Team Sports,Helmet M,Sports
Team Sports,Helmet XL,Sports
Team Sports,Bat - Large,Sports
Team Sports,Basket Ball Pro,Sports
Team Sports,Stephens Shirt,Sports
Team Sports,Red Cap,Sports
Team Sports,Red Scarf,Sports
Team Sports,Fga Home Shorts,Sports
Team Sports,Norwood Player Shirt,Sports
Team Sports,Prosoccer Away Shirt,Sports
Team Sports,Soccer Fan Football Player Shirt,Sports
Winter Sports,Additive Women's Ski Pants Vent Air,Sports
Winter Sports,Garbo Fleece Jacket,Sports
Winter Sports,Helmsdale Ski Jacket,Sports
Winter Sports,Helmsdale Ski Pants,Sports
Winter Sports,Mayday Soul Pro New Tech Ski Jacket,Sports
Winter Sports,Massif Bandit Ski Parcel Axial,Sports
Winter Sports,"Twain X-Scream 7.9 Ski,Sq 750 Dri",Sports
Winter Sports,Amber Cc,Sports
Winter Sports,Black Morphe,Sports
Winter Sports,"C.A.M.,Bone",Sports
Winter Sports,Cayenne Red,Sports
Winter Sports,"Ii Pmt,Bone",Sports
Winter Sports,"Regulator,Stopsign",Sports
Winter Sports,Shine Black PRO,Sports
Winter Sports,Coolman Pro 01 Neon Yellow,Sports
Winter Sports,Top Equipe 07 Green,Sports
Winter Sports,Top Equipe 99 Black,Sports
;;;;
run;

data ORION.PRODUCT_DIM;
   attrib Product_ID length=8 label='Product ID' format=12.;
   attrib Product_Line length=$20 label='Product Line';
   attrib Product_Category length=$25 label='Product Category';
   attrib Product_Group length=$25 label='Product Group';
   attrib Product_Name length=$45 label='Product Name';
   attrib Supplier_Country length=$2 label='Supplier Country';
   attrib Supplier_Name length=$30 label='Supplier Name';
   attrib Supplier_ID length=8 label='Supplier ID' format=12.;

   infile datalines dsd;
   input
      Product_ID
      Product_Line
      Product_Category
      Product_Group
      Product_Name
      Supplier_Country
      Supplier_Name
      Supplier_ID
   ;
datalines4;
210200100009,Children,Children Sports,"A-Team, Kids","Kids Sweat Round Neck,Large Logo",US,A Team Sports,3298
210200100017,Children,Children Sports,"A-Team, Kids",Sweatshirt Children's O-Neck,US,A Team Sports,3298
210200200022,Children,Children Sports,"Bathing Suits, Kids",Sunfit Slow Swimming Trunks,US,Nautlius SportsWear Inc,6153
210200200023,Children,Children Sports,"Bathing Suits, Kids",Sunfit Stockton Swimming Trunks Jr.,US,Nautlius SportsWear Inc,6153
210200300006,Children,Children Sports,"Eclipse, Kid's Clothes",Fleece Cuff Pant Kid'S,US,Eclipse Inc,1303
210200300007,Children,Children Sports,"Eclipse, Kid's Clothes",Hsc Dutch Player Shirt Junior,US,Eclipse Inc,1303
210200300052,Children,Children Sports,"Eclipse, Kid's Clothes",Tony's Cut & Sew T-Shirt,US,Eclipse Inc,1303
210200400020,Children,Children Sports,"Eclipse, Kid's Shoes",Kids Baby Edge Max Shoes,US,Eclipse Inc,1303
210200400070,Children,Children Sports,"Eclipse, Kid's Shoes",Tony's Children's Deschutz (Bg) Shoes,US,Eclipse Inc,1303
210200500002,Children,Children Sports,"Lucky Guy, Kids",Children's Mitten,US,AllSeasons Outdoor Clothing,772
210200500006,Children,Children Sports,"Lucky Guy, Kids","Rain Suit, Plain w/backpack Jacket",US,AllSeasons Outdoor Clothing,772
210200500007,Children,Children Sports,"Lucky Guy, Kids",Bozeman Rain & Storm Set,US,AllSeasons Outdoor Clothing,772
210200500016,Children,Children Sports,"Lucky Guy, Kids",Teen Profleece w/Zipper,US,AllSeasons Outdoor Clothing,772
210200600056,Children,Children Sports,"N.D. Gear, Kids",Butch T-Shirt with V-Neck,ES,Luna sastreria S.A.,4742
210200600067,Children,Children Sports,"N.D. Gear, Kids",Children's Knit Sweater,ES,Luna sastreria S.A.,4742
210200600085,Children,Children Sports,"N.D. Gear, Kids",Gordon Children's Tracking Pants,ES,Luna sastreria S.A.,4742
210200600112,Children,Children Sports,"N.D. Gear, Kids",O'my Children's T-Shirt with Logo,ES,Luna sastreria S.A.,4742
210200700016,Children,Children Sports,"Olssons, Kids",Strap Pants BBO,ES,Sportico,798
210200900004,Children,Children Sports,"Osprey, Kids",Kid Basic Tracking Suit,US,Triple Sportswear Inc,3664
210200900033,Children,Children Sports,"Osprey, Kids",Osprey France Nylon Shorts,US,Triple Sportswear Inc,3664
210200900038,Children,Children Sports,"Osprey, Kids",Osprey Girl's Tights,US,Triple Sportswear Inc,3664
210201000050,Children,Children Sports,Tracker Kid's Clothes,Kid Children's T-Shirt,US,3Top Sports,2963
210201000067,Children,Children Sports,Tracker Kid's Clothes,Logo Coord.Children's Sweatshirt,US,3Top Sports,2963
210201000126,Children,Children Sports,Tracker Kid's Clothes,Toddler Footwear Socks with Knobs,US,3Top Sports,2963
210201000198,Children,Children Sports,Tracker Kid's Clothes,South Peak Junior Training Shoes,US,3Top Sports,2963
210201000199,Children,Children Sports,Tracker Kid's Clothes,Starlite Baby Shoes,US,3Top Sports,2963
210201100004,Children,Children Sports,"Ypsilon, Kids",Ypsilon Children's Sweat w/Big Logo,FR,Ypsilon S.A.,14624
220100100019,Clothes & Shoes,Clothes,Eclipse Clothing,Fit Racing Cap,US,Eclipse Inc,1303
220100100025,Clothes & Shoes,Clothes,Eclipse Clothing,Knit Hat,US,Eclipse Inc,1303
220100100044,Clothes & Shoes,Clothes,Eclipse Clothing,Sports glasses Satin Alumin.,US,Eclipse Inc,1303
220100100101,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Chaser Poplin Pants,US,Eclipse Inc,1303
220100100105,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Clima Fit Jacket,US,Eclipse Inc,1303
220100100125,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Dri Fit Singlet,US,Eclipse Inc,1303
220100100153,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Fresh Soft Nylon Pants,US,Eclipse Inc,1303
220100100185,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Micro Fiber Full Zip Jacket,US,Eclipse Inc,1303
220100100189,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Micro Fibre Jacket,US,Eclipse Inc,1303
220100100192,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Micro Fibre Shorts XXL,US,Eclipse Inc,1303
220100100197,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Mid Layer Jacket,US,Eclipse Inc,1303
220100100235,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Running Shorts Dri.Fit,US,Eclipse Inc,1303
220100100241,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Santos Shorts Dri Fit,US,Eclipse Inc,1303
220100100272,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's T-Shirt,US,Eclipse Inc,1303
220100100273,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's T-Shirt Dri Fit,US,Eclipse Inc,1303
220100100298,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Twill Pants Golf,US,Eclipse Inc,1303
220100100304,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Victory Peach Poplin Pants,US,Eclipse Inc,1303
220100100309,Clothes & Shoes,Clothes,Eclipse Clothing,Big Guy Men's Woven Warm Up,US,Eclipse Inc,1303
220100100354,Clothes & Shoes,Clothes,Eclipse Clothing,Insu F.I.T Basic,US,Eclipse Inc,1303
220100100371,Clothes & Shoes,Clothes,Eclipse Clothing,Northern Fleece Scarf,US,Eclipse Inc,1303
220100100410,Clothes & Shoes,Clothes,Eclipse Clothing,Toto Tube Socks,US,Eclipse Inc,1303
220100100421,Clothes & Shoes,Clothes,Eclipse Clothing,Trois-fit Running Qtr Socks (Non-Cush),US,Eclipse Inc,1303
220100100513,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Deception Dress,US,Eclipse Inc,1303
220100100516,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Dri Fit Airborne Top,US,Eclipse Inc,1303
220100100523,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Dri-Fit Scoop Neck Bra,US,Eclipse Inc,1303
220100100530,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Emblished Work-Out Pants,US,Eclipse Inc,1303
220100100536,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Foxhole Jacket,US,Eclipse Inc,1303
220100100553,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Short Top Dri Fit,US,Eclipse Inc,1303
220100100568,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Micro Fibre Anorak,US,Eclipse Inc,1303
220100100581,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Out & Sew Airborn Top,US,Eclipse Inc,1303
220100100592,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Short Tights,US,Eclipse Inc,1303
220100100609,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Sweatshirt w/Hood,US,Eclipse Inc,1303
220100100617,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's T-Shirt w/Hood,US,Eclipse Inc,1303
220100100629,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Winter Tights,US,Eclipse Inc,1303
220100100631,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Work Out Pants Dri Fit,US,Eclipse Inc,1303
220100100635,Clothes & Shoes,Clothes,Eclipse Clothing,Woman's Woven Warm Up,US,Eclipse Inc,1303
220100200004,Clothes & Shoes,Clothes,Green Tomato,Green Lime Atletic Socks,US,Green Lime Sports Inc,18139
220100300001,Clothes & Shoes,Clothes,Knitwear,Fleece Jacket Compass,US,AllSeasons Outdoor Clothing,772
220100300008,Clothes & Shoes,Clothes,Knitwear,Dp Roller High-necked Knit,US,Mayday Inc,4646
220100300019,Clothes & Shoes,Clothes,Knitwear,Instyle Pullover Mid w/Small Zipper,US,AllSeasons Outdoor Clothing,772
220100300020,Clothes & Shoes,Clothes,Knitwear,Instyle T-Shirt,US,AllSeasons Outdoor Clothing,772
220100300025,Clothes & Shoes,Clothes,Knitwear,Lucky Knitwear Wool Sweater,US,AllSeasons Outdoor Clothing,772
220100300037,Clothes & Shoes,Clothes,Knitwear,Mayday Resque Fleece Pullover,US,Mayday Inc,4646
220100300042,Clothes & Shoes,Clothes,Knitwear,Truls Polar Fleece Cardigan,NO,Truls Sporting Goods,12869
220100400005,Clothes & Shoes,Clothes,LSF,Big Guy Men's Air Force 1 Sc,US,Eclipse Inc,1303
220100400022,Clothes & Shoes,Clothes,LSF,Ultra M803 Ng Men's Street Shoes,US,Ultra Sporting Goods Inc,5503
220100400023,Clothes & Shoes,Clothes,LSF,Ultra W802 All Terrain Women's Shoes,US,Ultra Sporting Goods Inc,5503
220100700002,Clothes & Shoes,Clothes,Orion,Dmx 10 Women's Aerobic Shoes,CA,Fuller Trading Co.,16733
220100700022,Clothes & Shoes,Clothes,Orion,Alexis Women's Classic Shoes,CA,Fuller Trading Co.,16733
220100700023,Clothes & Shoes,Clothes,Orion,Armadillo Road Dmx Men's Running Shoes,CA,Fuller Trading Co.,16733
220100700024,Clothes & Shoes,Clothes,Orion,Armadillo Road Dmx Women's Running Shoes,CA,Fuller Trading Co.,16733
220100700027,Clothes & Shoes,Clothes,Orion,Duration Women's Trainer Aerobic Shoes,CA,Fuller Trading Co.,16733
220100700042,Clothes & Shoes,Clothes,Orion,"Power Women's Dmx Wide, Walking Shoes",CA,Fuller Trading Co.,16733
220100700046,Clothes & Shoes,Clothes,Orion,Tcp 6 Men's Running Shoes,CA,Fuller Trading Co.,16733
220100700052,Clothes & Shoes,Clothes,Orion,Trooper Ii Dmx-2x Men's Walking Shoes,CA,Fuller Trading Co.,16733
220100800001,Clothes & Shoes,Clothes,Orion Clothing,Bra Top Wom.Fitn.Cl,CA,Fuller Trading Co.,16733
220100800009,Clothes & Shoes,Clothes,Orion Clothing,Peacock Pants,CA,Fuller Trading Co.,16733
220100800040,Clothes & Shoes,Clothes,Orion Clothing,Mick's Men's Cl.Tracksuit,CA,Fuller Trading Co.,16733
220100800071,Clothes & Shoes,Clothes,Orion Clothing,Tx Tribe Tank Top,CA,Fuller Trading Co.,16733
220100800096,Clothes & Shoes,Clothes,Orion Clothing,Zx Women's Dance Pants,CA,Fuller Trading Co.,16733
220100900006,Clothes & Shoes,Clothes,Osprey,Osprey Cabri Micro Suit,US,Triple Sportswear Inc,3664
220100900029,Clothes & Shoes,Clothes,Osprey,Osprey Men's King T-Shirt w/Small Logo,US,Triple Sportswear Inc,3664
220100900035,Clothes & Shoes,Clothes,Osprey,Osprey Shadow Indoor,US,Triple Sportswear Inc,3664
220101000002,Clothes & Shoes,Clothes,Shorts,Carribian Women's Jersey Shorts,US,A Team Sports,3298
220101200006,Clothes & Shoes,Clothes,Street Wear,Anthony Bork Maggan 3/4 Long Pique,US,Mayday Inc,4646
220101200020,Clothes & Shoes,Clothes,Street Wear,Tyfoon Flex Shorts,AU,Typhoon Clothing,11427
220101200025,Clothes & Shoes,Clothes,Street Wear,Tyfoon Ketch T-Shirt,AU,Typhoon Clothing,11427
220101200029,Clothes & Shoes,Clothes,Street Wear,Tyfoon Oliver Sweatshirt,AU,Typhoon Clothing,11427
220101300001,Clothes & Shoes,Clothes,T-Shirts,"T-Shirt, Short-sleeved, Big Logo",US,A Team Sports,3298
220101300012,Clothes & Shoes,Clothes,T-Shirts,Men's T-Shirt Small Logo,US,A Team Sports,3298
220101300017,Clothes & Shoes,Clothes,T-Shirts,Toncot Beefy-T Emb T-Shirt,US,A Team Sports,3298
220101400004,Clothes & Shoes,Clothes,Tracker Clothes,Badminton Cotton,US,3Top Sports,2963
220101400017,Clothes & Shoes,Clothes,Tracker Clothes,Men's Cap,US,3Top Sports,2963
220101400018,Clothes & Shoes,Clothes,Tracker Clothes,Men's Running Tee Short Sleeves,US,3Top Sports,2963
220101400032,Clothes & Shoes,Clothes,Tracker Clothes,Socks Wmns'Fitness,US,Eclipse Inc,1303
220101400047,Clothes & Shoes,Clothes,Tracker Clothes,Swimming Trunks Struc,US,3Top Sports,2963
220101400060,Clothes & Shoes,Clothes,Tracker Clothes,2bwet 3 Cb Swimming Trunks,US,3Top Sports,2963
220101400061,Clothes & Shoes,Clothes,Tracker Clothes,2bwet 3 Solid Bikini,US,3Top Sports,2963
220101400088,Clothes & Shoes,Clothes,Tracker Clothes,Casual Genuine Polo-Shirt,US,3Top Sports,2963
220101400091,Clothes & Shoes,Clothes,Tracker Clothes,Casual Genuine Tee,US,3Top Sports,2963
220101400092,Clothes & Shoes,Clothes,Tracker Clothes,Casual Logo Men's Sweatshirt,US,3Top Sports,2963
220101400098,Clothes & Shoes,Clothes,Tracker Clothes,Casual Sport Shorts,US,3Top Sports,2963
220101400117,Clothes & Shoes,Clothes,Tracker Clothes,Casual.st.polo Long-sleeved Polo-shirt,US,3Top Sports,2963
220101400130,Clothes & Shoes,Clothes,Tracker Clothes,Comp. Women's Sleeveless Polo,US,3Top Sports,2963
220101400138,Clothes & Shoes,Clothes,Tracker Clothes,Dima 2-Layer Men's Suit,US,3Top Sports,2963
220101400145,Clothes & Shoes,Clothes,Tracker Clothes,Essence.baseball Cap,US,3Top Sports,2963
220101400148,Clothes & Shoes,Clothes,Tracker Clothes,Essence.cap Men's Bag,US,3Top Sports,2963
220101400150,Clothes & Shoes,Clothes,Tracker Clothes,Essential Suit 2 Swim Suit,US,3Top Sports,2963
220101400152,Clothes & Shoes,Clothes,Tracker Clothes,Essential Trunk 2 Swimming Trunks,US,3Top Sports,2963
220101400201,Clothes & Shoes,Clothes,Tracker Clothes,Kaitum Women's Swim Suit,US,3Top Sports,2963
220101400216,Clothes & Shoes,Clothes,Tracker Clothes,Mm Daypouch Shoulder Bag,US,3Top Sports,2963
220101400237,Clothes & Shoes,Clothes,Tracker Clothes,Mns.jacket Jacket,US,3Top Sports,2963
220101400238,Clothes & Shoes,Clothes,Tracker Clothes,Mns.long Tights,US,3Top Sports,2963
220101400265,Clothes & Shoes,Clothes,Tracker Clothes,Ottis Pes Men's Pants,US,3Top Sports,2963
220101400269,Clothes & Shoes,Clothes,Tracker Clothes,Outfit Women's Shirt,US,3Top Sports,2963
220101400276,Clothes & Shoes,Clothes,Tracker Clothes,Pine Sweat with Hood,US,3Top Sports,2963
220101400285,Clothes & Shoes,Clothes,Tracker Clothes,Quali Jacket with Hood,US,3Top Sports,2963
220101400289,Clothes & Shoes,Clothes,Tracker Clothes,Quali Sweatpant,US,3Top Sports,2963
220101400290,Clothes & Shoes,Clothes,Tracker Clothes,Quali Sweatshirt,US,3Top Sports,2963
220101400306,Clothes & Shoes,Clothes,Tracker Clothes,Sherpa Pes Shiny Cotton,US,3Top Sports,2963
220101400310,Clothes & Shoes,Clothes,Tracker Clothes,Short Women's Tights,US,3Top Sports,2963
220101400328,Clothes & Shoes,Clothes,Tracker Clothes,Stars Swim Suit,US,3Top Sports,2963
220101400339,Clothes & Shoes,Clothes,Tracker Clothes,Tims Shorts,US,3Top Sports,2963
220101400349,Clothes & Shoes,Clothes,Tracker Clothes,Tracker Fitness Stockings,US,3Top Sports,2963
220101400363,Clothes & Shoes,Clothes,Tracker Clothes,Brafit Swim Tights,ES,Luna sastreria S.A.,4742
220101400373,Clothes & Shoes,Clothes,Tracker Clothes,Jogging Pants  Men's Tracking Pants w/Small L,GB,Greenline Sports Ltd,14682
220101400385,Clothes & Shoes,Clothes,Tracker Clothes,N.d.gear Basic T-Shirt,GB,Greenline Sports Ltd,14682
220101400387,Clothes & Shoes,Clothes,Tracker Clothes,N.d.gear Cap,GB,Greenline Sports Ltd,14682
220200100002,Clothes & Shoes,Shoes,Eclipse Shoes,Cnv Plus Men's Off Court Tennis,US,Eclipse Inc,1303
220200100009,Clothes & Shoes,Shoes,Eclipse Shoes,Atmosphere Imara Women's Running Shoes,US,Eclipse Inc,1303
220200100012,Clothes & Shoes,Shoes,Eclipse Shoes,Atmosphere Shatter Mid Shoes,US,Eclipse Inc,1303
220200100035,Clothes & Shoes,Shoes,Eclipse Shoes,Big Guy Men's Air Deschutz Viii Shoes,US,Eclipse Inc,1303
220200100090,Clothes & Shoes,Shoes,Eclipse Shoes,Big Guy Men's Air Terra Reach Shoes,US,Eclipse Inc,1303
220200100092,Clothes & Shoes,Shoes,Eclipse Shoes,Big Guy Men's Air Terra Sebec Shoes,US,Eclipse Inc,1303
220200100129,Clothes & Shoes,Shoes,Eclipse Shoes,Big Guy Men's International Triax Shoes,US,Eclipse Inc,1303
220200100137,Clothes & Shoes,Shoes,Eclipse Shoes,Big Guy Men's Multicourt Ii Shoes,US,Eclipse Inc,1303
220200100171,Clothes & Shoes,Shoes,Eclipse Shoes,Woman's Air Amend Mid,US,Eclipse Inc,1303
220200100179,Clothes & Shoes,Shoes,Eclipse Shoes,Woman's Air Converge Triax X,US,Eclipse Inc,1303
220200100190,Clothes & Shoes,Shoes,Eclipse Shoes,Woman's Air Imara,US,Eclipse Inc,1303
220200100202,Clothes & Shoes,Shoes,Eclipse Shoes,Woman's Air Rasp Suede,US,Eclipse Inc,1303
220200100226,Clothes & Shoes,Shoes,Eclipse Shoes,Woman's Air Zoom Drive,US,Eclipse Inc,1303
220200100229,Clothes & Shoes,Shoes,Eclipse Shoes,Woman's Air Zoom Sterling,US,Eclipse Inc,1303
220200200014,Clothes & Shoes,Shoes,Shoes,Dubby Low Men's Street Shoes,SE,Petterson AB,109
220200200018,Clothes & Shoes,Shoes,Shoes,Lulu Men's Street Shoes,SE,Petterson AB,109
220200200022,Clothes & Shoes,Shoes,Shoes,Pro Fit Gel Ds Trainer Women's Running Shoes,US,Pro Sportswear Inc,1747
220200200024,Clothes & Shoes,Shoes,Shoes,Pro Fit Gel Gt 2030 Women's Running Shoes,US,Pro Sportswear Inc,1747
220200200035,Clothes & Shoes,Shoes,Shoes,Soft Alta Plus Women's Indoor Shoes,US,Pro Sportswear Inc,1747
220200200036,Clothes & Shoes,Shoes,Shoes,Soft Astro Men's Running Shoes,US,Pro Sportswear Inc,1747
220200200071,Clothes & Shoes,Shoes,Shoes,Twain Men's Exit Low 2000 Street Shoes,US,Twain Inc,13198
220200200073,Clothes & Shoes,Shoes,Shoes,Twain Stf6 Gtx M Men's Trekking Boot,US,Twain Inc,13198
220200200077,Clothes & Shoes,Shoes,Shoes,Twain Women's Exit Iii Mid Cd X-Hiking Shoes,US,Twain Inc,13198
220200200079,Clothes & Shoes,Shoes,Shoes,Twain Women's Expresso X-Hiking Shoes,US,Twain Inc,13198
220200300002,Clothes & Shoes,Shoes,Tracker Shoes,Pytossage Bathing Sandal,US,3Top Sports,2963
220200300005,Clothes & Shoes,Shoes,Tracker Shoes,Liga Football Boot,US,3Top Sports,2963
220200300015,Clothes & Shoes,Shoes,Tracker Shoes,Men's Running Shoes Piedmmont,US,3Top Sports,2963
220200300079,Clothes & Shoes,Shoes,Tracker Shoes,Hilly Women's Crosstrainer Shoes,US,3Top Sports,2963
220200300082,Clothes & Shoes,Shoes,Tracker Shoes,Indoor Handbold Special Shoes,US,3Top Sports,2963
220200300096,Clothes & Shoes,Shoes,Tracker Shoes,Mns.raptor Precision Sg Football,US,3Top Sports,2963
220200300116,Clothes & Shoes,Shoes,Tracker Shoes,South Peak Men's Running Shoes,US,3Top Sports,2963
220200300129,Clothes & Shoes,Shoes,Tracker Shoes,Torino Men's Leather Adventure Shoes,US,3Top Sports,2963
220200300154,Clothes & Shoes,Shoes,Tracker Shoes,Hardcore Junior/Women's Street Shoes Large,GB,Greenline Sports Ltd,14682
220200300157,Clothes & Shoes,Shoes,Tracker Shoes,Hardcore Men's Street Shoes Large,GB,Greenline Sports Ltd,14682
230100100006,Outdoors,Outdoors,Anoraks & Parkas,Jacket Nome,ES,Luna sastreria S.A.,4742
230100100013,Outdoors,Outdoors,Anoraks & Parkas,Jacket with Removable Fleece,US,AllSeasons Outdoor Clothing,772
230100100015,Outdoors,Outdoors,Anoraks & Parkas,Men's Jacket Caians,NO,Scandinavian Clothing A/S,50
230100100017,Outdoors,Outdoors,Anoraks & Parkas,Men's Jacket Rem,NO,Scandinavian Clothing A/S,50
230100100018,Outdoors,Outdoors,Anoraks & Parkas,Men's Jacket Sandy,ES,Luna sastreria S.A.,4742
230100100025,Outdoors,Outdoors,Anoraks & Parkas,Women's Shorts,NO,Scandinavian Clothing A/S,50
230100100028,Outdoors,Outdoors,Anoraks & Parkas,4men Men's Polar Down Jacket,US,AllSeasons Outdoor Clothing,772
230100100033,Outdoors,Outdoors,Anoraks & Parkas,Big Guy Men's Packable Hiking Shorts,US,Miller Trading Inc,15218
230100100045,Outdoors,Outdoors,Anoraks & Parkas,Duwall Pants,US,AllSeasons Outdoor Clothing,772
230100100051,Outdoors,Outdoors,Anoraks & Parkas,Lucky Voss Jacket,US,AllSeasons Outdoor Clothing,772
230100100053,Outdoors,Outdoors,Anoraks & Parkas,Monster Men's Pants with Zipper,NO,Scandinavian Clothing A/S,50
230100100062,Outdoors,Outdoors,Anoraks & Parkas,Topper Pants,US,AllSeasons Outdoor Clothing,772
230100100063,Outdoors,Outdoors,Anoraks & Parkas,Tx Peak Parka,US,Miller Trading Inc,15218
230100200004,Outdoors,Outdoors,Backpacks,Black/Black,DK,Top Sports,755
230100200006,Outdoors,Outdoors,Backpacks,X-Large Bottlegreen/Black,DK,Top Sports,755
230100200019,Outdoors,Outdoors,Backpacks,Commanche Women's 6000 Q Backpack. Bark,DK,Top Sports,755
230100200022,Outdoors,Outdoors,Backpacks,Expedition Camp Duffle Medium Backpack,US,Miller Trading Inc,15218
230100200025,Outdoors,Outdoors,Backpacks,Feelgood 55-75 Litre Black Women's Backpack,AU,Toto Outdoor Gear,10692
230100200029,Outdoors,Outdoors,Backpacks,Jaguar 50-75 Liter Blue Women's Backpack,AU,Toto Outdoor Gear,10692
230100200043,Outdoors,Outdoors,Backpacks,Medium Black/Bark Backpack,DK,Top Sports,755
230100200047,Outdoors,Outdoors,Backpacks,Medium Gold Black/Gold Backpack,DK,Top Sports,755
230100200048,Outdoors,Outdoors,Backpacks,Medium Olive Olive/Black Backpack,DK,Top Sports,755
230100200054,Outdoors,Outdoors,Backpacks,Trekker 65 Royal Men's Backpack,AU,Toto Outdoor Gear,10692
230100200056,Outdoors,Outdoors,Backpacks,Victor Grey/Olive Women's Backpack,DK,Top Sports,755
230100200059,Outdoors,Outdoors,Backpacks,Deer Backpack,ES,Luna sastreria S.A.,4742
230100200066,Outdoors,Outdoors,Backpacks,Deer Waist Bag,ES,Luna sastreria S.A.,4742
230100200073,Outdoors,Outdoors,Backpacks,Hammock Sports Bag,ES,Luna sastreria S.A.,4742
230100200074,Outdoors,Outdoors,Backpacks,Sioux Men's Backpack 26 Litre.,US,Miller Trading Inc,15218
230100300006,Outdoors,Outdoors,Gloves & Mittens,Gloves Le Fly Mitten,PT,Magnifico Sports,1684
230100300010,Outdoors,Outdoors,Gloves & Mittens,Massif Dual Gloves,FR,Massif S.A.,13199
230100300013,Outdoors,Outdoors,Gloves & Mittens,Montana Adult Gloves,SE,Svensson Trading AB,6355
230100300023,Outdoors,Outdoors,Gloves & Mittens,Scania Unisex Gloves,SE,Svensson Trading AB,6355
230100400007,Outdoors,Outdoors,Knitted Accessories,Breaker Commandos Cap,DK,Norsok A/S,4793
230100400010,Outdoors,Outdoors,Knitted Accessories,Breaker Frozen Husky Hat,DK,Norsok A/S,4793
230100400012,Outdoors,Outdoors,Knitted Accessories,Breaker Russia Cap,DK,Norsok A/S,4793
230100400025,Outdoors,Outdoors,Knitted Accessories,Mayday Serious Headband,US,Mayday Inc,4646
230100500004,Outdoors,Outdoors,Outdoor Gear,"Backpack Flag, 6,5x9 Cm.",GB,Prime Sports Ltd,316
230100500006,Outdoors,Outdoors,Outdoor Gear,Collapsible Water Can,GB,Prime Sports Ltd,316
230100500008,Outdoors,Outdoors,Outdoor Gear,Dome Tent Monodome Alu,GB,Prime Sports Ltd,316
230100500012,Outdoors,Outdoors,Outdoor Gear,Inflatable 3.5,GB,Prime Sports Ltd,316
230100500013,Outdoors,Outdoors,Outdoor Gear,Lamp with Battery Box,GB,Prime Sports Ltd,316
230100500016,Outdoors,Outdoors,Outdoor Gear,"Money Purse, Black",DK,Top Sports,755
230100500020,Outdoors,Outdoors,Outdoor Gear,Pocket Light with Crypton Bulb,GB,Prime Sports Ltd,316
230100500023,Outdoors,Outdoors,Outdoor Gear,Proofing Spray,GB,Prime Sports Ltd,316
230100500024,Outdoors,Outdoors,Outdoor Gear,"Small Belt Bag, Black",DK,Top Sports,755
230100500026,Outdoors,Outdoors,Outdoor Gear,Trekking Tent,GB,Prime Sports Ltd,316
230100500045,Outdoors,Outdoors,Outdoor Gear,Cup Picnic Mug 25 Cl.,GB,Prime Sports Ltd,316
230100500056,Outdoors,Outdoors,Outdoor Gear,Knife,US,KN Outdoor Trading Inc,4718
230100500058,Outdoors,Outdoors,Outdoor Gear,Mattress with 5 channels 196x72,GB,Prime Sports Ltd,316
230100500066,Outdoors,Outdoors,Outdoor Gear,Outback Spirits Kitchen,GB,Prime Sports Ltd,316
230100500068,Outdoors,Outdoors,Outdoor Gear,Plate Picnic Deep,GB,Prime Sports Ltd,316
230100500072,Outdoors,Outdoors,Outdoor Gear,Single Full Box Madras honeycomb-weave,GB,Prime Sports Ltd,316
230100500074,Outdoors,Outdoors,Outdoor Gear,"Tent Milano Tent,4 Persons, about 4.8",GB,Prime Sports Ltd,316
230100500077,Outdoors,Outdoors,Outdoor Gear,Jl Legacy Curig I.A.Jacket,US,AllSeasons Outdoor Clothing,772
230100500080,Outdoors,Outdoors,Outdoor Gear,Jl Rainlight Essential Pants,US,AllSeasons Outdoor Clothing,772
230100500081,Outdoors,Outdoors,Outdoor Gear,Lucky Tech Classic Rain Pants,US,AllSeasons Outdoor Clothing,772
230100500082,Outdoors,Outdoors,Outdoor Gear,Lucky Tech Intergal Wp/B Rain Pants,US,AllSeasons Outdoor Clothing,772
230100500087,Outdoors,Outdoors,Outdoor Gear,Mayday Qd Zip Pants,US,Mayday Inc,4646
230100500091,Outdoors,Outdoors,Outdoor Gear,Mayday Soul Ht Jacket,US,Mayday Inc,4646
230100500092,Outdoors,Outdoors,Outdoor Gear,Mayday Sports Pullover,US,Mayday Inc,4646
230100500093,Outdoors,Outdoors,Outdoor Gear,Mayday W'S Sports Pullover,US,Mayday Inc,4646
230100500094,Outdoors,Outdoors,Outdoor Gear,"Men's Pants, Basic",US,Mayday Inc,4646
230100500095,Outdoors,Outdoors,Outdoor Gear,Men's Sports Pullover,US,Mayday Inc,4646
230100500096,Outdoors,Outdoors,Outdoor Gear,Rain Jacket,US,AllSeasons Outdoor Clothing,772
230100500101,Outdoors,Outdoors,Outdoor Gear,Ultra Ht Lightning Set,US,AllSeasons Outdoor Clothing,772
230100600003,Outdoors,Outdoors,Sleepingbags,"Sheet Sleeping Bag, Red",GB,Outback Outfitters Ltd,16422
230100600005,Outdoors,Outdoors,Sleepingbags,"Basic 10, Left , Yellow/Black",DK,Top Sports,755
230100600015,Outdoors,Outdoors,Sleepingbags,"Expedition Zero,Medium,Left,Charcoal",DK,Top Sports,755
230100600016,Outdoors,Outdoors,Sleepingbags,"Expedition Zero,Medium,Right,Charcoal",DK,Top Sports,755
230100600017,Outdoors,Outdoors,Sleepingbags,"Expedition Zero,Small,Left,Charcoal",DK,Top Sports,755
230100600018,Outdoors,Outdoors,Sleepingbags,"Expedition Zero,Small,Right,Charcoal",DK,Top Sports,755
230100600022,Outdoors,Outdoors,Sleepingbags,"Expedition10,Medium,Right,Blue Ribbon",DK,Top Sports,755
230100600023,Outdoors,Outdoors,Sleepingbags,"Expedition 10,Small,Left,Blue Ribbon",DK,Top Sports,755
230100600024,Outdoors,Outdoors,Sleepingbags,"Expedition 10,Small,Right,Blue Ribbon",DK,Top Sports,755
230100600026,Outdoors,Outdoors,Sleepingbags,"Expedition 20,Large,Right,Forestgreen",DK,Top Sports,755
230100600028,Outdoors,Outdoors,Sleepingbags,"Expedition 20,Medium,Right,Forestgreen",DK,Top Sports,755
230100600030,Outdoors,Outdoors,Sleepingbags,"Outback Sleeping Bag, Large,Left,Blue/Black",DK,Top Sports,755
230100600031,Outdoors,Outdoors,Sleepingbags,"Outback Sleeping Bag, Large,Right, Blue/Black",DK,Top Sports,755
230100600035,Outdoors,Outdoors,Sleepingbags,"Polar Bear Sleeping mat, Olive Green",GB,Outback Outfitters Ltd,16422
230100600036,Outdoors,Outdoors,Sleepingbags,Tent Summer 195 Twin Sleeping Bag,GB,Outback Outfitters Ltd,16422
230100600038,Outdoors,Outdoors,Sleepingbags,Tipee Summer Sleeping Bag,GB,Outback Outfitters Ltd,16422
230100600039,Outdoors,Outdoors,Sleepingbags,Tipee Twin Blue/Orange,GB,Outback Outfitters Ltd,16422
230100700002,Outdoors,Outdoors,Tents,Comfort Shelter,GB,Outback Outfitters Ltd,16422
230100700004,Outdoors,Outdoors,Tents,Expedition Dome 3,GB,Outback Outfitters Ltd,16422
230100700008,Outdoors,Outdoors,Tents,Family Holiday 4,SE,Petterson AB,109
230100700009,Outdoors,Outdoors,Tents,Family Holiday 6,SE,Petterson AB,109
230100700011,Outdoors,Outdoors,Tents,Hurricane 4,SE,Petterson AB,109
240100100029,Sports,Assorted Sports Articles,Assorted Sports articles,Buzz Saw,CA,CrystalClear Optics Inc,16814
240100100031,Sports,Assorted Sports Articles,Assorted Sports articles,Capsy Hood,US,Nautlius SportsWear Inc,6153
240100100063,Sports,Assorted Sports Articles,Assorted Sports articles,Grey Met.,CA,CrystalClear Optics Inc,16814
240100100065,Sports,Assorted Sports Articles,Assorted Sports articles,Grey,CA,CrystalClear Optics Inc,16814
240100100148,Sports,Assorted Sports Articles,Assorted Sports articles,Wood Box for 6 Balls,GB,Royal Darts Ltd,4514
240100100159,Sports,Assorted Sports Articles,Assorted Sports articles,A-team Smoothsport Bra,US,A Team Sports,3298
240100100184,Sports,Assorted Sports Articles,Assorted Sports articles,Barret 2.12 Men's Softboot,US,Roll-Over Inc,3815
240100100186,Sports,Assorted Sports Articles,Assorted Sports articles,Barret 3.1 Women's Softboot,US,Roll-Over Inc,3815
240100100232,Sports,Assorted Sports Articles,Assorted Sports articles,Dartsharpener Key ring,GB,Royal Darts Ltd,4514
240100100305,Sports,Assorted Sports Articles,Assorted Sports articles,Hiclass Mundo 78a 36x72mm Pink-Swirl,US,Roll-Over Inc,3815
240100100312,Sports,Assorted Sports Articles,Assorted Sports articles,Hot Mini Backboard Bulls,NL,Van Dammeren International,2995
240100100354,Sports,Assorted Sports Articles,Assorted Sports articles,Mk Splinter 66 5m 88a Pea.,PT,Magnifico Sports,1684
240100100365,Sports,Assorted Sports Articles,Assorted Sports articles,Northern Coach,GB,EA Sports Limited,12283
240100100366,Sports,Assorted Sports Articles,Assorted Sports articles,Northern Liquid Belt with Bottle,GB,EA Sports Limited,12283
240100100403,Sports,Assorted Sports Articles,Assorted Sports articles,Proskater Viablade Tx Women's Fitness,US,Roll-Over Inc,3815
240100100410,Sports,Assorted Sports Articles,Assorted Sports articles,Prosoccer  Club Football 4/32 (Replica) Synth,US,Teamsports Inc,5810
240100100433,Sports,Assorted Sports Articles,Assorted Sports articles,Shoelace White 150 Cm,US,Teamsports Inc,5810
240100100434,Sports,Assorted Sports Articles,Assorted Sports articles,Shoeshine Black,CA,CrystalClear Optics Inc,16814
240100100463,Sports,Assorted Sports Articles,Assorted Sports articles,Sparkle Spray Orange,CA,CrystalClear Optics Inc,16814
240100100477,Sports,Assorted Sports Articles,Assorted Sports articles,Stout Brass 18 Gram,GB,Royal Darts Ltd,4514
240100100508,Sports,Assorted Sports Articles,Assorted Sports articles,Top Elite Kit Small,US,Roll-Over Inc,3815
240100100535,Sports,Assorted Sports Articles,Assorted Sports articles,Victor 76 76mm Optics Blue,PT,Magnifico Sports,1684
240100100581,Sports,Assorted Sports Articles,Assorted Sports articles,Eliza T-Shirt,ES,Luna sastreria S.A.,4742
240100100605,Sports,Assorted Sports Articles,Assorted Sports articles,Fred T-Shirt,ES,Luna sastreria S.A.,4742
240100100610,Sports,Assorted Sports Articles,Assorted Sports articles,Goodtime Bag,ES,Luna sastreria S.A.,4742
240100100615,Sports,Assorted Sports Articles,Assorted Sports articles,Goodtime Toilet Bag,ES,Luna sastreria S.A.,4742
240100100646,Sports,Assorted Sports Articles,Assorted Sports articles,Lyon Men's Jacket,ES,Luna sastreria S.A.,4742
240100100654,Sports,Assorted Sports Articles,Assorted Sports articles,Montevideo Men's Shorts,ES,Luna sastreria S.A.,4742
240100100665,Sports,Assorted Sports Articles,Assorted Sports articles,Pool Shorts,ES,Luna sastreria S.A.,4742
240100100672,Sports,Assorted Sports Articles,Assorted Sports articles,Ribstop Jacket,ES,Luna sastreria S.A.,4742
240100100676,Sports,Assorted Sports Articles,Assorted Sports articles,Roth T-Shirt,ES,Luna sastreria S.A.,4742
240100100679,Sports,Assorted Sports Articles,Assorted Sports articles,Saturn Big Bag,ES,Luna sastreria S.A.,4742
240100100690,Sports,Assorted Sports Articles,Assorted Sports articles,Shirt Termir,ES,Luna sastreria S.A.,4742
240100100703,Sports,Assorted Sports Articles,Assorted Sports articles,Stream Sweatshirt with Tube,ES,Luna sastreria S.A.,4742
240100100714,Sports,Assorted Sports Articles,Assorted Sports articles,Tybor Sweatshirt with Hood,ES,Luna sastreria S.A.,4742
240100100734,Sports,Assorted Sports Articles,Assorted Sports articles,Wyoming Men's Socks,ES,Luna sastreria S.A.,4742
240100100737,Sports,Assorted Sports Articles,Assorted Sports articles,Wyoming Men's T-Shirt with V-Neck,ES,Luna sastreria S.A.,4742
240100200001,Sports,Assorted Sports Articles,Darts,Aim4it 16 Gram Softtip Pil,GB,Royal Darts Ltd,4514
240100200004,Sports,Assorted Sports Articles,Darts,Aim4it 80% Tungsten 22 Gram,GB,Royal Darts Ltd,4514
240100200014,Sports,Assorted Sports Articles,Darts,Pacific 95% 23 Gram,GB,Royal Darts Ltd,4514
240100400004,Sports,Assorted Sports Articles,Skates,Children's Roller Skates,PT,Magnifico Sports,1684
240100400005,Sports,Assorted Sports Articles,Skates,Cool Fit Men's Roller Skates,US,Twain Inc,13198
240100400006,Sports,Assorted Sports Articles,Skates,Cool Fit Women's Roller Skates,US,Twain Inc,13198
240100400037,Sports,Assorted Sports Articles,Skates,N.d.gear Roller Skates Ff80 80 millimetre78a,PT,Magnifico Sports,1684
240100400043,Sports,Assorted Sports Articles,Skates,Perfect Fit Men's  Roller Skates,US,Twain Inc,13198
240100400044,Sports,Assorted Sports Articles,Skates,Perfect Fit Men's Roller Skates,US,Twain Inc,13198
240100400046,Sports,Assorted Sports Articles,Skates,Perfect Fit Men's Stunt Skates,US,Twain Inc,13198
240100400049,Sports,Assorted Sports Articles,Skates,Perfect Fit Women's Roller Skates Custom,US,Twain Inc,13198
240100400058,Sports,Assorted Sports Articles,Skates,Pro-roll Hot Rod Roller Skates,PT,Magnifico Sports,1684
240100400062,Sports,Assorted Sports Articles,Skates,Pro-roll Lazer Roller Skates,PT,Magnifico Sports,1684
240100400069,Sports,Assorted Sports Articles,Skates,Pro-roll Panga Roller Skates,PT,Magnifico Sports,1684
240100400070,Sports,Assorted Sports Articles,Skates,Pro-roll Sabotage-Rp  Roller Skates,PT,Magnifico Sports,1684
240100400076,Sports,Assorted Sports Articles,Skates,Pro-roll Sq9 80-76mm/78a Roller Skates,PT,Magnifico Sports,1684
240100400080,Sports,Assorted Sports Articles,Skates,Proskater Kitalpha Gamma Roller Skates,US,Roll-Over Inc,3815
240100400083,Sports,Assorted Sports Articles,Skates,Proskater Viablade S Roller Skates,US,Roll-Over Inc,3815
240100400085,Sports,Assorted Sports Articles,Skates,Proskater W-500 Jr.Roller Skates,US,Roll-Over Inc,3815
240100400095,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Control Xi Adult,PT,Magnifico Sports,1684
240100400098,Sports,Assorted Sports Articles,Skates,Rollerskate  Roller Skates Ex9 76mm/78a Biofl,PT,Magnifico Sports,1684
240100400100,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Gretzky Mvp S.B.S,PT,Magnifico Sports,1684
240100400112,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Panga 72mm/78a,PT,Magnifico Sports,1684
240100400125,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Sq5 76mm/78a,PT,Magnifico Sports,1684
240100400128,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Sq7-Ls 76mm/78a,PT,Magnifico Sports,1684
240100400129,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Sq9 80-76mm/78a,PT,Magnifico Sports,1684
240100400136,Sports,Assorted Sports Articles,Skates,Rollerskate Roller Skates Xpander,PT,Magnifico Sports,1684
240100400142,Sports,Assorted Sports Articles,Skates,Twain Ac7/Ft7 Men's Roller Skates,US,Twain Inc,13198
240100400143,Sports,Assorted Sports Articles,Skates,Twain Ac7/Ft7 Women's Roller Skates,US,Twain Inc,13198
240100400147,Sports,Assorted Sports Articles,Skates,Twain Tr7 Men's Roller Skates,US,Twain Inc,13198
240100400151,Sports,Assorted Sports Articles,Skates,Weston F4 Men's Hockey Skates,US,Roll-Over Inc,3815
240200100007,Sports,Golf,Golf,Ball Bag,NL,Van Dammeren International,2995
240200100020,Sports,Golf,Golf,Red/White/Black Staff 9 Bag,GB,GrandSlam Sporting Goods Ltd,17832
240200100021,Sports,Golf,Golf,Tee Holder,NL,Van Dammeren International,2995
240200100034,Sports,Golf,Golf,Bb Softspikes - Xp 22-pack,GB,TeeTime Ltd,15938
240200100043,Sports,Golf,Golf,Bretagne Performance Tg Men's Golf Shoes L.,NL,Van Dammeren International,2995
240200100046,Sports,Golf,Golf,"Bretagne Soft-Tech Men's Glove, left",NL,Van Dammeren International,2995
240200100050,Sports,Golf,Golf,"Bretagne St2 Men's Golf Glove, left",NL,Van Dammeren International,2995
240200100051,Sports,Golf,Golf,Bretagne Stabilites 2000 Goretex Shoes,NL,Van Dammeren International,2995
240200100052,Sports,Golf,Golf,Bretagne Stabilities Tg Men's Golf Shoes,NL,Van Dammeren International,2995
240200100053,Sports,Golf,Golf,Bretagne Stabilities Women's Golf Shoes,NL,Van Dammeren International,2995
240200100056,Sports,Golf,Golf,Carolina,US,Carolina Sports,3808
240200100057,Sports,Golf,Golf,Carolina II,US,Carolina Sports,3808
240200100073,Sports,Golf,Golf,Donald Plush Headcover,GB,TeeTime Ltd,15938
240200100076,Sports,Golf,Golf,Expert Men's Firesole Driver,US,Twain Inc,13198
240200100081,Sports,Golf,Golf,Extreme Distance 90 3-pack,US,Carolina Sports,3808
240200100095,Sports,Golf,Golf,Grandslam Staff Fs Copper Insert Putter,GB,GrandSlam Sporting Goods Ltd,17832
240200100098,Sports,Golf,Golf,Grandslam Staff Grip Llh Golf Gloves,US,Carolina Sports,3808
240200100101,Sports,Golf,Golf,Grandslam Staff Tour Mhl Golf Gloves,US,Carolina Sports,3808
240200100116,Sports,Golf,Golf,Hi-fly Intimidator Ti R80/10,NL,Van Dammeren International,2995
240200100118,Sports,Golf,Golf,Hi-fly Intrepid Stand 8  Black,NL,Van Dammeren International,2995
240200100124,Sports,Golf,Golf,Hi-fly Staff Towel Blue/Black,NL,Van Dammeren International,2995
240200100131,Sports,Golf,Golf,Hi-fly Tour Advance Flex Steel,NL,Van Dammeren International,2995
240200100154,Sports,Golf,Golf,"Men's.m Men's Winter Gloves, Medium",NL,Van Dammeren International,2995
240200100157,Sports,Golf,Golf,Normal Standard,GB,TeeTime Ltd,15938
240200100164,Sports,Golf,Golf,Precision Jack 309 Lh Balata,GB,GrandSlam Sporting Goods Ltd,17832
240200100173,Sports,Golf,Golf,Proplay Executive Bi-Metal Graphite,NL,Van Dammeren International,2995
240200100180,Sports,Golf,Golf,Proplay Men's Tour Force Lp 7-Wood,NL,Van Dammeren International,2995
240200100181,Sports,Golf,Golf,Proplay Men's Tour Force Lp Driver,NL,Van Dammeren International,2995
240200100183,Sports,Golf,Golf,Proplay Men's Tour Force Ti 5w,NL,Van Dammeren International,2995
240200100207,Sports,Golf,Golf,Proplay Stand Black,NL,Van Dammeren International,2995
240200100211,Sports,Golf,Golf,Proplay Women's Tour Force 7w,NL,Van Dammeren International,2995
240200100221,Sports,Golf,Golf,Rosefinch Cart 8 1/2  Black,NL,Van Dammeren International,2995
240200100225,Sports,Golf,Golf,Rubby Men's Golf Shoes w/Goretex,ES,Rubby Zapatos S.A.,4168
240200100226,Sports,Golf,Golf,Rubby Men's Golf Shoes w/Goretex Plain Toe,ES,Rubby Zapatos S.A.,4168
240200100227,Sports,Golf,Golf,Rubby Women's Golf Shoes w/Gore-Tex,ES,Rubby Zapatos S.A.,4168
240200100230,Sports,Golf,Golf,Score Counter Scoreboard De Luxe,NL,Van Dammeren International,2995
240200100232,Sports,Golf,Golf,Tee18 Ascot Chipper,NL,Van Dammeren International,2995
240200100233,Sports,Golf,Golf,Tee18 Troon 7  Black,NL,Van Dammeren International,2995
240200100246,Sports,Golf,Golf,"White 90,Top.Flite Strata Tour 3-pack",NL,Van Dammeren International,2995
240200200007,Sports,Golf,Golf Clothes,Golf Polo(1/400),US,Mike Schaeffer Inc,7511
240200200011,Sports,Golf,Golf Clothes,Golf Windstopper,US,Mike Schaeffer Inc,7511
240200200013,Sports,Golf,Golf Clothes,Master Golf Rain Suit,US,Mike Schaeffer Inc,7511
240200200015,Sports,Golf,Golf Clothes,Tek Cap,US,Twain Inc,13198
240200200020,Sports,Golf,Golf Clothes,Big Boss Houston Pants,US,Mike Schaeffer Inc,7511
240200200024,Sports,Golf,Golf Clothes,Bogie Golf Fleece with small Zipper,US,Mike Schaeffer Inc,7511
240200200026,Sports,Golf,Golf Clothes,Eagle 5 Pocket Pants with Stretch,US,HighPoint Trading,10225
240200200035,Sports,Golf,Golf Clothes,Eagle Pants with Cross Pocket,US,HighPoint Trading,10225
240200200039,Sports,Golf,Golf Clothes,Eagle Plain Cap,US,HighPoint Trading,10225
240200200044,Sports,Golf,Golf Clothes,Eagle Polo-Shirt Interlock,US,HighPoint Trading,10225
240200200060,Sports,Golf,Golf Clothes,Eagle Windstopper Knit Neck,US,HighPoint Trading,10225
240200200061,Sports,Golf,Golf Clothes,Eagle Windstopper Sweat Neck,US,HighPoint Trading,10225
240200200068,Sports,Golf,Golf Clothes,Hi-fly Staff Rain Suit,NL,Van Dammeren International,2995
240200200071,Sports,Golf,Golf Clothes,Hi-fly Strata Cap Offwhite/Green,NL,Van Dammeren International,2995
240200200080,Sports,Golf,Golf Clothes,Release Golf Sweatshirt w/Logo(1/100),US,Mike Schaeffer Inc,7511
240200200081,Sports,Golf,Golf Clothes,Top (1/100),US,Mike Schaeffer Inc,7511
240200200091,Sports,Golf,Golf Clothes,Wind Proof Windstopper Merino/Acryl,US,HighPoint Trading,10225
240300100001,Sports,Indoor Sports,Fitness,Abdomen Shaper,NL,TrimSport B.V.,16542
240300100020,Sports,Indoor Sports,Fitness,Fitness Dumbbell Foam 0.90,NL,TrimSport B.V.,16542
240300100028,Sports,Indoor Sports,Fitness,Letour Heart Bike,NL,TrimSport B.V.,16542
240300100032,Sports,Indoor Sports,Fitness,Letour Trimag Bike,NL,TrimSport B.V.,16542
240300100046,Sports,Indoor Sports,Fitness,Weight  5.0 Kg,NL,TrimSport B.V.,16542
240300100048,Sports,Indoor Sports,Fitness,Wrist Weight 1.10 Kg,NL,TrimSport B.V.,16542
240300100049,Sports,Indoor Sports,Fitness,Wrist Weight  2.25 Kg,NL,TrimSport B.V.,16542
240300200009,Sports,Indoor Sports,Gymnastic Clothing,Blues Jazz Pants Suplex,ES,Sportico,798
240300200018,Sports,Indoor Sports,Gymnastic Clothing,Cougar Fleece Jacket with Zipper,US,SD Sporting Goods Inc,13710
240300200058,Sports,Indoor Sports,Gymnastic Clothing,Cougar Windbreaker Vest,US,SD Sporting Goods Inc,13710
240300300024,Sports,Indoor Sports,Top Trim,Men's Summer Shorts,US,Top Sports Inc,14648
240300300065,Sports,Indoor Sports,Top Trim,Top Men's Goretex Ski Pants,US,Top Sports Inc,14648
240300300070,Sports,Indoor Sports,Top Trim,Top Men's R&D Ultimate Jacket,US,Top Sports Inc,14648
240300300071,Sports,Indoor Sports,Top Trim,Top Men's Retro T-Neck,US,Top Sports Inc,14648
240300300090,Sports,Indoor Sports,Top Trim,Top R&D Long Jacket,US,Top Sports Inc,14648
240400200003,Sports,Racket Sports,Racket Sports,Bat 5-Ply,US,Carolina Sports,3808
240400200012,Sports,Racket Sports,Racket Sports,Sledgehammer 120 Ph Black,GB,GrandSlam Sporting Goods Ltd,17832
240400200022,Sports,Racket Sports,Racket Sports,Aftm 95 Vf Long Bg-65 White,GB,British Sports Ltd,1280
240400200036,Sports,Racket Sports,Racket Sports,Bag  Tit.Weekend,FR,Le Blanc S.A.,13079
240400200057,Sports,Racket Sports,Racket Sports,Grandslam Ultra Power Tennisketcher,GB,GrandSlam Sporting Goods Ltd,17832
240400200066,Sports,Racket Sports,Racket Sports,"Memhis 350,Yellow Medium, 6-pack tube",GB,British Sports Ltd,1280
240400200091,Sports,Racket Sports,Racket Sports,Smasher Rd Ti 70 Tennis Racket,GB,British Sports Ltd,1280
240400200093,Sports,Racket Sports,Racket Sports,Smasher Super Rq Ti 350 Tennis Racket,GB,British Sports Ltd,1280
240400200094,Sports,Racket Sports,Racket Sports,Smasher Super Rq Ti 700 Long Tennis,GB,British Sports Ltd,1280
240400200097,Sports,Racket Sports,Racket Sports,Smasher Tg 70 Tennis String Roll,GB,British Sports Ltd,1280
240400300013,Sports,Racket Sports,Tennis,Anthony Women's Tennis Cable Vest,US,Mayday Inc,4646
240400300033,Sports,Racket Sports,Tennis,Smasher Polo-Shirt w/V-Neck,GB,British Sports Ltd,1280
240400300035,Sports,Racket Sports,Tennis,Smasher Shorts,GB,British Sports Ltd,1280
240400300039,Sports,Racket Sports,Tennis,Smasher Tights,GB,British Sports Ltd,1280
240500100004,Sports,Running - Jogging,Jogging,Pants N,ES,Luna sastreria S.A.,4742
240500100015,Sports,Running - Jogging,Jogging,A-team Pants Taffeta,US,A Team Sports,3298
240500100017,Sports,Running - Jogging,Jogging,"A-team Sweat Round Neck, Small Logo",US,A Team Sports,3298
240500100026,Sports,Running - Jogging,Jogging,"Men's Sweat Pants without Rib, Small Logo",US,A Team Sports,3298
240500100029,Sports,Running - Jogging,Jogging,Men's Sweatshirt w/Hood Big Logo,US,A Team Sports,3298
240500100039,Sports,Running - Jogging,Jogging,Sweatshirt Women's Sweatshirt with O-Neck,US,A Team Sports,3298
240500100041,Sports,Running - Jogging,Jogging,Triffy Jacket,NL,Triffy B.V.,13314
240500100043,Sports,Running - Jogging,Jogging,Triffy Logo T-Shirt with V-Neck,NL,Triffy B.V.,13314
240500100057,Sports,Running - Jogging,Jogging,"Woman Sweat with Round Neck, Big Logo",US,A Team Sports,3298
240500100062,Sports,Running - Jogging,Jogging,Ypsilon Men's Sweatshirt w/Piping,FR,Ypsilon S.A.,14624
240500200003,Sports,Running - Jogging,Running Clothes,Men's Singlet,BE,Force Sports,5922
240500200007,Sports,Running - Jogging,Running Clothes,Running Gloves,BE,Force Sports,5922
240500200016,Sports,Running - Jogging,Running Clothes,T-Shirt,US,3Top Sports,2963
240500200042,Sports,Running - Jogging,Running Clothes,Bike.Pants Short Biking Pants,BE,Force Sports,5922
240500200056,Sports,Running - Jogging,Running Clothes,Breath-brief Long Underpants XXL,BE,Force Sports,5922
240500200073,Sports,Running - Jogging,Running Clothes,Force Classic Men's Jacket,BE,Force Sports,5922
240500200081,Sports,Running - Jogging,Running Clothes,Force Micro Men's Suit,BE,Force Sports,5922
240500200082,Sports,Running - Jogging,Running Clothes,Force Short Sprinter Men's Tights,BE,Force Sports,5922
240500200083,Sports,Running - Jogging,Running Clothes,Force Technical Jacket w/Coolmax,BE,Force Sports,5922
240500200093,Sports,Running - Jogging,Running Clothes,Maxrun Running Tights,BE,Force Sports,5922
240500200100,Sports,Running - Jogging,Running Clothes,Original Running Pants,BE,Force Sports,5922
240500200101,Sports,Running - Jogging,Running Clothes,Polar Jacket,BE,Force Sports,5922
240500200121,Sports,Running - Jogging,Running Clothes,Stout Running Shorts,BE,Force Sports,5922
240500200122,Sports,Running - Jogging,Running Clothes,Stout Running Shorts Micro,BE,Force Sports,5922
240500200130,Sports,Running - Jogging,Running Clothes,Topline Delphi Race Shorts,BE,Force Sports,5922
240600100010,Sports,Swim Sports,Bathing Suits,"Goggles, Assorted Colours",US,Nautlius SportsWear Inc,6153
240600100016,Sports,Swim Sports,Bathing Suits,Swim Suit Fabulo,US,Nautlius SportsWear Inc,6153
240600100017,Sports,Swim Sports,Bathing Suits,Swim Suit Laurel,ES,Luna sastreria S.A.,4742
240600100080,Sports,Swim Sports,Bathing Suits,Sharky Swimming Trunks,US,Dolphin Sportswear Inc,16292
240600100102,Sports,Swim Sports,Bathing Suits,Sunfit Luffa Bikini,US,Nautlius SportsWear Inc,6153
240600100181,Sports,Swim Sports,Bathing Suits,Milan Swimming Trunks,ES,Luna sastreria S.A.,4742
240600100185,Sports,Swim Sports,Bathing Suits,Pew Swimming Trunks,ES,Luna sastreria S.A.,4742
240700100001,Sports,Team Sports,American Football,Armour L,US,A Team Sports,3298
240700100004,Sports,Team Sports,American Football,Armour XL,US,A Team Sports,3298
240700100007,Sports,Team Sports,American Football,Football - Helmet M,US,A Team Sports,3298
240700100011,Sports,Team Sports,American Football,Football - Helmet Pro XL,US,A Team Sports,3298
240700100012,Sports,Team Sports,American Football,Football - Helmet S,US,A Team Sports,3298
240700100013,Sports,Team Sports,American Football,Football - Helmet XL,US,A Team Sports,3298
240700100017,Sports,Team Sports,American Football,Football Super Bowl,US,Carolina Sports,3808
240700200004,Sports,Team Sports,Baseball,Baseball Orange Small,US,Top Sports Inc,14648
240700200007,Sports,Team Sports,Baseball,Baseball White Small,US,Top Sports Inc,14648
240700200009,Sports,Team Sports,Baseball,Bat - Home Run M,US,Miller Trading Inc,15218
240700200010,Sports,Team Sports,Baseball,Bat - Home Run S,US,Miller Trading Inc,15218
240700200018,Sports,Team Sports,Baseball,Helmet L,US,Miller Trading Inc,15218
240700200019,Sports,Team Sports,Baseball,Helmet M,US,Miller Trading Inc,15218
240700200021,Sports,Team Sports,Baseball,Helmet XL,US,Miller Trading Inc,15218
240700200024,Sports,Team Sports,Baseball,Bat - Large,US,Miller Trading Inc,15218
240700300002,Sports,Team Sports,Basket Ball,Basket Ball Pro,US,HighPoint Trading,10225
240700400002,Sports,Team Sports,Soccer,Stephens Shirt,US,Teamsports Inc,5810
240700400003,Sports,Team Sports,Soccer,Red Cap,GB,SportsFan Products Ltd,6071
240700400004,Sports,Team Sports,Soccer,Red Scarf,GB,SportsFan Products Ltd,6071
240700400017,Sports,Team Sports,Soccer,Fga Home Shorts,US,Fga Sports Inc,14593
240700400020,Sports,Team Sports,Soccer,Norwood Player Shirt,US,Fga Sports Inc,14593
240700400024,Sports,Team Sports,Soccer,Prosoccer Away Shirt,US,Fga Sports Inc,14593
240700400031,Sports,Team Sports,Soccer,Soccer Fan Football Player Shirt,GB,SportsFan Products Ltd,6071
240800100026,Sports,Winter Sports,Ski Dress,Additive Women's Ski Pants Vent Air,NO,Scandinavian Clothing A/S,50
240800100039,Sports,Winter Sports,Ski Dress,Garbo Fleece Jacket,US,Miller Trading Inc,15218
240800100041,Sports,Winter Sports,Ski Dress,Helmsdale Ski Jacket,US,AllSeasons Outdoor Clothing,772
240800100042,Sports,Winter Sports,Ski Dress,Helmsdale Ski Pants,US,AllSeasons Outdoor Clothing,772
240800100074,Sports,Winter Sports,Ski Dress,Mayday Soul Pro New Tech Ski Jacket,US,Mayday Inc,4646
240800200002,Sports,Winter Sports,Winter Sports,Massif Bandit Ski Parcel Axial,FR,Massif S.A.,13199
240800200008,Sports,Winter Sports,Winter Sports,"Twain X-Scream 7.9 Ski,Sq 750 Dri",US,Twain Inc,13198
240800200009,Sports,Winter Sports,Winter Sports,Amber Cc,CA,CrystalClear Optics Inc,16814
240800200010,Sports,Winter Sports,Winter Sports,Black Morphe,CA,CrystalClear Optics Inc,16814
240800200020,Sports,Winter Sports,Winter Sports,"C.A.M.,Bone",CA,CrystalClear Optics Inc,16814
240800200021,Sports,Winter Sports,Winter Sports,Cayenne Red,CA,CrystalClear Optics Inc,16814
240800200030,Sports,Winter Sports,Winter Sports,"Ii Pmt,Bone",CA,CrystalClear Optics Inc,16814
240800200034,Sports,Winter Sports,Winter Sports,"Regulator,Stopsign",CA,CrystalClear Optics Inc,16814
240800200035,Sports,Winter Sports,Winter Sports,Shine Black PRO,CA,CrystalClear Optics Inc,16814
240800200037,Sports,Winter Sports,Winter Sports,Coolman Pro 01 Neon Yellow,US,Twain Inc,13198
240800200062,Sports,Winter Sports,Winter Sports,Top Equipe 07 Green,US,Twain Inc,13198
240800200063,Sports,Winter Sports,Winter Sports,Top Equipe 99 Black,US,Twain Inc,13198
;;;;
run;

data ORION.SALES;
   attrib Employee_ID length=8 format=12.;
   attrib First_Name length=$12;
   attrib Last_Name length=$18;
   attrib Gender length=$1;
   attrib Salary length=8;
   attrib Job_Title length=$25;
   attrib Country length=$2;
   attrib Birth_Date length=8;
   attrib Hire_Date length=8;

   infile datalines dsd;
   input
      Employee_ID
      First_Name
      Last_Name
      Gender
      Salary
      Job_Title
      Country
      Birth_Date
      Hire_Date
   ;
datalines4;
120102,Tom,Zhou,M,108255,Sales Manager,AU,3510,10744
120103,Wilson,Dawes,M,87975,Sales Manager,AU,-3996,5114
120121,Irenie,Elvish,F,26600,Sales Rep. II,AU,-5630,5114
120122,Christina,Ngan,F,27475,Sales Rep. II,AU,-1984,6756
120123,Kimiko,Hotstone,F,26190,Sales Rep. I,AU,1732,9405
120124,Lucian,Daymond,M,26480,Sales Rep. I,AU,-233,6999
120125,Fong,Hofmeister,M,32040,Sales Rep. IV,AU,-1852,6999
120126,Satyakam,Denny,M,26780,Sales Rep. II,AU,10490,17014
120127,Sharryn,Clarkson,F,28100,Sales Rep. II,AU,6943,14184
120128,Monica,Kletschkus,F,30890,Sales Rep. IV,AU,9691,17106
120129,Alvin,Roebuck,M,30070,Sales Rep. III,AU,1787,9405
120130,Kevin,Lyon,M,26955,Sales Rep. I,AU,9114,16922
120131,Marinus,Surawski,M,26910,Sales Rep. I,AU,7207,15706
120132,Fancine,Kaiser,F,28525,Sales Rep. III,AU,-3923,6848
120133,Petrea,Soltau,F,27440,Sales Rep. II,AU,9608,17075
120134,Sian,Shannan,M,28015,Sales Rep. II,AU,-3861,5114
120135,Alexei,Platts,M,32490,Sales Rep. IV,AU,3313,13788
120136,Atul,Leyden,M,26605,Sales Rep. I,AU,7198,15737
120137,Marina,Iyengar,F,29715,Sales Rep. III,AU,7010,16861
120138,Shani,Duckett,F,25795,Sales Rep. I,AU,7131,16983
120139,Fang,Wilson,F,26810,Sales Rep. II,AU,9726,17045
120140,Michael,Minas,M,26970,Sales Rep. I,AU,10442,17075
120141,Amanda,Liebman,F,27465,Sales Rep. II,AU,10298,16922
120142,Vincent,Eastley,M,29695,Sales Rep. III,AU,9661,16983
120143,Phu,Sloey,M,26790,Sales Rep. II,AU,-229,8309
120144,Viney,Barbis,M,30265,Sales Rep. III,AU,9562,17075
120145,Sandy,Aisbitt,M,26060,Sales Rep. II,AU,1482,9283
120146,Wendall,Cederlund,M,25985,Sales Rep. I,AU,-91,7518
120147,Skev,Rusli,F,26580,Sales Rep. II,AU,10245,17075
120148,Michael,Zubak,M,28480,Sales Rep. III,AU,-3762,6726
120149,Judy,Chantharasy,F,26390,Sales Rep. I,AU,5438,12054
120150,John,Filo,M,29965,Sales Rep. III,AU,-2002,8248
120151,Julianna,Phaiyakounh,F,26520,Sales Rep. II,AU,-5519,5114
120152,Sean,Dives,M,26515,Sales Rep. I,AU,7060,16527
120153,Samantha,Waal,F,27260,Sales Rep. I,AU,7066,13880
120154,Caterina,Hayawardhana,F,30490,Sales Rep. III,AU,-5643,5114
120155,Narelle,James,F,29990,Sales Rep. III,AU,8878,16892
120156,Gerry,Snellings,F,26445,Sales Rep. I,AU,10471,16861
120157,Leonid,Karavdic,M,27860,Sales Rep. II,AU,9548,17136
120158,Daniel,Pilgrim,M,36605,Sales Rep. III,AU,1656,10043
120159,Lynelle,Phoumirath,F,30765,Sales Rep. IV,AU,1515,9678
120160,Chuck,Segrave,M,27115,Sales Rep. I,AU,-1940,5387
120161,Rosette,Martines,F,30785,Sales Rep. III,AU,10293,17075
120162,Randal,Scordia,M,27215,Sales Rep. I,AU,10475,16833
120163,Brett,Magrath,M,26735,Sales Rep. II,AU,1603,11323
120164,Ranj,Stamalis,F,27450,Sales Rep. II,AU,-36,8067
120165,Tadashi,Pretorius,M,27050,Sales Rep. I,AU,8844,16861
120166,Fadi,Nowd,M,30660,Sales Rep. IV,AU,-5679,5114
120167,Kimiko,Tilley,F,25185,Sales Rep. I,AU,-2068,5145
120168,Selina,Barcoe,F,25275,Sales Rep. I,AU,8849,17106
120169,Cos,Tannous,M,28135,Sales Rep. III,AU,8767,16922
120170,Alban,Kingston,M,28830,Sales Rep. III,AU,5169,11962
120171,Alena,Moody,F,26205,Sales Rep. II,AU,8966,17045
120172,Edwin,Comber,M,28345,Sales Rep. III,AU,-5753,5114
120173,Hernani,Osborn,M,26715,Sales Rep. I,AU,-2138,6361
120174,Doungkamol,Simms,F,26850,Sales Rep. I,AU,-5835,5114
120175,Andrew,Conolly,M,25745,Sales Rep. I,AU,10457,17075
120176,Koavea,Pa,M,26095,Sales Rep. I,AU,9809,17106
120177,Franca,Kierce,F,28745,Sales Rep. III,AU,7034,13911
120178,Billy,Plested,M,26165,Sales Rep. II,AU,-1865,5204
120179,Matsuoka,Wills,M,28510,Sales Rep. III,AU,5187,16071
120180,Vino,George,M,26970,Sales Rep. II,AU,-2014,6909
120198,Meera,Body,F,28025,Sales Rep. III,AU,10247,17136
120261,Harry,Highpoint,M,243190,Chief Sales Officer,US,3339,10074
121018,Julienne,Magolan,F,27560,Sales Rep. II,US,-5842,5114
121019,Scott,Desanctis,M,31320,Sales Rep. IV,US,9672,16223
121020,Cherda,Ridley,F,31750,Sales Rep. IV,US,8819,15461
121021,Priscilla,Farren,F,32985,Sales Rep. IV,US,5457,12478
121022,Robert,Stevens,M,32210,Sales Rep. IV,US,7240,15372
121023,Shawn,Fuller,M,26010,Sales Rep. I,US,1533,10713
121024,Michael,Westlund,M,26600,Sales Rep. II,US,9030,16192
121025,Barnaby,Cassey,M,28295,Sales Rep. II,US,-3735,5722
121026,Terrill,Jaime,M,31515,Sales Rep. IV,US,9808,16892
121027,Allan,Rudder,M,26165,Sales Rep. II,US,1586,10927
121028,William,Smades,M,26585,Sales Rep. I,US,10344,17106
121029,Kuo-Chung,Mcelwee,M,27225,Sales Rep. I,US,1817,10927
121030,Jeryl,Areu,M,26745,Sales Rep. I,US,7255,15007
121031,Scott,Filan,M,28060,Sales Rep. III,US,1651,9344
121032,Nasim,Smith,M,31335,Sales Rep. IV,US,10281,16861
121033,Kristie,Snitzer,F,29775,Sales Rep. III,US,9806,16223
121034,John,Kirkman,M,27110,Sales Rep. II,US,10462,17167
121035,James,Blackley,M,26460,Sales Rep. II,US,-5760,5114
121036,Teresa,Mesley,F,25965,Sales Rep. I,US,10426,15979
121037,Muthukumar,Miketa,M,28310,Sales Rep. III,US,5276,15400
121038,David,Anstey,M,25285,Sales Rep. I,US,10270,17014
121039,Donald,Washington,M,27460,Sales Rep. II,US,-2038,7426
121040,Brienne,Darrohn,F,29525,Sales Rep. III,US,-179,8340
121041,Jaime,Wetherington,F,26120,Sales Rep. II,US,-5810,5114
121042,Joseph,Robbin-Coker,M,28845,Sales Rep. III,US,7033,14549
121043,Sigrid,Kagarise,F,28225,Sales Rep. II,US,3600,11748
121044,Ray,Abbott,M,25660,Sales Rep. I,US,-1847,5691
121045,Cascile,Hampton,F,28560,Sales Rep. II,US,1625,12419
121046,Roger,Mandzak,M,25845,Sales Rep. I,US,9016,16983
121047,Karen,Grzebien,F,25820,Sales Rep. I,US,7269,17045
121048,Lawrie,Clark,F,26560,Sales Rep. I,US,8941,17045
121049,Perrior,Bataineh,F,26930,Sales Rep. I,US,9541,17136
121050,Patricia,Capristo-Abramczyk,F,26080,Sales Rep. II,US,9508,17136
121051,Glorina,Myers,F,26025,Sales Rep. I,US,-3896,6879
121052,Richard,Fay,M,26900,Sales Rep. II,US,9505,17106
121053,Tywanna,Mcdade,F,29955,Sales Rep. III,US,-5578,5145
121054,Daniel,Pulliam,M,29805,Sales Rep. III,US,-1876,6149
121055,Clement,Davis,M,30185,Sales Rep. III,US,10234,17014
121056,Stacey,Lyszyk,F,28325,Sales Rep. II,US,8952,15826
121057,Tachaun,Voron,M,25125,Sales Rep. I,US,-6,7640
121058,Del,Kohake,M,26270,Sales Rep. I,US,5306,15614
121059,Jacqulin,Carhide,F,27425,Sales Rep. II,US,-68,7761
121060,Elizabeth,Spofford,F,28800,Sales Rep. III,US,-5685,5114
121061,Lauris,Hassam,M,29815,Sales Rep. III,US,-1995,8948
121062,Debra,Armant,F,30305,Sales Rep. IV,US,9067,17014
121063,Regi,Kinol,M,35990,Sales Rep. II,US,7147,16649
121064,Asishana,Polky,M,25110,Sales Rep. I,US,1488,11566
121065,Corneille,Malta,F,28040,Sales Rep. III,US,9014,16892
121066,Ceresh,Norman,F,27250,Sales Rep. II,US,-5609,5114
121067,Jeanilla,Macnair,F,31865,Sales Rep. IV,US,9514,16861
121068,Salaheloin,Osuba,M,27550,Sales Rep. II,US,3623,11932
121069,Jason,Lapsley,M,26195,Sales Rep. II,US,3365,11231
121070,Agnieszka,Holthouse,F,29385,Sales Rep. III,US,9074,16833
121071,John,Hoppmann,M,28625,Sales Rep. III,US,-113,6453
121072,Christer,North,M,26105,Sales Rep. I,US,6949,16315
121073,Donald,Court,M,27100,Sales Rep. I,US,-3883,5114
121074,Eric,Michonski,M,26990,Sales Rep. I,US,-306,10501
121075,Kasha,Sugg,F,28395,Sales Rep. II,US,-5487,5114
121076,Micah,Cobb,M,26685,Sales Rep. II,US,1743,8401
121077,Bryce,Smotherly,M,28585,Sales Rep. III,US,9014,17075
121078,Lionel,Wende,M,27485,Sales Rep. I,US,-3897,6879
121079,Azmi,Mees,M,25770,Sales Rep. I,US,5267,13819
121080,Kumar,Chinnis,M,32235,Sales Rep. I,US,-342,10105
121081,Susie,Knudson,F,30235,Sales Rep. III,US,-3931,5935
121082,Richard,Debank,M,28510,Sales Rep. III,US,-3832,6483
121083,Tingmei,Sutton,F,27245,Sales Rep. I,US,-296,6999
121084,Tulsidas,Ould,M,22710,Sales Rep. I,US,1689,11323
121085,Rebecca,Huslage,M,32235,Sales Rep. IV,US,9812,17167
121086,John-Michael,Plybon,M,26820,Sales Rep. I,US,-5494,5114
121087,Virtina,O'Suilleabhain,F,28325,Sales Rep. II,US,5454,14304
121088,Momolu,Kernitzki,M,27240,Sales Rep. I,US,10388,17167
121089,Gregory,Sauder,M,28095,Sales Rep. II,US,-1959,5295
121090,Betty,Klibbe,F,26600,Sales Rep. I,US,-2022,7336
121091,Ernest,Kadiri,M,27325,Sales Rep. II,US,3337,10593
121092,Gynell,Pritt,F,25680,Sales Rep. I,US,5180,15553
121093,Carl,Vasconcellos,M,27410,Sales Rep. I,US,1660,12419
121094,Larry,Tate,M,26555,Sales Rep. I,US,-2185,6818
121095,Sara,Kratzke,F,28010,Sales Rep. II,US,3391,11504
121096,Robert,Newstead,M,26335,Sales Rep. I,US,3425,12904
121097,Willeta,Chernega,F,26830,Sales Rep. II,US,5409,13057
121098,Hal,Heatwole,M,27475,Sales Rep. I,US,10308,16922
121099,Royall,Mrvichin,M,32725,Sales Rep. IV,US,7017,14731
121100,Tzue-Ing,Cormell,M,28135,Sales Rep. II,US,-3901,5935
121101,Burnetta,Buckner,F,25390,Sales Rep. I,US,9736,17106
121102,Rocheal,Flammia,F,27115,Sales Rep. I,US,7116,16953
121103,Brian,Farnsworth,M,27260,Sales Rep. I,US,10345,17045
121104,Leoma,Johnson,F,28315,Sales Rep. II,US,1777,9587
121105,Jessica,Savacool,F,29545,Sales Rep. III,US,7068,15706
121106,James,Hilburger,M,25880,Sales Rep. I,US,3320,13180
121107,Rose,Anger,F,31380,Sales Rep. IV,US,9610,16983
121108,Libby,Levi,F,25930,Sales Rep. I,US,10412,17106
121109,Harold,Boulus,M,26035,Sales Rep. I,US,3596,11078
121135,Tammy,Ruta,F,27010,Sales Rep. I,US,-2034,5326
121136,Lesia,Galarneau,F,27460,Sales Rep. I,US,5309,15675
121137,Michael. R.,Boocks,M,27055,Sales Rep. I,US,10244,16892
121138,Hershell,Tolley,M,27265,Sales Rep. I,US,-3959,5114
121139,Diosdado,Mckee,F,27700,Sales Rep. II,US,-135,10043
121140,Saunders,Briggi,M,26335,Sales Rep. I,US,6962,15066
121143,Louis,Favaron,M,95090,Senior Sales Manager,US,3617,13696
121144,Renee,Capachietti,F,83505,Sales Manager,US,1640,11627
121145,Dennis,Lansberry,M,84260,Sales Manager,US,-3692,5935
;;;;
run;

data ORION.SALESSTAFF;
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Job_Title length=$25 label='Employee Job Title';
   attrib Salary length=8 label='Employee Annual Salary' format=DOLLAR12.;
   attrib Gender length=$1 label='Employee Gender';
   attrib Birth_Date length=8 label='Employee Birth Date' format=DATE9.;
   attrib Emp_Hire_Date length=8 label='Employee Hire Date' format=DATE9. informat=DATE9.;
   attrib Emp_Term_Date length=8 label='Employee Termination Date' format=DATE9. informat=DATE9.;
   attrib Manager_ID length=8 label='Manager for Employee' format=12.;
   attrib SSN length=$16;
   attrib Employee_Name length=$40;

   infile datalines dsd;
   input
      Employee_ID
      Job_Title
      Salary
      Gender
      Birth_Date
      Emp_Hire_Date:BEST32.
      Emp_Term_Date:BEST32.
      Manager_ID
      SSN
      Employee_Name
   ;
datalines4;
120121,Sales Rep. II,26600,F,-5630,5114,,120102,42-8321-982,"Elvish, Irenie"
120134,Sales Rep. II,28015,M,-3861,5114,16982,120102,905-76-7767,"Shannan, Sian"
120151,Sales Rep. II,26520,F,-5519,5114,,120103,798-16-4924,"Phaiyakounh, Julianna"
120154,Sales Rep. III,30490,F,-5643,5114,,120102,534-14-1428,"Hayawardhana, Caterina"
120166,Sales Rep. IV,30660,M,-5679,5114,17044,120102,878-79-9390,"Nowd, Fadi"
120172,Sales Rep. III,28345,M,-5753,5114,,120102,801-5A-3640,"Comber, Edwin"
120174,Sales Rep. I,26850,F,-5835,5114,16739,120102,693-17-9406,"Simms, Doungkamol"
121018,Sales Rep. II,27560,F,-5842,5114,15825,121144,712-79-3016,"Magolan, Julienne"
121035,Sales Rep. II,26460,M,-5760,5114,,121144,305-03-6563,"Blackley, James"
121041,Sales Rep. II,26120,F,-5810,5114,,121144,114-96-2569,"Wetherington, Jaime"
121060,Sales Rep. III,28800,F,-5685,5114,,121143,749-47-4742,"Spofford, Elizabeth"
121066,Sales Rep. II,27250,F,-5609,5114,16740,121145,915-59-7961,"Norman, Ceresh"
121073,Sales Rep. I,27100,M,-3883,5114,,121145,219-68-2436abc,"Court, Donald"
121075,Sales Rep. II,28395,F,-5487,5114,,121145,161-74-5004,"Sugg, Kasha"
121086,Sales Rep. I,26820,M,-5494,5114,,121143,248-50-7517,"Plybon, John-Michael"
121138,Sales Rep. I,27265,M,-3959,5114,,121145,424-44-6422,"Tolley, Hershell"
120167,Sales Rep. I,25185,F,-2068,5145,16891,120102,139-34-1780,"Tilley, Kimiko"
121053,Sales Rep. III,29955,F,-5578,5145,,121143,973-70-5198,"Mcdade, Tywanna"
120178,Sales Rep. II,26165,M,-1865,5204,,120102,276-86-7310,"Plested, Billy"
121089,Sales Rep. II,28095,M,-1959,5295,17105,121143,963-87-3695,"Sauder, Gregory"
121135,Sales Rep. I,27010,F,-2034,5326,,121145,075-30-2918,"Ruta, Tammy"
120160,Sales Rep. I,27115,M,-1940,5387,,120102,421-02-5121,"Segrave, Chuck"
121044,Sales Rep. I,25660,M,-1847,5691,,121144,045-87-4776,"Abbott, Ray"
121025,Sales Rep. II,28295,M,-3735,5722,,121144,438-56-4418,"Cassey, Barnaby"
121081,Sales Rep. III,30235,F,-3931,5935,,121143,,"Knudson, Susie"
121100,Sales Rep. II,28135,M,-3901,5935,,121143,737-47-5975,"Cormell, Tzue-Ing"
121054,Sales Rep. III,29805,M,-1876,6149,,121143,864-48-5995,"Pulliam, Daniel"
120173,Sales Rep. I,26715,M,-2138,6361,16283,120102,546-22-9687,"Osborn, Hernani"
121071,Sales Rep. III,28625,M,-113,6453,,121145,556-65-5330,"Hoppmann, John"
121082,Sales Rep. III,28510,M,-3832,6483,,121143,609-81-9148,"Debank, Richard"
120148,Sales Rep. III,28480,M,-3762,6726,,120103,510-00-1866,"Zubak, Michael"
120122,Sales Rep. II,27475,F,-1984,6756,,120102,089-47-5114,"Ngan, Christina"
121094,Sales Rep. I,26555,M,-2185,6818,,121143,967-49-0193,"Tate, Larry"
120132,Sales Rep. III,28525,F,-3923,6848,,120102,456-22-3493,"Kaiser, Fancine"
121051,Sales Rep. I,26025,F,-3896,6879,,121143,968-92-3216,"Myers, Glorina"
121078,Sales Rep. I,27485,M,-3897,6879,,121143,242-70-4182,"Wende, Lionel"
120180,Sales Rep. II,26970,M,-2014,6909,,120102,918-93-7071,"George, Vino"
120124,Sales Rep. I,26480,M,-233,6999,,120102,097-92-8395,"Daymond, Lucian"
120125,Sales Rep. IV,32040,M,-1852,6999,16283,120102,257-58-1087,"Hofmeister, Fong"
121083,Sales Rep. I,27245,F,-296,6999,,121143,008-09-5291,"Sutton, Tingmei"
121090,Sales Rep. I,26600,F,-2022,7336,,121143,607-53-3101,"Klibbe, Betty"
121039,Sales Rep. II,27460,M,-2038,7426,,121144,561-54-0481,"Washington, Donald"
120146,Sales Rep. I,25985,M,-91,7518,16709,120103,713-92-9598,"Cederlund, Wendall"
121057,Sales Rep. I,25125,M,-6,7640,,121143,007-21-6147,"Voron, Tachaun"
121059,Sales Rep. II,27425,F,-68,7761,16070,121143,107-05-5563,"Carhide, Jacqulin"
120164,Sales Rep. II,27450,F,-36,8067,,120102,347-93-6206,"Stamalis, Ranj"
120150,Sales Rep. III,29965,M,-2002,8248,16191,120103,234-49-7560,"Filo, John"
120143,Sales Rep. II,26790,M,-229,8309,,120103,255-77-5079,"Sloey, Phu"
121040,Sales Rep. III,29525,F,-179,8340,,121144,985-86-9431,"Darrohn, Brienne"
121076,Sales Rep. II,26685,M,1743,8401,16222,121143,389-24-3331,"Cobb, Micah"
121061,Sales Rep. III,29815,M,-1995,8948,,121143,634-40-1176,"Hassam, Lauris"
120145,Sales Rep. II,26060,M,1482,9283,,120103,124-00-2425,"Aisbitt, Sandy"
121031,Sales Rep. III,28060,M,1651,9344,,121144,381-39-1694,"Filan, Scott"
120123,Sales Rep. I,26190,F,1732,9405,16467,120102,383-19-3715,"Hotstone, Kimiko"
120129,Sales Rep. III,30070,M,1787,9405,15795,120102,445-82-8341,"Roebuck, Alvin"
121104,Sales Rep. II,28315,F,1777,9587,15371,121143,061-33-7488,"Johnson, Leoma"
120159,Sales Rep. IV,30765,F,1515,9678,,120102,534-77-3294,"Phoumirath, Lynelle"
120158,Sales Rep. III,36605,M,1656,10043,16679,120102,977-60-2710,"Pilgrim, Daniel"
121139,Sales Rep. II,27700,F,-135,10043,,121145,451-61-9583,"Mckee, Diosdado"
121080,Sales Rep. I,32235,M,-342,10105,,121143,086-57-3574,"Chinnis, Kumar"
121074,Sales Rep. I,26990,M,-306,10501,,121145,855-53-1211,"Michonski, Eric"
121091,Sales Rep. II,27325,M,3337,10593,,121143,882-12-1413,"Kadiri, Ernest"
121023,Sales Rep. I,26010,M,1533,10713,16679,121144,520-53-3109,"Fuller, Shawn"
121027,Sales Rep. II,26165,M,1586,10927,,121144,829-83-4727,"Rudder, Allan"
121029,Sales Rep. I,27225,M,1817,10927,,121144,153-16-2789,"Mcelwee, Kuo-Chung"
121109,Sales Rep. I,26035,M,3596,11078,,121143,481-31-7308,"Boulus, Harold"
121069,Sales Rep. II,26195,M,3365,11231,,121145,872-69-3273,"Lapsley, Jason"
120163,Sales Rep. II,26735,M,1603,11323,,120102,706-28-4290,"Magrath, Brett"
121084,Sales Rep. I,22710,M,1689,11323,,121143,534-92-2128,"Ould, Tulsidas"
121095,Sales Rep. II,28010,F,3391,11504,,121143,175-95-9594,"Kratzke, Sara"
121064,Sales Rep. I,25110,M,1488,11566,,121145,163-54-3966,"Polky, Asishana"
121043,Sales Rep. II,28225,F,3600,11748,,121144,060-88-3887,"Kagarise, Sigrid"
121068,Sales Rep. II,27550,M,3623,11932,,121145,110-80-4309,"Osuba, Salaheloin"
120170,Sales Rep. III,28830,M,5169,11962,17105,120102,574-43-1404,"Kingston, Alban"
120149,Sales Rep. I,26390,F,5438,12054,,120103,905-60-3585,"Chantharasy, Judy"
121045,Sales Rep. II,28560,F,1625,12419,16130,121143,788-63-2249,"Hampton, Cascile"
121093,Sales Rep. I,27410,M,1660,12419,15886,121143,482-57-1127,"Vasconcellos, Carl"
121021,Sales Rep. IV,32985,F,5457,12478,,121144,337-71-9456,"Farren, Priscilla"
121096,Sales Rep. I,26335,M,3425,12904,,121143,810-60-4039,"Newstead, Robert"
121097,Sales Rep. II,26830,F,5409,13057,,121143,hello219-68-1098,"Chernega, Willeta"
121106,Sales Rep. I,25880,M,3320,13180,,121143,206-54-7999,"Hilburger, James"
120135,Sales Rep. IV,32490,M,3313,13788,16191,120102,967-44-0288,"Platts, Alexei"
121079,Sales Rep. I,25770,M,5267,13819,,121143,369-24-2683,"Mees, Azmi"
120153,Sales Rep. I,27260,F,7066,13880,16832,120102,117-57-5009,"Waal, Samantha"
120177,Sales Rep. III,28745,F,7034,13911,,120102,349-07-2227,"Kierce, Franca"
120127,Sales Rep. II,28100,F,6943,14184,,120102,036-29-9667,"Clarkson, Sharryn"
121087,Sales Rep. II,28325,F,5454,14304,16891,121143,788-14-2460,"O'Suilleabhain, Virtina"
121042,Sales Rep. III,28845,M,7033,14549,,121144,888-84-0152,"Robbin-Coker, Joseph"
121099,Sales Rep. IV,32725,M,7017,14731,,121143,658-54-7772,"Mrvichin, Royall"
121030,Sales Rep. I,26745,M,7255,15007,,121144,523-63-5913,"Areu, Jeryl"
121140,Sales Rep. I,26335,M,6962,15066,16832,121145,084-08-6174,"Briggi, Saunders"
121022,Sales Rep. IV,32210,M,7240,15372,16314,121144,355-45-0392,"Stevens, Robert"
121037,Sales Rep. III,28310,M,5276,15400,,121144,295-70-7059,"Miketa, Muthukumar"
121020,Sales Rep. IV,31750,F,8819,15461,,121144,703-63-9068,"Ridley, Cherda"
121092,Sales Rep. I,25680,F,5180,15553,,121143,447-78-9329,"Pritt, Gynell"
121058,Sales Rep. I,26270,M,5306,15614,,121143,821-15-1683,"Kohake, Del"
121136,Sales Rep. I,27460,F,5309,15675,16344,121145,954-18-9609,"Galarneau, Lesia"
120131,Sales Rep. I,26910,M,7207,15706,,120102,039-11-6094,"Surawski, Marinus"
121105,Sales Rep. III,29545,F,7068,15706,,121143,085-13-8459,"Savacool, Jessica"
120136,Sales Rep. I,26605,M,7198,15737,,120102,737-35-1762,"Leyden, Atul"
121056,Sales Rep. II,28325,F,8952,15826,,121143,823-65-9311,"Lyszyk, Stacey"
121036,Sales Rep. I,25965,F,10426,15979,16740,121144,314-13-2259,"Mesley, Teresa"
120179,Sales Rep. III,28510,M,5187,16071,16314,120102,728-25-9828,"Wills, Matsuoka"
121024,Sales Rep. II,26600,M,9030,16192,,121144,716-97-6713,"Westlund, Michael"
121019,Sales Rep. IV,31320,M,9672,16223,16648,121144,027-00-3578,"Desanctis, Scott"
121033,Sales Rep. III,29775,F,9806,16223,,121144,274-77-8534,"Snitzer, Kristie"
121072,Sales Rep. I,26105,M,6949,16315,16740,121145,802-74-3703,"North, Christer"
120152,Sales Rep. I,26515,M,7060,16527,,120102,148-75-5338,"Dives, Sean"
121063,Sales Rep. II,35990,M,7147,16649,,121145,729-96-4035,"Kinol, Regi"
120162,Sales Rep. I,27215,M,10475,16833,,120102,943-43-0183,"Scordia, Randal"
121070,Sales Rep. III,29385,F,9074,16833,,121145,728-21-7433,"Holthouse, Agnieszka"
120137,Sales Rep. III,29715,F,7010,16861,,120102,402-94-7709,"Iyengar, Marina"
120156,Sales Rep. I,26445,F,10471,16861,,120102,772-99-2367,"Snellings, Gerry"
120165,Sales Rep. I,27050,M,8844,16861,,120102,181-00-5355,"Pretorius, Tadashi"
121032,Sales Rep. IV,31335,M,10281,16861,,121144,910-64-2664,"Smith, Nasim"
121067,Sales Rep. IV,31865,F,9514,16861,17045,121145,294-60-9411,"Macnair, Jeanilla"
120155,Sales Rep. III,29990,F,8878,16892,,120102,640-85-7012,"James, Narelle"
121026,Sales Rep. IV,31515,M,9808,16892,,121144,162-30-9249,"Jaime, Terrill"
121065,Sales Rep. III,28040,F,9014,16892,,121145,557-40-7901,"Malta, Corneille"
121137,Sales Rep. I,27055,M,10244,16892,,121145,876-12-1631,"Boocks, Michael. R."
120130,Sales Rep. I,26955,M,9114,16922,,120102,143-12-4676,"Lyon, Kevin"
120141,Sales Rep. II,27465,F,10298,16922,,120103,283-90-3049,"Liebman, Amanda"
120169,Sales Rep. III,28135,M,8767,16922,,120102,966-26-7530,"Tannous, Cos"
121098,Sales Rep. I,27475,M,10308,16922,,121143,080-66-5221,"Heatwole, Hal"
121102,Sales Rep. I,27115,F,7116,16953,,121143,657-70-9638,"Flammia, Rocheal"
120138,Sales Rep. I,25795,F,7131,16983,,120102,373-16-4566,"Duckett, Shani"
120142,Sales Rep. III,29695,M,9661,16983,,120103,350-61-1042,"Eastley, Vincent"
121046,Sales Rep. I,25845,M,9016,16983,17167,121143,921-73-4364,"Mandzak, Roger"
121107,Sales Rep. IV,31380,F,9610,16983,,121143,778-29-5999,"Anger, Rose"
120126,Sales Rep. II,26780,M,10490,17014,,120102,088-24-9595,"Denny, Satyakam"
121038,Sales Rep. I,25285,M,10270,17014,17198,121144,366-10-0075,"Anstey, David"
121055,Sales Rep. III,30185,M,10234,17014,,121143,174-95-3655,"Davis, Clement"
121062,Sales Rep. IV,30305,F,9067,17014,,121145,957-64-2816,"Armant, Debra"
120139,Sales Rep. II,26810,F,9726,17045,,120102,327-84-0220,"Wilson, Fang"
120171,Sales Rep. II,26205,F,8966,17045,,120102,314-53-2123,"Moody, Alena"
121047,Sales Rep. I,25820,F,7269,17045,17226,121143,856-23-7556,"Grzebien, Karen"
121048,Sales Rep. I,26560,F,8941,17045,17226,121143,410-21-8164,"Clark, Lawrie"
121103,Sales Rep. I,27260,M,10345,17045,,121143,862-19-2330,"Farnsworth, Brian"
120133,Sales Rep. II,27440,F,9608,17075,,120102,088-57-9593,"Soltau, Petrea"
120140,Sales Rep. I,26970,M,10442,17075,,120103,510-27-7886,"Minas, Michael"
120144,Sales Rep. III,30265,M,9562,17075,,120103,436-40-3617,"Barbis, Viney"
120147,Sales Rep. II,26580,F,10245,17075,,120103,002-76-2169,"Rusli, Skev"
120161,Sales Rep. III,30785,F,10293,17075,,120102,493-21-1108,"Martines, Rosette"
120175,Sales Rep. I,25745,M,10457,17075,,120102,602-65-4238,"Conolly, Andrew"
121077,Sales Rep. III,28585,M,9014,17075,,121143,445-56-8520,"Smotherly, Bryce"
120128,Sales Rep. IV,30890,F,9691,17106,,120102,107-58-5960,"Kletschkus, Monica"
120168,Sales Rep. I,25275,F,8849,17106,,120102,315-91-4521,"Barcoe, Selina"
120176,Sales Rep. I,26095,M,9809,17106,,120102,248-57-5992,"Pa, Koavea"
121028,Sales Rep. I,26585,M,10344,17106,,121144,732-94-3985,"Smades, William"
121052,Sales Rep. II,26900,M,9505,17106,,121143,063-51-7196,"Fay, Richard"
121101,Sales Rep. I,25390,F,9736,17106,,121143,428-59-7468,"Buckner, Burnetta"
121108,Sales Rep. I,25930,F,10412,17106,17287,121143,076-69-8811,"Levi, Libby"
120157,Sales Rep. II,27860,M,9548,17136,,120102,546-36-2811,"Karavdic, Leonid"
120198,Sales Rep. III,28025,F,10247,17136,,120103,619-59-4011,"Body, Meera"
121049,Sales Rep. I,26930,F,9541,17136,,121143,008-90-9458,"Bataineh, Perrior"
121050,Sales Rep. II,26080,F,9508,17136,,121143,941-62-4741,"Capristo-Abramczyk, Patricia"
120146,Sales Rep. II,27284.25,M,-91,17167,,120103,713-92-9598,"Cederlund, Wendall"
121034,Sales Rep. II,27110,M,10462,17167,,121144,590-47-7664,"Kirkman, John"
121085,Sales Rep. IV,32235,M,9812,17167,,121143,157-59-1652,"Huslage, Rebecca"
121088,Sales Rep. I,27240,M,10388,17167,,121143,701-31-9529,"Kernitzki, Momolu"
120134,Sales Rep. II,29415.75,M,-3861,17501,,120102,905-76-7767,"Shannan, Sian"
120166,Sales Rep. II,32193,M,-5679,17501,,120102,878-79-9390,"Nowd, Fadi"
120167,Sales Rep. II,26444.25,F,-2068,17501,,120102,139-34-1780,"Tilley, Kimiko"
;;;;
run;

data ORION.STAFF;
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Start_Date length=8 label='Start Date' format=DATE9.;
   attrib End_Date length=8 label='End Date' format=DATE9.;
   attrib Job_Title length=$25 label='Employee Job Title';
   attrib Salary length=8 label='Employee Annual Salary' format=DOLLAR12.;
   attrib Gender length=$1 label='Employee Gender';
   attrib Birth_Date length=8 label='Employee Birth Date' format=DATE9.;
   attrib Emp_Hire_Date length=8 label='Employee Hire Date' format=DATE9. informat=DATE9.;
   attrib Emp_Term_Date length=8 label='Employee Termination Date' format=DATE9. informat=DATE9.;
   attrib Manager_ID length=8 label='Manager for Employee' format=12.;

   infile datalines dsd;
   input
      Employee_ID
      Start_Date
      End_Date
      Job_Title
      Salary
      Gender
      Birth_Date
      Emp_Hire_Date:BEST32.
      Emp_Term_Date:BEST32.
      Manager_ID
   ;
datalines4;
120101,15887,2936547,Director,163040,M,6074,15887,,120261
120102,10744,2936547,Sales Manager,108255,M,3510,10744,,120101
120103,5114,2936547,Sales Manager,87975,M,-3996,5114,,120101
120104,7671,2936547,Administration Manager,46230,F,-2061,7671,,120101
120105,14365,2936547,Secretary I,27110,F,5468,14365,,120101
120106,5114,2936547,Office Assistant II,26960,M,-5487,5114,,120104
120107,5145,2936547,Office Assistant III,30475,F,-3997,5145,,120104
120108,17014,2936547,Warehouse Assistant II,27660,F,8819,17014,,120104
120109,17075,2936547,Warehouse Assistant I,26495,F,9845,17075,,120104
120110,7244,2936547,Warehouse Assistant III,28615,M,-3694,7244,,120104
120111,5418,2936547,Security Guard II,26895,M,-3814,5418,,120104
120112,11139,2936547,Security Guard I,26550,F,3335,11139,,120104
120113,5114,2936547,Security Guard II,26870,F,-5714,5114,,120104
120114,5114,2936547,Security Manager,31285,F,-5806,5114,,120104
120115,16649,2936547,Service Assistant I,26500,M,8894,16649,,120104
120116,7336,2936547,Service Assistant II,29250,M,-202,7336,,120104
120117,9587,2936547,Cabinet Maker III,31670,M,1715,9587,,120104
120118,8948,2936547,Cabinet Maker II,28090,M,-212,8948,,120104
120119,13880,2936547,Electrician IV,30255,M,3642,13880,,120104
120120,5114,2936547,Electrician II,27645,F,-5719,5114,,120104
120121,5114,2936547,Sales Rep. II,26600,F,-5630,5114,,120102
120122,6756,2936547,Sales Rep. II,27475,F,-1984,6756,,120102
120123,9405,16467,Sales Rep. I,26190,F,1732,9405,16467,120102
120124,6999,2936547,Sales Rep. I,26480,M,-233,6999,,120102
120125,6999,16283,Sales Rep. IV,32040,M,-1852,6999,16283,120102
120126,17014,2936547,Sales Rep. II,26780,M,10490,17014,,120102
120127,14184,2936547,Sales Rep. II,28100,F,6943,14184,,120102
120128,17106,2936547,Sales Rep. IV,30890,F,9691,17106,,120102
120129,9405,15795,Sales Rep. III,30070,M,1787,9405,15795,120102
120130,16922,2936547,Sales Rep. I,26955,M,9114,16922,,120102
120131,15706,2936547,Sales Rep. I,26910,M,7207,15706,,120102
120132,6848,2936547,Sales Rep. III,28525,F,-3923,6848,,120102
120133,17075,2936547,Sales Rep. II,27440,F,9608,17075,,120102
120134,5114,16982,Sales Rep. II,28015,M,-3861,5114,16982,120102
120135,13788,16191,Sales Rep. IV,32490,M,3313,13788,16191,120102
120136,15737,2936547,Sales Rep. I,26605,M,7198,15737,,120102
120137,16861,2936547,Sales Rep. III,29715,F,7010,16861,,120102
120138,16983,2936547,Sales Rep. I,25795,F,7131,16983,,120102
120139,17045,2936547,Sales Rep. II,26810,F,9726,17045,,120102
120140,17075,2936547,Sales Rep. I,26970,M,10442,17075,,120103
120141,16922,2936547,Sales Rep. II,27465,F,10298,16922,,120103
120142,16983,2936547,Sales Rep. III,29695,M,9661,16983,,120103
120143,8309,2936547,Sales Rep. II,26790,M,-229,8309,,120103
120144,17075,2936547,Sales Rep. III,30265,M,9562,17075,,120103
120145,9283,2936547,Sales Rep. II,26060,M,1482,9283,,120103
120146,7518,16709,Sales Rep. I,25985,M,-91,7518,16709,120103
120147,17075,2936547,Sales Rep. II,26580,F,10245,17075,,120103
120148,6726,2936547,Sales Rep. III,28480,M,-3762,6726,,120103
120149,12054,2936547,Sales Rep. I,26390,F,5438,12054,,120103
120150,8248,16191,Sales Rep. III,29965,M,-2002,8248,16191,120103
120151,5114,2936547,Sales Rep. II,26520,F,-5519,5114,,120103
120152,16527,2936547,Sales Rep. I,26515,M,7060,16527,,120102
120153,13880,16832,Sales Rep. I,27260,F,7066,13880,16832,120102
120154,5114,2936547,Sales Rep. III,30490,F,-5643,5114,,120102
120155,16892,2936547,Sales Rep. III,29990,F,8878,16892,,120102
120156,16861,2936547,Sales Rep. I,26445,F,10471,16861,,120102
120157,17136,2936547,Sales Rep. II,27860,M,9548,17136,,120102
120158,10043,16679,Sales Rep. III,36605,M,1656,10043,16679,120102
120159,9678,2936547,Sales Rep. IV,30765,F,1515,9678,,120102
120160,5387,2936547,Sales Rep. I,27115,M,-1940,5387,,120102
120161,17075,2936547,Sales Rep. III,30785,F,10293,17075,,120102
120162,16833,2936547,Sales Rep. I,27215,M,10475,16833,,120102
120163,11323,2936547,Sales Rep. II,26735,M,1603,11323,,120102
120164,8067,2936547,Sales Rep. II,27450,F,-36,8067,,120102
120165,16861,2936547,Sales Rep. I,27050,M,8844,16861,,120102
120166,5114,17044,Sales Rep. IV,30660,M,-5679,5114,17044,120102
120167,5145,16891,Sales Rep. I,25185,F,-2068,5145,16891,120102
120168,17106,2936547,Sales Rep. I,25275,F,8849,17106,,120102
120169,16922,2936547,Sales Rep. III,28135,M,8767,16922,,120102
120170,11962,17105,Sales Rep. III,28830,M,5169,11962,17105,120102
120171,17045,2936547,Sales Rep. II,26205,F,8966,17045,,120102
120172,5114,2936547,Sales Rep. III,28345,M,-5753,5114,,120102
120173,6361,16283,Sales Rep. I,26715,M,-2138,6361,16283,120102
120174,5114,16739,Sales Rep. I,26850,F,-5835,5114,16739,120102
120175,17075,2936547,Sales Rep. I,25745,M,10457,17075,,120102
120176,17106,2936547,Sales Rep. I,26095,M,9809,17106,,120102
120177,13911,2936547,Sales Rep. III,28745,F,7034,13911,,120102
120178,5204,2936547,Sales Rep. II,26165,M,-1865,5204,,120102
120179,16071,16314,Sales Rep. III,28510,M,5187,16071,16314,120102
120180,6909,2936547,Sales Rep. II,26970,M,-2014,6909,,120102
120181,17136,17256,Temp. Sales Rep.,27065,F,10559,17136,17256,120103
120182,17136,17166,Temp. Sales Rep.,25020,M,9044,17136,17166,120103
120183,17136,17166,Temp. Sales Rep.,26910,M,3540,17136,17166,120103
120184,17136,17286,Temp. Sales Rep.,25820,M,-3683,17136,17286,120103
120185,17136,17197,Temp. Sales Rep.,25080,F,5210,17136,17197,120103
120186,17136,17347,Temp. Sales Rep.,26795,F,7048,17136,17347,120103
120187,17136,17317,Temp. Sales Rep.,26665,F,9110,17136,17317,120103
120188,17136,17166,Temp. Sales Rep.,26715,F,-2132,17136,17166,120103
120189,17136,17256,Temp. Sales Rep.,25180,M,8950,17136,17256,120103
120190,16376,16556,Trainee,24100,M,9105,16376,16556,120103
120191,15706,15886,Trainee,24015,F,-349,15706,15886,120103
120192,16588,16770,Trainee,26185,M,8894,16588,16770,120103
120193,16680,16860,Trainee,24515,M,9106,16680,16860,120103
120194,16468,16648,Trainee,25985,M,9032,16468,16648,120103
120195,16983,17166,Trainee,24990,F,9125,16983,17166,120103
120196,15706,15886,Trainee,24025,F,8796,15706,15886,120103
120197,15706,15886,Trainee,25580,F,-1972,15706,15886,120103
120198,17136,2936547,Sales Rep. III,28025,F,10247,17136,,120103
120259,10836,2936547,Chief Executive Officer,433800,M,1485,10836,,
120260,9071,2936547,Chief Marketing Officer,207885,F,1797,9071,,120259
120261,10074,2936547,Chief Sales Officer,243190,M,3339,10074,,120259
120262,10471,2936547,Chief Financial Officer,268455,M,3581,10471,,120259
120263,8674,16070,Financial Analyst III,42605,M,1501,8674,16070,120262
120264,17136,2936547,Financial Analyst II,37510,F,8788,17136,,120262
120265,5114,15705,Auditor III,51950,F,-5567,5114,15705,120262
120266,10683,2936547,Secretary IV,31750,F,3469,10683,,120259
120267,15737,2936547,Secretary III,28585,F,9649,15737,,120259
120268,13635,2936547,Senior Strategist,76105,M,5357,13635,,120260
120269,5114,16191,Strategist II,52540,F,-5574,5114,16191,120260
120270,5114,2936547,Concession Director,48435,M,-2108,5114,,120261
120271,9740,2936547,Concession Manager,43635,F,1679,9740,,120270
120272,5114,2936547,Concession Consultant II,34390,M,-5770,5114,,120271
120273,16861,2936547,Concession Assistant III,28455,F,9654,16861,,120271
120274,12388,2936547,Concession Assistant I,26840,F,1469,12388,,120271
120275,9040,2936547,Concession Consultant II,32195,F,-5,9040,,120271
120276,5114,15856,Concession Assistant II,28090,M,-5494,5114,15856,120271
120277,16192,16587,Concession Consultant I,32645,F,10455,16192,16587,120271
120278,17014,2936547,Concession Assistant III,27685,M,9847,17014,,120271
120279,13270,2936547,Concession Consultant I,32925,F,3580,13270,,120271
120280,10348,15521,Concession Consultant III,36930,F,1776,10348,15521,120271
120656,14304,2936547,Logistics Coordinator II,42570,F,5141,14304,,120660
120657,11262,2936547,Logistics Coordinator I,36110,F,1467,11262,,120660
120658,7702,2936547,Logistics Coordinator II,42485,M,-1838,7702,,120660
120659,5114,2936547,Director,161290,M,-3821,5114,,120259
120660,16496,2936547,Logistics Manager,61125,M,6731,16496,,120659
120661,8766,15886,Senior Logistics Manager,85495,F,-1861,8766,15886,120659
120662,17106,2936547,Secretary II,27045,M,10403,17106,,120659
120663,13574,2936547,Pricing Manager,56385,F,3372,13574,,120659
120664,5599,2936547,Pricing Specialist,47605,M,-2143,5599,,120663
120665,15400,2936547,Senior Logistics Manager,80070,F,5410,15400,,120659
120666,11657,16191,Logistics Manager,64555,M,3460,11657,16191,120659
120667,16833,2936547,Office Assistant III,29980,M,7111,16833,,120666
120668,6909,2936547,Services Manager,47785,M,-3722,6909,,120659
120669,5114,2936547,Services Assistant IV,36370,M,-5640,5114,,120668
120670,5114,15705,Shipping Manager,65420,M,-5759,5114,15705,120659
120671,8432,2936547,Shipping Agent III,40080,M,-2045,8432,,120670
120672,11748,2936547,Shipping Manager,60980,M,1698,11748,,120659
120673,5114,2936547,Shipping Agent II,35935,F,-5666,5114,,120672
120677,12085,2936547,Shipping Manager,65555,F,3532,12085,,120659
120678,6695,15948,Shipping Agent III,40035,F,-4006,6695,15948,120677
120679,15522,2936547,Shipping Manager,46190,F,6155,15522,,120659
120680,11443,2936547,Shipping Agent I,27295,F,3524,11443,,120679
120681,16162,2936547,Shipping Agent II,30950,M,7163,16162,,120679
120682,13240,2936547,Shipping Agent I,26760,F,3641,13240,,120679
120683,5114,15764,Shipping Agent III,36315,F,-1876,5114,15764,120679
120684,17106,2936547,Warehouse Assistant I,26960,F,9826,17106,,120679
120685,17106,2936547,Warehouse Assistant I,25130,F,8826,17106,,120679
120686,5114,2936547,Warehouse Assistant II,26690,F,-5717,5114,,120679
120687,16284,16467,Warehouse Assistant I,26800,F,7084,16284,16467,120679
120688,5114,15583,Warehouse Assistant I,25905,F,-3659,5114,15583,120679
120689,16983,2936547,Warehouse Assistant III,27780,F,7140,16983,,120679
120690,16406,2936547,Warehouse Assistant I,25185,F,8782,16406,,120679
120691,5114,2936547,Shipping Manager,49240,M,-5586,5114,,120659
120692,8126,2936547,Shipping Agent II,32485,M,-1866,8126,,120691
120693,7091,2936547,Shipping Agent I,26625,M,-244,7091,,120691
120694,16892,2936547,Warehouse Assistant I,27365,F,10455,16892,,120691
120695,10774,17013,Warehouse Assistant II,28180,M,1655,10774,17013,120691
120696,5173,16891,Warehouse Assistant I,26615,M,-1966,5173,16891,120691
120697,16953,2936547,Warehouse Assistant IV,29625,F,10405,16953,,120691
120698,6057,16495,Warehouse Assistant I,26160,M,-2055,6057,16495,120691
120710,13880,2936547,Business Analyst II,54840,M,5441,13880,,120719
120711,12478,2936547,Business Analyst III,59130,F,3435,12478,,120719
120712,5114,2936547,Marketing Manager,63640,F,-3855,5114,,120719
120713,5114,2936547,Marketing Assistant III,31630,M,-5791,5114,,120712
120714,14123,2936547,Marketing Manager,62625,M,5938,14123,,120719
120715,16468,2936547,Marketing Assistant II,28535,F,7102,16468,,120714
120716,12266,2936547,Events Manager,53015,M,5318,12266,,120719
120717,7883,2936547,Marketing Assistant II,30155,M,-2183,7883,,120716
120718,11078,2936547,Marketing Assistant II,29190,M,1650,11078,,120716
120719,13180,2936547,Senior Marketing Manager,87420,F,3309,13180,,120260
120720,11779,2936547,Corp. Comm. Manager,46580,M,1588,11779,,120719
120721,5114,2936547,Marketing Assistant II,29870,F,-5550,5114,,120720
120722,9405,2936547,Corp. Comm. Specialist I,32460,M,-101,9405,,120720
120723,5114,2936547,Corp. Comm. Specialist II,33950,F,-3796,5114,,120720
120724,11779,2936547,Marketing Manager,63705,M,1487,11779,,120719
120725,16223,16436,Marketing Assistant II,29970,M,7236,16223,16436,120724
120726,17045,2936547,Marketing Assistant I,27380,F,10409,17045,,120724
120727,9648,2936547,Marketing Assistant IV,34925,M,1637,9648,,120724
120728,8036,2936547,Purchasing Agent II,35070,F,-1854,8036,,120735
120729,15820,16702,Purchasing Agent I,31495,F,10320,15820,16702,120735
120730,10501,2936547,Purchasing Agent I,30195,M,1811,10501,,120735
120731,8644,2936547,Purchasing Agent II,34150,M,-292,8644,,120735
120732,5114,2936547,Purchasing Agent III,35870,M,-3792,5114,,120736
120733,11262,2936547,Purchasing Agent I,31760,M,1554,11262,,120736
120734,16861,2936547,Purchasing Agent III,34270,M,7055,16861,,120736
120735,6695,2936547,Purchasing Manager,61985,F,-2028,6695,,120261
120736,11596,2936547,Purchasing Manager,63985,F,1792,11596,,120261
120737,10532,2936547,Purchasing Manager,63605,F,-279,10532,,120261
120738,5114,2936547,Purchasing Agent I,30025,F,-3831,5114,,120737
120739,16922,2936547,Purchasing Agent III,36970,M,9715,16922,,120737
120740,5114,15948,Purchasing Agent II,35110,F,-3726,5114,15948,120737
120741,5114,2936547,Purchasing Agent III,36365,F,-5512,5114,,120737
120742,5114,2936547,Purchasing Agent I,31020,M,-5810,5114,,120737
120743,13666,2936547,Purchasing Agent II,34620,F,3319,13666,,120737
120744,16253,16739,Purchasing Agent II,33490,F,10397,16253,16739,120737
120745,16953,2936547,Purchasing Agent I,31365,F,9682,16953,,120737
120746,15431,2936547,Account Manager,46090,M,5396,15431,,120262
120747,12996,2936547,Financial Controller I,43590,F,5284,12996,,120746
120748,15765,2936547,Building Admin. Manager,48380,F,6030,15765,,120262
120749,13423,2936547,Office Assistant II,26545,M,5376,13423,,120748
120750,6971,15371,Accountant I,32675,F,-2034,6971,15371,120751
120751,10440,2936547,Finance Manager,58200,M,1556,10440,,120262
120752,5691,15825,Accountant I,30590,M,-2144,5691,15825,120751
120753,12631,2936547,Financial Controller II,47000,M,6010,12631,,120751
120754,16922,2936547,Accountant II,34760,M,10380,16922,,120751
120755,8613,2936547,Accountant III,36440,F,1697,8613,,120751
120756,13331,2936547,Financial Controller III,52295,F,5164,13331,,120751
120757,5114,16252,Accountant III,38545,M,-5767,5114,16252,120751
120758,11962,2936547,Accountant II,34040,M,1756,11962,,120751
120759,8401,2936547,Accountant II,36230,M,1769,8401,,120746
120760,12174,2936547,Financial Controller III,53475,F,3293,12174,,120746
120761,16983,2936547,Accountant I,30960,F,9858,16983,,120746
120762,16861,2936547,Accountant I,30625,M,7245,16861,,120746
120763,5114,2936547,Auditor II,45100,M,-5545,5114,,120766
120764,15675,2936547,Auditor I,40450,M,5469,15675,,120766
120765,5114,2936547,Financial Controller III,51950,F,-1841,5114,,120766
120766,15035,2936547,Auditing Manager,53400,F,5422,15035,,120262
120767,9952,2936547,Accountant I,32965,M,1590,9952,,120766
120768,7944,16039,Accountant II,44955,M,-1989,7944,16039,120766
120769,13240,2936547,Auditor II,47990,M,5257,13240,,120766
120770,9952,15825,Auditor I,43930,F,1575,9952,15825,120766
120771,6179,2936547,Accountant II,36435,F,-1976,6179,,120766
120772,17014,2936547,HR Generalist I,27365,M,10325,17014,,120780
120773,7761,2936547,HR Generalist II,27370,F,-313,7761,,120780
120774,15400,16740,HR Specialist II,45155,F,6834,15400,16740,120780
120775,13454,2936547,HR Analyst II,41580,F,3329,13454,,120780
120776,15066,2936547,HR Generalist III,32580,M,7203,15066,,120780
120777,12539,2936547,HR Specialist I,40955,M,3372,12539,,120780
120778,8797,2936547,HR Specialist I,43650,F,-1850,8797,,120780
120779,13574,2936547,HR Analyst II,43690,F,6121,13574,,120780
120780,11596,2936547,HR Manager,62995,F,3531,11596,,120262
120781,16406,16801,Recruiter I,32620,F,10249,16406,16801,120782
120782,14396,2936547,Recruitment Manager,63915,F,5446,14396,,120262
120783,13149,2936547,Recruiter III,42975,M,5467,13149,,120782
120784,16315,2936547,Recruiter II,35715,F,7053,16315,,120782
120785,12205,2936547,Training Manager,48335,F,3308,12205,,120780
120786,5114,2936547,Trainer I,32650,F,-5767,5114,,120785
120787,13149,2936547,Trainer II,34000,M,3521,13149,,120785
120788,12753,2936547,Trainer I,33530,M,3451,12753,,120785
120789,8370,15856,Trainer III,39330,M,1656,8370,15856,120785
120790,12904,2936547,ETL Specialist II,53740,F,5454,12904,,120791
120791,9770,2936547,Systems Architect IV,61115,M,1668,9770,,120798
120792,13727,2936547,Systems Architect II,54760,F,5922,13727,,120791
120793,13301,2936547,ETL Specialist I,47155,M,3507,13301,,120791
120794,15887,2936547,Applications Developer IV,51265,F,6939,15887,,120800
120795,10440,15736,Applications Developer II,49105,M,3303,10440,15736,120794
120796,8460,2936547,Applications Developer II,47030,M,-2060,8460,,120794
120797,6544,2936547,Applications Developer I,43385,F,-1871,6544,,120794
120798,9862,2936547,Senior Project Manager,80755,F,-192,9862,,120800
120799,14184,2936547,Office Assistant III,29070,M,7021,14184,,120800
120800,13666,15736,IS Director,80210,M,5467,13666,15736,120262
120801,14426,2936547,Applications Developer I,40040,F,5178,14426,,120798
120802,6575,16252,Applications Developer IV,65125,F,-3887,6575,16252,120798
120803,6575,2936547,Applications Developer I,43630,M,-2035,6575,,120798
120804,5114,2936547,IS Administrator III,55400,M,-5803,5114,,120798
120805,14701,2936547,BI Administrator IV,58530,M,6752,14701,,120798
120806,11719,2936547,IS Administrator II,47285,F,5169,11719,,120798
120807,8036,16314,IS Administrator I,43325,F,-18,8036,16314,120798
120808,8918,2936547,BI Specialist II,44425,M,1613,8918,,120798
120809,5114,2936547,BI Architect II,47155,F,-5831,5114,,120798
120810,7365,2936547,IS Architect III,58375,M,-1915,7365,,120798
120811,12235,2936547,Applications Developer I,43985,M,3556,12235,,120814
120812,15188,2936547,Applications Developer II,45810,M,5163,15188,,120814
120813,12054,16070,Applications Developer IV,50865,M,3544,12054,16070,120814
120814,7183,2936547,Project Manager,59140,M,-212,7183,,120800
120815,16892,2936547,Service Administrator III,31590,M,10588,16892,,120719
120816,12266,2936547,Service Administrator I,30485,F,3410,12266,,120719
120992,14823,2936547,Office Assistant I,26940,F,6987,14823,,120996
120993,13574,2936547,Office Assistant I,26260,F,3639,13574,,120996
120994,12723,2936547,Office Administrator I,31645,F,5280,12723,,120996
120995,17014,2936547,Office Administrator II,34850,F,8930,17014,,120996
120996,15584,2936547,Office Assistant IV,32745,M,5315,15584,,121000
120997,13393,2936547,Shipping Administrator I,27420,F,5438,13393,,121000
120998,16527,2936547,Clerk I,26330,F,7279,16527,,120997
120999,8857,2936547,Clerk I,27215,F,-4,8857,,120997
121000,12388,2936547,Administration Manager,48600,M,1485,12388,,121141
121001,6453,2936547,Warehouse Manager,43615,M,-345,6453,,121000
121002,7274,16314,Warehouse Assistant II,26650,F,-1931,7274,16314,121001
121003,16983,2936547,Warehouse Assistant I,26000,M,10352,16983,,121001
121004,5114,2936547,Security Manager,30895,M,-5629,5114,,121000
121005,16102,2936547,Security Guard I,25020,M,8962,16102,,121004
121006,16376,16740,Security Guard I,26145,M,9781,16376,16740,121004
121007,9893,2936547,Security Guard II,27290,M,1746,9893,,121004
121008,12266,2936547,Security Guard II,27875,M,3471,12266,,121004
121009,14457,2936547,Service Administrator I,32955,M,7277,14457,,121000
121010,16861,2936547,Service Assistant I,25195,M,8992,16861,,121009
121011,5114,2936547,Service Assistant I,25735,M,-5774,5114,,121009
121012,15949,16405,Service Assistant II,29575,M,9522,15949,16405,121009
121013,14701,2936547,Electrician II,26675,M,7057,14701,,121016
121014,14457,2936547,Electrician III,28510,F,5234,14457,,121016
121015,14854,2936547,Technician I,26140,M,7286,14854,,121016
121016,16315,2936547,Technical Manager,48075,F,5862,16315,,121000
121017,16496,2936547,Technician II,29225,M,8771,16496,,121016
121018,5114,15825,Sales Rep. II,27560,F,-5842,5114,15825,121144
121019,16223,16648,Sales Rep. IV,31320,M,9672,16223,16648,121144
121020,15461,2936547,Sales Rep. IV,31750,F,8819,15461,,121144
121021,12478,2936547,Sales Rep. IV,32985,F,5457,12478,,121144
121022,15372,16314,Sales Rep. IV,32210,M,7240,15372,16314,121144
121023,10713,16679,Sales Rep. I,26010,M,1533,10713,16679,121144
121024,16192,2936547,Sales Rep. II,26600,M,9030,16192,,121144
121025,5722,2936547,Sales Rep. II,28295,M,-3735,5722,,121144
121026,16892,2936547,Sales Rep. IV,31515,M,9808,16892,,121144
121027,10927,2936547,Sales Rep. II,26165,M,1586,10927,,121144
121028,17106,2936547,Sales Rep. I,26585,M,10344,17106,,121144
121029,10927,2936547,Sales Rep. I,27225,M,1817,10927,,121144
121030,15007,2936547,Sales Rep. I,26745,M,7255,15007,,121144
121031,9344,2936547,Sales Rep. III,28060,M,1651,9344,,121144
121032,16861,2936547,Sales Rep. IV,31335,M,10281,16861,,121144
121033,16223,2936547,Sales Rep. III,29775,F,9806,16223,,121144
121034,17167,2936547,Sales Rep. II,27110,M,10462,17167,,121144
121035,5114,2936547,Sales Rep. II,26460,M,-5760,5114,,121144
121036,15979,16740,Sales Rep. I,25965,F,10426,15979,16740,121144
121037,15400,2936547,Sales Rep. III,28310,M,5276,15400,,121144
121038,17014,17198,Sales Rep. I,25285,M,10270,17014,17198,121144
121039,7426,2936547,Sales Rep. II,27460,M,-2038,7426,,121144
121040,8340,2936547,Sales Rep. III,29525,F,-179,8340,,121144
121041,5114,2936547,Sales Rep. II,26120,F,-5810,5114,,121144
121042,14549,2936547,Sales Rep. III,28845,M,7033,14549,,121144
121043,11748,2936547,Sales Rep. II,28225,F,3600,11748,,121144
121044,5691,2936547,Sales Rep. I,25660,M,-1847,5691,,121144
121045,12419,16130,Sales Rep. II,28560,F,1625,12419,16130,121143
121046,16983,17167,Sales Rep. I,25845,M,9016,16983,17167,121143
121047,17045,17226,Sales Rep. I,25820,F,7269,17045,17226,121143
121048,17045,17226,Sales Rep. I,26560,F,8941,17045,17226,121143
121049,17136,2936547,Sales Rep. I,26930,F,9541,17136,,121143
121050,17136,2936547,Sales Rep. II,26080,F,9508,17136,,121143
121051,6879,2936547,Sales Rep. I,26025,F,-3896,6879,,121143
121052,17106,2936547,Sales Rep. II,26900,M,9505,17106,,121143
121053,5145,2936547,Sales Rep. III,29955,F,-5578,5145,,121143
121054,6149,2936547,Sales Rep. III,29805,M,-1876,6149,,121143
121055,17014,2936547,Sales Rep. III,30185,M,10234,17014,,121143
121056,15826,2936547,Sales Rep. II,28325,F,8952,15826,,121143
121057,7640,2936547,Sales Rep. I,25125,M,-6,7640,,121143
121058,15614,2936547,Sales Rep. I,26270,M,5306,15614,,121143
121059,7761,16070,Sales Rep. II,27425,F,-68,7761,16070,121143
121060,5114,2936547,Sales Rep. III,28800,F,-5685,5114,,121143
121061,8948,2936547,Sales Rep. III,29815,M,-1995,8948,,121143
121062,17014,2936547,Sales Rep. IV,30305,F,9067,17014,,121145
121063,16649,2936547,Sales Rep. II,35990,M,7147,16649,,121145
121064,11566,2936547,Sales Rep. I,25110,M,1488,11566,,121145
121065,16892,2936547,Sales Rep. III,28040,F,9014,16892,,121145
121066,5114,16740,Sales Rep. II,27250,F,-5609,5114,16740,121145
121067,16861,17045,Sales Rep. IV,31865,F,9514,16861,17045,121145
121068,11932,2936547,Sales Rep. II,27550,M,3623,11932,,121145
121069,11231,2936547,Sales Rep. II,26195,M,3365,11231,,121145
121070,16833,2936547,Sales Rep. III,29385,F,9074,16833,,121145
121071,6453,2936547,Sales Rep. III,28625,M,-113,6453,,121145
121072,16315,16740,Sales Rep. I,26105,M,6949,16315,16740,121145
121073,5114,2936547,Sales Rep. I,27100,M,-3883,5114,,121145
121074,10501,2936547,Sales Rep. I,26990,M,-306,10501,,121145
121075,5114,2936547,Sales Rep. II,28395,F,-5487,5114,,121145
121076,8401,16222,Sales Rep. II,26685,M,1743,8401,16222,121143
121077,17075,2936547,Sales Rep. III,28585,M,9014,17075,,121143
121078,6879,2936547,Sales Rep. I,27485,M,-3897,6879,,121143
121079,13819,2936547,Sales Rep. I,25770,M,5267,13819,,121143
121080,10105,2936547,Sales Rep. I,32235,M,-342,10105,,121143
121081,5935,2936547,Sales Rep. III,30235,F,-3931,5935,,121143
121082,6483,2936547,Sales Rep. III,28510,M,-3832,6483,,121143
121083,6999,2936547,Sales Rep. I,27245,F,-296,6999,,121143
121084,11323,2936547,Sales Rep. I,22710,M,1689,11323,,121143
121085,17167,2936547,Sales Rep. IV,32235,M,9812,17167,,121143
121086,5114,2936547,Sales Rep. I,26820,M,-5494,5114,,121143
121087,14304,16891,Sales Rep. II,28325,F,5454,14304,16891,121143
121088,17167,2936547,Sales Rep. I,27240,M,10388,17167,,121143
121089,5295,17105,Sales Rep. II,28095,M,-1959,5295,17105,121143
121090,7336,2936547,Sales Rep. I,26600,F,-2022,7336,,121143
121091,10593,2936547,Sales Rep. II,27325,M,3337,10593,,121143
121092,15553,2936547,Sales Rep. I,25680,F,5180,15553,,121143
121093,12419,15886,Sales Rep. I,27410,M,1660,12419,15886,121143
121094,6818,2936547,Sales Rep. I,26555,M,-2185,6818,,121143
121095,11504,2936547,Sales Rep. II,28010,F,3391,11504,,121143
121096,12904,2936547,Sales Rep. I,26335,M,3425,12904,,121143
121097,13057,2936547,Sales Rep. II,26830,F,5409,13057,,121143
121098,16922,2936547,Sales Rep. I,27475,M,10308,16922,,121143
121099,14731,2936547,Sales Rep. IV,32725,M,7017,14731,,121143
121100,5935,2936547,Sales Rep. II,28135,M,-3901,5935,,121143
121101,17106,2936547,Sales Rep. I,25390,F,9736,17106,,121143
121102,16953,2936547,Sales Rep. I,27115,F,7116,16953,,121143
121103,17045,2936547,Sales Rep. I,27260,M,10345,17045,,121143
121104,9587,15371,Sales Rep. II,28315,F,1777,9587,15371,121143
121105,15706,2936547,Sales Rep. III,29545,F,7068,15706,,121143
121106,13180,2936547,Sales Rep. I,25880,M,3320,13180,,121143
121107,16983,2936547,Sales Rep. IV,31380,F,9610,16983,,121143
121108,17106,17287,Sales Rep. I,25930,F,10412,17106,17287,121143
121109,11078,2936547,Sales Rep. I,26035,M,3596,11078,,121143
121110,17136,17166,Temp. Sales Rep.,26370,M,-5740,17136,17166,121145
121111,17136,17286,Temp. Sales Rep.,26885,M,-5646,17136,17286,121145
121112,17136,17166,Temp. Sales Rep.,26855,M,9843,17136,17166,121145
121113,17136,17197,Temp. Sales Rep.,27480,F,-2140,17136,17197,121145
121114,17136,17347,Temp. Sales Rep.,26515,F,-5536,17136,17347,121145
121115,17136,17286,Temp. Sales Rep.,26430,M,-322,17136,17286,121145
121116,17136,17256,Temp. Sales Rep.,26670,F,1727,17136,17256,121145
121117,17136,17166,Temp. Sales Rep.,26640,F,5190,17136,17166,121145
121118,17136,17317,Temp. Sales Rep.,25725,M,6999,17136,17317,121145
121119,17136,17225,Temp. Sales Rep.,25205,M,1768,17136,17225,121145
121120,17136,17225,Temp. Sales Rep.,25020,F,5411,17136,17225,121145
121121,17136,17317,Temp. Sales Rep.,25735,F,9560,17136,17317,121145
121122,17136,17256,Temp. Sales Rep.,26265,M,9556,17136,17256,121145
121123,17136,17256,Temp. Sales Rep.,26410,M,-5727,17136,17256,121145
121124,17136,17166,Temp. Sales Rep.,26925,M,3333,17136,17166,121145
121125,15706,15886,Trainee,25315,M,5220,15706,15886,121145
121126,15706,15886,Trainee,26015,M,-1893,15706,15886,121145
121127,16588,16770,Trainee,25435,F,9742,16588,16770,121145
121128,15706,15886,Trainee,25405,F,5290,15706,15886,121145
121129,15706,15886,Trainee,30945,M,1582,15706,15886,121145
121130,16102,16283,Trainee,25255,M,8786,16102,16283,121145
121131,15706,15886,Trainee,25445,M,3468,15706,15886,121145
121132,15706,15886,Trainee,24390,M,-2153,15706,15886,121145
121133,15706,15886,Trainee,25405,M,7253,15706,15886,121145
121134,15706,15886,Trainee,25585,M,1644,15706,15886,121145
121135,5326,2936547,Sales Rep. I,27010,F,-2034,5326,,121145
121136,15675,16344,Sales Rep. I,27460,F,5309,15675,16344,121145
121137,16892,2936547,Sales Rep. I,27055,M,10244,16892,,121145
121138,5114,2936547,Sales Rep. I,27265,M,-3959,5114,,121145
121139,10043,2936547,Sales Rep. II,27700,F,-135,10043,,121145
121140,15066,16832,Sales Rep. I,26335,M,6962,15066,16832,121145
121141,5114,2936547,Vice President,194885,M,-5674,5114,,120261
121142,12174,2936547,Director,156065,M,3332,12174,,121141
121143,13696,2936547,Senior Sales Manager,95090,M,3617,13696,,121142
121144,11627,2936547,Sales Manager,83505,F,1640,11627,,121142
121145,5935,2936547,Sales Manager,84260,M,-3692,5935,,121142
121146,16892,2936547,Secretary III,29320,F,9839,16892,,121141
121147,10105,2936547,Secretary II,29145,F,3435,10105,,121142
121148,13880,15736,Business Analyst II,52930,M,3288,13880,15736,121141
;;;;
run;

data ORION.USCUSTOMERS;
   attrib state length=$2;
   attrib custID length=$5;
   attrib Gender length=$1 label='Customer Gender';
   attrib name length=$40 label='Customer Name';
   attrib birthDate length=8 label='Customer Birth Date' format=DATE9.;
   attrib address length=$45 label='Customer Address';

   infile datalines dsd;
   input
      state
      custID
      Gender
      name
      birthDate
      address
   ;
datalines4;
CA,4,M,James Kvarniq,5291,4382 Gralyn Rd
OR,5,F,Sandrina Stephano,7129,6468 Cog Hill Ct
NE,10,F,Karen Ballinger,9057,425 Bryant Estates Dr
NC,12,M,David Black,3389,1068 Haithcock Rd
CA,17,M,Jimmie Evans,-1963,391 Greywood Dr
NY,18,M,Tonie Asmussen,-2159,117 Langtree Ln
AZ,20,M,Michael Dineley,-259,2187 Draycroft Pl
TX,23,M,Tulio Devereaux,-3682,1532 Ferdilah Ln
CA,24,F,Robyn Klem,-213,435 Cambrian Way
NC,27,F,Cynthia Mccluney,3392,188 Grassy Creek Pl
NE,31,F,Cynthia Martinez,-147,42 Arrowood Ln
,34,M,Alvan Goheen,8783,844 Glen Eden Dr
,36,M,Phenix Hill,1553,417 Halstead Cir
,39,M,Alphone Greenwald,8972,4386 Hamrick Dr
,45,F,Dianne Patchin,7065,7818 Angier Rd
,49,F,Annmarie Leveille,8963,185 Birchford Ct
,52,M,Yan Kozlowski,3383,1233 Hunters Crossing
,56,M,Roy Siferd,-9465,334 Kingsmill Rd
,60,F,Tedi Lanzarone,3430,2429 Hunt Farms Ln
,63,M,James Klisurich,3646,25 Briarforest Pl
,69,F,Patricia Bertolozzi,7072,4948 Dargan Hills Dr
,71,F,Viola Folsom,3553,290 Glenwood Ave
,75,M,Mikel Spetz,8935,101 Knoll Ridge Ln
,79,F,Najma Hicks,9518,9658 Dinwiddie Ct
,88,M,Attila Gibbs,-316,3815 Askham Dr
,89,F,Wynella Lewis,-9226,2572 Glenharden Dr
,90,F,Kyndal Hooks,1674,252 Clay St
,92,M,Lendon Celii,-5587,421 Blue Horizon Dr
;;;;
run;

data ORION.Y2011M1;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1241054779,3,99999999,24,18629,18632
1241063739,1,121135,89,18630,18631
1241066216,1,120134,171,18631,18631
1241086052,3,99999999,53,18633,18636
1241147641,1,120131,53,18640,18640
1241235281,1,120136,171,18650,18657
1241244297,1,120164,111,18651,18651
1241263172,3,99999999,3959,18652,18653
1241286432,3,99999999,27,18655,18660
1241298131,2,99999999,2806,18656,18666
;;;;
run;

data ORION.Y2011M10;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1243515588,1,121024,89,18901,18901
1243568955,1,121060,31,18907,18907
1243643970,1,120138,171,18916,18916
1243644877,3,99999999,70079,18916,18919
1243661763,1,120124,41,18918,18918
1243670182,1,121065,69,18918,18918
1243680376,1,121061,31,18919,18919
;;;;
run;

data ORION.Y2011M11;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1243797399,1,121053,10,18932,18932
1243799681,1,120128,41,18933,18933
1243815198,1,120732,10,18934,18934
1243817278,1,120127,171,18935,18935
1243887390,2,99999999,908,18942,18946
1243951648,1,121068,34,18949,18949
1243960910,1,121028,90,18950,18950
1243963366,1,120175,215,18951,18951
1243991721,1,120124,171,18954,18954
1243992813,2,99999999,70187,18954,18959
1244066194,2,99999999,2806,18961,18965
;;;;
run;

data ORION.Y2011M12;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1244086685,3,99999999,14104,18964,18967
1244107612,1,121107,45,18966,18966
1244117101,1,121109,45,18967,18967
1244117109,1,121117,49,18967,18967
1244171290,1,121121,31,18973,18973
1244181114,1,121092,10,18974,18974
1244197366,1,121118,89,18976,18976
1244296274,1,121040,5,18987,18987
;;;;
run;

data ORION.Y2011M2;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1241359997,1,121043,12,18663,18663
1241371145,1,120124,171,18665,18665
1241390440,1,120131,41,18667,18667
1241461856,1,121042,18,18674,18675
1241561055,1,120127,171,18686,18686
;;;;
run;

data ORION.Y2011M3;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1241623505,3,99999999,24,18692,18695
1241645664,2,99999999,70100,18695,18699
1241652707,3,99999999,27,18695,18700
1241686210,1,121040,10,18699,18705
1241715610,1,121106,92,18702,18702
1241731828,1,121025,31,18704,18704
1241789227,3,99999999,17023,18711,18716
;;;;
run;

data ORION.Y2011M4;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1241895594,1,121051,56,18722,18726
1241909303,3,99999999,46966,18724,18725
1241930625,3,99999999,27,18726,18731
1241977403,1,120152,171,18732,18732
1242012259,1,121040,10,18735,18735
1242012269,1,121040,45,18735,18735
1242035131,1,120132,183,18738,18738
1242076538,3,99999999,31,18742,18746
;;;;
run;

data ORION.Y2011M5;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1242130888,1,121086,92,18748,18748
1242140006,3,99999999,5,18749,18754
1242140009,2,99999999,90,18749,18751
1242149082,1,121032,90,18750,18750
1242159212,3,99999999,5,18751,18756
1242161468,3,99999999,2550,18751,18756
1242162201,3,99999999,46966,18752,18753
1242173926,3,99999999,1033,18753,18757
1242185055,1,120136,41,18755,18755
1242214574,3,99999999,70079,18758,18761
1242229985,1,120127,171,18760,18760
1242259863,2,99999999,70187,18763,18768
1242265757,1,121105,10,18763,18763
;;;;
run;

data ORION.Y2011M6;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1242449327,3,99999999,27,18783,18788
1242458099,1,121071,10,18784,18784
1242467585,3,99999999,34,18785,18791
1242477751,3,99999999,31,18786,18790
1242493791,1,121056,5,18788,18788
1242502670,1,121067,31,18789,18789
1242515373,3,99999999,17023,18791,18796
1242534503,3,99999999,70165,18793,18800
1242557584,2,99999999,89,18795,18799
1242559569,1,120130,171,18796,18796
1242568696,2,99999999,2806,18796,18800
1242578860,2,99999999,70100,18798,18802
1242610991,1,121037,12,18801,18801
1242647539,1,121109,45,18805,18805
1242657273,1,121037,90,18806,18806
;;;;
run;

data ORION.Y2011M7;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1242691897,2,99999999,90,18810,18812
1242736731,1,121107,10,18815,18815
1242773202,3,99999999,24,18819,18822
1242782701,3,99999999,27,18820,18825
1242827683,1,121105,10,18825,18825
1242836878,1,121027,10,18826,18826
1242838815,1,120195,41,18827,18827
1242848557,2,99999999,2806,18827,18831
1242923327,3,99999999,70165,18836,18837
1242938120,1,120124,171,18838,18838
;;;;
run;

data ORION.Y2011M8;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1242977743,2,99999999,65,18842,18846
1243012144,2,99999999,2806,18845,18849
1243026971,1,120733,10,18847,18847
1243039354,1,120143,41,18849,18849
1243049938,3,99999999,53,18850,18853
1243110343,1,121032,10,18856,18856
1243127549,1,120159,171,18859,18859
1243152030,1,120734,45,18861,18862
1243152039,1,121089,90,18861,18861
1243165497,3,99999999,70201,18863,18868
1243198099,1,121061,10,18866,18866
1243227745,1,120141,171,18870,18880
;;;;
run;

data ORION.Y2011M9;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1243269405,2,99999999,928,18874,18878
1243279343,3,99999999,27,18875,18880
1243290080,1,121057,31,18876,18876
1243290089,1,121065,45,18876,18876
1243315613,1,121026,5,18879,18879
1243398628,1,121051,12,18888,18888
1243417726,1,121029,69,18890,18890
1243462945,3,99999999,24,18895,18898
1243465031,1,120195,41,18896,18896
1243485097,3,99999999,11,18898,18902
;;;;
run;

data ORION.YTD2011;
   attrib Order_ID length=8 label='Order ID' format=12.;
   attrib Order_Type length=8 label='Order Type';
   attrib Employee_ID length=8 label='Employee ID' format=12.;
   attrib Customer_ID length=8 label='Customer ID' format=12.;
   attrib Order_Date length=8 label='Date Order was placed by Customer' format=DATE9.;
   attrib Delivery_Date length=8 label='Date Order was Delivered' format=DATE9.;

   infile datalines dsd;
   input
      Order_ID
      Order_Type
      Employee_ID
      Customer_ID
      Order_Date
      Delivery_Date
   ;
datalines4;
1241054779,3,99999999,24,17168,17171
1241063739,1,121135,89,17169,17170
1241066216,1,120134,171,17170,17170
1241086052,3,99999999,53,17172,17175
1241147641,1,120131,53,17179,17179
1241235281,1,120136,171,17189,17196
1241244297,1,120164,111,17190,17190
1241263172,3,99999999,3959,17191,17192
1241286432,3,99999999,27,17194,17199
1241298131,2,99999999,2806,17195,17205
1243515588,1,121024,89,17440,17440
1243568955,1,121060,31,17446,17446
1243643970,1,120138,171,17455,17455
1243644877,3,99999999,70079,17455,17458
1243661763,1,120124,41,17457,17457
1243670182,1,121065,69,17457,17457
1243680376,1,121061,31,17458,17458
1243797399,1,121053,10,17471,17471
1243799681,1,120128,41,17472,17472
1243815198,1,120732,10,17473,17473
1243817278,1,120127,171,17474,17474
1243887390,2,99999999,908,17481,17485
1243951648,1,121068,34,17488,17488
1243960910,1,121028,90,17489,17489
1243963366,1,120175,215,17490,17490
1243991721,1,120124,171,17493,17493
1243992813,2,99999999,70187,17493,17498
1244066194,2,99999999,2806,17500,17504
1244086685,3,99999999,14104,17503,17506
1244107612,1,121107,45,17505,17505
1244117101,1,121109,45,17506,17506
1244117109,1,121117,49,17506,17506
1244171290,1,121121,31,17512,17512
1244181114,1,121092,10,17513,17513
1244197366,1,121118,89,17515,17515
1244296274,1,121040,5,17526,17526
1241359997,1,121043,12,17202,17202
1241371145,1,120124,171,17204,17204
1241390440,1,120131,41,17206,17206
1241461856,1,121042,18,17213,17214
1241561055,1,120127,171,17225,17225
1241623505,3,99999999,24,17231,17234
1241645664,2,99999999,70100,17234,17238
1241652707,3,99999999,27,17234,17239
1241686210,1,121040,10,17238,17244
1241715610,1,121106,92,17241,17241
1241731828,1,121025,31,17243,17243
1241789227,3,99999999,17023,17250,17255
1241895594,1,121051,56,17261,17265
1241909303,3,99999999,46966,17263,17264
1241930625,3,99999999,27,17265,17270
1241977403,1,120152,171,17271,17271
1242012259,1,121040,10,17274,17274
1242012269,1,121040,45,17274,17274
1242035131,1,120132,183,17277,17277
1242076538,3,99999999,31,17281,17285
1242130888,1,121086,92,17287,17287
1242140006,3,99999999,5,17288,17293
1242140009,2,99999999,90,17288,17290
1242149082,1,121032,90,17289,17289
1242159212,3,99999999,5,17290,17295
1242161468,3,99999999,2550,17290,17295
1242162201,3,99999999,46966,17291,17292
1242173926,3,99999999,1033,17292,17296
1242185055,1,120136,41,17294,17294
1242214574,3,99999999,70079,17297,17300
1242229985,1,120127,171,17299,17299
1242259863,2,99999999,70187,17302,17307
1242265757,1,121105,10,17302,17302
1242449327,3,99999999,27,17322,17327
1242458099,1,121071,10,17323,17323
1242467585,3,99999999,34,17324,17330
1242477751,3,99999999,31,17325,17329
1242493791,1,121056,5,17327,17327
1242502670,1,121067,31,17328,17328
1242515373,3,99999999,17023,17330,17335
1242534503,3,99999999,70165,17332,17339
1242557584,2,99999999,89,17334,17338
1242559569,1,120130,171,17335,17335
1242568696,2,99999999,2806,17335,17339
1242578860,2,99999999,70100,17337,17341
1242610991,1,121037,12,17340,17340
1242647539,1,121109,45,17344,17344
1242657273,1,121037,90,17345,17345
1242691897,2,99999999,90,17349,17351
1242736731,1,121107,10,17354,17354
1242773202,3,99999999,24,17358,17361
1242782701,3,99999999,27,17359,17364
1242827683,1,121105,10,17364,17364
1242836878,1,121027,10,17365,17365
1242838815,1,120195,41,17366,17366
1242848557,2,99999999,2806,17366,17370
1242923327,3,99999999,70165,17375,17376
1242938120,1,120124,171,17377,17377
1242977743,2,99999999,65,17381,17385
1243012144,2,99999999,2806,17384,17388
1243026971,1,120733,10,17386,17386
1243039354,1,120143,41,17388,17388
1243049938,3,99999999,53,17389,17392
1243110343,1,121032,10,17395,17395
1243127549,1,120159,171,17398,17398
1243152030,1,120734,45,17400,17401
1243152039,1,121089,90,17400,17400
1243165497,3,99999999,70201,17402,17407
1243198099,1,121061,10,17405,17405
1243227745,1,120141,171,17409,17419
1243269405,2,99999999,928,17413,17417
1243279343,3,99999999,27,17414,17419
1243290080,1,121057,31,17415,17415
1243290089,1,121065,45,17415,17415
1243315613,1,121026,5,17418,17418
1243398628,1,121051,12,17427,17427
1243417726,1,121029,69,17429,17429
1243462945,3,99999999,24,17434,17437
1243465031,1,120195,41,17435,17435
1243485097,3,99999999,11,17437,17441
;;;;
run;


proc datasets lib=ORION nolist nowarn;
   modify CONTINENT ;
       ic create Primary Key (Continent_ID );
   modify DISCOUNT ;
       ic create Primary Key (Product_ID Start_Date );
   modify STAFF ;
       ic create Primary Key (Employee_ID Start_Date );
quit;

proc contents data=ORION._all_ nods;
run;
