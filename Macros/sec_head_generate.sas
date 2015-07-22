/**************************************************************************
 Program:  Sec_head_generate.sas
 Library:  Profiles
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  01/14/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to generate all section header
 variables and labels in DC neighborhood profiles.

 Modifications:
  10/22/11 PAT  Added local macro variable declaration.
  11/19/12 PAT  Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
**************************************************************************/

%macro sec_head_generate( sec_head_mac, sec_head_list );

  %local delim i sec_var sec_lbl;

  %let delim = %str(%quote(;));
  %let i = 1;
  
  %*put Input = &&&sec_head_list;
  
  %** Read section variable name from list **;
  
  %let sec_var = %scan( &&&sec_head_list, &i, &delim );
  
  %** Execute loop until end of list is reached **;
  
  %do %while( %length( &sec_var ) > 0 );

    %*put The variable = &sec_var;
  
    %** Read section label from list **;
  
    %let sec_lbl = %scan( &&&sec_head_list, %eval(&i+1), &delim );
    %*put The label = &sec_lbl;
    
    %** Write out statements for creating and labeling section header **;
    
    %&sec_head_mac( &sec_var, &sec_lbl );

    %** Increment list pointer and read next var name **;

    %let i = %eval( &i + 2 );
    %let sec_var = %scan( &&&sec_head_list, &i, &delim );
    
  %end;

%mend sec_head_generate;

