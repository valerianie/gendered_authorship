clear all
set more off

global SOURCE "N:/BibliometricsGenderRatio/datasets/source/"
global DERIVED "N:/BibliometricsGenderRatio/datasets/derived/"

******************* STEP 1 ***
*** IMPORT NAME DATABASE *****
******************************

import excel $SOURCE/02_NAMES.xlsx, sheet("nam_dict") firstrow allstring 

order name1 gender1 
drop C D E F G H I J descripti~1f

bysort name1: g help = 1 if name1[_n+1] != name1[_n]
recode help . = 0
bysort name1: egen help1 = mean(help)
replace gender1 = "0" if help1 != 1
drop if help == 0
drop help*
br

//mit diesem Schritt habe ich Namen, die die Datenbank mehrfach aufgeführt und mehreren Kategorien zugeordnet hatte, als "unbekannte Kategorie" codiert und die Doppelungen gelöscht.

save 02_NAMES.dta, replace
*use 02_NAMES.dta, clear

******************* STEP 2 ***
*** IMPORT AUTHOR DATABASE ***
******************************

import delimited $SOURCE/01_DATA.csv, clear 

save 01_DATA.dta, replace
*use 01_DATA.dta, clear

******************* STEP 3 ***
*** GENERATE COAUTHORSHIP ****
******************************

gen co_auth = 2 
replace co_auth = 1 if missing(name2)
codebook co_auth

//co_auth = 1 wenn Einzelautor_in, co_auth = 2 wenn Kooperation

******************* STEP 4 ***
*** RESHAPE DATA *************
******************************

gene seqnum=_n
reshape long name, i(seqnum) j(auth_number)
br
drop if missing(name)

//in diesem Schritt habe ich allen Publikationen eine Sequenznummer zugewiesen, die sie innerhalb dieser Arbeit identifizierbar macht. Im Anschluss habe ich die Daten von einem weiten in ein langes Format gebracht.

******************* STEP 5 ***
*** GENERATE FIRST AUTHOR ****
******************************

g first_auth = auth_number

******************* STEP 6 ***
*** ORDER ********************
******************************

rename name name1
order seqnum auth_number name* surname* co_auth subfield title
br

save 01_DATA.dta, replace

******************* STEP 7 ***
*** MERGING BOTH DATASETS ****
******************************

use 01_DATA, clear
merge m:m name1 using 02_NAMES, keep(master match)
gsort seqnum 

******************* STEP 8 ***
*** CLEAN & ORDER ************
******************************

replace surname1 = "." if auth_number != 1
replace surname2 = "." if auth_number != 2
replace surname3 = "." if auth_number != 3
replace surname4 = "." if auth_number != 4

g surname = surname1
replace surname = surname2 if surname2 != "."
replace surname = surname3 if surname3 != "."
replace surname = surname4 if surname4 != "."
drop surname1 surname2 surname3 surname4
br

//in diesem Schritt habe ich aus allen Beobachtungen jene Nachnamen gelöscht, die nicht zu den Autor_innen dieser Beobachtung gehörten
//Erklärung: durch reshape waren die Nachnamen aller Autor_innen einer Publikation in jede Beobachtung für diese Publikation mit eingeflossen

g gender = real(gender1)
replace gender = . if gender == 0 | gender == 3 | gender == 4
replace gender = 0 if gender == 2
drop gender1

order seqnum auth_number name1 surname gender co_auth first_auth subfield title
br

******************* STEP 9 ***
*** EDIT GENDER IF MISSING ***
****************************** 

g gender_code = 1
replace gender_code = . if gender == . 

//gender_code nimmt den Wert 1 an, wenn die Namenszuordnung automatisch geschieht

ed

//In diesem Schritt ordne ich per Personenidentifikation durch Internetrecherche Personen ein Geschlecht zu.

*save 01_DATA_ed.dta, replace


****************** STEP 10 ***
*** DESCRIPTIVES *************
****************************** 

use 01_DATA_ed.dta, clear

tab gender year, row col chi
tab gender subfield, row col chi
tab gender subfield if year == 2010, row col chi
tab gender co_auth, row col chi
tab gender first_auth, row col chi

tab gender subfield if first_auth == 1, row col chi
tab gender subfield if co_auth == 1, row col chi

tab subfield year if gender == 1, col chi
tab subfield year if gender == 0, col chi

label define subfield 1 "Fertility" 2 "Mortality" 3 "Migration" 4 "Socioecon" 5 "Formal Demo" 6 "Others" 7 "Health&Care"
label values subfield subfield
graph pie if gender == 1, over(subfield) 
graph bar gender, over(subfield) stack
histogram subfield if gender == 1, discrete frequency xtitle(Subfield)
histogram subfield if gender == 0, discrete frequency xtitle(Subfield)


****************** STEP 11 ***
*** MULTIVARIATE *************
****************************** 

logit gender ib1995.year ib1.subfield
margins ib1995.year ib1.subfield, atmeans
estat classification
estat gof






