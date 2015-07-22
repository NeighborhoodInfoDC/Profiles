/**************************************************************************
 Program:  Suppress_data.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  02/19/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro for suppressing data based on specified
 conditions.

 Modifications:
  10/25/12 PAT Added optional Round= parameter to specify rounding before
               data supression criterion is applied.
  11/19/12 PAT Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
                Documented macro parameters. 
**************************************************************************/

/** Macro Suppress_data - Start Definition **/

%macro Suppress_data( 
  var=,   /** Base name for variables **/
  when=,  /** Logical expression specifying when data values should be suppressed **/
  years=, /** List of nonsequential years **/
  from=,  /** Starting year for sequential list **/
  to=,    /** Ending year for seqeuntial list **/
  value=, /** Value to assign to replace suppressed data **/
  round=  /** Rounding to perform before evaluating when= expression (optional) **/
  );

  %if &years ~= %then %do;
  
    %** List of years (nonsequential) **; 
  
    %let i = 1;
    %let y = %scan( &years, &i );
    
    %if &round ~= %then %do;
      &var._&y = round( &var._&y, &round );
    %end;
    
    %do %while ( &y ~= );
    
      if %unquote(&when) then &var._&y = &value;

      %let i = %eval( &i + 1 );
      %let y = %scan( &years, &i );

    %end;
  
  %end;
  %else %if &from ~= and &to ~= %then %do;
  
    %** Sequential years **;

    %do y = &from %to &to;
  
      %if &round ~= %then %do;
        &var._&y = round( &var._&y, &round );
      %end;
    
      if %unquote(&when) then &var._&y = &value;

    %end;

  %end;  
  %else %do;
    %err_mput( macro=Suppress_data, msg=Must specify values for either YEARS= or FROM=/TO=. )
  %end;
  
%mend Suppress_data;

/** End Macro Definition **/

