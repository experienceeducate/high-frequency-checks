*! version 4.1.0 08apr2024
*! Innovations for Poverty Action
* ipacheckenumdb: Outputs survey statistics by enumerator
* modified by matteo ramina

program ipacheckenumdb, rclass
	
	version 17

	#d;
	syntax 	,
			[SHEETname(string)]
        	date(varname)
        	[PERiod(string)]
        	ENUMerator(varname)
			[TEAM(varname)]
        	[CONSent(string)]
        	[DONTKnow(string)]
			[REFuse(string)]
			[OTHERspecify(varlist)]
        	[DURation(varname)]
        	FORMVersion(varname)
        	OUTFile(string)
			[SHEETREPlace SHEETMODify]
			[NOLabel]
		;	
	#d cr

	qui {
	    
		preserve
		
		destring duration, replace

		tempvar tmv_subdate tmv_consent_yn tmv_team tmv_enum
		tempvar tmv_obs tmv_enum tmv_formversion tmv_days tmv_dur tmv_miss tmv_dk tmv_ref tmv_other 

		tempfile tmf_main_data tmf_datecal tmf_varcodes
		
		* save number of obs and vars in local
		
		loc obs_count 	= c(N)
		loc vars_count 	= c(k)
		
		* get list of all vars
		unab allvars: _all
		
		* check missing
		egen `tmv_miss' = rowmiss(_all)
		
		* create dummies scalars for options
		loc _cons 	= "`consent'" 	~= ""
		loc _dk 	= "`dontknow'" 	~= ""
		loc _ref 	= "`refuse'" 	~= ""
		loc _other 	= "`otherspecify'" ~= ""
		loc _dur 	= "`duration'" 	~= ""
		loc _team 	= "`team'"		~= ""
		
		* check for dk, ref. Generate dummies if not specified
		
		if `_dk' {
			token `"`dontknow'"', parse(,)
				
			* check numeric number
			if "`1'" ~= "" {
				cap confirm integer number `1'
				if _rc == 7 {
					cap assert regexm("`1'", "^[\.][a-z]$")
					if _rc == 9 {
						disp as err "`1' found where integer is expected in option dontknow()"
						exit 198
					}
				}
			}
			ipaanycount _all, generate(`tmv_dk') numval(`1') strval("`3'")
		}
		else gen `tmv_dk' = 0
		if `_ref' {
			token `"`refuse'"', parse(,)
			* check numeric number
			if "`1'" ~= "" {
				cap confirm integer number `1'
				if _rc == 7 {
					cap assert regexm("`1'", "^[\.][a-z]$")
					if _rc == 9 {
						disp as err "`1' found where integer is expected in option refuse()"
						exit 198
					}
				}
			}
			ipaanycount _all, generate(`tmv_ref') numval(`1') strval("`3'")
		}
		else gen `tmv_ref' = 0

		if `_other' {
			unab otherspecify: `otherspecify'
			loc other_count = wordcount("`otherspecify'")
			egen `tmv_other' = rownonmiss(`otherspecify'), strok
		}
		else {
			gen `tmv_other' = 0
			loc other_count 0
		}
		
		* team: team()
		if `_team' {
			gen `tmv_team' 	= `team' 
		}
		else gen `tmv_team' = ""
		
		ipagettd `date'
	
		* period: period(auto | daily | weekly | monthly) 
		* check : check options in period
		if "`period'" ~= "" & !inlist("`period'", "auto", "daily", "weekly", "monthly") {
			disp as err `"option period incorrectly specified. Expecting auto, daily, weekly or monthly."'
			ex 198
		}
		else if "`period'" == "" loc period "auto"
		if "`period'" == "auto" {
		    su `date'
			loc min_date `r(min)'
			loc max_date `r(max)'
			loc days = `max_date' - `min_date'
			loc period = cond(`days' <= 40,  "daily", ///
						 cond(`days' <= 280, "weekly", ///
											 "monthly"))
		}

		* duration: check that duration is a numeric var
		if `_dur' {
		    cap confirm numeric var `duration'
		    if _rc == 7 {
			    disp as err "variable `duration' found at option duration() where numeric variable is expected"
				ex 7
			} 
			else {
				gen `tmv_dur' = `duration'
			}
		}
		else gen `tmv_dur' = 0

		* consent: consent(consent, 1) or consent(consent, 1 2 3)
		if `_cons' {	
			* check  : check that consent variable is numeric and values is a numlist
			token "`consent'", parse(,)
			* check variable specified
			cap unab consent_var	: `1'
			if _rc == 102 {
				disp as err `"no variables specified for consent() option"'
				ex 198
			}
			else if _rc == 111 {
				disp as err `"variable `1' specifed in consent() option not found"'
				ex 111
			}
			else {
	
				* check that consent var is numeric
				cap confirm numeric var `consent_var'
				if _rc == 7 {
					disp as err `"variable `consent_var' specifed in consent() option is not numeric"'
					ex 7
				}
				
				macro shift
				loc consent_vals = subinstr(trim(itrim("`*'")), ",", "", 1)
				if missing("`consent_vals'") {
					disp as err `"no values specified with consent() option."' ///
								`"expected format is consent(varname, varlist)."' 
					ex 198
				}
				gen `tmv_consent_yn' = 0
				foreach val of numlist `consent_vals' {
					replace `tmv_consent_yn' = 1 if `consent_var' == `val'
				}
			}
		}
		else {
			gen `tmv_consent_yn' = 0
		}
		
		* save main dataset
		save "`tmf_main_data'", replace
				
		*** Summary (by enumerator) ***
		
		* generate vars to keep track of uniq number of forms, enums days in each group
		
		gen `tmv_formversion' 	= 0
		gen `tmv_days'			= 0
		
		cap confirm string var `enumerator'
		if !_rc {
			levelsof `enumerator', loc (enums)
			foreach enum in `enums' {
				tab `formversion' if `enumerator' == "`enum'"
				replace `tmv_formversion' 	= `r(r)'  if `enumerator' == "`enum'"
				tab `date' if `enumerator' == "`enum'"
				replace `tmv_days' = `r(r)' if `enumerator' == "`enum'"
			}
		}
		else {
			levelsof `enumerator', loc (enums) clean
			foreach enum in `enums' {
				tab `formversion' 						if `enumerator' == `enum'
				replace `tmv_formversion' 	= `r(r)' 	if `enumerator' == `enum'
				tab `date'								if `enumerator' == `enum'
				replace `tmv_days' 			= `r(r)' 	if `enumerator' == `enum'
			}
		}
		
		gen `tmv_obs' = 1
		
		* calculate overall median
		su duration, detail
		loc overall_duration_median = r(p50)/60
		
		* generate final table
		#d;
		collapse (first)    team 			= `tmv_team'
				 (mean)	 	duration_mean   = `tmv_dur'
				 (median) 	duration_median = `tmv_dur'
				 (min)	 	duration_min   	= `tmv_dur'
				 (max)	 	duration_max   	= `tmv_dur'
				 (count) 	submissions 	= `tmv_obs'
				 ,
				 by(`enumerator')
			;
		#d cr
		
		* label variables
		lab var team 			"team"
		lab var duration_mean   "mean duration"
		lab var duration_median "median duration"
		lab var duration_min   	"min duration"
		lab var duration_max   	"max duration"
		lab var submissions 	"# of submissions"
		
		* drop consent, dk, ref, other, duration
		if !`_team'		drop team
		if !`_dur' 		drop duration_*

		ipalabels `enumerator', `nolabel'
		lab var `enumerator' ""
		
		* sort in descending order according to mean duration
		gsort -duration_mean
		
		* transform durations from seconds to minutes
		foreach var in duration_mean duration_median duration_min duration_max {
			replace `var' = `var' / 60
		}
		
		* calculate overall mean duration
		sum submissions
		local total_submissions = r(sum)
		gen weighted_duration = duration_mean * submissions
		sum weighted_duration
		local total_weighted_duration = r(sum)
		local overall_mean_duration = `total_weighted_duration' / `total_submissions'
		set obs `=_N + 1'
		replace enum_name = "Overall" if _n == _N
		replace submissions = `total_submissions' if _n == _N
		replace duration_mean = `overall_mean_duration' if _n == _N
		replace duration_median = `overall_duration_median' if _n == _N
		drop weighted_duration
		
		* export file
		export excel using "`outfile'", first(varl) sheet("duration") `sheetreplace' `sheetmodify'
		ipacolwidth using "`outfile'", sheet("duration")
		iparowformat using "`outfile'", sheet("duration") type(header)
		if `_dur'   ipacolformat using "`outfile'", sheet("duration") ///
			vars(duration_mean duration_median duration_min duration_max) format("number_sep")				

	}
end
