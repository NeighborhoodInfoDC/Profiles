/**************************************************************************
 Program:  Init_nbr_prof_vars.sas
 Library:  Profiles
 Project:  DC Data Warehouse
 Author:   P. Tatian
 Created:  01/14/05
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Autocall macro to initialize global macro variables
 for use in producing DC neighborhood profiles.

 Modifications:
  01/14/05 Removed AFSCEM0 & AFSCEM9
  01/27/05 Added housing market section
  01/28/05 Added 2002 teen & low wt. births
  02/07/05 Commented out 1999 teen & low wt. births
  04/04/05 Updated
  02/19/08 PAT Updated births, sales prices, price changes, subprime.
  02/20/08 PAT Added FS and TANF clients.
  01/20/09 PAT Added FS and TANF 2008, births 2006, home sales 2007, 
               mortgage lending 2006, crimes 2007.
  04/21/10 ANW Added births 2007, FS and TANF 2009,home sales 2009
  12/21/10 PAT Added 2005-09 ACS data, crimes through 2009,
               TANF/FS through 2010.
  03/24/11 PAT Added Census 2010 redistricting data, property sales 2010.
  06/28/11 SLL Added crime 2010.
  09/10/11 PAT Test of profiles 2.0.
  06/30/12 PAT Added MOE column info.
  09/15/12 PAT Implemented production version.
  10/26/12 PAT Added foreclosure tab. 
  11/19/12 PAT Profiles 2.0, final production version.
  11/26/13      Added data for Schools tab.
  03/28/14 PAT  Updated for new SAS1 server.
  04/29/14 SXZ Added FS and TANF data for 2014, 2013 schools data 
  03/10/15 MSW Added data for seniors
  05/27/16 RP Update with new ACS and Sales data
  07/01/16 RP Update with 2012-2015 crime data
  03/07/17 RP Update with 2011-2015 ACS, 2016 crime, and 2016 sales data. 
  08/15/17 RP Update with TANF and FS Data through 2016.
**************************************************************************/

/** Macro Init_nbr_prof_vars - Start Definition **/

