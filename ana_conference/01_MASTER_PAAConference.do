clear all
set more off

global SOURCE "C:\Users\v.nieberg\Documents\GitHub\gendered_authorship"

******************* STEP 1 ***
*** IMPORT NAME DATABASE *****
******************************
*import delimited $SOURCE\source_files\02_NAMES.csv

*order name1 gender1 
*drop v3 v4 v5 v6 v7 v8 v9 v10 description0genderunknown1female

*bysort name1: g help = 1 if name1[_n+1] != name1[_n]
*drop if help == .
*drop help

*replace gender 

*replace gender1 = "2" if name1 == "James" | name1 == "George" | name1 == "Larry" | name1 == "John" | | name1 == "Jack" | name1 == "Paul" | name1 == "Harry" | name1 == "Max" | name1 == "Steven"
*replace gender1 = "1" if name1 == "Susan" | name1 == "Maria" 
*br

//mit diesem Schritt habe ich Namen, die die Datenbank mehrfach aufgefuehrt und mehreren Kategorien zugeordnet hatte, als "unbekannte Kategorie" codiert und die Doppelungen gel򳣨t.
//es fehlt der Umkodierungsschritt. Es soll sein: gender nimmt den Wert 1 fuer eine Frau an, 0 fuer einen Mann, und missing fuer unklar. 

*save 02_NAMES.dta, replace

******************* STEP 2 ***
*** IMPORT AUTHOR DATABASE ***
******************************

cd $SOURCE\source_files\name_database
use 02_NAMES.dta, clear\
//dies ist die korrekt bearbeite Datenbank und abweichend von der oben codierten (work in progress)
import delimited $SOURCE\source_files\paa_conference\txt_files\paa_conference_final.txt, varnames(1) clear 
save paa_conference_final.dta, replace

******************* STEP 3 ***
*** GENERATE COAUTHORSHIP ****
******************************
use paa_conference_final.dta, clear

gen co_auth = 2 
replace co_auth = 1 if missing(author2_firstname)
codebook co_auth

//co_auth = 1 wenn Einzelautor_in, co_auth = 2 wenn Kooperation

******************* STEP 4 ***
*** RESHAPE DATA *************
******************************

gene seqnum=_n

rename author1_firstname firstname1
rename author1_name surname_author1
rename author2_firstname firstname2
rename author2_name surname_author2
rename author3_firstname firstname3
rename author3_name surname_author3
rename author4_firstname firstname4
rename author4_name surname_author4
rename author5_firstname firstname5
rename author5_name surname_author5
rename author6_firstname firstname6
rename author6_name surname_author6
rename author7_firstname firstname7
rename author7_name surname_author7
 

reshape long firstname, i(seqnum) j(auth_number)
drop if mi(firstname)
order seqnum auth_number
*br

//in diesem Schritt habe ich allen Publikationen eine Sequenznummer zugewiesen, die sie innerhalb dieser Arbeit identifizierbar macht. Im Anschluss habe ich die Daten von einem weiten in ein langes Format gebracht.

******************* STEP 5 ***
*** GENERATE CO VARIABLES ****
******************************

g authorship = .
replace authorship = 1 if co_auth == 1 & auth_number == 1
replace authorship = 2 if co_auth == 2 & auth_number == 1
replace authorship = 4 if co_auth == 2 & auth_number[_n+1] == 1
replace authorship = 3 if authorship == .

// 1 = single authorship, 2 = multiple authorship & first author, 3 = multiple authorship & middle author, 4 = multiple authorship & last author


******************* STEP 6 ***
*** ORDER ********************
******************************

order seqnum firstname* surname* authorship title
rename firstname name1
*br

save 02_paa_conference.dta, replace

******************* STEP 7 ***
*** MERGING BOTH DATASETS ****
******************************

use 02_paa_conference.dta, clear
merge m:1 name1 using 02_NAMES, keep(master match)
gsort seqnum name* surname* authorship title

******************* STEP 8 ***
*********** ORDER ************
******************************

g gender = real(gender1)
replace gender = . if gender == 0 | gender == 3 | gender == 4
replace gender = 0 if gender == 2
drop gender1

g gender_code = 1
replace gender_code = 2 if gender == . 

//gender_code nimmt den Wert 1 an, wenn die Namenszuordnung automatisch geschieht

order seqnum year auth_number name1 gender gender_code authorship
gsort seqnum year auth_number
*br

******************* STEP 9 ***
*** EDIT GENDER IF MISSING ***
****************************** 
 
ed

//In diesem Schritt ordne ich per Personenidentifikation durch Internetrecherche Personen ein Geschlecht zu.

save paa_conference_gendered.dta, replace
