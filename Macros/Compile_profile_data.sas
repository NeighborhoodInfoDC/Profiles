/**************************************************************************
 Program:  Compile_profile_data.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/01/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to compile data for neighborhood
 profiles.

 Modifications:
  02/19/08 PAT Updated births, sales prices, price changes, subprime.
  02/20/08 PAT Switched to remote data access.
  02/20/08 PAT Added FS and TANF clients. 
               Recode system missing (.) to insufficient data (.i).
  01/20/09 PAT Updated program to use macro vars for latest data years.
  04/21/10 ANW Updated HMDA dollars to 2006 and r_mprice_sf dollars to 2010
  01/20/09 PAT Updated program to use macro vars for latest data years.
  03/24/11 PAT Added Census 2010 redistricting data.
               Updated dollar conversion to 2010.
  09/10/11 PAT Test of profiles 2.0.
               Replaced dollar_year macro var with global var 
               inc_dollar_yr and rsales_end_yr.
  10/25/12 PAT Changed sum= to mean= in Proc Summary. No longer need
               to divide count vars by _freq_ to get averages.
  10/26/12 PAT Added foreclosure data.
  11/19/12 PAT Profiles 2.0, final production version.
               Replaced %Moe_prop() with %Moe_prop_a().
  11/26/13      Added data for Schools tab.
  03/28/14 PAT  Updated for new SAS1 server.
  03/10/14 MSW Added Senior Data
**************************************************************************/

/** Macro Compile_profile_data - Start Definition **/

