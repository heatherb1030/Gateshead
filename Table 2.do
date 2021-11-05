clear all
cd "D:\ARC Gateshead\Data\"
use "LSOA_FHRS_Deprivation_Population2.dta", clear

merge m:1 lsoacode using "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Data\FHRS\DID\PSM Results.dta"
drop _merge

*drop unmatched samples
keep if _weight != .

keep Gateshead Year TSS RCC PBN RSH 

collapse (sum) TSS RCC PBN RSH, by(Gateshead Year)

rename TSS Number14
rename PBN Number9
rename RCC Number10
rename RSH Number12

reshape long Number, i(Gateshead Year) j(BusinessType)
reshape wide Number, i(Gateshead BusinessType) j(Year)

export excel using "C:\Users\Huash\OneDrive - Newcastle University\SPD Evaluation Gateshead\Tables\Number of Foodoutlets.xlsx", firstrow(variables) replace