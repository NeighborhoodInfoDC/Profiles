/**************************************************************************
 Program:  Prof_toc_generate_web.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  10/23/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to generate table of contents (section
 links) for web profile. Saved to global macro variable g_prof_toc_web.

 Modifications:
  02/11/12 PAT  Removed <SMALL> tags from TOC HTML code.
  10/27/12 PAT  If 4 or fewer section headings, just display as one col.
  11/19/12 PAT  Profiles 2.0, final production version.
  03/28/14 PAT  Updated for new SAS1 server.
**************************************************************************/

/** Macro Prof_toc_generate_web - Start Definition **/

%macro Prof_toc_generate_web( sec_heads );

  %local i j v b num_sec_heads offset;
  
  %** Count section heads **;
  
  %let num_sec_heads = 0;
  
  %let i = 1;
  %let v = %scan( &&&sec_heads, &i, %str(;) );

  %do %until ( &v = );

    %let num_sec_heads = %eval( &num_sec_heads + 1 );

    %let i = %eval( &i + 2 );
    %let v = %scan( &&&sec_heads, &i, %str(;) );

  %end;
  
  %if &num_sec_heads > 4 %then %do;
  
    %**** 2-column TOC ****;
  
    %** Calculate offset for second column entries **;
    
    %let offset = %sysfunc( int( ( &num_sec_heads + 1 ) / 2 ) );
    
    %** Generate TOC code **;
    
    %let g_prof_toc_web = ;
    
    %do j = 1 %to &offset;
    
      %let i = %eval( ( 2 * &j ) - 1 );
    
      %let g_prof_toc_web = %trim( &g_prof_toc_web ) "<tr align=""left"">";
      
      %** First column **;
      
      %let v = %lowcase( %scan( &&&sec_heads, &i, %str(;) ) );
      %let b = %scan( &&&sec_heads, &i + 1, %str(;) );
      
      %let g_prof_toc_web = %trim( &g_prof_toc_web ) "<td><a href=""#&v"">&b</a></td>";
      
      %** Second column **;
      
      %if &j + &offset <= &num_sec_heads %then %do;
       
        %let v = %lowcase( %scan( &&&sec_heads, &i + ( 2 * &offset ), %str(;) ) );
        %let b = %scan( &&&sec_heads, &i + ( 2 * &offset ) + 1, %str(;) );
        
        %let g_prof_toc_web = %trim( &g_prof_toc_web ) "<td><a href=""#&v"">&b</a></td>";
      
      %end;
      %else %do;
      
        %** If odd number of headings, last entry is blank **;
        %let g_prof_toc_web = %trim( &g_prof_toc_web ) "<td>&html_nbsp.</td>";
      
      %end;
    
      %let g_prof_toc_web = %trim( &g_prof_toc_web ) "</tr>";
      
    %end;
    
  %end;
  %else %do;
  
    %**** 1-column TOC (2nd col is empty) ****;
  
    %** Generate TOC code **;
    
    %let g_prof_toc_web = ;
    
    %do j = 1 %to &num_sec_heads;
    
      %let i = %eval( ( 2 * &j ) - 1 );
      
      %let g_prof_toc_web = %trim( &g_prof_toc_web ) "<tr align=""left"">";
      
      %** First column **;
      
      %let v = %lowcase( %scan( &&&sec_heads, &i, %str(;) ) );
      %let b = %scan( &&&sec_heads, &i + 1, %str(;) );
      
      %let g_prof_toc_web = %trim( &g_prof_toc_web ) "<td><a href=""#&v"">&b</a></td>";
      
      %** Second column **;

      %let g_prof_toc_web = %trim( &g_prof_toc_web ) "<td>&html_nbsp.</td>";

      %let g_prof_toc_web = %trim( &g_prof_toc_web ) "</tr>";
      
    %end;
  
  %end;
    
%mend Prof_toc_generate_web;

/** End Macro Definition **/


/********** UNCOMMENT TO TEST **************

options mprint symbolgen mlogic;

%global g_prof_toc_web sec_head1 html_nbsp;

%let html_nbsp = %nrstr(&nbsp;);

%let sec_head1 =
         %str( Sec_pop; Population; 
               Sec_race; Population by Race/Ethnicity;
               Sec_Fam_Risk; Family Risk Factors;
               Sec_Isolat; Isolation Indicators;
               Sec_Child_Ind; Child Well-Being Indicators;
               Sec_Inc; Income Conditions;
               Sec_Pub_Asst; Public Assistance;
               Sec_Hsng; Housing Conditions;
               Sec_Hsng_Market; Housing Market (Single-Family Homes);
               Sec_Mortgage; Mortgage Lending (Home Purchase Loans);
               Sec_Police; Reported Crimes (per 1,000 pop.)
              )
;

%let sec_head1 =
         %str( Sec_pop; Population; 
               Sec_race; Population by Race/Ethnicity;
               Sec_Fam_Risk; Family Risk Factors;
               Sec_Isolat; Isolation Indicators
              )
;

%Prof_toc_generate_web( sec_head1 )

data _null_;

  put &g_prof_toc_web;
  
run;

/***************************************************/
