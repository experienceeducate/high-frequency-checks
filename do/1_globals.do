********************************************************************************
** 	TITLE	: 1_globals.do
**
**	PURPOSE	: Globals do-file
**				
**	AUTHOR	: 
**
**	DATE	: 
********************************************************************************

**# Run/Turn Off Specific Checks
*------------------------------------------------------------------------------*


	* NB: Edit this section: Change value to 0 to turn off specific checks
	
	gl run_version			1	//	Check for outdated survey form versions
	gl run_ids				1	//	Check Survey ID for duplicates
	gl run_dups				1	//	Check other Survey variables for duplicates
	gl run_missing			1	//	Check variable missingness
	gl run_outliers			1	//	Check numeric variables for outliers
	gl run_surveydb			1	//	Create survey Dashboard
	gl run_enumdb			1	//	Create enumerator Dashboard
	gl run_tracksurvey		1	// 	Report on survey progress
	
/* Datasets
	
	Description of globals for datasets:
	------------------------------------
	
	rawsurvey 			Raw Survey Data
	
	preppedsurvey		Prepped Survey Data
	
	checkedsurvey		Post HFC de-duplicated Survey dataset
	
*/
*------------------------------------------------------------------------------*
	
	* NB: Edit this section: Change filenames if neccesary
	
	gl rawsurvey			"${cwd}/4_data/2_survey/household_survey.dta" 		
	gl preppedsurvey		"${cwd}/4_data/2_survey/household_survey_prepped.dta"			
	gl checkedsurvey		"${cwd}/4_data/2_survey/household_survey_checked.dta"
	gl mastersurvey 		"${cwd}/4_data/2_survey/household_preloads.xlsx"

**# Output Date Folder
*------------------------------------------------------------------------------*	
	
	* NB: DO NOT EDIT THIS SECTION
	
	gl folder_date			= string(year(today())) + "-`:disp %tdNN today()'-`:disp %tdDD today()'"
	cap mkdir				"${cwd}/3_checks/2_outputs/$folder_date"


/* Output files

	Description of globals for output files:
	----------------------------------------
	
	id_dups_output 		[.dta]  Raw Duplicates output
	
	hfc_output			[.xlsx] Output file for HFCs 
		
	surveydb_output		[.xlsx] Output file for Surveyor Dashboard 
	
	enumdb_output		[.xlsx] Output file for Enumerator Dashboard
	
	tracking_output     [.xlsx] Output file for Survey Tracking
		
*/
*------------------------------------------------------------------------------*

	* NB: Edit this section: Change filenames if neccesary
	

	gl id_dups_output 		"${cwd}/3_checks/2_outputs/$folder_date/survey_duplicates.dta"
	gl hfc_output			"${cwd}/3_checks/2_outputs/$folder_date/hfc_output.xlsx"

/* Admin variables

	Description of globals for admin variables:
	-------------------------------------------
	
	Admin variables specified here are variables that will be used multiple 
	times for different checks. Users can also modify variables for specific 
	commands in the master do-file if neccesary. 
	
	* Required Variables: 
	
	key					Unique key. Variable containing unique keys for each 
						submission. Note that this is different from the Survey ID. 
	
	id 					Survey ID. Variable containing the ID for each respondent/
						observation. 
	
	enum				Enumerator variable
	
	date				Survey Date Variable. Must be a DATETIME variable
	
	
	* Optional Variables:

	team 				Enumerator Team variable
	
	starttime 			Survey start time Variable. Must be a DATETIME variable
	
	duration			Duration variable. Must be a numeric variable. 
	
	formversion 		Form version variable. Must be a numeric variable. Note 
						that this is expected to be a numeric variable with higher 
						values representing the most recent form version.  
	
	consent 			Consent Variable. Must be a numeric variable. 
	
*/
*------------------------------------------------------------------------------*

	* NB: Edit this section: Change variable names if neccesary. 
	
	* Required Variables:
	
	gl key					"key"
	gl id					"uuid"
	gl enum 				"enum_name"
	gl date					"starttime"											
	
	* Optional Variables:

	gl team 				"team"													
	gl starttime 			"starttime"											
	gl duration				"duration"											
	gl formversion 			"formdef_version"									
	gl consent 				"consent"

	
