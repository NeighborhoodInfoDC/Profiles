/**************************************************************************
 Program:  Make_profile.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/04/06
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to create HTML profiles, PDF profiles,
 comparison tables, and comparison graphs for the specified
 geographic level (GEO=).

 Modifications:
  11/19/12 PAT  Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
**************************************************************************/

/** Macro Make_profile - Start Definition **/

%macro Make_profile( 
  geo=,                /** Geographic level **/
  fmt=                 /** Display format **/
);

  %** Initialize variable lists **;
  %Init_nbr_prof_vars
  
  %** Compile all profile data for geographic level **;
  %Compile_profile_data( geo=&geo )
  
  %** Generate web-based profiles for geographic level **;
  %Make_profile_web( geo=&geo, fmt=&fmt )

  %** Generate comparison tables for geographic level **;
  %Comp_table( geo=&geo )

%mend Make_profile;

/** End Macro Definition **/

