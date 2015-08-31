/**************************************************************************
 Program:  Style_profile_xhtml.sas
 Library:  Profiles
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  04/01/07
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Autocall macro to create XHTML style for neighborhood
 profiles for geography GEO=.
 
 XHMTL style includes the following page elements:
 - Meta names in page header
 - Google Analytics code
 - HTML document type
 - Page banner and navigation bar (page menu)
 - Page footer

 Modifications:
  01/20/09 PAT Updated NAV bar to include Map library.
               Added Google Analytics tracking code.
  04/21/10 PAT Removed HitBox code.
  03/24/11 PAT Updated page header and nav bar.
  06/22/11 PAT Updated nav bar.
  08/05/11 PAT Made formating changes for new web site design:
               - Removed class= from body tag
               - Reformatted banner & nav bar
               - New page footer
  10/20/12 PAT Updated Google Analytics code (in head tag).
  10/29/12 PAT Updated header, nav bar, footer.
               Fixed NOWRAP attribute spec. in data element.
  10/30/12 PAT All meta names in <head> tag (including geo tags) 
               now added here.
  11/19/12 PAT Profiles 2.0, final production version.
  03/28/14 PAT Updated for new SAS1 server.
  04/16/14 PAT Write revised template to LOG (SOURCE statement). 
  04/17/14 PAT Commented out SOURCE statement. 
  03/30/15 MSW Updated footer
**************************************************************************/

/** Macro Style_profile_xhtml - Start Definition **/

