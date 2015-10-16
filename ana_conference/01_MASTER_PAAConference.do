clear all
set more off

global SOURCE "C:\Users\v.nieberg\Documents\GitHub\gendered_authorship"


******************* STEP 1 ***
*** IMPORT AUTHOR DATABASE ***
******************************

cd $SOURCE\source_files\name_database
use 02_NAMES.dta, clear
import delimited $SOURCE\source_files\paa_conference\txt_files\paa_conference_final.txt, varnames(1) clear 
cd $SOURCE\source_files\paa_conference
save paa_conference_final.dta, replace

******************* STEP 2 ***
*** NAMING VARIABLES *********
******************************

rename v20 author8_firstname
rename v21 author8_name
rename v22 author9_firstname
rename v23 author9_name
rename v24 author10_firstname
rename v25 author10_name
rename v26 author11_firstname
rename v27 author11_name
rename v28 author12_firstname
rename v29 author12_name
rename v30 author13_firstname
rename v31 author13_name
rename v32 author14_firstname
rename v33 author14_name

rename author1_firstname firstname1
rename author1_name surname1
rename author2_firstname firstname2
rename author2_name surname2
rename author3_firstname firstname3
rename author3_name surname3
rename author4_firstname firstname4
rename author4_name surname4
rename author5_firstname firstname5
rename author5_name surname5
rename author6_firstname firstname6
rename author6_name surname6
rename author7_firstname firstname7
rename author7_name surname7
rename author8_firstname firstname8
rename author8_name surname8
rename author9_firstname firstname9
rename author9_name surname9
rename author10_firstname firstname10
rename author10_name surname10
rename author11_firstname firstname11
rename author11_name surname11
rename author12_firstname firstname12
rename author12_name surname12
rename author13_firstname firstname13
rename author13_name surname13
rename author14_firstname firstname14
rename author14_name surname14

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
