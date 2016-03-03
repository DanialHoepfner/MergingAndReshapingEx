********************************************************************************
********************************************************************************
********************************************************************************
************Do File to take WElong and EElong to Technocrats********************
*****************DATA RESHAPING AND MERGING EXAMPLE*****************************
*************************Written in STATA 14************************************
********************************************************************************
****Note: Data has been abbreviated and is only to be used demonstrate code
cd "YOUR CURRENT DIRECTORY GOES HERE" //Be sure to use files for your version of STATA
*** Use Western Europe Dataset to start
use "WElongEx.dta", clear
append using "EElongEx.dta", force //Eastern Europe data was gathered later and separately, appended to West Europe
save "EEWElongEx.dta", replace

***** Data structure is currently Ministers nested in administrations(or governments as they are referred to in Europe)
*****Project requires single observation per Government, but all minister data should be maintained
*****Solution is to reshape the data to be wide, so that there is a variable for each minister for each variable for that minister
tab gov2, miss //No missing government codes to interfere
gen tag=1 if min>8 //Ministers past 8 do not have a portfolio, and since they are irrelevant to study, only add empty observations for the most part

tab min if ccode<23
tab min if ccode<23&tag!=1
tab min if ccode>22
tab min if ccode>22&tag!=1 //Checking distribution of ministers in East/West Europe
drop if min>8 //getting rid of any minister not in one of our portfolios
drop tag
***Below are variables which should be constant at government level

drop n // old number variable used for recoding and listing tasks
reshape wide minid party	newtogov noparty partyfamily	totalseatslower	partyseatslower	welfare	markecon welfexp	welflimit	laborpos	laborneg	minheldbyparty	rile	pjoint	progtype	planecon	gender	gendercode	born	birthplace	war	wardesc	education	edulevel	edusubcat1	edusubcat2	edusubcat3	economist	priorprofcat1	priorprofcat2	priorprofcat3		yearsmin	portsheld	preapptpolitics	postapptpolitics	priorparlexp	cmp	died	portfolio, i(gov2) j(min)

