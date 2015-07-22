/**************************************************************************
 Program:  Make_cluster_fmt.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/03/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Make format for HTML cluster profiles.

 Modifications:
  11/19/12 PAT  Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
**************************************************************************/

/** Macro Make_cluster_fmt - Start Definition **/

%macro Make_cluster_fmt( fmt= );

  %Data_to_format(
    FmtLib=work,
    FmtName=&fmt,
    Data=General.Cluster2000,
    Value=cluster2000,
    Label=
      trim( cluster_num ) || "<br /><small>" || put( ward2002, $ward02a. ) ||
      " / " || trim( nbh_names ) || "</small>" ,
    OtherLabel=' ',
    DefaultLen=.,
    MaxLen=.,
    MinLen=.,
    Print=N,
    Contents=N
  )

%mend Make_cluster_fmt;

/** End Macro Definition **/