%macro Compile_profile_data( geo= );

  %local geosuf geoafmt j; 

  %let geosuf = %sysfunc( putc( %upcase( &geo ), $geosuf. ) );
  %let geoafmt = %sysfunc( putc( %upcase( &geo ), $geoafmt. ) );

  /**%syslput geosuf=&geosuf;**/
  /**%syslput geo=&geo;**/

  ** Start submitting commands to remote server **;

  **rsubmit;
  
  data Nbr_profile&geosuf._A (compress=no);
  
    merge
      Ncdb.Ncdb_sum&geosuf
        (keep=&geo
           TotPop: PopUnder18Years: Pop65andOverYears: PopForeignBorn: Pop5andOverYears:
           PopSameHouse5YearsAgo: PopWithRace: PopBlackNonHispBridge:
           PopWhiteNonHispBridge: PopHisp: PopAsianPINonHispBridge:
           PopOtherRaceNonHispBridge: PersonsPovertyDefined:
           PopPoorPersons: PopInCivLaborForce: PopUnemployed:
           Pop16andOverYears: Pop16andOverEmployed: Pop25andOverYears:
           Pop25andOverWoutHS: NumFamiliesOwnChildren:
           NumFamiliesOwnChildrenFH: NumOccupiedHsgUnits:
           NumHshldPhone: NumHshldCar:
           ChildrenPovertyDefined: ElderlyPovertyDefined: PopPoorChildren: PopPoorElderly: NumFamilies:
           AggFamilyIncome: NumRenterHsgUnits:
           NumVacantHsgUnitsForRent: NumOwnerOccupiedHsgUnits: )
      Ncdb.Ncdb_sum_2010&geosuf
        (keep=&geo
           TotPop: PopUnder18Years: Pop65andOverYears: PopWithRace: PopBlackNonHispBridge:
           PopWhiteNonHispBridge: PopHisp: PopAsianPINonHispBridge:
           PopOtherRaceNonHispBridge: 
           NumOccupiedHsgUnits: )
      ACS.Acs_2008_12_sum_bg&geosuf
        (keep=&geo TotPop: mTotPop: PopUnder18Years: mPopUnder18Years: Pop65andOverYears: mPop65andOverYears:
		   PopWithRace: PopBlackNonHispBridge:
           PopWhiteNonHispBridge: PopHisp: PopAsianPINonHispBridge:
           PopOtherRaceNonHispBridg: 
           Pop25andOverYears: mPop25andOverYears: 
           NumOccupiedHsgUnits: mNumOccupiedHsgUnits:
           Pop25andOverWoutHS: mPop25andOverWoutHS: 
           NumHshldPhone: mNumHshldPhone: 
           NumHshldCar: mNumHshldCar: 
           NumFamilies_: mNumFamilies_:
           AggFamilyIncome: mAggFamilyIncome: 
           NumRenterHsgUnits: mNumRenterHsgUnits:
           NumVacantHsgUnitsForRent: mNumVacantHUForRent: 
           NumOwnerOccupiedHsgUnits: mNumOwnerOccupiedHU: )
      ACS.Acs_2008_12_sum_tr&geosuf
        (keep=&geo TotPop: mTotPop: 
           PopForeignBorn: mPopForeignBorn: 
           PersonsPovertyDefined: mPersonsPovertyDefined:
           PopPoorPersons: mPopPoorPersons: 
           PopInCivLaborForce: mPopInCivLaborForce: 
           PopUnemployed: mPopUnemployed:
           Pop16andOverYears: mPop16andOverYears: 
           Pop16andOverEmployed: mPop16andOverEmployed: 
           NumFamiliesOwnChildren: mNumFamiliesOwnChildren:
           NumFamiliesOwnChildrenFH: mNumFamiliesOwnChildFH: 
           ChildrenPovertyDefined: mChildrenPovertyDefined: 
           PopPoorChildren: mPopPoorChildren: 
		   PopPoorElderly: mPopPoorElderly:
		   ElderlyPovertyDefined: mElderlyPovertyDefined: 
         rename=(TotPop_2008_12=TotPop_tr_2008_12 mTotPop_2008_12=mTotPop_tr_2008_12))
      Vital.Births_sum&geosuf
        (keep=&geo Births_w_weight: Births_low_wt: Births_w_age: Births_teen: )
      RealProp.Sales_sum&geosuf
        (keep=&geo sales_sf: mprice_sf: )
      Hmda.Hmda_sum&geosuf
        (keep=&geo NumMrtgOrigHomePurch1_4m: NumHsngUnits1_4Fam: MedianMrtgInc1_4m_adj: 
           NumConvMrtgOrigHomePurch: NumSubprimeConvOrigHomePur: )
      Police.Crimes_sum&geosuf
        (keep=&geo Crime_rate_pop: Crimes_pt1_violent: Crimes_pt1_property: )
      Tanf.Tanf_sum&geosuf
        (keep=&geo tanf_client:)
      Tanf.Fs_sum&geosuf
        (keep=&geo fs_client:)
      Rod.Foreclosures_sum&geosuf
        (keep=&geo forecl_ssl_sf_condo_: forecl_ssl_1kpcl_sf_condo_:
              trustee_ssl_sf_condo_: trustee_ssl_1kpcl_sf_condo_:)
      Schools.MSF_sum&geosuf
        (keep=&geo school_present_: charter_present_: dcps_present_: aud_: )
      ;
    by &geo;
    
  run;
  
  proc summary data=Nbr_profile&geosuf._A;
    var _numeric_;
    class &geo;
    output out=Nbr_profile&geosuf._B (compress=no) mean=;

  run;

  /***
  proc download status=no
      inlib=work 
      outlib=work memtype=(data);
    select Nbr_profile&geosuf._B;

  run;
  ***/

  **endrsubmit;

  ** End submitting commands to remote server **;

  data Nbr_profile&geosuf (compress=no);
  
    set Nbr_profile&geosuf._B;
    
    ** Population **;
    
    %Label_var_years( var=TotPop, label=Population, years=1980 1990 2000 2010 )
    
    if TotPop_1980 > 0 then PctChgTotPop_1980_1990 = %pctchg( TotPop_1980, TotPop_1990 );
    if TotPop_1990 > 0 then PctChgTotPop_1990_2000 = %pctchg( TotPop_1990, TotPop_2000 );
    if TotPop_2000 > 0 then PctChgTotPop_2000_2008_12 = %pctchg( TotPop_2000, TotPop_2008_12 );
    if TotPop_2000 > 0 then PctChgTotPop_2000_2010 = %pctchg( TotPop_2000, TotPop_2010 );
    
    label
      PctChgTotPop_1980_1990 = "% change population, 1980 to 1990"
      PctChgTotPop_1990_2000 = "% change population, 1990 to 2000"
      PctChgTotPop_2000_2008_12 = "% change population, 2000 to 2008-12"
      PctChgTotPop_2000_2010 = "% change population, 2000 to 2010"
      ;
      
    %Pct_calc( var=PctPopUnder18Years, label=% children, num=PopUnder18Years, den=TotPop, years=1980 1990 2000 2008_12 2010 )
    
    %Moe_prop_a( var=PctPopUnder18Years_m_2008_12, mult=100, num=PopUnder18Years_2008_12, den=TotPop_2008_12, 
                       num_moe=mPopUnder18Years_2008_12, den_moe=mTotPop_2008_12 );
    
    if PopUnder18Years_1980 > 0 then PctChgPopUnder18Years_1980_1990 = %pctchg( PopUnder18Years_1980, PopUnder18Years_1990 );
    if PopUnder18Years_1990 > 0 then PctChgPopUnder18Years_1990_2000 = %pctchg( PopUnder18Years_1990, PopUnder18Years_2000 );
    if PopUnder18Years_2000 > 0 then PctChgPopUnder18Yea_2000_2008_12 = %pctchg( PopUnder18Years_2000, PopUnder18Years_2008_12 );
    if PopUnder18Years_2000 > 0 then PctChgPopUnder18Yea_2000_2010 = %pctchg( PopUnder18Years_2000, PopUnder18Years_2010 );
        
    label
      PctChgPopUnder18Years_1980_1990 = "% change child population, 1980 to 1990"
      PctChgPopUnder18Years_1990_2000 = "% change child population, 1990 to 2000"
      PctChgPopUnder18Yea_2000_2008_12 = "% change child population, 2000 to 2008-2012"
      PctChgPopUnder18Yea_2000_2010 = "% change child population, 2000 to 2010"
    ;
      
	%Pct_calc( var=PctPop65andOverYears, label=% seniors, num=Pop65andOverYears, den=TotPop, years=1980 1990 2000 2008_12 2010 )

    %Moe_prop_a( var=PctPop65andOverYears_m_2008_12, mult=100, num=Pop65andOverYears_2008_12, den=TotPop_2008_12, 
                       num_moe=mPop65andOverYears_2008_12, den_moe=mTotPop_2008_12 );
    
    if Pop65andOverYears_1980 > 0 then PctChgPop65andOverYear_1980_1990 = %pctchg( Pop65andOverYears_1980, Pop65andOverYears_1990 );
    if Pop65andOverYears_1990 > 0 then PctChgPop65andOverYear_1990_2000 = %pctchg( Pop65andOverYears_1990, Pop65andOverYears_2000 );
    if Pop65andOverYears_2000 > 0 then PctChgPop65andOverY_2000_2008_12 = %pctchg( Pop65andOverYears_2000, Pop65andOverYears_2008_12 );
    if Pop65andOverYears_2000 > 0 then PctChgPop65andOverYear_2000_2010 = %pctchg( Pop65andOverYears_2000, Pop65andOverYears_2010 );
        
    label
      PctChgPop65andOverYear_1980_1990 = "% change senior population, 1980 to 1990"
      PctChgPop65andOverYear_1990_2000 = "% change senior population, 1990 to 2000"
      PctChgPop65andOverY_2000_2008_12 = "% change senior population, 2000 to 2008-2012"
      PctChgPop65andOverYear_2000_2010 = "% change senior population, 2000 to 2010"
    ;

    %Pct_calc( var=PctForeignBorn, label=% foreign born, num=PopForeignBorn, den=TotPop, years=1980 1990 2000 )
    %Pct_calc( var=PctForeignBorn, label=% foreign born, num=PopForeignBorn, den=TotPop_tr, years=2008_12 )

    %Moe_prop_a( var=PctForeignBorn_m_2008_12, mult=100, num=PopForeignBorn_2008_12, den=TotPop_tr_2008_12, 
                       num_moe=mPopForeignBorn_2008_12, den_moe=mTotPop_tr_2008_12 );

    %Pct_calc( var=PctSameHouse5YearsAgo, label=% same house 5 years ago, num=PopSameHouse5YearsAgo, den=Pop5andOverYears, years=1990 2000 )
    
    ** Population by Race/Ethnicity **;
    
    %Pct_calc( var=PctBlackNonHispBridge, label=% black non-Hispanic, num=PopBlackNonHispBridge, den=PopWithRace, years=1990 2000 2008_12 2010 )
    %Pct_calc( var=PctWhiteNonHispBridge, label=% white non-Hispanic, num=PopWhiteNonHispBridge, den=PopWithRace, years=1990 2000 2008_12 2010 )
    %Pct_calc( var=PctHisp, label=% Hispanic, num=PopHisp, den=PopWithRace, years=1990 2000 2008_12 2010 )
    %Pct_calc( var=PctAsianPINonHispBridge, label=% Asian/P.I. non-Hispanic, num=PopAsianPINonHispBridge, den=PopWithRace, years=1990 2000 2008_12 2010 )
    
    %Pct_calc( var=PctOtherRaceNonHispBridge, label=% other race non-Hispanic, num=PopOtherRaceNonHispBridge, den=PopWithRace, years=1990 2000 2010 )
    %Pct_calc( var=PctOtherRaceNonHispBridg, label=% other race non-Hispanic, num=PopOtherRaceNonHispBridg, den=PopWithRace, years=2008_12 )

    ** Family Risk Factors **;

    %Pct_calc( var=PctPoorPersons, label=Poverty rate (%), num=PopPoorPersons, den=PersonsPovertyDefined, years=1980 1990 2000 2008_12 )
    %Pct_calc( var=PctUnemployed, label=Unemployment rate (%), num=PopUnemployed, den=PopInCivLaborForce, years=1980 1990 2000 2008_12 )
    %Pct_calc( var=Pct16andOverEmployed, label=% pop. 16+ yrs. employed, num=Pop16andOverEmployed, den=Pop16andOverYears, years=1980 1990 2000 2008_12 )
    %Pct_calc( var=Pct25andOverWoutHS, label=% persons without HS diploma, num=Pop25andOverWoutHS, den=Pop25andOverYears, years=1980 1990 2000 2008_12 )
    %Pct_calc( var=PctFamiliesOwnChildrenFH, label=% female-headed families with children, num=NumFamiliesOwnChildrenFH, den=NumFamiliesOwnChildren, years=1990 2000 2008_12 )
    
    %Moe_prop_a( var=PctPoorPersons_m_2008_12, mult=100, num=PopPoorPersons_2008_12, den=PersonsPovertyDefined_2008_12, 
                       num_moe=mPopPoorPersons_2008_12, den_moe=mPersonsPovertyDefined_2008_12 );
    
    %Moe_prop_a( var=PctUnemployed_m_2008_12, mult=100, num=PopUnemployed_2008_12, den=PopInCivLaborForce_2008_12, 
                       num_moe=mPopUnemployed_2008_12, den_moe=mPopInCivLaborForce_2008_12 );
    
    %Moe_prop_a( var=Pct16andOverEmployed_m_2008_12, mult=100, num=Pop16andOverEmployed_2008_12, den=Pop16andOverYears_2008_12, 
                       num_moe=mPop16andOverEmployed_2008_12, den_moe=mPop16andOverYears_2008_12 );
    
    %Moe_prop_a( var=Pct25andOverWoutHS_m_2008_12, mult=100, num=Pop25andOverWoutHS_2008_12, den=Pop25andOverYears_2008_12, 
                       num_moe=mPop25andOverWoutHS_2008_12, den_moe=mPop25andOverYears_2008_12 );
    
    %Moe_prop_a( var=PctFamiliesOwnChildFH_m_2008_12, mult=100, num=NumFamiliesOwnChildrenFH_2008_12, den=NumFamiliesOwnChildren_2008_12, 
                       num_moe=mNumFamiliesOwnChildFH_2008_12, den_moe=mNumFamiliesOwnChildren_2008_12 );
    
    ** Isolation Indicators **;
    
    %Pct_calc( var=PctHshldPhone, label=% HHs with a phone, num=NumHshldPhone, den=NumOccupiedHsgUnits, years=2000 2008_12 )
    %Pct_calc( var=PctHshldCar, label=% HHs with a car, num=NumHshldCar, den=NumOccupiedHsgUnits, years=2000 2008_12 )
    
    %Moe_prop_a( var=PctHshldPhone_m_2008_12, mult=100, num=NumHshldPhone_2008_12, den=NumOccupiedHsgUnits_2008_12, 
                       num_moe=mNumHshldPhone_2008_12, den_moe=mNumOccupiedHsgUnits_2008_12 );
    
    %Moe_prop_a( var=PctHshldCar_m_2008_12, mult=100, num=NumHshldCar_2008_12, den=NumOccupiedHsgUnits_2008_12, 
                       num_moe=mNumHshldCar_2008_12, den_moe=mNumOccupiedHsgUnits_2008_12 );
    
   ** Child Well-Being Indicators **;
    
    %Pct_calc( var=PctPoorChildren, label=% children in poverty, num=PopPoorChildren, den=ChildrenPovertyDefined, years=1990 2000 2008_12 )
    
    %Moe_prop_a( var=PctPoorChildren_m_2008_12, mult=100, num=PopPoorChildren_2008_12, den=ChildrenPovertyDefined_2008_12, 
                       num_moe=mPopPoorChildren_2008_12, den_moe=mChildrenPovertyDefined_2008_12 );
    
    %Pct_calc( var=Pct_births_low_wt, label=% low weight births (under 5.5 lbs), num=Births_low_wt, den=Births_w_weight, from=&births_start_yr, to=&births_end_yr )
    %Pct_calc( var=Pct_births_teen, label=% births to teen mothers, num=Births_teen, den=Births_w_age, from=&births_start_yr, to=&births_end_yr )
    
	 ** Elderly Well-Being Indicators **;
    
    %Pct_calc( var=PctPoorElderly, label=% seniors in poverty, num=PopPoorElderly, den=ElderlyPovertyDefined, years=1990 2000 2008_12 )
    
    %Moe_prop_a( var=PctPoorElderly_m_2008_12, mult=100, num=PopPoorElderly_2008_12, den=ElderlyPovertyDefined_2008_12, 
                       num_moe=mPopPoorElderly_2008_12, den_moe=mElderlyPovertyDefined_2008_12 );

    ** Income Conditions **;
    
    %Pct_calc( var=AvgFamilyIncome, label=Average family income last year ($), num=AggFamilyIncome, den=NumFamilies, mult=1, years=1980 1990 2000 2008_12 )
    
    %dollar_convert( AvgFamilyIncome_1980, AvgFamilyIncAdj_1980, 1979, &inc_dollar_yr )
    %dollar_convert( AvgFamilyIncome_1990, AvgFamilyIncAdj_1990, 1989, &inc_dollar_yr )
    %dollar_convert( AvgFamilyIncome_2000, AvgFamilyIncAdj_2000, 1999, &inc_dollar_yr )
    %dollar_convert( AvgFamilyIncome_2008_12, AvgFamilyIncAdj_2008_12, 2012, &inc_dollar_yr )
    
    label
      AvgFamilyIncAdj_1980 = "Avg. family income, 1979"
      AvgFamilyIncAdj_1990 = "Avg. family income, 1989"
      AvgFamilyIncAdj_2000 = "Avg. family income, 1999"
      AvgFamilyIncAdj_2008_12 = "Avg. family income, 2008-12"
      ;
      
    AvgFamilyIncome_m_2008_12 = 
      %Moe_ratio( num=AggFamilyIncome_2008_12, den=NumFamilies_2008_12, 
                  num_moe=mAggFamilyIncome_2008_12, den_moe=mNumFamilies_2008_12 );
                        
    %dollar_convert( AvgFamilyIncome_m_2008_12, AvgFamilyIncAdj_m_2008_12, 2012, &inc_dollar_yr )
    
    if AvgFamilyIncAdj_1980 > 0 then PctChgAvgFamilyIncAdj_1980_1990 = %pctchg( AvgFamilyIncAdj_1980, AvgFamilyIncAdj_1990 );
    if AvgFamilyIncAdj_1990 > 0 then PctChgAvgFamilyIncAdj_1990_2000 = %pctchg( AvgFamilyIncAdj_1990, AvgFamilyIncAdj_2000 );
    if AvgFamilyIncAdj_2000 > 0 then PctChgAvgFamilyIncA_2000_2008_12 = %pctchg( AvgFamilyIncAdj_2000, AvgFamilyIncAdj_2008_12 );
    
    label
      PctChgAvgFamilyIncAdj_1980_1990 = "% change in avg. family income, 1980 to 1990"
      PctChgAvgFamilyIncAdj_1990_2000 = "% change in avg. family income, 1990 to 2000"
      PctChgAvgFamilyIncA_2000_2008_12 = "% change in avg. family income, 2000 to 2008-12"
      ;
    
    PctChgAvgFamIncA_m_2000_2008_12 = AvgFamilyIncAdj_m_2008_12 / AvgFamilyIncAdj_2000;
    
    ** Public Assistance **;
    
    %Label_var_years( var=fs_client, label=Persons receiving food stamps, from=&fs_tanf_start_yr, to=&fs_tanf_end_yr )
    %Label_var_years( var=tanf_client, label=Persons receiving TANF, from=&fs_tanf_start_yr, to=&fs_tanf_end_yr )
    
    ** Round to whole numbers **;
    
    %Suppress_data( var=fs_client, when=%nrstr(0 < fs_client_&y < 5), value=.s, from=&fs_tanf_start_yr, to=&fs_tanf_end_yr, round=1 )
    %Suppress_data( var=tanf_client, when=%nrstr(0 < tanf_client_&y < 5), value=.s, from=&fs_tanf_start_yr, to=&fs_tanf_end_yr, round=1 )

    ** Housing Conditions **;
    
    %Label_var_years( var=NumOccupiedHsgUnits, label=Occupied housing units, years=1980 1990 2000 2008_12 2010 )

    %Pct_calc( var=PctVacantHsgUnitsForRent, label=Rental vacancy rate (%), num=NumVacantHsgUnitsForRent, den=NumRenterHsgUnits, years=1980 1990 2000 2008_12 )
    %Pct_calc( var=PctOwnerOccupiedHsgUnits, label=Homeownership rate (%), num=NumOwnerOccupiedHsgUnits, den=NumOccupiedHsgUnits, years=1980 1990 2000 2008_12 )
    
    %Moe_prop_a( var=PctVacantHUForRent_m_2008_12, mult=100, num=NumVacantHsgUnitsForRent_2008_12, den=NumRenterHsgUnits_2008_12, 
                       num_moe=mNumVacantHUForRent_2008_12, den_moe=mNumRenterHsgUnits_2008_12 );
    
    %Moe_prop_a( var=PctOwnerOccupiedHU_m_2008_12, mult=100, num=NumOwnerOccupiedHsgUnits_2008_12, den=NumOccupiedHsgUnits_2008_12, 
                       num_moe=mNumOwnerOccupiedHU_2008_12, den_moe=mNumOccupiedHsgUnits_2008_12 );
    
    ** Housing Market (Single-Family Homes) **;
    
    %Label_var_years( var=sales_sf, label=Number of sales, from=&rsales_start_yr, to=&rsales_end_yr )
    
    ** Convert to constant dollars for last sale year **;
    
    array mprice{&rsales_start_yr:&rsales_end_yr} mprice_sf_&rsales_start_yr-mprice_sf_&rsales_end_yr;
    array r_mprice{&rsales_start_yr:&rsales_end_yr} r_mprice_sf_&rsales_start_yr-r_mprice_sf_&rsales_end_yr;
    
    do i = &rsales_start_yr to &rsales_end_yr;
      %dollar_convert( mprice{i}, r_mprice{i}, i, &rsales_end_yr, series=CUUR0000SA0L2 )
    end;
    
    %Label_var_years( var=r_mprice_sf, label=Median sales price, from=&rsales_start_yr, to=&rsales_end_yr )
    
    ** Suppress sales prices if fewer than 10 sales **;
    
    *options mprint symbolgen mlogic;

    %Suppress_data( var=r_mprice_sf, when=%nrstr(sales_sf_&y < 10), value=.i, from=&rsales_start_yr, to=&rsales_end_yr )
    
    *options mprint nosymbolgen nomlogic;
    
    ** Calculate sales price changes **;

    %let rsales_b1yr = %eval( &rsales_end_yr - 1 );
    %let rsales_b5yr = %eval( &rsales_end_yr - 5 );
    %let rsales_b10yr = %eval( &rsales_end_yr - 10 );
    
    PctAnnChgRMPriceSf_1yr = 100 * %annchg( r_mprice_sf_&rsales_b1yr, r_mprice_sf_&rsales_end_yr, 1 );
    PctAnnChgRMPriceSf_5yr = 100 * %annchg( r_mprice_sf_&rsales_b5yr, r_mprice_sf_&rsales_end_yr, 5 );
    PctAnnChgRMPriceSf_10yr = 100 * %annchg( r_mprice_sf_&rsales_b10yr, r_mprice_sf_&rsales_end_yr, 10 );

    if PctAnnChgRMPriceSf_1yr = . then PctAnnChgRMPriceSf_1yr = .i;
    if PctAnnChgRMPriceSf_5yr = . then PctAnnChgRMPriceSf_5yr = .i;
    if PctAnnChgRMPriceSf_10yr = . then PctAnnChgRMPriceSf_10yr = .i;
    
    label
      PctAnnChgRMPriceSf_1yr = "% annual change median price, &rsales_b1yr-&rsales_end_yr"
      PctAnnChgRMPriceSf_5yr = "% annual change median price, &rsales_b5yr-&rsales_end_yr"
      PctAnnChgRMPriceSf_10yr = "% annual change median price, &rsales_b10yr-&rsales_end_yr";
    
    ** Round sales prices to nearest $1,000 **;
    
    array r_mprice_sf{*} r_mprice_sf_&rsales_start_yr-r_mprice_sf_&rsales_end_yr;
    
    do i = 1 to dim( r_mprice_sf );
      r_mprice_sf{i} = round( r_mprice_sf{i}, 1000 );
    end;
    
    ** Mortgage Lending (Home Purchase Loans) **;
    
    %Pct_calc( var=NumMrtgOrigHomePurchPerUnit, label=%str(Loans per 1,000 housing units), num=NumMrtgOrigHomePurch1_4m, den=NumHsngUnits1_4Fam, mult=1000, from=&hmda_start_yr, to=&hmda_end_yr )
    %Pct_calc( var=PctSubprimeConvOrigHomePur, label=% subprime loans, num=NumSubprimeConvOrigHomePur, den=NumConvMrtgOrigHomePurch, from=&hmda_start_yr, to=&hmda_end_yr )
    
    %Label_var_years( var=MedianMrtgInc1_4m_adj, label=Median borrower income, from=&hmda_start_yr, to=&hmda_end_yr )
    
    ** Reported Crimes (per 1,000 pop.) **;
    
    %Pct_calc( var=Rate_crimes_pt1_violent, label=Violent crimes, num=Crimes_pt1_violent, den=Crime_rate_pop, mult=1000, from=&crime_start_yr, to=&crime_end_yr )
    %Pct_calc( var=Rate_crimes_pt1_property, label=Property crimes, num=Crimes_pt1_property, den=Crime_rate_pop, mult=1000, from=&crime_start_yr, to=&crime_end_yr )
        
    ** Foreclosures **;
    
    %Label_var_years( var=forecl_ssl_sf_condo, label=SF homes/condos receiving foreclosure notice, from=&fcl_start_yr, to=&fcl_end_yr )
    %Label_var_years( var=forecl_ssl_1kpcl_sf_condo, label=Foreclosure notice rate, from=&fcl_start_yr, to=&fcl_end_yr )
    %Label_var_years( var=trustee_ssl_sf_condo, label=SF homes/condos receiving trustee deed sale notice, from=&fcl_start_yr, to=&fcl_end_yr )
    %Label_var_years( var=trustee_ssl_1kpcl_sf_condo, label=Trustee deed sale rate, from=&fcl_start_yr, to=&fcl_end_yr )

	** Schools **;
	%Label_var_years( var=school_present, label=Number of schools, from=&msf_start_yr, to=&msf_end_yr )
	%Label_var_years( var=dcps_present, label=Number of DCPS schools, from=&msf_start_yr, to=&msf_end_yr )
	%Label_var_years( var=charter_present, label=Number of charter schools, from=&msf_start_yr, to=&msf_end_yr )
	%Label_var_years( var=aud, label=Total school enrollment, from=&enroll_start_yr, to=&enroll_end_yr )
	%Label_var_years( var=aud_charter, label=Charter school enrollment, from=&enroll_start_yr, to=&enroll_end_yr )
	%Label_var_years( var=aud_dcps, label=DCPS school enrollment, from=&enroll_start_yr, to=&enroll_end_yr )

    ** Create flag for generating profile **;
    
    if TotPop_2010 >= 100 then _make_profile = 1;
    else _make_profile = 0;
    
    ** Recode system missing to .I (insufficient data) **;
    
    array a{*} 
    
      %do j = 1 %to &g_prof_num_pages;
        &&prof_vars_no_sec&j
      %end;
    
    ;
    
    do i = 1 to dim( a );
      if a{i} = . then a{i} = .i;
    end;
    
    ** Create short geo name var for bread crumbs **;
    
    length geo_name_bc $ 40;
    
    geo_name_bc = put( &geo, &geoafmt );
    
    drop i;

  run;
    
  %File_info( data=Nbr_profile&geosuf, printobs=0, contents=n )
  
%mend Compile_profile_data;

/** End Macro Definition **/

