/**************************************************************************
 Program:  Nbr_profile_web.sas
 Library:  Profiles
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  01/14/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro for creating HTML neighborhood
 profiles.

 The following named macro parameters must be supplied:
    html_out       - Html output location & base file name
    prof_vars_list - Macro variable containing profile var list
    ods_template   - ODS template for profile output
    ds_in          - Input data set library & name
    geo_var        - Geographic subarea variable name
    geo_name       - Geographic subarea name
    geo_fmt        - Geographic subarea SAS format
    prof_title     - Profile title 
    sec_head_list  - Macro variable containing list of 
                     section heading vars and labels

 The following parameters are optional:
    num_obs        - Set to 2 for testing profile format 
    where_cond     - A where condition for filtering input data
    ds_out         - Output data set library & name (default is temp. ds)

 Modifications:
  01/19/05 - Adapted to new web site style.
  04/02/07 PAT  Added COMPARE_COL=.
  01/20/09 PAT  Added Soures and Notes link to top of profile.
  08/05/11 PAT  Made formating changes for new web site design:
                - Added ../stylesheet_home.css stylesheet
  09/10/11 PAT  Test of profiles 2.0.
  10/30/12 PAT  All meta names in <head> tag moved to 
                Style_profile_xhtml.sas.
  11/19/12 PAT  Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
  04/17/14 PAT  Adjusted title3 (tabs) in profile to make shorter so
                that it won't break (removed alt=).
*************************************************************************/

/** Macro Nbr_profile_web - Start Definition **/

