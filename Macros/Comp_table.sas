/**************************************************************************
 Program:  Comp_table.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/03/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create comparison table for specified geography GEO=.

 Modifications:
  02/11/12 PAT  Test of profiles 2.0.
                Comparison tables now saved as XML files with .XLS ext.
  11/19/12 PAT  Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
**************************************************************************/

/** Macro Comp_table - Start Definition **/

%macro Comp_table( geo= );

  %local geosuf geofmt Prof_path k tab_label;

  %let geo = %upcase( &geo );

  %let geosuf = %sysfunc( putc( &geo, $geosuf. ) );
  %let geofmt = %sysfunc( putc( &geo, $geoafmt. ) );
  
  %** Create folder for profile files **;
  
  %let Prof_path = &g_prof_path_web\comparisontables;
  
  options noxwait;
  
  x "md &Prof_path";
  x "del /q &Prof_path\comp_table&geosuf..xls";
    
  %do k = 1 %to &g_prof_num_pages;
  
    %let tab_label = %scan( &g_tab_labels, &k, %str(;) );
    
    data _comp_table&k (compress=no);
    
      retain &geo &&&prof_vars_no_sec&k;
    
      set Nbr_profile&geosuf 
        (keep=_type_ &geo &&&prof_vars_no_sec&k
         where=(_type_=1));

      %if &geo = GEO2000 or &geo = GEO2010 %then %do;
      
        ** Suppress NCDB data for tract-level comp file **;
        
        array ncdb{*} 
          AvgPopulation_1980 AvgPopulation_1990 PctChgTotPop_1980_1990
          PctChgTotPop_1990_2000 PctPopUnder18Years_1980
          PctPopUnder18Years_1990 PctChgPopUnder18Years_1980_1990
          PctChgPopUnder18Years_1990_2000 PctForeignBorn_1980
          PctForeignBorn_1990  PctSameHouse5YearsAgo_1990
          PctBlackNonHispBridge_1990 PctWhiteNonHispBridge_1990
          PctAsianPINonHispBridge_1990 PctPoorPersons_1980
          PctPoorPersons_1990 PctUnemployed_1980 PctUnemployed_1990
          Pct16andOverEmployed_1980 Pct16andOverEmployed_1990
          Pct25andOverWoutHS_1980 Pct25andOverWoutHS_1990
          PctFamiliesOwnChildrenFH_1990 PctPoorChildren_1990
          AvgFamilyIncAdj_1980 AvgFamilyIncAdj_1990
          PctChgAvgFamilyIncAdj_1980_1990
          PctChgAvgFamilyIncAdj_1990_2000 AvgOccupiedHsgUnits_1980
          AvgOccupiedHsgUnits_1990  PctVacantHsgUnitsForRent_1980
          PctVacantHsgUnitsForRent_1990 PctOwnerOccupiedHsgUnits_1980
          PctOwnerOccupiedHsgUnits_1990 
        ;
        
        do i = 1 to dim( ncdb );
          ncdb{i} = .s;
        end;
        
      %end;
      
      format &geo &geofmt &&&prof_vars_no_sec&k profnum12.;
      
      keep &geo &&&prof_vars_no_sec&k;
      
    run;
    
    ** Create contents file **;
    
    proc contents data=_comp_table&k out=_comp_table_cnt&k (keep=varnum name label) noprint;
    
    proc sort data=_comp_table_cnt&k;
      by varnum;
      
    data _comp_table_cnt&k;
    
      length tab_label $ 80;
      
      retain tab_label "&tab_label";
    
      set _comp_table_cnt&k;
      
      if varnum = 1 then do;
        name = "-";
        label = "Geographic area identifier (ward, cluster, etc.)";
      end;
      
    run;
  
    proc print data=_comp_table_cnt&k;
    run;
    
  %end;
  
  ** Combine contents files **;
  
  data _comp_table_cnt_all;
  
    set 
    
      %do k = 1 %to &g_prof_num_pages;
        _comp_table_cnt&k
      %end;
    ;
    
  run;
  
  ** Start writing to XML workbook **;
    
  ods listing close;

  ods tagsets.excelxp file="&Prof_path\comp_table&geosuf..xls" style=/*Minimal*/Normal 
      options( sheet_interval='Proc' orientation='landscape' );

  ** Write data dictionary to first worksheet **;

  ods tagsets.excelxp 
      options( sheet_name="Dictionary" 
               embedded_titles='yes' embedded_footnotes='yes' 
               embed_titles_once='yes' embed_footers_once='yes' );
  
  proc print data=_comp_table_cnt_all label;
    by tab_label notsorted;
    id varnum;
    var name label;
    label 
      tab_label = 'Tab'
      varnum = 'Col #'
      name = 'Name'
      label = 'Description';
    title1 bold "Comparison tables data dictionary";
    title2 height=10pt "Prepared by NeighborhoodInfo DC (revised%sysfunc(date(),worddate.)).";
    title3 height=10pt "Notes: i = Insufficient data; s = Suppressed proprietary or confidential data.";
    footnote1;
  run;
  
  ** Write data to workbook **;
  
  %do k = 1 %to &g_prof_num_pages;
  
    %let tab_label = %scan( &g_tab_labels, &k, %str(;) );

    ods tagsets.excelxp options( sheet_name="&tab_label" embedded_titles='no' embedded_footnotes='no' );
    
    proc print data=_comp_table&k;
      id &geo;
      var &&&prof_vars_no_sec&k;
      title1;
      footnote1;
    run;
    
  %end;
  
  ** Close workbook **;
  
  ods tagsets.excelxp close;
  ods listing;
  
  ** Cleanup temporary data sets **;

  proc datasets library=Work nolist;
    delete _comp_table: /memtype=data;
  quit;

  run;

%mend Comp_table;

/** End Macro Definition **/


