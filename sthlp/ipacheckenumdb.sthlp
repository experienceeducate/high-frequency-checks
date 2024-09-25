{smcl}
{* *! version 4.0.1 Innovations for Poverty Action 07jul2022}{...}
{title:Title}

{phang}
{cmd:ipacheckenumdb} {hline 2}
Create enumerator dashboard with information on interviews completion and duration by enumerator. 

{title:Syntax}

{p 8 10 2}
{cmd:ipacheckenumdb}{cmd:,}
{opth enum:erator(varname)}
{opth date(varname)}
{opth outf:ile(filename)} 
[{it:{help ipacheckenumdb##options:options}}]

{marker options}{...}

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:* {opth formv:ersion(varlist)}}form version variable{p_end}
{synopt:* {opth enum:erator(varname)}}enumerator variable{p_end}
{synopt:* {opth date(varname)}}date/datetime variable indication date of survey{p_end}
{synopt:* {opth outf:ile(filename)}}save output to Excel workbook{p_end}

{syntab:Specifications}
{synopt:{opth per:iod(ipacheckenumdb##period:period)}}report by specified period eg. daily, weekly, monthly or auto{p_end}
{synopt:{opt cons:ent}{cmd:(}{help varname}{cmd:, }{help numlist}{cmd:)}}}consent variable and values{p_end}
{synopt:{opth dur:ation(varlist)}}duration variables{p_end}
{synopt:{opt sheetmod:ify}}modify excel sheet {cmd:outsheet}{p_end}
{synopt:{opt sheetrep:lace}}overwrite Excel worksheet{p_end}
{synopt:{opt nol:abel}}export variable values instead of value labels{p_end}

{synoptline}
{p2colreset}{...}
{p 4 6 2}* {opt sheet()}, {opt enumerator()}, {opt date()}, {opt formversions()} and {opt outfile()} are required.

{title:Description}

{pstd}
{cmd:ipacheckenumdb} creates an Excel workbook with 2 sheets.

{phang2}.  "duration": summary of duration by enumerator.{p_end}
{phang2}.  "productivity": number of surveys by days/weeks/months.{p_end}

{title:Options}

{dlgtab:Main}

{phang}
{pstd}
{opth enumerator(varname)} specifies the enumerator variable for the dataset. 
{cmd:enumerator()} is required and is automatically included in the output. 

{pstd}
{opt date(varname)} specifies the date or datetime variable indicating the date of 
survey. Recommended variables are Survey start, end or submission dates. This option 
expects a %td date variable or a %tc/%tC datetime variable. If variable specified 
is a datetime variable, the output will show the correspondent date instead of 
datetime. {cmd:date()} is required. 

{pstd}
{opt outfile("filename.xlsx")} specifies Excel workbook to export the report into. 
{cmd:outfile()} is required. Excel formats xls and xlsx are supported in {cmd:outfile()}. 
If a file extension is not specified with {cmd:outfile()}, .xls is assumed, because 
this format is more common and is compatible with more applications that also can read from Excel files.

{dlgtab:Specifications}

{pstd}
{cmd:period(}{help ipacheckenumdb##period:period}{cmd:)} specifies the time frame for showing summaries and statistics 
in the daashboard. eg. {opt period(daily)} {p_end}

{marker period}{...}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt daily}}show daily summaries.{p_end}
{synopt:{opt weekly}}show weekly summaries. Week is Sunday to Saturday{p_end}
{synopt:{opt monthly}}show monthly summaries. Month is based on calendar month{p_end}
{synopt:{opt auto}}Auto adjust period. Changes period to weekly after 40 days and monthly after 40 weeks{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
{cmd:consent(}{help varname}{cmd:, }{help numlist}{cmd:)} option specifies variable and the 
values for consent. eg. consent(consent, 1) or consent(consent, 1 2). When a 
{help numlist} is specified as values, {cmd:ipacheckenumdb} will assume any of 
these values to indicate a valid consent. 

{pstd}
{opth duration(varname)} option specifies the duration variable. If specified, {cmd:ipacheckenumdb} will show statistics on minimimum, maximum, mean and median duration per enumerator.   

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
Unlike IPA's original {cmd:ipacheckenumdb}, this version does not require an input file (except for the globals do-file) and produces a simplified dashboard with only two sheets, formatted as a .xlsx file. The output can also be used directly from the command window or within other do-files.

{title:Examples}

{synoptline}
  {text:Setup}
	{phang}{com}   . use "https://raw.githubusercontent.com/PovertyAction/high-frequency-checks/master/data/household_survey.dta", clear{p_end}
	{phang}{com}   . destring duration, replace
		
  {text:Run ipacheckenumdb}
    {phang}{com}   . ipacheckenumdb, formv(formdef_version) dur(duration) cons(c_consent, 1) dontk(-999, "-999") ref(-888, "888") other(*_osp*) enum(a_enum_name) team(a_team_name) date(starttime) outf("enumdb.xlsx") sheetrep{p_end}
	
{synoptline}

{txt}{...}
	
{title:Authors}

{pstd}
Ishmail Azindoo Baako
(Innovations for Poverty Action){p_end}

{pstd}For questions or suggestions, submit a
{browse "https://github.com/PovertyAction/high-frequency-checks/issues":GitHub issue}
or e-mail researchsupport@poverty-action.org.{p_end}

{title:Also see}

User-written: {helpb ipachecksurveydb:ipachecksurveydb}

{title:Modified by}

{pstd}{browse "https://github.com/matteoram":Matteo Ramina}{p_end}