%macro Nbr_profile_web( 
    num_obs=1000000 ,
    html_out= ,
    ds_out=Nbr_profile_web ,
    prof_vars_list= ,
    ods_template= ,
    cell_fmt=comma12.0 ,
    ds_in = ,
    geo_var= ,
    geo_name= ,
    geo_fmt= ,
    prof_title= ,
    sec_head_list= ,
    moe_col = ,           /** Crosswalk for MOE columns (if appl.) **/
    breadcrumb_code= ,    /** Code for navigation breadcrumbs **/
    tab_code= ,           /** Code for profile tabs **/
    header_notes= ,       /** Notes to print in header section **/
    where_cond= ,
    compare_col=Y         /** Comparison columns (Y/N) **/
  );
  
  %local DOT_S DOT_I i v moe_orig_list moe_var_list;
  
  %** Numeric codes for special missing values **;
  
  %let DOT_S = -9999999999;    %** .s = suppressed data **;
  %let DOT_I = -9999999998;    %** .i = insufficient data **;
  
  %let compare_col = %upcase( &compare_col );

  %** Generate table of contents **;
  
  %Prof_toc_generate_web( &sec_head_list )
  
  ** Display default style in LOG **;

  proc template;
     source &ods_template;
  run;
  
  ** Create number format for profile **;

  proc format;
    picture profnum (default=12 round)
      &DOT_I, .i = 'i' (noedit)
      &DOT_S, .s = 's' (noedit)
      -999999999 - -10 = '000,000,009' (prefix='-')
      -10 <-< 0 = '009.9' (prefix='-')
       0   -<10 = '009.9'
      10 - high = '000,000,009' ;
  run;
  
  ** Read input data and create section headings **;
  
  proc sort data=&ds_in (obs=&num_obs) out=_npw_Nbr_Data_a;
  %if %length( &where_cond ) > 0 %then %do;
    where &where_cond;
  %end;
    by &geo_var;
  run;

  data _npw_Nbr_Data;

    set _npw_Nbr_Data_a;
    
    ** File number **;
    
    if _type_ > 0 then _file_n + 1;

    ** Section headings **;
    
    %Sec_head_generate( Sec_head_web, &Sec_head_list );

    keep &geo_var _file_n geo_name_bc _type_ _make_profile &&&prof_vars_list;

  run;

  ** Transpose subarea-level data **;

  proc transpose data=_npw_Nbr_Data out=_npw_Tr_Data;
    where _type_ > 0;
    var &&&prof_vars_list;
    by &geo_var _file_n geo_name_bc;
  run;
  
  ** Number observations to retain original transpose file order **;

  data _npw_Tr_Data_2;

    set _npw_Tr_Data;
    
    _profile_n = _n_;
    
  run;

  *proc print data=_last_;

  ** Compute min, max for each variable across all subareas **;

  proc sort data=_npw_Tr_Data_2;
    by _name_;
    
  proc summary data=_npw_Tr_Data_2;
    var col1;
    by _name_;
    output out=_npw_Tr_Data_Min_Max min= max= /autoname;
    
  run;

  ** Transpose larger area totals **;

  proc transpose data=_npw_Nbr_Data out=_npw_Tr_Data_Big;
    where _type_ = 0;
    var &&&prof_vars_list;

  proc sort data=_npw_Tr_Data_Big;
    by _name_;

  run;

  ** Merge summary statistics back to transposed file **;

  data _npw_Tr_Data_Mrgd;

    merge 
      _npw_Tr_Data_2 (drop=_LABEL_)
      _npw_Tr_Data_Big (rename=(col1=col1_mean)) 
      _npw_Tr_Data_Min_Max;
    by _name_;
    
    ** Blank column for spacing **;
    
    retain blank ' ';
    
    ** Recode special missing values for appearance in Proc Report **;

    if col1 = .i then col1 = &DOT_I;
    if col1 = .s then col1 = &DOT_S;
           
  run;
  
  %** Create lists of MOE variables **;
  
  %if %length( &&&moe_col ) > 0 %then %do;
  
    %let i = 1;
    %let v = %scan( &&&moe_col, &i, %str( =) );
    %let moe_var_list = ;
    %let moe_orig_list = ;

    %do %until ( &v = );

      %if %sysfunc( mod( &i, 2 ) ) = 1 %then 
        %let moe_var_list = &moe_var_list &v;
      %else
        %let moe_orig_list = &moe_orig_list &v;
      
      %let i = %eval( &i + 1 );
      %let v = %scan( &&&moe_col, &i, %str( =) );

    %end;
    
    ** Create transpose file with MOE values **;
    
    data Nbr_moe;
    
      set _npw_Nbr_Data_a (keep=&geo_var &moe_var_list);
      
      rename &&&moe_col;
      
    run;
    
    ** Transpose MOE data **;

    proc transpose data=Nbr_moe out=_npw_Tr_moe prefix=moe;
      where not missing( &geo_var );
      var &moe_orig_list;
      by &geo_var;
    run;
    
    ** Create formatted character var with MOE info **;
    
    data _npw_Tr_moe_char;
    
      set _npw_Tr_moe;
      
      length moe_char $ 200;
      
      if not missing( moe1 ) then 
        moe_char = '<a title="What&#39;s this? 90% margin of error for ACS estimate. Click for more info." href="../Sources_notes.html#moe">±&nbsp;' || 
        trim( left( put( moe1, profnum. ) ) ) || '</a>';
      else
        moe_char = '';
        
    run;

    ** Merge with main data **;
    
    proc sql noprint;
      create table _npw_Tr_data_final as
      select * from _npw_Tr_data_mrgd as dat left join _npw_Tr_moe_char as moe
      on dat.&geo_var=moe.&geo_var and 
      upcase( dat._name_ ) = upcase( moe._name_ );
    quit;

  %end;
  %else %do;
  
    proc datasets library=Work memtype=(data) nolist;
      change _npw_Tr_data_mrgd=_npw_Tr_data_final;
    quit;

  %end;
  
  ** Restore original file order **;

  proc sort data=_npw_Tr_Data_final out=&ds_out;
    by _profile_n;

  *proc print data=_last_ (obs=50);
    
  run;
  
  /***%File_info( data=&ds_out )***/
  
  ** Generate profiles **;

  options missing=' ';

  ods tagsets.profileXhtml 
    file="&html_out" (title="&prof_title - NeighborhoodInfo DC") 
    newfile=page 
    stylesheet=(url='../stylesheet_home.css ../stylesheet_pr.css')
    ;

  ods listing close;

  options nobyline;

  proc report list data=&ds_out nowd split="*" 
    style(header)=[font_size=3];
    by &geo_var _file_n geo_name_bc;
    
    %if &compare_col = Y %then %do;
    
      %** Display multiple comparison columns **;
      
      %if %length( &&&moe_col ) > 0 %then %do;
        %** Include MOE column **;
        column _label_ ( "%nrstr(This )&geo_name%nrstr(   )" Col1 Moe_char ) blank ( "All &geo_name.s in D.C." Col1_mean Col1_min Col1_max );
      %end;
      %else %do;
        %** No MOE column **;
        column _label_ ( "%nrstr(This )&geo_name%nrstr(   )" Col1 ) blank ( "All &geo_name.s in D.C." Col1_mean Col1_min Col1_max );
      %end;      
      format Col1 Col1_mean Col1_min Col1_max &cell_fmt
             &geo_var &geo_fmt;
      label
        &geo_var = ''
        _label_ = '*'
        blank = '*'
        col1 = '*'
        %if %length( &&&moe_col ) > 0 %then %do;
          moe_char = '*'
        %end;
        %else %do;
        %end;
        col1_mean = 'Average'
        col1_min = '    Low    '
        col1_max = '    High    ';
        
    %end;
    %else %do;
    
      %** Display single column for selected area **;
    
      %if %length( &&&moe_col ) > 0 %then %do;
        column _label_ ( "%nrstr(   )&geo_name%nrstr(   )" Col1 moe_char );
      %end;
      %else %do;
        column _label_ ( "%nrstr(   )&geo_name%nrstr(   )" Col1 );
      %end;
      format Col1 &cell_fmt
             &geo_var &geo_fmt;
      label
        &geo_var = ''
        _label_ = '*'
        col1 = '*'
        %if %length( &&&moe_col ) > 0 %then %do;
          moe_char = '*'
        %end;
        ;
        
    %end;

    title1 " ";

    title2 
      "<!--BREADCRUMBS-->"
      "<small><a href=""../index.html"">Home</a>&html_right_arrow" 
      "<a href=""../profiles.html"">Profiles</a>&html_right_arrow"
      &breadcrumb_code
      "</small>";
    
    title3
      /***"<!--TABS-->"***/
      "<dl id=""navigation"">"
      &tab_code
      "</dl><img src=""../images/h-line.gif"" width=""829"" height=""1"" border=""0"" align=""left"" hspace=""0"" vspace=""0"" />";

    title4 " ";
    
    title5 "<i>&prof_title</i>";

    title6
      "<!--TABLE OF CONTENTS-->"
      "<table align=""left"" border=""0"" cellspacing=""5"" cellpadding=""0"" width=""75%"">"
        &g_prof_toc_web
        "<tr align=""left"">
          <td colspan=""2"">&html_nbsp.</td>
        </tr>"
        "<tr align=""left"">
          <td colspan=""2""><a href=""../Sources_notes.html"">Sources and Notes</a></td>
        </tr>"
        %if %length( &&&header_notes ) > 0 %then %do;
          "<tr align=""left"">
            <td colspan=""2"">&&&header_notes</td>
          </tr>"
        %end;
        "<tr align=""left"">
          <td colspan=""2"">&html_nbsp.</td>
        </tr>"
      "</table>";

    *title7 bold height=16pt "#byval( &geo_var )";
    
    footnote1 height=10pt "Notes:";
    footnote2 height=10pt "i = Insufficient data; s = Suppressed proprietary or confidential data.";
    footnote3 height=10pt " ";
    footnote4 height=10pt bold "Prepared by NeighborhoodInfo DC (revised %sysfunc(date(),worddate.)).";
    footnote5 height=10pt " ";
    footnote6 "<a href=""../Sources_notes.html"">Sources and Notes</a>";

  run;

  ods _all_ close;
  ods listing;

  options byline;
  options missing='.';
  
  ** Generate list of HTML file numbers with subarea geographic identifiers **;
  
  data _npw_Nbr_Data_pr;
    set _npw_Nbr_Data;
    where _type_ > 0;
  run;
  
  proc print data=_npw_Nbr_Data_pr obs="HTML File No." label;
    var &geo_var;
    label &geo_var = "&geo_name";
    title1 "&prof_title";
    title3 "List of HTML File Numbers with Corresponding &geo_name Identifiers";
    footnote1;
    
  run;
  
  title1;
  
  ** Cleanup temporary files **;
  
  proc datasets library=Work memtype=(data);
    delete _npw_: ;
  quit;
 
  run;

%mend Nbr_profile_web;

/** End Macro Definition **/
