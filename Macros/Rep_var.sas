/**************************************************************************
 Program:  Rep_var.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/01/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to repeat variables across multiple years.

 Variable names are generated based on a nonsequential list of years
 (years=) or a sequential list (from=/to=). If both specified, only non-
 sequential list will be used.

 Modifications:
  11/19/12 PAT  Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
                Documented macro parameters.
**************************************************************************/

/** Macro Rep_var - Start Definition **/

%macro Rep_var( 
  var=,    /** Base name of variables **/
  years=,  /** List of nonsequential years **/
  from=,   /** Starting year for sequential list **/
  to=      /** Ending year for seqeuntial list **/
  );

  %if &years ~= %then %do;
  
    %** List of years (nonsequential) **; 
  
    %let i = 1;
    %let y = %scan( &years, &i );
    
    %do %while ( &y ~= );

      &var._&y

      %let i = %eval( &i + 1 );
      %let y = %scan( &years, &i );

    %end;
  
  %end;
  %else %if &from ~= and &to ~= %then %do;
  
    %** Sequential years **;

    %do y = &from %to &to;
    
      &var._&y 
  
    %end;

  %end;  
  %else %do;
    %err_mput( macro=Rep_var, msg=Must specify values for either YEARS= or FROM=/TO=. )
  %end;
  
%mend Rep_var;

/** End Macro Definition **/