%macro Init_nbr_prof_vars;

  %local i j v;
  
  %** Special values **;
  
  %global html_gt html_lt html_nbsp html_right_arrow;
  
  %let html_gt = %nrstr(&gt;);
  %let html_lt = %nrstr(&lt;);
  %let html_nbsp = %nrstr(&nbsp;);
  %let html_right_arrow = <img src=""../images/right-arrow.gif"" width=""16"" height=""10"" border=""0"" hspace=""2"" alt=""Right arrow"" />;

  %** Profile locations **;
  
  %global g_prof_path_web g_prof_path_rtf g_prof_num_pages g_tab_labels g_prof_toc_web;
  
  %let g_prof_path_web = &_dcdata_path\profiles\html;
  %let g_prof_path_rtf = &_dcdata_path\profiles\rtf;
  
  %** Number of pages (tabs) and tab labels **;
  %let g_prof_num_pages = 5;
  %let g_tab_labels = %str( Population; Well-Being; Housing; Foreclosures; Schools );
  
  %** Profile variables and section headings **;

  %global prof_vars1 prof_vars_no_sec1 sec_heads1 prof_moe_col1 prof_notes1
          prof_vars2 prof_vars_no_sec2 sec_heads2 prof_moe_col2 prof_notes2
          prof_vars3 prof_vars_no_sec3 sec_heads3 prof_moe_col3 prof_notes3
          prof_vars4 prof_vars_no_sec4 sec_heads4 prof_moe_col4 prof_notes4
          prof_vars5 prof_vars_no_sec5 sec_heads5 prof_moe_col5 prof_notes5
          ;
          
  %****** Continuous series indicators ******;

  %global births_start_yr births_end_yr fs_tanf_start_yr fs_tanf_end_yr 
          rsales_start_yr rsales_end_yr hmda_start_yr hmda_end_yr 
          crime_start_yr crime_end_yr inc_dollar_yr
          fcl_start_yr fcl_end_yr msf_start_yr msf_end_yr enroll_start_yr enroll_end_yr
		  acs_start_yr acs_end_yr acs_infl_yr acsyr;
  
  %** UPDATE WITH CORRECT YEARS FOR LATEST DATA AVAILABLE;
  %let births_start_yr = 1998;
  %let births_end_yr = 2011;
  %let fs_tanf_start_yr = 2000;
  %let fs_tanf_end_yr = 2016;
  %let rsales_start_yr = 1995;
  %let rsales_end_yr = 2016;
  %let hmda_start_yr = 1997;
  %let hmda_end_yr = 2006;
  %let crime_start_yr = 2000;
  %let crime_end_yr = 2016;
  %let inc_dollar_yr = 2010;
  %let fcl_start_yr = 1995;
  %let fcl_end_yr = 2013;
  %let msf_start_yr = 2000;
  %let msf_end_yr = 2013;
  %let enroll_start_yr = 2001;
  %let enroll_end_yr = 2013;
  **************************;

  %** UPDATE WITH CORRECT YEARS FOR ACS DATA AVAILABLE;
  %let acs_start_yr = 2011;	**Four digit year for ACS end year **;
  %let acs_end_yr = 15;	**Two digit only for ACS end year **;
  %let acs_infl_yr= 2015; ** Four digit  for ACS end year **;

  %let acsyr = &acs_start_yr._&acs_end_yr.; 
  

  
  %****** Profile tab specifications ******;
  
  %** List sections and variables in order they should appear in profile **;
  
  %** Profile tab 1 - Population **;

  %let prof_vars1 = 
        Sec_1_Pop 
          TotPop_1980 TotPop_1990 TotPop_2000 TotPop_2010
          PctChgTotPop_1980_1990 PctChgTotPop_1990_2000 
          PctChgTotPop_2000_2010
        Sec_1_Child
          PctPopUnder18Years_1980 PctPopUnder18Years_1990 PctPopUnder18Years_2000 
          PctPopUnder18Years_2010
          PctChgPopUnder18Years_1980_1990 PctChgPopUnder18Years_1990_2000 
          PctChgPopUnder18Yea_2000_2010
		Sec_1_Senior
		  PctPop65andOverYears_1980 PctPop65andOverYears_1990 PctPop65andOverYears_2000
		  PctPop65andOverYears_2010
          PctChgPop65andOverYear_1980_1990 PctChgPop65andOverYear_1990_2000 
          PctChgPop65andOverYear_2000_2010
        Sec_1_Race
          PctBlackNonHispBridge_1990 PctBlackNonHispBridge_2000 
          PctBlackNonHispBridge_2010
          PctWhiteNonHispBridge_1990 PctWhiteNonHispBridge_2000 
          PctWhiteNonHispBridge_2010
          PctHisp_1990 PctHisp_2000 PctHisp_2010
          PctAsianPINonHispBridge_1990 PctAsianPINonHispBridge_2000 
          PctAsianPINonHispBridge_2010
        Sec_1_Foreign
          PctForeignBorn_1980 PctForeignBorn_1990 PctForeignBorn_2000 PctForeignBorn_&acsyr.
        Sec_1_Families
          PctFamiliesOwnChildrenFH_1990 PctFamiliesOwnChildrenFH_2000 PctFamiliesOwnChildrenFH_&acsyr.
        Sec_1_Births_low
          %Rep_var( var=Pct_births_low_wt, from=&births_start_yr, to=&births_end_yr )
        Sec_1_Births_teen
          %Rep_var( var=Pct_births_teen, from=&births_start_yr, to=&births_end_yr )
          ;

  %let sec_heads1 = 
         %str( Sec_1_Pop; Total;
               Sec_1_Child; Children;
			   Sec_1_Senior; Seniors;
               Sec_1_Race; Race/Ethnicity;
               Sec_1_Foreign; Foreign-Born;
               Sec_1_Families; Families;
               Sec_1_Births_low; Low weight births;
               Sec_1_Births_teen; Births to teen mothers
              );

  %let prof_moe_col1 = 
         PctForeignBorn_m_&acsyr.=PctForeignBorn_&acsyr.
         PctFamiliesOwnChildFH_m_&acsyr.=PctFamiliesOwnChildrenFH_&acsyr.
       ;

  %let prof_notes1 = ;
  
  %** Profile tab 2 - Well-Being **;

  %let prof_vars2 = 
        Sec_2_Poverty
          PctPoorPersons_1980 PctPoorPersons_1990 PctPoorPersons_2000 PctPoorPersons_&acsyr.
          PctPoorChildren_1990 PctPoorChildren_2000 PctPoorChildren_&acsyr.
		  PctPoorElderly_1990 PctPoorElderly_2000 PctPoorElderly_&acsyr.
        Sec_2_Employment
          PctUnemployed_1980 PctUnemployed_1990 PctUnemployed_2000 PctUnemployed_&acsyr.
          Pct16andOverEmployed_1980 Pct16andOverEmployed_1990 Pct16andOverEmployed_2000 
          Pct16andOverEmployed_&acsyr.
        Sec_2_Education
          Pct25andOverWoutHS_1980 Pct25andOverWoutHS_1990 Pct25andOverWoutHS_2000 
          Pct25andOverWoutHS_&acsyr.
        Sec_2_Isolat
          PctHshldPhone_2000 PctHshldPhone_&acsyr.
          PctHshldCar_2000 PctHshldCar_&acsyr.
        Sec_2_Inc
          AvgFamilyIncAdj_1980 AvgFamilyIncAdj_1990 AvgFamilyIncAdj_2000 AvgFamilyIncAdj_&acsyr.
          PctChgAvgFamilyIncAdj_1980_1990 PctChgAvgFamilyIncAdj_1990_2000 
          PctChgAvgFamilyIncA_2000_&acsyr.
        Sec_2_FS
          %Rep_var( var=fs_client, from=&fs_tanf_start_yr, to=&fs_tanf_end_yr )
        Sec_2_Tanf
          %Rep_var( var=tanf_client, from=&fs_tanf_start_yr, to=&fs_tanf_end_yr )
        Sec_2_Violent
          %Rep_var( var=Rate_crimes_pt1_violent, from=&crime_start_yr, to=&crime_end_yr )
        Sec_2_Property
          %Rep_var( var=Rate_crimes_pt1_property, from=&crime_start_yr, to=&crime_end_yr )
          ;

  %let sec_heads2 = 
         %str( Sec_2_Poverty; Poverty;
               Sec_2_Employment; Employment;
               Sec_2_Education; Education;
               Sec_2_Isolat; Isolation;
               Sec_2_Inc; Family income (&inc_dollar_yr $);
               Sec_2_FS; Food stamps;
               Sec_2_Tanf; TANF;
               Sec_2_Violent; Violent Crimes (per 1,000 pop.);
               Sec_2_Property; Property Crimes (per 1,000 pop.)
              );

  %let prof_moe_col2 = 
         PctPoorPersons_m_&acsyr.=PctPoorPersons_&acsyr.
         PctPoorChildren_m_&acsyr.=PctPoorChildren_&acsyr.
		 PctPoorElderly_m_&acsyr.=PctPoorElderly_&acsyr.
         PctUnemployed_m_&acsyr.=PctUnemployed_&acsyr.
         Pct16andOverEmployed_m_&acsyr.=Pct16andOverEmployed_&acsyr.
         Pct25andOverWoutHS_m_&acsyr.=Pct25andOverWoutHS_&acsyr.
         PctHshldPhone_m_&acsyr.=PctHshldPhone_&acsyr.
         PctHshldCar_m_&acsyr.=PctHshldCar_&acsyr.
         AvgFamilyIncAdj_m_&acsyr.=AvgFamilyIncAdj_&acsyr.
         PctChgAvgFamIncA_m_2000_&acsyr.=PctChgAvgFamilyIncA_2000_&acsyr.
       ;

  %let prof_notes2 = ;

  %** Profile tab 3 - Housing **;

  %let prof_vars3 = 
        Sec_3_Hsng
          NumOccupiedHsgUnits_1980 NumOccupiedHsgUnits_1990 NumOccupiedHsgUnits_2000
          NumOccupiedHsgUnits_2010
        Sec_3_Mobility
          PctSameHouse5YearsAgo_1990 PctSameHouse5YearsAgo_2000
        Sec_3_Vacant
          PctVacantHsgUnitsForRent_1980 PctVacantHsgUnitsForRent_1990 PctVacantHsgUnitsForRent_2000
          PctVacantHsgUnitsForRent_&acsyr.
        Sec_3_Owner
          PctOwnerOccupiedHsgUnits_1980 PctOwnerOccupiedHsgUnits_1990 PctOwnerOccupiedHsgUnits_2000
          PctOwnerOccupiedHsgUnits_&acsyr.
        Sec_3_Sales
          %Rep_var( var=sales_sf, from=&rsales_start_yr, to=&rsales_end_yr )
        Sec_3_Price
          %Rep_var( var=r_mprice_sf, from=&rsales_start_yr, to=&rsales_end_yr )
          PctAnnChgRMPriceSf_10yr
          PctAnnChgRMPriceSf_5yr
          PctAnnChgRMPriceSf_1yr
        Sec_3_Mrtg_orig
          %Rep_var( var=NumMrtgOrigHomePurchPerUnit, from=&hmda_start_yr, to=&hmda_end_yr )
        Sec_3_Mrtg_inc
          %Rep_var( var=MedianMrtgInc1_4m_adj, from=&hmda_start_yr, to=&hmda_end_yr )
        Sec_3_Mrtg_sub
          %Rep_var( var=PctSubprimeConvOrigHomePur, from=&hmda_start_yr, to=&hmda_end_yr )
          ;

  %let sec_heads3 = 
         %str( Sec_3_Hsng; Housing Units;
               Sec_3_Mobility; Mobility;
               Sec_3_Vacant; Rental Vacancy;
               Sec_3_Owner; Homeownership;
               Sec_3_Sales; Sales of Single-Family Homes;
               Sec_3_Price; Price of Single-Family Homes (&rsales_end_yr $);
               Sec_3_Mrtg_orig; Mortgage Lending (Home Purchase Loans);
               Sec_3_Mrtg_inc; Mortgage Borrower Income (&hmda_end_yr $);
               Sec_3_Mrtg_sub; Subprime Lending
              );

  %let prof_moe_col3 = 
    PctVacantHUForRent_m_&acsyr.=PctVacantHsgUnitsForRent_&acsyr.
    PctOwnerOccupiedHU_m_&acsyr.=PctOwnerOccupiedHsgUnits_&acsyr.;

  %let prof_notes3 = ;

  %** Profile tab 4 - Foreclosures **;

  %let prof_vars4 = 
        Sec_4_Fcl_notice
          %Rep_var( var=forecl_ssl_sf_condo, from=&fcl_start_yr, to=&fcl_end_yr )
        Sec_4_Fcl_rate
          %Rep_var( var=forecl_ssl_1kpcl_sf_condo, from=&fcl_start_yr, to=&fcl_end_yr )
        Sec_4_Td_notice
          %Rep_var( var=trustee_ssl_sf_condo, from=&fcl_start_yr, to=&fcl_end_yr )
        Sec_4_Td_rate
          %Rep_var( var=trustee_ssl_1kpcl_sf_condo, from=&fcl_start_yr, to=&fcl_end_yr )
          ;

  %let sec_heads4 = 
         %str( Sec_4_Fcl_notice; SF Homes/Condos Receiving Foreclosure Notice (Foreclosure Start);
               Sec_4_Fcl_rate; Foreclosure Notice Rate (per 1,000 SF Homes/Condos);
               Sec_4_Td_notice; SF Homes/Condos Receiving Trustee Deed Sale Notice (Foreclosure Completion);
               Sec_4_Td_rate; Trustee Deed Sale Rate (per 1,000 SF Homes/Condos)
              );

  %let prof_moe_col4 = ;

  %let prof_notes4 = ;

  %** Profile tab 5 - Schools **;

  %let prof_vars5 = 
        Sec_5_msf_all
          %Rep_var( var=school_present, from=&msf_start_yr, to=&msf_end_yr )
        Sec_5_msf_dcps
          %Rep_var( var=dcps_present, from=&msf_start_yr, to=&msf_end_yr )
        Sec_5_msf_charter
          %Rep_var( var=charter_present, from=&msf_start_yr, to=&msf_end_yr )
        Sec_5_enroll_all
          %Rep_var( var=aud, from=&enroll_start_yr, to=&enroll_end_yr )
		 Sec_5_enroll_dcps
          %Rep_var( var=aud_dcps, from=&enroll_start_yr, to=&enroll_end_yr )
		  Sec_5_enroll_charter
          %Rep_var( var=aud_charter, from=&enroll_start_yr, to=&enroll_end_yr )
          ;

  %let sec_heads5 = 
         %str( Sec_5_msf_all; Number of Schools;
               Sec_5_msf_dcps; Number of DCPS Schools;
               Sec_5_msf_charter; Number of Charter Schools;
               Sec_5_enroll_all; Total Audited School Enrollment;
			   Sec_5_enroll_dcps; DCPS Audited School Enrollment;
			   Sec_5_enroll_charter; Charter Audited School Enrollment
              );
              
  %let prof_moe_col5 = ;

  %let prof_notes5 =  ;


  %****** ---- DO NOT MODIFY BELOW THIS LINE ---- ********;

  %** Create lists of profile variables without section headers **;
  
  %do j = 1 %to &g_prof_num_pages;
  
    %let prof_vars_no_sec&j = ;
    
    %let i = 1;
    %let v = %scan( &&prof_vars&j, &i );
    
    %do %until ( %length( &v ) = 0 );
    
      %if %upcase( %substr( &v, 1, 4 ) ) ~= SEC_ %then
        %let prof_vars_no_sec&j = &&prof_vars_no_sec&j &v;
        
      %let i = %eval( &i + 1 );
      %let v = %scan( &&prof_vars&j, &i );
    
    %end;
    
  %end;
  
  %put _global_;

%mend Init_nbr_prof_vars;

/** End Macro Definition **/

/***** Test **********

options mprint symbolgen mlogic;

%Init_nbr_prof_vars

%put _user_;

**********************/
