{smcl}
{* *! version 4.0.1 Innovations for Poverty Action 07jul2022}{...}
{title:Title}

{phang}
{cmd:ipacheckoutliers} {hline 2}
Checks for outliers among numeric survey variables.

{marker syntax}{...}
{title:Syntax}

{p 8 10 2}
{cmd:ipacheckoutliers,}
{opth enum:erator(varname)}
{opth date(varname)}
{opth id(varname)}
{opt outf:ile("filename.xlsx")}
[{it:{help ipacheckoutliers##options:options}}]

{marker options}{...}
{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth sh:eet(filename)}}Excel worksheet to load{p_end}
{synopt:* {opth id(varname)}}unique Survey ID variable{p_end}
{synopt:* {opth enum:erator(varname)}}enumerator variable{p_end}
{synopt:* {opth date(varname)}}date/datetime variable indication date of survey{p_end}
{synopt:* {opt outf:ile("filename.xlsx")}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opt outsh:eet("sheetname")}}save summary of duplicates to excel sheet{p_end}
{synopt:{opt sheetmod:ify}}modify excel sheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite excel sheet {cmd:outsheet}{p_end}
{synopt:{opt nol:abel}}export variable values instead of value labels{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt enumerator()}, {opt id()}, {opt date()} and {opt outfile()} are required.{p_end}
{p 4 6 2}* Variables {opt variable} is required is required in using data.{p_end}

{title:Description}

{pstd}
{cmd:ipacheckoutliers} checks for outliers in numeric survey variables. ipacheckoutliers checks for outliers using the standard deviation (SD) method.

{title:Options}

{dlgtab:Main}

{phang}
{pstd}
{opt id(varname)} specifies the id variable for the dataset. {cmd:id()} is required 
and the variable specified with {cmd:id()} must contain unique values only. 
The id variable is automatically included in the output.

{pstd}
{opth enumerator(varname)} specifies the enumerator variable for the dataset. {cmd:enumerator()} is 
required and is automatically included in the output. 

{pstd}
{opt date(varname)} specifies the date or datetime variable indicating the date of 
survey. Reommended variables are Survey start, end or submission dates. This option 
expects a %td date variable or a %tc/%tC datetime variable. If variable specified 
is a datetime variable, the output will show the correspondent date instead of 
datetime. {cmd:date()} is required. 

{pstd}
{opt outfile("filename.xlsx")} specifies Excel workbook to export the duplicate report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{pstd}
{opt outsheet("sheetname")} specifies the Excel worksheet Excel sheet to export the 
output to for the {opt outfile()} specified. The default is to save to Excel sheet "outliers".

{pstd}
{opt sheetmodify} specifies that the output sheet should only be modified 
but not be replaced if it already exist.  

{pstd}
{opt sheetreplace} specifies that the output sheet should be replaced if 
it already exist.  

{pstd}
{opt nolabel} nolabel exports the underlying numeric values instead of the value labels.

{title:Remarks}

{pstd}
Unlike IPA's original {cmd:ipacheckoutliers}, this version does not require an input file (except for the globals do-file). The relevant numerical variables are automatically obtained by going through all variables of the dataset.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master/data/household_survey.dta", clear{p_end}
	{phang}{com}   . destring j_land_size j_land_value duration, replace{p_end}
	{phang}{com}   . recode j_land_size j_land_value (.999 -999 .888 -888 = .){p_end}
	{phang}{com}   . gen j_land_value_acre = j_land_value/j_land_size{p_end}

  {text:Run check}
	{phang}{com}   . ipacheckoutliers, id(hhid) enum(a_enum_id) date(starttime) outf("hfc_outputs.xlsx") sheetrep{p_end}
	
{synoptline}

{txt}{...}

{title:Stored results}

{p 6} {cmd:ipacheckoutliers} stores the following in r():{p_end}

{synoptset 25 tabbed}{...}
{syntab:{opt Scalars}}
{synopt:{cmd: r(N_outliers)}}number of outliers values found{p_end}
{synopt:{cmd: r(N_vars)}}number variables with outlier values{p_end}
{p2colreset}{...}
	
{title:Acknowledgement}

{pstd}
{cmd:ipacheckoutliers} is based on previous versions written by Chris Boyer of Innovations for Poverty Action.

{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {helpb ipacheckcorrections:ipacheckconstraints}, {helpb ipacheckcorrections:ipacheckcorrections}, {helpb extremes:extremes}

{title:Modified by}

{pstd}{browse "https://github.com/matteoram":Matteo Ramina}{p_end}