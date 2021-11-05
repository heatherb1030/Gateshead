clear all
set more off

cd "D:\ARC Gateshead\Data\"
use "LSOA_FHRS_Deprivation_Population2.dta", clear

*generate variables
*Treated Years
g Time = cond(Year > 2015, 1, 0)
*DID dummy
g DID = Time * Gateshead

*Density of all types of food outlets
g Total = TSS + PBN + RCC + RSH
g Density = Total*100000/Population

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

merge m:1 lsoacode using "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Data\FHRS\DID\PSM Results.dta"
drop _merge

keep if _weight != .

forvalues i = 2012/2019 {
	g D`i' = cond(Year == `i', 1, 0)
	replace D`i' = D`i' * Gateshead
	}

xtset LSOA Year

eststo: xi: xtreg Takeaway_Density D2012 D2013 D2014 D2016 D2017 D2018 D2019 RCC_Density PBN_Density RSH_Density i.Year, fe cluster(LSOA)
eststo: xi: xtreg Takeaway_Proportion D2012 D2013 D2014 D2016 D2017 D2018 D2019 RCC_Density PBN_Density RSH_Density i.Year, fe cluster(LSOA)
cd "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Tables"
esttab _all using "Table A3.csv", b(3) se(3) r2(3) nogap star( * 0.10 ** 0.05 *** 0.01) replace
eststo clear 