/*(DO FILE WON"T RUN FROM START TO FINISH) Must stop here  and run following commands to fix data entry errors
*^Remove slash and run to continue

reshape error //Misentered data in original sets, variables which should be consistent within a government are not, need to be fixed
tab leader_id if ccode<22
replace leader_id=12121 if gov2==120530
replace leader_id=22108 if gov2==220174
reshape wide minid party	newtogov noparty partyfamily	totalseatslower	partyseatslower	welfare	markecon welfexp	welflimit	laborpos	laborneg	minheldbyparty	rile	pjoint	progtype	planecon	gender	gendercode	born	birthplace	war	wardesc	education	edulevel	edusubcat1	edusubcat2	edusubcat3	economist	priorprofcat1	priorprofcat2	priorprofcat3		yearsmin	portsheld	preapptpolitics	postapptpolitics	priorparlexp	cmp	died	portfolio, i(gov2) j(min)
*****Data are now wide, numbers after variable names are the minister to which they refer
***** For example, Prime ministers are number 1, finance ministers number 3, will be labelled later for ease of reading

sum minid1 if ccode<23
sum minid1 if ccode>22
forvalues i=1/8 {
di "Minister :`i'"
sum edulevel`i' if ccode>22
sum minid`i' if ccode>22
}
***************making sure everything is still in order, plenty of missingness for non-PM, non-FINANCE, and non-ECON but that's as it should be(Hasn't been gathered yet)
save "EEWEwideEx.dta", replace //government  level wide data now complete and proper

*****************Fixing errant TOGs, other errors made by data enterers
***Fixing Dini 1
tab tog if gov2==120530
recode tog (8=7) if gov2==120530
***Fixing Papademos 1
tab tog if gov2==90191
recode tog (3=6) if gov2==90191
***Fixing Samaras 1
tab tog if gov2==90200
recode tog (3=6) if gov2==90200
***Fixing Monti 1 in 2011
tab tog if gov2==120620
replace tog=7 if gov2==120620
***Fixing Monti 1 in 2012
recode tog (6=7) if gov2==120621
***Fixing Moro V
recode tog (6=1) if gov2==120330
***Fixing Andreotti V
recode tog (6=2) if gov2==120360
***Fixing Andreotti V
recode tog (6=2) if gov2==120361
********************************************************************************
********************************************************************************
********************************************************************************
****************************Coding Main Variables ******************************
********************************************************************************
********************************************************************************

*******Coding technocrats
gen techno3=0 if minid3!=.
recode techno3 (0=1) if (priorprofcat13==1|priorprofcat23==1|priorprofcat33==1 ///
|priorprofcat13==2|priorprofcat23==2|priorprofcat33==2 ///
|priorprofcat13==3|priorprofcat23==3|priorprofcat33==3 ///
|priorprofcat13==8|priorprofcat23==8|priorprofcat33==8 ///
|priorprofcat13==14|priorprofcat23==14|priorprofcat33==14 ///
|priorprofcat13==7|priorprofcat23==7|priorprofcat33==7 ///
|priorprofcat13==9|priorprofcat23==9|priorprofcat33==9 ///
|priorprofcat13==17|priorprofcat23==17|priorprofcat33==17 ///
|priorprofcat13==25|priorprofcat23==25|priorprofcat33==25) ///
&priorparlexp3==0

*******Coding Strict technocrats
bysort minid3: egen parl3=mean(priorparlexp3) //Technocrats who never enter office, if the mean value of their prior parliamentary experience is anything other than 0 they did eventually go into parliament
tab parl3, miss
replace parl3=1 if parl3!=0&parl3!=.
tab parl3
gen strtechno3=0 if minid3!=.
recode strtechno3 (0=1) if (priorprofcat13==1|priorprofcat23==1|priorprofcat33==1 ///
|priorprofcat13==2|priorprofcat23==2|priorprofcat33==2 ///
|priorprofcat13==3|priorprofcat23==3|priorprofcat33==3 ///
|priorprofcat13==8|priorprofcat23==8|priorprofcat33==8 ///
|priorprofcat13==14|priorprofcat23==14|priorprofcat33==14 ///
|priorprofcat13==7|priorprofcat23==7|priorprofcat33==7 ///
|priorprofcat13==9|priorprofcat23==9|priorprofcat33==9 ///
|priorprofcat13==17|priorprofcat23==17|priorprofcat33==17 ///
|priorprofcat13==25|priorprofcat23==25|priorprofcat33==25) ///
&parl3==0
drop parl3
*******Coding Technopols
gen technopol3=0 if minid3!=.
recode technopol3 (0=1) if priorparlexp3==1&((edulevel3==4&edusubcat13==1) ///
|(priorprofcat13==1|priorprofcat23==1|priorprofcat33==1| ///
priorprofcat13==25|priorprofcat23==25|priorprofcat33==25))

******Coding PhD Economists
gen phdeconomin3=0 if minid3!=.
recode phdeconomin3 (0=1) if edulevel3==4&edusubcat13==1

sum techno3 strtechno3 technopol3 phdeconomin3 if ccode<23
sum techno3 strtechno3 technopol3 phdeconomin3 if ccode>22 
*All categories correctly coded in East an West Europe
gen partisan3=0 if minid3!=.
recode partisan3 (0=1) if techno3==0&technopol3==0
tab techno3 if technopol3==1
tab technopol3 if techno3==1
tab partisan3 if technopol3==1
tab partisan3 if techno3==1  
// Technopols technocrats and partisans are mutually exclusive as they should be
************Encoding government start and end dates
gen govstartenc=date(govstartdate, "DMY") if ccode>22
replace govstartenc=date(govstartdate, "DMY", 2016) if ccode<23 //Dates were coded differently in East and West Europe, now in STATA readable form

tab gedate if ccode>22
gen govendenc=date(gedate, "DMY") if ccode>22
replace govendenc=date(gedate, "DMY", 2016) if ccode<23 //Same for government end date
format govstartenc %td //Formatted to be human readable
format govendenc %td
tab govstartenc 
tab govendenc

*Appointment dates of various types of finance ministers and their effect on sovereign bond yeilds was goal of study 
*Below variable code those dates, newtogov3 means that the finanance minister is
* new in this government, i.e. the lag of minid3, is not equal to minid3
gen	techinoff3d	=govstartenc if newtogov3==1& techno3==1 
gen	strtechinoff3d	=govstartenc if newtogov3==1&strtechno3 ==1
gen	technopol3d	=govstartenc if newtogov3==1& technopol3==1
gen	phdeconmininoff3d	=govstartenc if newtogov3==1& phdeconomin3==1
gen partisaninoff3d =govstartenc if newtogov3==1& partisan3==1

format techinoff3d %td
format strtechinoff3d %td
format technopol3d %td
format phdeconmininoff3d %td
format partisaninoff3d %td //Human readable formats

gen year=year(govstartenc)
gen month=month(govstartenc) //getting years and months to merge monthly and yearly OECD economic information

label variable techno3 "Finance Technocrat" 
label variable strtechno3 "Finance Strict Technocrat" 
label variable technopol3 "Finance Technopol"
label variable phdeconomin3 "Finance PhD Economist"
label variable partisan3 "Finance Partisan"
forvalues i= 1/8 {
label variable newtogov`i' "`i' New to Government"
}
label variable gov2 "Distinct Among States Government Code" 
label variable govstartdate "Orginal Start Date"
label variable gedate "Original End Date"
label variable reshuffle "Government Resulted From Reshuffle"
label variable multiparty "Multiparty Government"
label variable leader_id "Government Leader ID"
label variable partiesingovt "Number of Partys in Government"
label variable tog "Type of Government"
label variable rft "Reason For Termination"
label variable cpg "CPG Measure"
label variable country "Country"
label variable ccode "Ministers Dataset Country Code"
label variable government "Minister Government Code"
label variable gcount "Government Code to use for lags"

****Labelling variables so at least the lables show ministry positions rather than just numbers
forvalues i=1/8 {
	local vlist="minid`i' party`i' partyfamily`i' totalseatslower`i' partyseatslower`i' welfare`i' markecon`i' welfexp`i' welflimit`i' laborpos`i' laborneg`i' minheldbyparty`i' rile`i' pjoint`i' progtype`i' planecon`i' gender`i' gendercode`i' born`i' birthplace`i' war`i' wardesc`i' education`i' edulevel`i' edusubcat1`i' edusubcat2`i' edusubcat3`i' economist`i' priorprofcat1`i' priorprofcat2`i' priorprofcat3`i'  yearsmin`i' portsheld`i' preapptpolitics`i' postapptpolitics`i' priorparlexp`i' noparty`i' cmp`i' died`i' portfolio`i' newtogov`i'"
	local post= "PM Foreign Finance Economics Budget Health Labour SocialAffairs" 
	local pos : word `i' of `post'
	foreach v in `vlist' {
			local label : var label `v'
			local label : subinstr local label "`i'" "`pos'", all
			label var `v' `"`label'"'
	}
}

label variable govstartenc "Government Start" 
label variable govendenc "Government End"

label variable  techinoff3d "Date Technocrat Enters Office"
label variable  strtechinoff3d "Date Strict Technocrat Enters Office"
label variable  technopol3d "Date Technopol Enters Office"
label variable  phdeconmininoff3d "Date PhD Economist Enters Office"
label variable  partisaninoff3d "Date Partisan Enters Office"

save "EEWEwideEx.dta", replace //government  level wide data now complete 

****************Merging OECD data into government unit of obs dataset 
merge m:1 ccode year month using "oecda.dta"
drop if _merge==2 //Dropping observations that are in OECD data but not government data
rename _merge _mergeOECD

merge m:1 ccode year using "eubmedianvoter.dta"
drop if _merge==2 //Dropping observations that are in Eurobarometer data but not government data
rename _merge _mergeEUB
label variable lrag "Left/Right(EUB)"

save "FinalGovObsEx.dta", replace

***Country by country frequency of types
tab ccode techno3 
tab ccode strtechno3 
tab ccode technopol3 
tab ccode partisan3 
tab ccode phdeconomin3 