%macro Style_profile_xhtml( page_name= );

  %** Convert spaces to + **;
  
  %let page_name = %sysfunc( translate( &page_name, '+', ' ' ) );
  
  ** Create profileXHTML tagset **;

  proc template;
    path sashelp.tmplmst;
    
    define tagset tagsets.profileXHTML /store=sasuser.templat (write);
    
      parent = Tagsets.Xhtml;

      define event doc_head;
         start:
            put "<head>" NL;
            put VALUE NL;

            put "<meta name=""Robots"" content=""INDEX"" />" NL;
            
            put "<meta name=""geo.region"" content=""US-DC"" />" NL;
            put "<meta name=""geo.placename"" content=""Washington"" />" NL;
            put "<meta name=""geo.position"" content=""38.895112;-77.036366"" />" NL;
            put "<meta name=""ICBM"" content=""38.895112, -77.036366"" />" NL;

         finish:
            /** Insert Google Analytics Code (updated 10/20/12) **/
            put NL "<!-- Google Analytics code -->" NL;
            put "<script type=""text/javascript"">" NL;
            put NL;
            put "  var _gaq = _gaq || [];" NL;
            put "  _gaq.push(['_setAccount', 'UA-7017847-1']);" NL;
            put "  _gaq.push(['_trackPageview']);" NL;
            put "" NL;
            put "  (function() {" NL;
            put "    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;" NL;
            put "    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';" NL;
            put "    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);" NL;
            put "  })();" NL;
            put NL;
            put "</script>" NL;
            put NL;
            put "</head>" NL;
      end;

      define event doc;
        start:
           set $empty_tag_suffix " /";
           set $doctype "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Transitional//EN"""
                        "    ""http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"">";
           set $framedoctype "<!DOCTYPE html PUBLIC ""-//W3C//DTD XHTML 1.0 Frameset//EN"">";
           put $doctype NL;
           put "<html xmlns=""http://www.w3.org/1999/xhtml"">" NL;
        finish:
           put "</html>" NL;
      end;

      define event contents;
        start:
           put $doctype NL;
           put "<html xmlns=""http://www.w3.org/1999/xhtml"">" NL;
        finish:
           put "</html>" NL;
      end;

     define event doc_body;
        put "<body onload=""startup()""";
           put " onunload=""shutdown()""";
           put " bgproperties=""fixed""" / WATERMARK;
           /**putq " class=" HTMLCLASS;**/
           putq " background=" BACKGROUNDIMAGE;

           trigger style_inline;
           put ">" NL;
           
           trigger pre_post;
           put NL;

           trigger ie_check;

           put "<div id=""container"">" NL;

           put NL "<!-- BANNER AND NAV BAR -->" NL;
           put "<div id=""banner"" title=""NeighborhoodInfo DC"">";
           put "<a href=""../index.html"">";
           put "<img src=""../images/neighborhoodinfodc.gif"" width=""920"" height=""88"" alt=""NeighorhoodInfo DC banner""/></a></div>";

           /** Nav bar code updated 10/29/12 **/
           put "<div id=""navbar"" style=""background-color: #c98d95"">";
           put "<a href=""../index.html"">Home</a>";
           put "<a href=""../about.html"">About Us</a>";
           put "<a href=""../profiles.html"" class=""highlight"">Neighborhood Profiles</a>";
           put "<a href=""../Housing/index.html"">Housing</a>";
           put "<a href=""../maps.html"">Maps</a>";
           put "<a href=""../resources.html"">Resources</a>";
           put "<a href=""../Maryland/index.html"">Maryland</a>";
           put "<a href=""../Questions.html"" class=""no_pipe"">Ask a Question</a>";
           put "</div>" NL;
           put "<div class=""branch"" style=""padding-left:10px"">" NL;
           
        finish:

          /**New footer: 3/30/15**/
		put "<div id=""select_footer"">" NL;
		put "<!-- Links to different geographies -->" NL;
		put "<p>" NL;
		put "<a href=""../city/nbr_prof_city.html"">City </a>|" NL;
		put "<a href=""../wards/wards.html"">Wards (2012)</a> |" NL;
		put "<a href=""../wards02/wards.html"">Wards (2002)</a> |" NL;
		put "<a href=""../anc12/anc.html"">ANCs</a> |" NL;
		put "<a href=""../nclusters/nclusters.html"">Neighborhood Clusters</a> |" NL;
		put "<a href=""../psa12/psa.html"">PSAs</a> |" NL;
		put "<a href=""../zip/zip.html"">ZIP codes</a> |" NL;
		put "<a href=""../censustract10/census.html"">Census Tracts (2010)</a> |" NL;
		put "<a href=""../censustract/census.html"">Census Tracts (2000)</a> |" NL;
		put "<a href=""../comparisontables/comparisontables.html"">Download Data</a>" NL;
		put "</p>" NL;
		put "</div>" NL;
		put "<div id=""footer"" align=""center"" style=""margin:0; padding:0;"">" NL;
		put "<div style=""background-color:#c98d95; padding: 12px 0; font-weight: bold;"">" NL;
		put "	Neighborhood Info DC &mdash;a project of the Urban Institute and a partner of the National Neighborhood Indicators Partnership.<br />" NL;
		put "	P: 202-643-4110 / E:<a href=""mailto:info@neighborhoodinfodc.org"">info@neighborhoodinfodc.org</a><br />" NL;
		put "<a href=""https://twitter.com/NborhoodInfoDC"" class=""twitter-follow-button"" data-show-count=""false"">Follow @NborhoodInfoDC</a>" NL;
		put "<script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id))";
		put "{js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');</script>" NL;
		put "</div>" NL;
		put "<table width=""50%"" border=""0"" align=""center"" cellpadding=""4"" cellspacing=""0"">" NL;
		put "<tr valign=""top"">" NL;
		put "<td width=""100%"" align=""center"">" NL;
		put "<a href=""http://www.urban.org""><img src=""../images/new_urban_logo.png"" alt=""Urban Institute logo"" width=""400"" height=""17"" border=""0"" /></a><br />" NL;
		put "</td>" NL;
		put "</tr>" NL;
		put "</table>" NL;

		put "</div>" NL;


           /** New footer: 8/5/11 **/
          /*put "<div id=""footer"" align=""center"" style=""margin:0; padding:0; "">" NL;
           put "<div style=""background-color:#c98d95; padding: 12px 0; font-weight: bold;"">" NL;
           put ' Neighborhood Info DC &mdash;a project of The Urban Institute and Washington DC Local Initiatives Support Corporation (LISC)<br />' NL;
           put "P: 202-261-5760 / E: <a href=""mailto:info@neighborhoodinfodc.org"">info@neighborhoodinfodc.org</a> </div>" NL;
           put "<table width=""50%"" border=""0"" align=""center"" cellpadding=""4"" cellspacing=""0"">" NL;
           put "<tr valign=""top"">" NL;
           put "<td width=""50%"" align=""center"">" NL;
           put "<a href=""http://www.urban.org""><img src=""../images/UI-logo-small.png"" alt=""Urban Institute logo"" width=""130"" height=""38"" border=""0"" /></a><br />" NL;
           put "    2100 M Street, NW<br />" NL;
           put "    Washington, DC 20037</td>" NL;
           put "<td width=""50%"" align=""center"">" NL;
           put "  <a href=""http://www.lisc.org/washingtondc/""><img src=""../images/LISC.png"" alt=""LISC logo"" width=""66"" height=""37"" border=""0"" /></a><br />" NL;
           put "    1825 K Street NW Suite 1100<br />" NL;
           put "    Washington, DC 20006</td>" NL;
           put "</tr>" NL;
           put "</table>" NL;
           put "  </div>" NL;

           put "</div>" NL;
           put "</div>" NL;
           put "</div>" NL;

           trigger pre_post;

           put "</body>" NL;*/
     
      end;

      define event data;
         start:
            put "<td";
            putq " id=" HTMLID;
            putq " headers=" headers /if $header_data_associations;

            trigger rowcol;

            trigger align;
            put " nowrap=""nowrap""" /if no_wrap;
            put ">";

            trigger cell_value;

         finish:
            trigger cell_value;
            put "</td>" NL;
      end;

    end;
    
    /***source tagsets.profileXHTML /store=sasuser.templat;***/
    
  run;

%mend Style_profile_xhtml;

/** End Macro Definition **/

