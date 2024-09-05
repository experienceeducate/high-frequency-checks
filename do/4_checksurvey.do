*! version 4.0.4 Innovations for Poverty Action 13mar2023

********************************************************************************
** 	TITLE	: 4_checksurvey.do
**
**	PURPOSE	: Run IPA's High Frequency Check Commands 
**				
**	AUTHOR	: 
**
**	DATE	: 
********************************************************************************

/* =============================================================================
   =================== IPA HIGH FREQUENCY CHECK TEMPLATE ======================= 
   ============================================================================= */
   
   *====================== Remove existing excel files ========================* 
   
	foreach file in hfc corrlog id_dups textaudit surveydb enumdb timeuse tracking bc {
		cap confirm file "${`file'_output}"
		if !_rc {
			rm "${`file'_output}"
		}
	}
   
   *========================= Import Prepped Dataset ==========================* 

	use "${preppedsurvey}", clear
   
   *========================== Find Survey Duplicates ==========================* 
   
   if $run_ids {
	   ipacheckids ${id},								///
				enumerator(${enum}) 					///	
				date(${date})	 						///
				key(${key}) 							///
				outfile("${hfc_output}") 				///
				outsheet("id duplicates")				///
				keep(${id_keepvars})	 				///
				dupfile("${id_dups_output}")			///
				save("${checkedsurvey}")				///
				${id_nolabel}							///
				force									///
				sheetreplace
				
		use "${checkedsurvey}", clear
		
   }
   else {
		isid ${id}
		save "${checkedsurvey}", replace
   }
  
    *============================= Form versions ===============================* 

   if $run_version {
		ipacheckversions ${formversion}, 				///
				enumerator(${enum}) 					///	
				date(${date})							///
				outfile("${hfc_output}") 				///
				outsheet1("form versions")				///
				outsheet2("outdated")					///
				keep(${vs_keepvars})					///
				sheetreplace							///
				$vs_nolabel
   }
   
   *========================== Variable Duplicates ============================* 
   
   if $run_dups {
	   ipacheckdups ${dp_vars},							///
				id(${id})								///
				enumerator(${enum}) 					///	
				date(${date})	 						///
				outfile("${hfc_output}") 				///
				outsheet("duplicates")					///
				keep(${dp_keepvars})	 				///
				${dp_nolabel}							///
				sheetreplace
   }
   
   *========================= Variable Missingness ============================* 
   
   if $run_missing {
		ipacheckmissing ${ms_vars}, 					///
			priority(${ms_pr_vars})						///
			outfile("${hfc_output}") 					///
			outsheet("missing")							///
			sheetreplace
   }
   
   *=============================== Outliers ==================================* 

   if $run_outliers {
		ipacheckoutliers using "${inputfile}",			///
			id(${id})									///
			enumerator(${enum}) 						///	
			date(${date})	 							///
			sheet("outliers")							///
        	outfile("${hfc_output}") 					///
			outsheet("outliers")						///
			${ol_nolabel}								///
			sheetreplace
   }
   
   *=========================== Survey Dashboard ==============================* 
	
   if $run_surveydb {
		ipachecksurveydb,			 					///
			by(${sv_by})								///
			enumerator(${enum}) 						///
			date(${date})								///
			period("${sv_period}")						///
			consent(${consent}, ${cons_vals})			///
			dontknow(.d, ${dk_str})						///
			refuse(.r, ${ref_str})						///
			otherspecify("`childvars'")					///
			duration(${duration})						///
			formversion(${formversion})					///
        	outfile("${surveydb_output}")				///
			${sv_nolabel}								///
			sheetreplace
   }
   
   *========================= Enumerator Dashboard ============================* 
  
   if $run_enumdb {
		ipacheckenumdb using "${inputfile}",			///
			sheetname("enumstats")						///		
			enumerator(${enum})							///
			team(${team})								///
			date(${date})								///
			period("${en_period}")						///
			consent($consent, ${cons_vals})				///
			dontknow(.d, ${dk_str})						///
			refuse(.r, ${ref_str})						///
			otherspecify("`childvars'")					///
			duration(${duration})						///
			formversion(${formversion})					///
        	outfile("${enumdb_output}")					///
			${en_nolabel}								///
			sheetreplace
   }
  
   *========================= Track Survey Progress ===========================* 

   if $run_tracksurvey {
       ipatracksurvey,									///
			surveydata("$checkedsurvey")				///
			id(${id})									///
			date(${date})								///
			by(${tr_by})								///
			outcome(${tr_outcome})						///
			target(${tr_target})						///
			masterdata("${mastersurvey}")				///
			masterid(${tr_masterid})					///
			trackingdata("${trackingsurvey}")			///
			keepmaster(${tr_keepmaster})				///
			keeptracking(${tr_keeptracking})			///
			keepsurvey(${tr_keepsurvey})				///
			outfile("${tracking_output}")				///
			save("${tr_save}")							///
			${tr_nolabel} 								///
			${tr_summaryonly}							///
			${tr_workbooks} 							///
			${tr_surveyok}								///
			replace
   }
