/**************************************************************************
 Program:  Print_templates.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/16/14
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Profiles, local=n )

%Style_profile_xhtml()

proc template;
  path sashelp.tmplmst;
  
  source tagsets.profileXHTML /store=sasuser.templat;
  source tagsets.xhtml;
  source tagsets.html4;
  source tagsets.htmlcss;
  source tagsets.phtml;
run;

