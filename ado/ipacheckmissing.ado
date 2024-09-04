*! version 4.1.0 08apr2024
*! Innovations for Poverty Action
* ipacheckmissing: Outputs a table showing information missing data in survey

program ipacheckmissing, rclass
	
	version 17

	#d;
	syntax 	varlist,
        	[DROPvars(varlist)] 
        	OUTFile(string)
        	[show(string)]
        	[OUTSHeet(string)]  
			[SHEETMODify SHEETREPlace]
		;	
	#d cr

	qui {

		* create temp vars
		tempvar tmv_uniq_index

		preserve
	
		* show(): if % -- check that value is within 0 to 100
		* 		  if not specified, default to 0
		if "`show'" ~= "" {
			if regexm("`show'", "%") {
				loc show_val = real(subinstr("`show'", "%", "", .))/100
				if !inrange(`show_val', 0, 1) {
					dis as err "option show(`show') must be in range 0% to 100%.", 				///
					           "Use appropraite percentage value or use an absolute number.",	///
					           "eg. show(10%) or show(15)"
					ex 198
				}
			}
		}
		else loc show_val = 0

		* set default outsheet
		if "`outsheet'" == "" loc outsheet "missing"

		* create output frame
		cap frame drop frm_missing
		#d;
		frames 	create 	frm_missing 
				str32  	variable 
				str80 	label 
				double  (percent_missing number_missing number_unique) 
				str3    important_var
			;
		#d cr

		* list important vars
		if "`priority'" ~= "" unab priority: `priority'

		* unabbrev varlist
		unab vars: `varlist'

		* list vars to check
		loc vars: list vars | priority

		* create & post stats for each variable
		foreach var of varlist `vars' {
			
			qui count if missing(`var')
			loc missing_cnt `r(N)'
			
			bys `var': gen `tmv_uniq_index' = _n
			count if !missing(`var') & `tmv_uniq_index' == 1
			loc unique_cnt `r(N)'
			drop `tmv_uniq_index'

			if "`priority'" ~= "" loc important_var: list var in priority

			* post results to frame
			frames post ///
				frm_missing ("`var'") 				///
							("`:var lab `var''") 	///
							(`missing_cnt'/`=_N') 		///
							(`missing_cnt') 	///
							(`unique_cnt') 			///
							("`important_var'")
		}
		
		* drop unnecessary variables
		loc cto_list "device_info deviceid duration endtime formdef_version" ///
			"key starttime submissiondate username uuid uuid_confirm caseid" ///
			"devicephonenum audio_audit"
		local drop_vars "`dropvars'"
		loc drop_list ""
		foreach var of local cto_list {
			cap confirm var `var' 
			if _rc == 0 {
				loc drop_list `drop_list' `var'
			}
		}
		if "`drop_vars'" != "" {
			foreach var of local drop_vars {
				cap confirm var `var' 
				if _rc == 0 {
					loc drop_list `drop_list' `var'
				}
				else {
					di as err "Warning: Variable `var' not found and not added to drop list."
				}
			}
		}
		
		frames frm_missing {
			foreach var of local drop_list {
				drop if variable == "`var'"
			}
		}
			

		* export results
		frames frm_missing {
		    
			loc varscount = wordcount("`vars'")
			
			count if percent_missing == 1
			loc allmisscount `r(N)'

			count if number_missing > 0
			loc misscount `r(N)'

			* apply show option
			if regexm("`show'", "%") {
				drop if float(percent_missing) < float(`show_val')
			}
			else if "`show'" ~= "" drop if number_missing < `show'
			
			* sort data by importance & percent missing
			gsort -percent_missing -number_missing variable
			
			lab var percent_missing "% missing"
			lab var number_missing 	"# missing"
			
			drop number_unique important_var
			
			* export & format output
			export excel using "`outfile'", first(varl) sheet("`outsheet'") `sheetmodify' `sheetreplace'
			ipacolwidth using "`outfile'", sheet("`outsheet'")
			ipacolformat using "`outfile'", sheet("`outsheet'") vars("percent_missing") format("percent_d2")
			iparowformat using "`outfile'", sheet("`outsheet'") type(header)
		}
	}
	
	frame drop frm_missing

	noi disp "Found {cmd:`allmisscount'} of `varscount' variables with all missing values."
	noi disp "Found {cmd:`misscount'} of `varscount' variables with at least 1 missing values."

	return local N_vars 	= `varscount'		
	return local N_allmiss 	= `allmisscount' 
	return local N_miss 	= `misscount'
	
end
