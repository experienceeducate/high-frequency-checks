*! version 4.3.1 28aug2024
*! Innovations for Poverty Action
* ipacheck: Update ipacheck package and initialize new projects

program ipacheck, rclass
	
	version 17
	
	#d;
	syntax 	name(name=subcmd id="sub command"), 
			[SURVeys(string)] 
			[FOLDer(string)]
			[OBSID(string)]
			[ENUMID(string)]
			[TEAMID(string)]
			[CONSENTVAR(string)]
			[SUBfolders] 
			[FILESonly] 
			[EXercise]
			[BRanch(name) force]
			;
	#d cr

	qui {
		if !inlist("`subcmd'", "new", "version", "update") {
			disp as err "illegal ipacheck sub command. Sub commands are:"
			noi di as txt 	"{cmd:ipacheck new}"
			noi di as txt 	"{cmd:ipacheck update}"
			noi di as txt 	"{cmd:ipacheck version}"
			ex 198
		}
		if inlist("`subcmd'", "update", "version") {
			if "`surveys'" ~= "" {
				disp as error "subccommand `subcmd' and surveys options are mutually exclusive"
				ex 198
			}
			if "`folder'" ~= "" {
				disp as error "sub command `subcmd' and folder options are mutually exclusive"
				ex 198
			}
			if "`subfolders'" ~= "" {
				disp as error "sub command `subcmd' and subfolders options are mutually exclusive"
				ex 198
			}
			if "`filesonly'" ~= "" {
				disp as error "sub command `subcmd' and files options are mutually exclusive"
				ex 198
			}
			if "`exercise'" ~= "" {
				disp as error "sub command `subcmd' and exercise options are mutually exclusive"
				ex 198
			}
	 	}
		else if "`subcmd'" == "new" {
			if "`surveys'" == "" & "`subfolders'" ~= "" {
				disp as err "subfolders option & survey options must be specified together"
				ex 198
			}
			if "`exercise'" ~= "" {
				if "`subfolders'" ~= "" {
					disp as err "exercise and subfolders options are mutually exclusive"
					ex 198
				}
				if "`filesonly'" ~= "" {
					disp as err "exercise and filesonly options are mutually exclusive"
					ex 198
				}
			}
		}
		
		if "`subcmd'" ~= "update" & "`force'" ~= "" {
			disp as err "Sub-command `subcmd' and option force are mutually exclusive"
			ex 198
		}
		
		
		loc url 	= "https://raw.githubusercontent.com/experienceeducate/high-frequency-checks"

		if "`subcmd'" == "new" {
			noi ipacheck_new, surveys(`surveys') folder("`folder'") obsid(`obsid') enumid(`enumid') teamid(`teamid') consentvar(`consentvar') `subfolders' `filesonly' url("`url'") branch(`branch') `exercise'
			ex
		}
		else {
			noi ipacheck_`subcmd', branch(`branch') url(`url') `force'
			ex
		}
		
		if inlist("`subcmd'", "version", "update") {
			noi ipacheck `subcmd', `force'
			ex
		}
	}
end

program define ipacheck_update
	
	syntax, [branch(name)] url(string) [force]
	
	qui {
		loc branch 	= cond("`branch'" ~= "", "`branch'", "master")
		noi net install ipacheck, replace from("`url'/`branch'")

		noi net install ipahelper, all replace from("https://raw.githubusercontent.com/experienceeducate/ipahelper/main")
	}
	
end

