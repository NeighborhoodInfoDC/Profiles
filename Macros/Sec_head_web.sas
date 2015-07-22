/**************************************************************************
 Program:  Sec_head_web.sas
 Library:  Profiles
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  01/14/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to create section header variable and label
 in DC neighborhood profiles.
 
 Macro name is submitted as a parameter in %Sec_head_generate() macro.
 
 HTML version.

 Modifications:
  01/20/09 PAT Converted name to lowercase to comply with XHTML standard.
  11/19/12 PAT  Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro sec_head_web( sec_var, sec_lbl );
  &sec_var = .;
  label &sec_var = "<a name=""%lowcase(&sec_var)""><b>&sec_lbl</b></a>";
%mend sec_head_web;

