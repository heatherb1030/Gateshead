clear all
set more off

cd "D:\ARC Gateshead\Data\"
use "LSOA_FHRS_Deprivation_Population2.dta", clear

*Calculating Weight
duplicates drop LSOA, force
drop Year
logistic Gateshead Area_Sq_Km incomedecile employmentdecile educationandskillsdecile healthanddisabilitydecile crimedecile barrierstohousingservicesdecile livingenvironmentdecile idacidecile, coef

predict p_Gateshead, pr
gen weight=.
replace weight = 1/p_Gateshead if Gateshead==1
replace weight = 1/(1-p_Gateshead) if Gateshead==0
save "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Data\FHRS\IPW\IPW.dta",replace

*IPW Estimate
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
*Density of takeaways
g Takeaway_Density = TSS*100000/Population
*Proportion of Takeaways (100%)
g Takeaway_Proportion = TSS*100/Total
*Density of restaurants
g RCC_Density = RCC*100000/Population
*Density of Pub/Bar/NightClub
g PBN_Density = PBN*100000/Population
*Density of Supermarkets/hypermarkets
g RSH_Density = RSH*100000/Population
*Density of other retailers
g RO_Density = RO*100000/Population

*Match with the IPW
merge m:1 lsoacode using "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Data\FHRS\IPW\IPW.dta"
drop _merge

*Regression (No Weight)
xtset LSOA Year
eststo: xi: xtreg Takeaway_Density DID i.Year, fe cluster(LSOA) 
eststo: xi: xtreg Takeaway_Density DID RCC_Density PBN_Density RSH_Density i.Year, fe cluster(LSOA)

eststo: xi: xtreg Takeaway_Proportion DID i.Year, fe cluster(LSOA)
eststo: xi: xtreg Takeaway_Proportion DID RCC_Density PBN_Density RSH_Density i.Year, fe cluster(LSOA)
cd "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Tables"
esttab _all using "Table A2.csv", b(3) se(3) r2(3) nogap star( * 0.10 ** 0.05 *** 0.01) replace
eststo clear 

*Regression (Weight)
eststo: xi: xtreg Takeaway_Density DID i.Year [pweight=weight], fe cluster(LSOA) 
eststo: xi: xtreg Takeaway_Density DID RCC_Density PBN_Density RSH_Density i.Year [pweight=weight], fe cluster(LSOA)

eststo: xi: xtreg Takeaway_Proportion DID i.Year [pweight=weight], fe cluster(LSOA)
eststo: xi: xtreg Takeaway_Proportion DID RCC_Density PBN_Density RSH_Density i.Year [pweight=weight], fe cluster(LSOA)
cd "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Tables"
esttab _all using "Table A4.csv", b(3) se(3) r2(3) nogap star( * 0.10 ** 0.05 *** 0.01) replace
eststo clear 
