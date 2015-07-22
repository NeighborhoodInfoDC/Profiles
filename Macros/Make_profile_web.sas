/**************************************************************************
 Program:  Make_profile_web.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/01/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to create web-based neighborhood
 profiles for a specified geography (GEO=).

 Modifications:
  09/10/11 PAT  Test of profiles 2.0.
  10/30/12 PAT  Updated folders for new geographies.
                Adjusted geo labels to identify years for geos, 
                where needed.
                Revised breadcrumb code to use basic formatted geo value
                (new var geo_name_bc).
  11/19/12 PAT  Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
  03/30/14 PAT  Added support for voterpre2012.
  04/17/14 PAT  Removed extra spaces from #byval(_file_n).
**************************************************************************/

/** Macro Make_profile_web - Start Definition **/

%macro Make_profile_web( geo=, fmt= );

  %local compare_col geosuf geofmt geo_name geo_name_full geo_folder geo_page geo_psuf 
         where_cond prof_path prof_base prof_base_suf prof_title
         breadcrumb_code tab_base_suf tab_label tab_code tab_file_ext j k;

  %** Geography name, format, labels, file suffix **;
  
  %let compare_col = Y;    %** Default is to include comparison data columns **;
  
  %let geo = %upcase( &geo );

  %let geosuf = %sysfunc( putc( &geo, $geosuf. ) );
  
  %if &fmt = %then 
    %let geofmt = %sysfunc( putc( &geo, $geoafmt. ) );
  %else
    %let geofmt = &fmt..;

  %let geo_name = %sysfunc( putc( &geo, $geoslbl. ) );
  %let geo_name_full = &geo_name;
  %let where_cond = (_make_profile);
  
  %if &geo = CITY %then %do;
    %let geo_folder = city;
    %let geo_page = ;
    %let geo_psuf = city;
    %let compare_col = N;   %** No comparison data columns **;
  %end;
  %else %if &geo = WARD2002 %then %do;
    %let geo_name_full = 2002 Ward;
    %let geo_folder = wards02;
    %let geo_page = wards.html;
    %let geo_psuf = wrd;
  %end;
  %else %if &geo = WARD2012 %then %do;
    %let geo_name_full = 2012 Ward;
    %let geo_folder = wards;
    %let geo_page = wards.html;
    %let geo_psuf = wrd;
  %end;
  %else %if &geo = ANC2002 %then %do;
    %let geo_folder = anc;
    %let geo_page = anc.html;
    %let geo_psuf = anc;
  %end;
  %else %if &geo = ANC2012 %then %do;
    %let geo_name_full = 2012 ANC;
    %let geo_folder = anc12;
    %let geo_page = anc.html;
    %let geo_psuf = anc;
  %end;
  %else %if &geo = GEO2000 %then %do;
    %let geo_name_full = 2000 Tract;
    %let geo_folder = censustract;
    %let geo_page = census.html;
    %let geo_psuf = trct;
  %end;
  %else %if &geo = GEO2010 %then %do;
    %let geo_name_full = 2010 Tract;
    %let geo_folder = censustract10;
    %let geo_page = census.html;
    %let geo_psuf = trct;
  %end;
  %else %if &geo = CLUSTER_TR2000 %then %do;
    %let geo_folder = nclusters;
    %let geo_page = nclusters.html;
    %let geo_psuf = clus;
    %let where_cond = &where_cond and (cluster_tr2000~='99');
  %end;
  %else %if &geo = PSA2004 %then %do;
    %let geo_folder = psa;
    %let geo_page = psa.html;
    %let geo_psuf = psa;
  %end;
  %else %if &geo = PSA2012 %then %do;
    %let geo_name_full = 2012 PSA;
    %let geo_folder = psa12;
    %let geo_page = psa.html;
    %let geo_psuf = psa;
  %end;
  %else %if &geo = ZIP %then %do;
    %let geo_folder = zip;
    %let geo_page = zip.html;
    %let geo_psuf = zip;
  %end;
  %else %if &geo = VOTERPRE2012 %then %do;
    %let geo_folder = voter12;
    %let geo_page = voter.html;
    %let geo_psuf = voter;
  %end;
  %else %do;
    %err_mput( macro=Make_profile_web, msg=Unsupported geography GEO=&geo.. No profiles will be created. )
    %goto exit_macro;
  %end;

  %** Create ODS tagset for profile pages **;
  
  %Style_profile_xhtml( page_name=&geo_name_full profile )

  %** Location for profile files **;
  
  %let Prof_path = &g_prof_path_web\&geo_folder;
  
  %** Breadcrumbs **;
  %if &geo = CITY %then %do;
    %let breadcrumb_code = "Washington, D.C.";
  %end;
  %else %do;
    %let breadcrumb_code = "<a href=""&geo_page"">&geo_name_full.s</a>&html_right_arrow" "#byval( geo_name_bc )";
  %end;
  
  %** Create folder for profile files and delete its contents **;
  
  options noxwait;
  
  x "md &Prof_path";
  x "del /q &Prof_path\*.*";
  
  %** Create individual profile pages (tabs) **;
  
  %do j = 1 %to &g_prof_num_pages;

    %** Name for profile files **;
    
    %let prof_base_suf = %substr( %str( bcdefghijkl), &j, 1 );
    
    %if &geo = CITY %then 
      %let Prof_base = Nbr_prof_&geo_psuf&prof_base_suf;
    %else 
      %let Prof_base = Nbr_prof_&geo_psuf&prof_base_suf.1;
      
    %** Generate tab code **;
    
    %let tab_code = ;
        
    %do k = 1 %to &g_prof_num_pages;
    
      %** NOTE: Initial blank in tab_base_suf is intentional **;
      %let tab_base_suf = %substr( %str( bcdefghijkl), &k, 1 );
      %let tab_label = %scan( &g_tab_labels, &k, %str(;) );
      
      %if &geo = CITY %then %do;
        %let tab_base = Nbr_prof_&geo_psuf&tab_base_suf;
        %let tab_file_ext = .html;
      %end;
      %else %do; 
        %let tab_base = Nbr_prof_&geo_psuf&tab_base_suf.#byval(_file_n);
        %let tab_file_ext = ..html;
      %end;
      
      %if &k = &j %then %do;
        %let tab_code = &tab_code "<dt id=""selected""><span>&tab_label</span></dt>";
        %let prof_title = DC &geo_name_full Profile - &tab_label;
      %end;
      %else %do;
        %let tab_code = &tab_code "<dt><a href=""&tab_base&tab_file_ext""><span>&tab_label</span></a></dt>";
      %end;
        
    %end;
    
    %** Create web profiles **;

    %Nbr_profile_web(
       html_out = &Prof_path\&Prof_base..html ,
       prof_vars_list = prof_vars&j ,
       sec_head_list = sec_heads&j ,
       breadcrumb_code = &breadcrumb_code,
       tab_code = &tab_code,
       header_notes = prof_notes&j ,
       moe_col = prof_moe_col&j ,
       ods_template = Tagsets.Xhtml,
       cell_fmt = profnum12. ,
       
       ds_in = Nbr_profile&geosuf,
       geo_var = &geo,
       geo_name = &geo_name,
       geo_fmt = &geofmt,
       prof_title = &prof_title, 
       where_cond= &where_cond,
       compare_col = &compare_col
     )
     
  %end;

  %exit_macro:

%mend Make_profile_web;

/** End Macro Definition **/

