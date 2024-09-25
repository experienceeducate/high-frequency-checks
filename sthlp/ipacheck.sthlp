{smcl}
{* *! version 4.1.2 Innovations for Poverty Action 23nov2022}{...}

{cmd:ipacheck} {c -} Update ipacheck package and initialize a high frequency check project or exercise

{title:Syntax}

{phang}
Start new project with folder structure and/or input files

{pmore}
{cmd:ipacheck new}
[{cmd:,} {it:{help ipacheck##new_options:new_options}}]

{phang}
Update ipacheck package

{pmore}
{cmd:ipacheck update}
[{cmd:,} {it:{help ipacheck##update_options:update_options}}]

{phang}
Display version for each command in ipacheck

{pmore}
{cmd:ipacheck version}

{marker new_options}
{synoptset 23 tabbed}{...}
{synopthdr:new_options}
{synoptline}
{synopt:{opt surv:eys(namelist)}}get input files for multiple projects{p_end}
{synopt:{opt fold:er("folder path")}}save to folder location{p_end}
{synopt:{opt obsid(varname)}}specify the variable that uniquely identifies each observation{p_end}
{synopt:{opt enumid(varname)}}specify the variable that uniquely identifies each enumerator{p_end}
{synopt:{opt teamid(varname)}}specify the variable that uniquely identifies each supervisor or enumerator team{p_end}
{p2colreset}{...}

{marker update_options}
{synoptset 23 tabbed}{...}
{synopthdr:update_options}
{synoptline}
{synopt:{opt branch("branchname")}}install programs and files from specified repository instead of master{p_end}
{synoptline}
{p2colreset}{...}

{title:Description} 

{pstd}
{cmd:ipacheck} creates a new project folder structure, updates all ado files and 
mata libraries, or displays the current version of ado files.

{hline}

{pstd}
{cmd:ipacheck new} initializes a project's high frequency checks. It incluses options to create the folder structure and download inputs files.
 
{title:Options for {it:ipacheck new}}

{phang}
{cmd:surveys(string)} lists all survey forms on which HFCs will be run. 
The {cmd:surveys()} option is typical used for managing projects with multiple surveys. The 
{cmd:surveys()} option can be specified as {cmd:surveys(household adult)} to indidate 2 
surveys; a household and an adult survey. Items in the {cmd:survey()}  option 
must be enclosed in double quotes if they contain blacks. eg. 
{cmd:surveys("household survey" "adult survey")}. If {cmd:surveys()} is not 
specified, the default is to set up input files for one survey only
  
{phang}
{cmd:folder("folder path")} specifies the location in which the new folder structure 
should be saved. If the {cmd:folder()} option is not specified, the default is to save 
the folder structure and files in the current working directory.

{phang}
{cmd:obsid(varname)} specifies the variable that uniquely identifies each observation. If the {cmd:obsid(var)} option is not specified, the default value
for {cmd:obsid} is {cmd:uuid}.

{phang}
{cmd:enumid(varname)} specifies the variable that uniquely identifies each enumerator. If the {cmd:enumid(var)} option is not specified, the default value
for {cmd:enumid} is {cmd:enum_name}.

{phang}
{cmd:teamid(varname)} specifies the variable that uniquely identifies each enumerator. If the {cmd:teamid(var)} option is not specified, the default value
for {cmd:teamid} is {cmd:team}.

{phang}
{cmd:branch("branchname")} specifies the branch from the github repository to 
connect to. This option is mostly used for debugging and should only be used upon
the request of the authors. 

{hline}

{pstd}
{cmd:ipacheck update} updates all commands and mata libraries in the ipacheck package 
to the most recent versions on the 
{browse "https://github.com/PovertyAction/high-frequency-checks/master":high-frequency-checks} 
repository of PovertyAction Github account. 

{title:Options for {it:ipacheck update}}

{phang}
{cmd:branch("branchname")} specifies the branch from the github repository to 
connect to. This option is mostly used for debugging and should only be used upon
the request of the authors. 

{hline}

{pstd}
{cmd:ipacheck version} displays the version information for all commands in the 
ipacheck package.

{hline}

{title:Examples} 

{phang}
{txt}Setting up new HFC folder for a project with one form (Household) and specifying ID variables form{p_end}

{phang}{com}. ipacheck new, surveys(Household) folder("My project") obsid(hh_id)
enumid(enum_id) teamid(team_id)

{title:Remarks}

{pstd}All files and source code for the {cmd:ipacheck} package can found
{browse "https://github.com/matteoram/high-frequency-checks":here} on Github. 
The {cmd:ipacheck} package contains the following commands:

{synoptset 30 tabbed}{...}
{synopthdr:Program}
{synoptline}
{syntab:Main programs}
{synopt:{help ipacheckcorrections}}makes corrections to data{p_end}
{synopt:{help ipacheckspecifyrecode}}recodes other specify values{p_end}
{synopt:{help ipacheckversions}}analyze and report on survey form version{p_end}
{synopt:{help ipacheckids}}export duplicates in survey ID{p_end}
{synopt:{help ipacheckdups}}export duplicates in non-ID variables{p_end}
{synopt:{help ipacheckmissing}}export statistics on missingness & distinctness for each variable{p_end}
{synopt:{help ipacheckspecify}}export all values specified for variables with an 'other' category{p_end}
{synopt:{help ipacheckoutliers}}export outliers in numeric variables{p_end}
{synopt:{help ipacheckconstraints}}export constraint violations in numeric variables{p_end}
{synopt:{help ipacheckcomments}}export field comments generated with SurveyCTO's comments field type{p_end}
{synopt:{help ipachecktextaudit}}export field duration statistics using the SurveyCTO's text audit files{p_end}
{synopt:{help ipachecktimeuse}}export statistics on hours of engagement using the SurveyCTO's text audit files{p_end}
{synopt:{help ipachecksurveydb}}export general statistics about dataset{p_end}
{synopt:{help ipacheckenumdb}}export general statistics about enumerator performance{p_end}
{synopt:{help ipatracksurvey}}export dashboard for tracking survey progress{p_end}
{synopt:{help ipabcstats}}compare survey and back check data{p_end}

{syntab:Ancilliary programs}
{synopt:{help ipacodebook}}export codebook to excel{p_end}
{synopt:{help ipasctocollate}}collate and export a dataset of SurveyCTO generated text audit or comment files{p_end}
{synopt:{help ipalabels}}remove labels or values from variables{p_end}
{synopt:{help ipagettd}}convert datetime variables to date{p_end}
{synopt:{help ipagetcal}}create a date calendar dataset{p_end}
{synopt:{help ipaanycount}}create a variable that returns the number of variables in varlist for which values are equal to any specified integer/string{p_end}

{syntab:Mata library}
{synopt:{help addlines}}add a lower border line to a row in an excel file{p_end}
{synopt:{help addflags}}add a background color to a cell in an excel file{p_end}
{synopt:{help colwidths}}adjust column widths in excel file using length of values in current dataset{p_end}
{synopt:{help colformats}}apply number format to a column in an excel file{p_end}
{synopt:{help setfont}}set font size and type for a range of cells in an excel file{p_end}
{synopt:{help setheader}}set the first row in an excel file as a header row{p_end}
{synopt:{help settotal}}set the last row in an excel file as a total row{p_end}

{synoptline}
{p2colreset}{...}

{title:Acknowledgements}

{pstd}The {cmd:ipacheck} and all of its associated content and materials is developed 
by the Global Research & Data Support (GRDS) Team of Innovations for Poverty Action. 
The current {cmd:version 4.0} of this Stata package is partly based on previous 
versions of which were authored by:

{phang}{com} .Chris Boyer{p_end}
{phang}{com} .Ishmail Azindoo Baako{p_end}
{phang}{com} .Rosemarie Sandino{p_end}
{phang}{com} .Isabel Onate{p_end}
{phang}{com} .Kelsey Larson{p_end}
{phang}{com} .Caton Brewster{p_end}

{title:Author}

{pstd}Ishmail Azindoo Baako, GRDS, Innovations for Poverty Action{p_end}
{pstd}Rosemarie Sandino, GRDS, Innovations for Poverty Action{p_end}
{pstd}{it:Last updated: October 17, 2022 (v4.1.0)}{p_end}

{title:Modified by}

{pstd}{browse "https://github.com/matteoram":Matteo Ramina}{p_end}