clear all
set more off

*This do file shows the codes for propensity score matching (PSM) and difference in differences (DID) estimates
*First, we merge the deprivation data for the LAs in the North East. We need the deprivation to perform PSM. (As mentioned in the "Data.do", the deprivation information was dropped from the "DID Regression.dta" when collapsed from postcode level to LSOA level)
*Then, we use a logit regression to perform PSM
*Finally, we run DID by using the matched sample

*PSM matching
cd "D:\ARC Gateshead\Data\"
use "LSOA_FHRS_Deprivation_Population2.dta", clear

*Drop years since the matching characteristics are constant
duplicates drop LSOA, force
drop Year

*PSM (Table A1)
psmatch2 Gateshead Area_Sq_Km incomedecile employmentdecile educationandskillsdecile healthanddisabilitydecile crimedecile barrierstohousingservicesdecile livingenvironmentdecile idacidecile, common logit caliper(.01) noreplacement

///This code generates some new variables. 
///_treated is the treatment dummy; 
///_support indicates whether if the unit is matched with an untreated unit (note: all untreated unit is defined as on support);
///_weight refers matching numbers (We use noreplacement, so the value should be either 1 or missing. Without noreplacement, some of the untreated LSOAs can be matched with more than 1 treated LSOAs);
///_pdif is the matching score difference between the matched treated and untreated LSOAs, i.e. the _pscore difference. We use caliper(0.01), so _pdif should be smaller than 0.01.

*PSM test
pstest

*save matching results
keep lsoacode _pscore _weight _pdif _support
save "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Data\FHRS\DID\PSM Results.dta",replace

*DID Estimates
clear all
cd "D:\ARC Gateshead\Data\"
use "LSOA_FHRS_Deprivation_Population2.dta", clear

*generate variables
*Treated Years
g Time = cond(Year > 2015, 1, 0)
*DID dummy
g DID = Time * Gateshead

*Number of all 4 types of food outlets
g Total = TSS + PBN + RCC + RSH
g Density = Total*100000/Population

*Density of takeaways
g Takeaway_Density = TSS*100000/Population

*Proportion of Takeaways (100%)
g Takeaway_Proportion = TSS*100/Total

*Density of restaurants
g RCC_Density = RCC*100000/Population
*Proportion of restaurants (100%)
g RCC_Proportion = RCC*100/Total

*Density of Pub/Bar/NightClub
g PBN_Density = PBN*100000/Population

*Density of Supermarkets/hypermarkets
g RSH_Density = RSH*100000/Population

*Density of other retailers
g RO_Density = RO*100000/Population

*Match with the PSM results
merge m:1 lsoacode using "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Data\FHRS\DID\PSM Results.dta"
drop _merge

*drop unmatched samples
keep if _weight != .

xtset LSOA Year

*DID regression after PSM
eststo: xi: xtreg Takeaway_Density DID i.Year, fe cluster(LSOA)
eststo: xi: xtreg Takeaway_Density DID RCC_Density PBN_Density RSH_Density i.Year, fe cluster(LSOA)

eststo: xi: xtreg Takeaway_Proportion DID i.Year, fe cluster(LSOA)
eststo: xi: xtreg Takeaway_Proportion DID RCC_Density PBN_Density RSH_Density i.Year, fe cluster(LSOA)

cd "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Tables"
esttab _all using "Table 3.csv", b(3) se(3) r2(3) nogap star( * 0.10 ** 0.05 *** 0.01) replace
eststo clear 

*Density of other types of food outlets
eststo: xi: xtreg RCC_Density DID Takeaway_Density PBN_Density RSH_Density i.Year, fe cluster(LSOA)
eststo: xi: xtreg RCC_Proportion DID Takeaway_Density RCC_Density RSH_Density i.Year, fe cluster(LSOA)

esttab _all using "Table 4.csv", b(3) se(3) r2(3) nogap star( * 0.10 ** 0.05 *** 0.01) replace
eststo clear 