program define ipacheck_version
	
	syntax, [branch(name)] url(string)
	
	qui {
		
		* Check versions for ipacheck
		loc branch 	= cond("`branch'" ~= "", "`branch'", "master")

		* create frame
		cap frames drop frm_verdate
		frames create frm_verdate str32 (line)
			
		* get list of programs from pkg file 
		tempname pkg
		loc linenum = 0
		file open `pkg' using "`url'/`branch'/ipacheck.pkg", read
		file read `pkg' line
		
		while r(eof)==0 {
			loc ++linenum
			frame post frm_verdate (`" `macval(line)'"')
			file read `pkg' line
		}
		
		file close `pkg'
		
		frame frm_verdate {
			egen program = ends(line), punct("/") tail
			drop if !regexm(program, "\.ado$")
			replace program = subinstr(program, ".ado", "", 1)
			loc prog_cnt `c(N)'
			
			gen loc_vers = ""
			gen loc_date = ""
			
			gen git_vers = ""
			gen git_date = ""
		}
		
		* for each program, find the loc version number and date as well as the github version
		forval i = 1/`prog_cnt' {
			frame frm_verdate: loc prg = program[`i']
			
			cap confirm file "`c(sysdir_plus)'i/`prg'.ado"
			if !_rc {
				mata: get_version("`c(sysdir_plus)'i/`prg'.ado")
				di regexm("`verdate'", "[1-4]\.[0-9]+\.[0-9]+")
				loc vers_num 	= regexs(0)
				di regexm("`verdate'", "[0-9]+[a-zA-Z]+[0-9]+")
				loc vers_date 	= regexs(0)
			
				frame frm_verdate: replace loc_vers = "`vers_num'" if program == "`prg'"
				frame frm_verdate: replace loc_date = "`vers_date'" if program == "`prg'"
			}
			
			mata: get_version("`url'/`branch'/ado/`prg'.ado")
			di regexm("`verdate'", "[1-4]\.[0-9]+\.[0-9]+")
			loc vers_num 	= regexs(0)
			di regexm("`verdate'", "[0-9]+[a-zA-Z]+[0-9]+")
			loc vers_date 	= regexs(0)
			
			frame frm_verdate: replace git_vers = "`vers_num'" if program == "`prg'"
			frame frm_verdate: replace git_date = "`vers_date'" if program == "`prg'"
		}
		
		frame frm_verdate {
			gen loc_vers_num = 	real(word(subinstr(loc_vers, ".", " ", .), 1)) * 100 + ///
								real(word(subinstr(loc_vers, ".", " ", .), 2)) * 10 + ///
								real(word(subinstr(loc_vers, ".", " ", .), 3))
			
			gen loc_date_num = date(loc_date, "DMY")
								
			gen git_vers_num = 	real(word(subinstr(git_vers, ".", " ", .), 1)) * 100 + ///
								real(word(subinstr(git_vers, ".", " ", .), 2)) * 10 + ///
								real(word(subinstr(git_vers, ".", " ", .), 3))
								
			gen git_date_num = date(loc_date, "DMY")
			
			format %td loc_date_num git_date_num
			
			* generate var to indicate if new version is available
			gen update_available = cond(git_date > loc_date | git_vers_num > loc_vers_num, "yes", "no")
			replace update_available = "" if missing(loc_date)
			
			gen current = loc_vers + " " + loc_date
			gen latest = git_vers + " " + git_date
			noi list program current latest update_available, noobs h sep(0) abbrev(32)
			
			count if update_available == "yes" 
			loc update_cnt `r(N)'
			if `update_cnt' > 0 {
				noi disp "Updates are available for `r(N)' programs."
			}
			count if update_available == ""
			loc new_cnt `r(N)'
			if `new_cnt' > 0 {
				noi disp "`r(N)' new programs available"
			}
			if `update_cnt' > 0 | `new_cnt' > 0 {
				noi disp "Click {stata ipacheck update:here} to update"
			}	
		}
	}
	
end

mata: 
void get_version(string scalar program) {
	real scalar fh
	
    fh = fopen(program, "r")
    line = fget(fh)
    st_local("verdate", line) 
    fclose(fh)
}
end

