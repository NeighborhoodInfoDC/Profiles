/**************************************************************************
 Program:  Make_all_profiles.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/01/07
 Version:  SAS 9.2
 Environment:  Local Windows session (desktop)
 
 Description:  Create all NeighborhoodInfo DC HTML profiles and
 comparison tables for all geographic levels.
 
 See "..\Doc\Profile creation ProgramDoc.doc" for instructions on
 modifying the profiles.
 
 NOTE:  The following messages in the LOG can be ignored:
   WARNING: Apparent symbolic reference NBSP not resolved.
   WARNING: Variable ... already exists on file WORK._NPW_TR_DATA_FINAL.
   WARNING: Variable _NAME_ already exists on file WORK._NPW_TR_DATA_FINA
   WARNING: Multiple lengths were specified for the BY variable ... by input data sets. 
            This may cause unexpected results.
 
 NOTE:  You must search and replace on all neighborhood cluster profiles 
 in the ..\html\nclusters folder before posting to web site:
 
 	&lt;  TO  <
 	&gt;  TO  >

 Modifications:
  09/10/11 PAT  Test of profiles 2.0.
  11/19/12 PAT  Profiles 2.0, final production version.
  11/26/13      Added data for Schools tab.
  03/28/14 PAT  Updated for new SAS1 server.
  04/17/14 PAT  Changed to local session because of page formatting 
                issues in remote session. 
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Profiles, local=y )
%DCData_lib( Ncdb, local=y )
%DCData_lib( ACS, local=y )
%DCData_lib( Vital, local=y )
%DCData_lib( Hmda, local=y )
%DCData_lib( Police, local=y )
%DCData_lib( RealProp, local=y )
%DCData_lib( TANF, local=y )
%DCData_lib( ROD, local=y )
%DCData_lib( Schools, local=y )

** Create profiles for all geographies **;

***options mprint symbolgen mlogic;

%Make_profile( geo=city )

%Make_profile( geo=ward2002 )
%Make_profile( geo=ward2012 )

%Make_profile( geo=anc2012 )

%Make_profile( geo=psa2012 )

%Make_profile( geo=zip )

%Make_profile( geo=geo2000 )
%Make_profile( geo=geo2010 )

%Make_cluster_fmt( fmt=$clus00p )
%Make_profile( geo=cluster_tr2000, fmt=$clus00p )

%Make_profile( geo=VoterPre2012 )

run;

