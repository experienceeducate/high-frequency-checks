*! version 4.1.0 08apr2024
*! Innovations for Poverty Action
* ipacheckoutliers: Flag outliers in numeric variables

program ipacheckoutliers, rclass
	
	
	version 17

	#d;
	syntax 	,
			[SHeet(string)]
        	OUTFile(string)
        	[OUTSheet(string)]  
			id(varname) 
        	ENUMerator(varname) 
        	date(varname) 
			[SHEETMODify SHEETREPlace] 
			[NOLABel]
		;	
	#d cr

	qui {
		
		preserve
		
		* identify all categorical variables (variables with value labels)
		ds, has(type numeric)
		local num_vars `r(varlist)'

		* identify all categorical variables (variables with value labels)
		ds, has(vallabel)
		local cat_vars `r(varlist)'
				
		* identify all binary variables
		local binary_vars ""
		foreach var of varlist _all {
			cap confirm numeric var `var'
			if !_rc {
				qui levelsof `var', local(levels)
				if wordcount("`levels'") == 2 {
					local binary_vars `binary_vars' `var'
				}
			}
		}
		
		* inititialize standard variables to exclude
		local exclude_vars duration devicephonenum caseid formdef_version submissiondate starttime endtime
			
		* keep only non-categorical and non-binary numerical variables
		local cleaned_vars : list num_vars - cat_vars
		local cleaned_vars : list cleaned_vars - binary_vars
		local cleaned_vars : list cleaned_vars - exclude_vars
		local num_cleaned_vars : word count `cleaned_vars'
		
		* create input frame
		cap frame drop frm_inputs
		frame create frm_inputs
		frame frm_inputs {
			set obs `num_cleaned_vars'
			generate str32 variable = ""
			generate str20 by = ""
			generate str20 method = ""
			generate int multiplier = .
			generate str3 combine = ""
		}

		* populate frame
		local i = 1
		foreach var of local cleaned_vars {
			frame frm_inputs: replace variable = "`var'" in `i'
			local i = `i' + 1
		}
		frame frm_inputs: replace by = "enum_name"
		frame frm_inputs: replace method = "sd"
		frame frm_inputs: replace multiplier = 3		

		* identify variables to combine
		local common_prefixes ""
		frame frm_inputs {
			gen str32 common_prefix = ""
			forvalues i = 1/`=_N' {
				local var_name = variable[`i']

				if ustrregexm("`var_name'", "^(.+?_)\d+$") {
					local prefix = ustrregexs(1)
					local common_prefixes `common_prefixes' `prefix'
				}
			}
		}
		local common_prefixes : list uniq common_prefixes
		local matched_vars ""
		frame frm_inputs {
			forvalues i = 1/`=_N' {
				local var_name = variable[`i']
				
				foreach prefix of local common_prefixes {
					if ustrregexm("`var_name'", "^`prefix'\d+$") {
						replace common_prefix = "`prefix'" in `i'
						local matched_vars `matched_vars' `var_name'
					}
				}
				replace variable = "`matched_vars'" if common_prefix != ""
			}
			replace common_prefix = common_prefix + "*" if common_prefix != ""
			replace combine = "yes" if common_prefix != ""
			duplicates drop variable, force
			drop common_prefix
			
		}
		
		frame frm_inputs: loc cnt = _N

		restore, preserve 

		* rename and reshape outlier vars
		unab vars: `cleaned_vars'
		loc vars: list uniq vars
		loc i 1
		foreach var of varlist `vars' {
			* check that variable is numeric
			cap confirm numeric var `var'
			if _rc == 7 {
				disp as err "Variable `var' must be a numeric variable"
				ex 7
			}

			ren `var' ovvalue_`i'
			gen ovname_`i' = "`var'" if !missing(ovvalue_`i')
			gen ovlabel_`i' = "`:var lab ovvalue_`i''" if !missing(ovvalue_`i'), after(ovvalue_`i')
			loc ++i
		}
		
		* keep only relevant variables
		keep `id' `enumerator' `date' ovvalue_* ovname_* ovlabel_*

		gen reshape_id = _n

		reshape long ovvalue_ ovname_ ovlabel_, i(reshape_id) j(index)
		ren (ovvalue_ ovname_ ovlabel_) (value variable varlabel)

		drop if missing(value)
		drop reshape_id index

		* gen placeholders for important vars
		loc statvars "value_count value_min value_max value_mean value_median value_sd p25 p75 iqr"
		foreach var of newlist `statvars' {
			gen `var' = .
		}

		gen byvar 		= ""
		gen method 		= ""
		gen multiplier 	= .
		gen combine 	= variable
		gen combine_ind = 0
				
		frame frm_inputs: levelsof by, loc (byvars) clean
		
		* calculate outliers
		forval i = 1/`cnt' {
			frames frm_inputs {
				loc vars`i' 		= variable[`i']
				loc by`i' 			= by[`i']
				loc method`i' 		= method[`i']
				loc multiplier`i' 	= multiplier[`i']
				loc combine`i' 		= combine[`i'] 
			}

			* check if vars are combined
			if lower("`combine`i''") == "yes" {
				foreach var in `vars`i'' {
					replace combine = "`vars`i''" if variable == "`var'"
					replace combine_ind = 1 if variable == "`var'"
				}
				
				if "`by`i''" ~= "" 	loc by_syntax "bys `by`i'':"
				else 				loc by_syntax ""
					
				`by_syntax' egen vcount  = count(value)   if combine == "`vars`i''"
				`by_syntax' egen vmin 	  = min(value) 	  if combine == "`vars`i''"
				`by_syntax' egen vmax 	  = max(value) 	  if combine == "`vars`i''"
				`by_syntax' egen vmean   = mean(value)    if combine == "`vars`i''"
				`by_syntax' egen vmedian = median(value)  if combine == "`vars`i''"
				`by_syntax' egen vsd     = sd(value)      if combine == "`vars`i''"
				`by_syntax' egen vp25 	  = pctile(value) if combine == "`vars`i''", p(25)
				`by_syntax' egen vp75 	  = pctile(value) if combine == "`vars`i''", p(75)
				`by_syntax' egen viqr 	  = iqr(value)    if combine == "`vars`i''"

				replace value_count 	  = vcount 		  if combine == "`vars`i''"
				replace value_min 		  = vmin 		  if combine == "`vars`i''"
				replace value_max 		  = vmax 		  if combine == "`vars`i''"
				replace value_mean 		  = vmean 		  if combine == "`vars`i''"
				replace value_median 	  = vmedian 	  if combine == "`vars`i''"
				replace value_sd 	  	  = vsd 	  	  if combine == "`vars`i''"
				replace p25 			  = vp25       	  if combine == "`vars`i''"
				replace p75 			  = vp75 		  if combine == "`vars`i''"
				replace iqr 			  = viqr 		  if combine == "`vars`i''"

				replace byvar 		= "`by`i''" 		if combine == "`vars`i''" 
				replace method = "`method`i''" if combine == "`vars`i''"
				replace multiplier 	= `multiplier`i''   if combine == "`vars`i''"

				drop vcount vmin vmax vmean vmedian vsd vp25 vp75 viqr
			}
			else {
				foreach var in `vars`i'' {
					if "`by`i''" ~= "" 	loc by_syntax "bys `by`i'':"
					else 				loc by_syntax ""
					
					`by_syntax' egen vcount  = count(value)  if variable == "`var'"
					`by_syntax' egen vmin 	  = min(value) 	  if variable == "`var'"
					`by_syntax' egen vmax 	  = max(value) 	  if variable == "`var'"
					`by_syntax' egen vmean   = mean(value)   if variable == "`var'"
					`by_syntax' egen vmedian = median(value) if variable == "`var'"
					`by_syntax' egen vsd     = sd(value)     if variable == "`var'"
					`by_syntax' egen vp25 	  = pctile(value) if variable == "`var'", p(25)
					`by_syntax' egen vp75 	  = pctile(value) if variable == "`var'", p(75)
					`by_syntax' egen viqr 	  = iqr(value)    if variable == "`var'"

					replace value_count 	  = vcount 		  if variable == "`var'"
					replace value_min 		  = vmin 		  if variable == "`var'"
					replace value_max 		  = vmax 		  if variable == "`var'"
					replace value_mean 		  = vmean 		  if variable == "`var'"
					replace value_median 	  = vmedian 	  if variable == "`var'"
					replace value_sd 	  	  = vsd 	  	  if variable == "`var'"
					replace p25 			  = vp25       	  if variable == "`var'"
					replace p75 			  = vp75 		  if variable == "`var'"
					replace iqr 			  = viqr 		  if variable == "`var'"

					replace byvar 		= "`by`i''" 		  if variable == "`var'" 
					replace method 		= "`method`i''"		  if variable == "`var'"
					replace multiplier 	= `multiplier`i''     if variable == "`var'"

					drop vcount vmin vmax vmean vmedian vsd vp25 vp75 viqr
				}
			}
		}

		* clean up and rename combine variables
		replace combine = "" if !combine_ind
		drop 	combine_ind

		gen range_min = cond(method == "iqr", p25 - (1.5 * iqr), value_mean - (multiplier * value_sd))
		gen range_max = cond(method == "iqr", p75 + (1.5 * iqr), value_mean + (multiplier * value_sd)) 
		
		keep if !inrange(value, range_min, range_max)
		
		if `c(N)' > 0 {

			ipagettd `date'

			foreach var of varlist _all {
				lab var `var' "`var'"
			}
			
			lab var varlabel 		"label"
			lab var value_count 	"count"
			lab var value_sd 		"sd"
			lab var value_mean 		"mean"
			lab var value_min 		"min"
			lab var value_max 		"max"
			
			keep 	`enumerator' `keep' `date' `id'  variable varlabel value value_mean 

			order 	`enumerator' `keep' `date' `id'  variable varlabel value value_mean 
					
			if "`keep'" ~= "" ipalabels `keep', `nolabel'
			ipalabels `id' `enumerator', `nolabel'
			
			loc drop_list "device_info deviceid duration endtime  starttime formdef_version key submissiondate username uuid uuid_confirm caseid devicephonenum audio_audit startdate subdate enddate"
			foreach var of local drop_list {
				drop if variable == "`var'"
			}
			
			gsort -`date'
			
			export excel using "`outfile'", first(varl) sheet("`outsheet'") `sheetreplace'

			ipacolwidth using "`outfile'", sheet("`outsheet'")
			ipacolformat using "`outfile'", sheet("`outsheet'") vars(value value_mean) format("number_sep_d2")	
			ipacolformat using "`outfile'", sheet("`outsheet'") vars(`date') format("date_d_mon_yy")
			iparowformat using "`outfile'", sheet("`outsheet'") type(header)
			
			tab variable
			loc var_cnt `r(r)'
			
			* display number of outliers flagged
			noi disp "Found {cmd:`c(N)'} outliers in `var_cnt' variable(s)."
		}
		else {
		    loc var_cnt 0
			noi disp "Found {cmd:0} outliers."
		}
		
		return local N_outliers = `c(N)'
		return local N_vars = `var_cnt'
	}
	
end