program define ipacheck_new
	
	syntax, [surveys(string)] [folder(string)] [SUBfolders] [obsid(string)] ///
	[enumid(string)] [teamid(string)] [consentvar(string)] [filesonly] ///
	[exercise] [branch(name)] url(string)
	
	loc branch 	= cond("`branch'" ~= "", "`branch'", "master") 
	
	if "`folder'" == "" {
		loc folder "`c(pwd)'"
	}
	if "`obsid'" != "" {
		global id "`obsid'"
	}
	if "`enumid'" != "" {
		global enum "`enumid'"
	}
	if "`teamid'" != "" {
		global team "`teamid'"
	}
	if "`consentvar'" != "" {
		global consent "`consentvar'"
	}
		
	loc surveys_cnt = `:word count `surveys''
	
	if "`filesonly'" == "" {
		#d;
		loc folders 
			""1_instruments"
				"1_instruments/1_paper"
				"1_instruments/2_scto_print"
				"1_instruments/3_scto_xls"
			"2_dofiles"
			"3_checks"	
			"4_data"
			"5_corrections""
			;
		#d cr
		
		noi disp
		noi disp "Setting up folders ..."
		noi disp

		foreach f in `folders' {
			mata : st_numscalar("exists", direxists("`folder'/`f'"))
			if scalar(exists) == 1 {
				noi disp "{red:Skipped}: Folder `f' already exists"
			}
			else {
				mkdir "`folder'/`f'"
				noi disp "Successful: Folder `f' created"
			}
		}
		
		if "`subfolders'" == "subfolders" {
			
			#d;
			loc sfs
				;
			#d cr
			
			noi disp
			noi disp "Creating subfolders ..."
			noi disp
			loc i 1
			
			foreach survey in `surveys' {
				loc sublab = "`i'_`survey'"
				foreach sf in `sfs' {
					mata : st_numscalar("exists", direxists("`folder'/`sf'/`sublab'"))
					if scalar(exists) == 1 {
						noi disp "{red:Skipped}: Sub-folder `sf' already exists"
					}
					else {
						mkdir "`folder'/`sf'/`sublab'"
						noi disp "Successful: Folder `sf'/`sublab' created"
					}
				}
				loc ++i
			}
		}
	}
	
	loc exp_dir "`folder'"
		
	noi disp
	noi disp "Copying files to `exp_dir' ..."
	noi disp
	
	cap confirm file "`exp_dir'/0_master.do"
	if _rc == 601 {
		copy "`url'/`branch'/do/0_master.do" "`exp_dir'/0_master.do"
		noi disp "0_master.do copied to `exp_dir'"
	}
	else {
		noi disp  "{red:Skipped}: File 0_master.do already exists"
	}
	
	* Modify 0_master.do to specify survey file
	copy "`exp_dir'/0_master.do" "`exp_dir'/0_master_tmp.do", replace
	file open master_orig using "`exp_dir'/0_master.do", read text
	file open master_new using "`exp_dir'/0_master_tmp.do", read write text
	file read master_orig line
	while r(eof) == 0 {
		 if strpos(`"`line'"', "2_dofiles/1_globals.do") {
			file write master_new `"	    do "2_dofiles/1_globals_`surveys'.do"    // globals do-file"' _n			
		}
		else if strpos(`"`line'"', "2_dofiles/3_prepsurvey.do") {
			file write master_new `"	    do "2_dofiles/3_prepsurvey_`surveys'.do"    // prep survey do-file"' _n
			
		}
		else if strpos(`"`line'"', "2_dofiles/4_checksurvey.do") {
			file write master_new `"	    do "2_dofiles/4_checksurvey_`surveys'.do"    // check survey do-file"' _n
			
		}
		else if strpos(`"`line'"', `"if "$cwd" ~= "" cd "$cwd""') {
			file write master_new `"        if "\$cwd" ~= "" cd "\$cwd""' _n			
                        
		}
        else if strpos(`"`line'"', `"else global cwd "`c(pwd)'""') {
			file write master_new `"        else global cwd "\`c(pwd)'""' _n			
                        
		}
		else {
			file write master_new `"`line'"' _n
		}		
		file read master_orig line
	}
	file close master_orig
	file close master_new
	copy "`exp_dir'/0_master_tmp.do" "`exp_dir'/0_master.do", replace
	erase "`exp_dir'/0_master_tmp.do"
	
	* Copy corrections file
	cap confirm file "`exp_dir'/5_corrections/corrections.xlsm"
	if _rc == 601 {
		qui copy "`url'/`branch'/excel/templates/corrections.xlsm" "`exp_dir'/5_corrections/corrections.xlsm"
		noi disp "corrections.xlsm copied to `exp_dir'/5_corrections/"
	}
	else {
		noi disp "{red:Skipped}: File corrections.xlsm already exists"
	}
	
	if "`filesonly'" == "" 	loc exp_dir "`folder'/2_dofiles"
	else 					loc exp_dir "`folder'"
	
	foreach file in 1_globals 3_prepsurvey 4_checksurvey {
		if `surveys_cnt' > 0 {
			forval i = 1/`surveys_cnt' {
				loc exp_file = "`file'_" + word("`surveys'", `i')
				cap confirm file "`exp_dir'/`exp_file'.do"
				if _rc == 601 {
					copy "`url'/`branch'/do/`file'.do" "`exp_dir'/`exp_file'.do"
					noi disp "`exp_file'.do copied to `exp_dir'"
				}
				else {
					noi disp  "{red:Skipped}: File `file'.do already exists"
				}
			}
		}
		else {
			cap confirm file "`exp_dir'/`file'.do"
			if _rc == 601 {
				copy "`url'/`branch'/do/`file'.do" "`exp_dir'/`file'.do"
				noi disp "`file'.do copied to `exp_dir'"
			}
			else {
				noi disp  "{red:Skipped}: File `file'.do already exists"
			}
		}
	}

	* Modify 1_globals.do to specify survey file
	copy "`exp_dir'/1_globals_`surveys'.do" "`exp_dir'/1_globals_`surveys'_tmp.do", replace
	file open global_orig using "`exp_dir'/1_globals_`surveys'.do", read text
	file open global_new using "`exp_dir'/1_globals_`surveys'_tmp.do", read write text
	file read global_orig line
	while r(eof) == 0 {
		 if strpos(`"`line'"', "gl rawsurvey") {
			file write global_new `"    gl rawsurvey "\${cwd}/4_data/`surveys'.dta" "' _n			
		}
		else if strpos(`"`line'"', "gl preppedsurvey") {
			file write global_new `"    gl preppedsurvey "\${cwd}/4_data/`surveys'_prepped.dta" "' _n
			
		}
		else if strpos(`"`line'"', "gl checkedsurvey") {
			file write global_new `"    gl checkedsurvey "\${cwd}/4_data/`surveys'_checked.dta" "' _n
			
		}
		else if strpos(`"`line'"', "gl mastersurvey") {
			file write global_new `"    gl mastersurvey "\${cwd}/4_data/`surveys'_preloads.dta" "' _n
			
		}		
		else if strpos(`"`line'"', "gl folder_date") {
			file write global_new `"    gl folder_date			= string(year(today())) + "-\`:disp %tdNN today()'-\`:disp %tdDD today()'" "' _n
			
		}
		else if strpos(`"`line'"', "cap mkdir") {
			file write global_new `"    cap mkdir        "\${cwd}/3_checks/\$folder_date" "' _n
			
		}
		else if strpos(`"`line'"', "gl id_dups_output") {
			file write global_new `"    gl id_dups_output        "\${cwd}/3_checks/\$folder_date/survey_duplicates.dta" "' _n
			
		}
		else if strpos(`"`line'"', "gl hfc_output") {
			file write global_new `"    gl hfc_output        "\${cwd}/3_checks/\$folder_date/hfc_output.xlsx" "' _n
		}
        else if strpos(`"`line'"', "gl id") & "`obsid'" != "" {
			file write global_new 	`"    gl id					"`obsid'""' _n            
		}
        else if strpos(`"`line'"', "gl enum") & "`enumid'" != "" {
			file write global_new 	`"    gl enum					"`enumid'""' _n            
		}	
        else if strpos(`"`line'"', "gl team") & "`teamid'" != "" {
			file write global_new 	`"    gl team					"`teamid'""' _n            
		}
        else if strpos(`"`line'"', "gl consent") & "`consentvar'" != "" {
			file write global_new 	`"    gl consent					"`consentvar'""' _n            
		}		
		else {
			file write global_new `"`line'"' _n
		}		
		file read global_orig line
	}
	file close global_orig
	file close global_new
	copy "`exp_dir'/1_globals_`surveys'_tmp.do" "`exp_dir'/1_globals_`surveys'.do", replace
	erase "`exp_dir'/1_globals_`surveys'_tmp.do"
	
	if "`filesonly'" == "" 	loc exp_dir "`folder'/3_checks/"
	else 					loc exp_dir "`folder'"
	
	noi disp
	noi disp "Copying files to `folder'/3_checks/ ..."
	noi disp

	if "`exercise'" ~= "" {
	
		* copy exercise files

		noi disp
		noi disp "Copying exercise files ..."
		noi disp

		foreach file in household_survey.dta household_backcheck.dta household_preloads.xlsx respondent_targets.xlsx {
			qui copy "`url'/`branch'/data/`file'" "`folder'/4_data/`file'", replace
			noi disp "`file' copied to 4_data/`file'"
		}
		
		qui copy "`url'/`branch'/excel/exercise/Household_Survey.xlsx" "`folder'/1_instruments/3_scto_xls/Household_Survey.xlsx", replace
		noi disp "Household_Survey.xlsx copied to 1_instruments/3_scto_xls/Household_Survey.xlsx"
		
		qui copy "`url'/`branch'/excel/exercise/Household_Back_Check_Survey.xlsx" "`folder'/1_instruments/3_scto_xls/Household_Back_Check_Survey.xlsx", replace
		noi disp "Household_Back_Check_Survey.xlsx copied to 1_instruments/3_scto_xls/Household_Back_Check_Survey.xlsx"

		noi disp
		noi disp "Unpacking text audit and comment files ..."
		noi disp

		mata: st_numscalar("exists", direxists("`folder'/4_data/media"))
		if scalar(exists) == 1 {
			cd "`folder'/4_data"
		}
		else {
			mkdir "`folder'/4_data/media"
			cd "`folder'/4_data"
		} 

		* unpack text audits and comment files
		unzipfile "`url'/`branch'/data/media.zip", replace

		cd "`folder'"

		noi disp
		noi disp "Unpacking audio audit files ..."
		noi disp

		cap frames drop frm_audio_audit
		frames create frm_audio_audit
		frames frm_audio_audit: use aud_audit using "`url'/`branch'/data/household_survey.dta"

		qui copy "`url'/`branch'/data/m4a_sample_on_&_on.m4a" "`c(tmpdir)'/audio_file_sample.m4a", replace
		
		frames frm_audio_audit {
			
			drop if missing(aud_audit)

			loc import_cnt `c(N)'
			
			noi _dots 0, title(Unpacking `import_cnt' audio audit files ...) reps(`import_cnt')
			
			forval i = 1/`import_cnt' {

				loc file = subinstr("`=aud_audit[`i']'", "media\", "", 1)
			
				qui copy 	"`c(tmpdir)'/audio_file_sample.m4a" "`folder'/4_data/media/`file'", replace
				noi _dots `i' 0
			}

		}
	}

end
