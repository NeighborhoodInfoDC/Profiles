/**************************************************************************
 Program:  Test_styles.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/16/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Test styles for XHTML table output.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Profiles, local=n )


data Test;
  input geo_name_bc A:$1. B;
  _file_n = geo_name_bc;
  datalines;
  1 A 1
  1 B 2
  1 C 3
  ;
run;

%Style_profile_xhtml( page_name=Page )

%let html_out = L:\Libraries\Profiles\Html\test\Test_styles.html;
%let prof_title = Test page; 

  ods tagsets.profileXhtml 
    file="&html_out" (title="&prof_title - NeighborhoodInfo DC") 
    newfile=page 
    stylesheet=(url='../stylesheet_home.css ../stylesheet_pr.css')
    ;

  ods listing close;

  options nobyline;

proc report list data=Test nowd split="*"
    style(header)=[font_size=3];
    by _file_n geo_name_bc;
    column A;
    column B;

title2 "<!--BREADCRUMBS-->"
"<small><a href=""../index.html"">Home</a><img src=""../images/right-arrow.gif"" width=""16"" height=""10"" border=""0"" hspace=""2"" alt=""Right arrow"" />"
"<a href=""../profiles.html"">Profiles</a><img src=""../images/right-arrow.gif"" width=""16"" height=""10"" border=""0"" hspace=""2"" alt=""Right arrow"" />"
"<a href=""wards.html"">2012 Wards</a><img src=""../images/right-arrow.gif"" width=""16"" height=""10"" border=""0"" hspace=""2"" alt=""Right arrow"" />"
"#byval( geo_name_bc )"
"</small>";

title3 
"<dl id=""navigation"">"
"<dt id=""selected""><span>Population</span></dt>"
"<dt><a href=""Nbr_prof_wrdb#byval(_file_n)..html""><span>Well-Being</span></a></dt>"
"<dt><a href=""Nbr_prof_wrdc#byval(_file_n)..html""><span>Housing</span></a></dt>"
"<dt><a href=""Nbr_prof_wrdd#byval(_file_n)..html""><span>Foreclosures</span></a></dt>"
"<dt><a href=""Nbr_prof_wrde#byval(_file_n)..html""><span>Schools</span></a></dt>"
"</dl><img src=""../images/h-line.gif"" width=""829"" height=""1"" border=""0"" align=""left"" hspace=""0"" vspace=""0"" />"
;
run;

ods tagsets.profileXhtml close;
ods listing;


