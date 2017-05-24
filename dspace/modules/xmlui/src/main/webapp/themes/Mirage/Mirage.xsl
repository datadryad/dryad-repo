<?xml version="1.0" encoding="UTF-8"?>
<!--
    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at
    http://www.dspace.org/license/
-->
<!--
    Original author: Alexey Maslov
    Extensively modified by many others....
-->

<xsl:stylesheet xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                xmlns:dri="http://di.tamu.edu/DRI/1.0/"
                xmlns:mets="http://www.loc.gov/METS/"
                xmlns:xlink="http://www.w3.org/TR/xlink/"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
                xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
                xmlns:xhtml="http://www.w3.org/1999/xhtml"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:confman="org.dspace.core.ConfigurationManager"
                exclude-result-prefixes="confman dc dim dri i18n mets mods xhtml xlink xsl">

    <xsl:import href="../dri2xhtml-alt/dri2xhtml.xsl"/>
    <xsl:import href="lib/xsl/core/global-variables.xsl"/>
    <xsl:import href="lib/xsl/core/page-structure.xsl"/>
    <xsl:import href="lib/xsl/core/navigation.xsl"/>
    <xsl:import href="lib/xsl/core/elements.xsl"/>
    <xsl:import href="lib/xsl/core/forms.xsl"/>
    <xsl:import href="lib/xsl/core/attribute-handlers.xsl"/>
    <xsl:import href="lib/xsl/core/utils.xsl"/>
    <xsl:import href="lib/xsl/aspect/general/choice-authority-control.xsl"/>
    <xsl:import href="lib/xsl/aspect/administrative/administrative.xsl"/>
    <xsl:import href="lib/xsl/aspect/artifactbrowser/item-list.xsl"/>
    <xsl:import href="lib/xsl/aspect/artifactbrowser/item-view.xsl"/>
    <xsl:import href="lib/xsl/aspect/artifactbrowser/community-list.xsl"/>
    <xsl:import href="lib/xsl/aspect/artifactbrowser/collection-list.xsl"/>
    <xsl:import href="lib/xsl/aspect/JournalLandingPage/main.xsl"/>
    <xsl:import href="integrated-view.xsl"/>
    <xsl:import href="DryadItemSummary.xsl"/>
    <xsl:import href="DryadUtils.xsl"/>
    <xsl:import href="DryadSearch.xsl"/>
    
    <xsl:output indent="yes"/>
    <xsl:variable name="iframe.maxheight" select="confman:getIntProperty('iframe.maxheight', 300)"/>
    <xsl:variable name="iframe.maxwidth" select="confman:getIntProperty('iframe.maxwidth', 600)"/>

    <xsl:template match="dri:body[//dri:meta/dri:pageMeta/dri:metadata[@element='request' and @qualifier='URI'] = '' ]">
        <!-- add special style just for the homepage -->
        <style type="text/css">
            /* special style for Dryad homepage only */
            #ds-body {
                width: 100%;
            }

            .labelcell {
                font-weight: bold;
            }

            .datacell {
                text-align: right;
            }

            .ds-div-head a {
                font-size: 0.7em;
                font-weight: normal;
                position: relative;
                top: -0.1em;
            }

            .ds-artifact-list {
                /* font-size: 100%; */
                line-height: 1.4em;
            }

            .artifact-title {
                font-size: 100%;
            }

            .ds-artifact-list .artifact-info {
                display: none;
            }

            /* implied 3 columns @300px width, 25px gutters */
            .home-col-1 {
                float: left;
                width: 625px;
                padding: 0;
                /* margin-right: 25px;*/
            }

            .home-col-2 {
                float: right;
                width: 300px;
                margin-left: 0;
                margin-right: 0;
            }

            .home-top-row {
                height: 220px;
            }

            .home-bottom-row {
                height: 420px;
            }

            #recently_integrated_journals,
            #aspect_statistics_StatisticsTransformer_div_stats,
            #aspect_dryadinfo_DryadBlogFeed_div_blog-hook {
                height: 300px;
                overflow-x: visible;
                overflow-y: scroll;
            }

        #aspect_statistics_StatisticsTransformer_div_stats table {
            width: 100%;
            margin-top: 10px;
        }
        #aspect_statistics_StatisticsTransformer_div_stats .ds-table-row {
	        height: 40px;
	    }
        #aspect_statistics_StatisticsTransformer_div_stats tr.odd td {
	        background-color: #eee;
	    }
        #aspect_statistics_StatisticsTransformer_div_stats th,
        #aspect_statistics_StatisticsTransformer_div_stats td {
            padding: 0 8px;
            text-align: right
        }
        #aspect_statistics_StatisticsTransformer_div_stats td:first-child {
            text-align: left;
        }

        #recently_integrated_journals img.pub-cover {
	        margin: 7px 10px;
	    }

	    #recently_integrated_journals .container {
	        text-align: center;
	    }

            #dryad-home-carousel {
                font-size: 23px;
                font-weight: bold;
                background-color: rgb(255, 255, 255);
                height: 216px;
                padding: 0px;
                overflow: hidden;
            }

            #dryad-home-carousel .bx-viewport {
                height: 194px;
                width: 627px;
            }

            #dryad-home-carousel div.bxslider {
                overflow: visible;
            }

            #dryad-home-carousel div.bxslider div {
                height: 190px;
                padding: 0;
                margin: 0;
                position: relative;
                display: none;
            }

            #dryad-home-carousel div.bxslider div > a > img,
            #dryad-home-carousel div.bxslider div > img {
                display: block;
                height: 194px;
                width: 627px;
            }

            #dryad-home-carousel div.bxslider div .publication-date {
                display: none;
            }

            #dryad-home-carousel div.bxslider div p {
                width: 550px;
                margin: auto;
                margin-top: 1em;
            }

            #dryad-home-carousel .bx-pager {
            }
            #dryad-home-carousel .bx-pager-item {
            }

            #dryad-home-carousel .bx-controls-auto {
                bottom: -16px;
            }
            #dryad-home-carousel .bx-controls-auto-item {
                float: right;
                padding-right: 8px;
            }

            .blog-box ul {
                list-style: none;
                margin-left: 0;
            }

            .blog-box li {
                margin: 0.5em 0 1.2em;
            }
            .home-col-2 #connect-illustrated-prose p {
                line-height: 1.3em;
            }

            #connect-illustrated-prose img {
                width: auto;
                margin: 4px;		
            }

            #aspect_discovery_SiteViewer_field_query {
                width: 85%;
            }

        </style>


        <div id="ds-body">

            <!-- SYSTEM-WIDE ALERT BOX -->
            <xsl:if test="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']">
                <div id="ds-system-wide-alert">
                    <p>
                        <xsl:copy-of
                                select="/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='alert'][@qualifier='message']/node()"/>
                    </p>
                </div>
            </xsl:if>

            <!-- CAROUSEL -->
            <div class="home-col-1">
                <div id="dryad-home-carousel" class="ds-static-div primary">
                    <!-- REMINDER: slide publication dates are in the format YEAR-MONTH-DAY, eg, 2013-12-28 -->
                    <div class="bxslider" style="">
                        <div><span class="publication-date">2015-04-14</span>
                            <a href="/pages/submissionIntegration">
                                <img src="/themes/Mirage/images/integration-slide.jpg" alt="Publishers: Simplify data submission. Strengthen links between articles and data. For free. Integrate your journal with Dryad now" />
                            </a>
                        </div>
                        <div><span class="publication-date">2015-02-15</span>
                            <a href="/pages/dryadlab">
                                <img alt="" src="/themes/Mirage/images/dryadlab-promo.png" />
                                <p style="width: 580px; color: #444; font-size: 80%; top: 75px; right: 10px; line-height: 1.2em; position: absolute; text-shadow: 1px 2px 2px rgba(33, 33, 33, 0.25);"> 
                                    DryadLab is a collection of free, openly-licensed, high-quality, hands-on, educational modules for students to engage in scientific inquiry using real data.
                                </p>
                                <p style="drop-shadow: 4px 4px; position: absolute; right: 40px; bottom: 6px; font-size: 70%; text-align: right; text-shadow: 1px 2px 2px rgba(33, 33, 33, 0.25);">Learn More &#187;</p>
                            </a>
                        </div>
                        <!--><div><span class="publication-date">2015-03-23</span>
                            <a href="/pages/membershipOverview">
                                <img alt="" src="/themes/Mirage/images/watering-can.png" />
                                <p style="width: 450px; color: #363; font-size: 90%; top: 0px; right: 10px; line-height: 1.2em; position: absolute; text-shadow: 1px 2px 2px rgba(33, 33, 33, 0.25);">Help grow open data at Dryad:<br />Become an organizational member</p>
                                <p style="drop-shadow: 4px 4px; position: absolute; right: 40px; bottom: 80px; font-size: 70%; text-align: right; text-shadow: 1px 2px 2px rgba(33, 33, 33, 0.25);">Learn more &#187;</p>
                            </a>
                        </div>-->
                        <div><span class="publication-date">2013-02-01</span>
                            <p Xid="ds-dryad-is" style="font-size: 88%; line-height: 1.35em;"
                               xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/">
                                <span style="color: #595;">DataDryad.org</span>
                                is a
                                <span style="color: #363;">curated general-purpose repository</span>
                                that makes the
                                <span style="color: #242;">data underlying scientific publications</span>
                                discoverable, freely reusable, and citable. Dryad has
                                <span style="color: #595;">integrated data submission</span>
                                for a growing list of journals; submission of data from other publications is also welcome.
                            </p>
                        </div>
                        <div><span class="publication-date">2013-01-01</span>
                            <a href="/pages/repository#keyFeatures">
                                <img src="/themes/Mirage/images/bookmarkSubmissionProcess.png" alt="Deposit data. Get permanent identifier. Watch your citations grow! Relax, your data are discoverable and secure." />
                            </a>
                        </div>
                    </div>
                </div>
            </div>


            <!-- START NEWS -->
            <!--<div class="home-col-2">-->
            <!--<xsl:apply-templates select="dri:div[@id='file.news.div.news']"/>-->
            <!--</div>-->

            <!-- START DEPOSIT -->
            <div id="submit-data-sidebar-box" class="home-col-2 simple-box" style="padding: 8px 34px; width: 230px; margin: 8px 0 12px;">
                <div class="ds-static-div primary" id="file_news_div_news" style="height: 75px;">
                    <p class="ds-paragraph">
		      <!-- The next line should remain as one piece (without linebreaks) to allow it to be matched and replaced with mod_substitute on read-only servers -->
                        <a class="submitnowbutton"><xsl:attribute name="href"><xsl:value-of select="/dri:document/dri:options/dri:list[@n='submitNow']/dri:item[@n='submitnowitem']/dri:xref[@rend='submitnowbutton']/@target"/></xsl:attribute><xsl:text>Submit data now</xsl:text></a>
                    </p>
                    <p style="margin: 14px 0 4px;">
                        <a href="/pages/faq#deposit">How and why?</a>
                    </p>
                </div>
            </div>

            <!-- START SEARCH -->
            <div class="home-col-2">
                <h1 class="ds-div-head">Search for data</h1>

                <form xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/"
                      id="aspect_discovery_SiteViewer_div_front-page-search" class="ds-interactive-div primary" style="overflow: hidden;"
                      action="/discover" method="get" onsubmit="javascript:tSubmit(this);">
                    <p class="ds-paragraph" style="overflow; hidden; margin-bottom: 0px;">
                        <label for="aspect_discovery_SiteViewer_field_query" class="accessibly-hidden">Enter keyword, author, title, DOI</label>
                        <input xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/"
                               id="aspect_discovery_SiteViewer_field_query" class="ds-text-field" name="query"
                               placeholder="Enter keyword, author, title, DOI, etc. Example: herbivory"
                               title="Enter keyword, author, title, DOI, etc. Example: herbivory"
                               type="text" value="" style="width: 224px;"/><!-- no whitespace between these!
                     --><input xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                               id="aspect_discovery_SiteViewer_field_submit" class="ds-button-field" name="submit"
                               type="submit" value="Go" style="margin-right: -4px;"/>
                        <a style="float:left; font-size: 95%;" href="/discover?query=&amp;submit=Search#advanced">Advanced search</a>
                    </p>
                </form>
            </div>

            <!-- START CONNECT  -->
            <div class="home-col-2" style="clear: right;">
                <h1 class="ds-div-head ds_connect_with_dryad_head" id="ds_connect_with_dryad_head">Latest from @datadryad
                </h1>

                <div id="ds_connect_with_dryad" class="ds-static-div primary" style="height: 475px; font-size: 14px;">
                    <div id="connect-illustrated-prose">
		      <a class="twitter-timeline" href="https://twitter.com/datadryad" data-widget-id="572434627277901824">Latest from @datadryad</a>
		      <script>!function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+"://platform.twitter.com/widgets.js";fjs.parentNode.insertBefore(js,fjs);}}(document,"script","twitter-wjs");</script>	
                    </div>
                </div>
            </div>

            <!-- START BROWSE -->
            <div class="home-col-1">
                <h1 class="ds-div-head">Browse for data</h1>
                <div id="browse-data-buttons" class="tab-buttons">
                    <a href="#recently-published-data"><span>Recently published</span></a>

                    <a href="#most-viewed-data"><span>Popular</span></a>
                    <a id="by_author" href="#by-author"><span>By author</span></a>
                    <a id="by_journal" href="#by-journal"><span>By journal</span></a>
                </div>
                <div id="aspect_discovery_RecentlyAdded_div_Home" class="ds-static-div primary" style="height: 649px; overflow: auto;">
                    <div id="recently-published-data" class="browse-data-panel">
   <!--                     <xsl:for-each select="dri:div[@n='site-home']">
                            <xsl:apply-templates/>
                        </xsl:for-each>
-->
<!-- Start of temp Recently Added -->

<h1 class="ds-div-head">Recently published
data  <a xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/" href="/feed/atom_1.0/10255/3" class="single-image-link" title="Web feed of data packages recently added to Dryad">
<img src="/themes/Dryad/images/rss.jpg" style="border: 0px;" alt="RSS feed - Recently published data" />
</a>
</h1>

<div id="aspect_discovery_SiteRecentSubmissions_div_site-recent-submission" class="ds-static-div secondary recent-submission">
<ul class="ds-artifact-list">

<li class="ds-artifact-item odd">
<div xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:mets="http://www.loc.gov/METS/" xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" style="padding: 6px;" class="artifact-description">
<a href="/resource/doi:10.5061/dryad.6q3db">
<span class="author">Hiramatsu C, Melin A, Allen W, Dubuc C, Higham J</span>
<span class="artifact-title">Data from: Experimental evidence that primate trichromacy is well suited for detecting primate social colour signals. </span>
<span class="italics">Proceedings of the Royal Society B</span> <span class="doi">http://dx.doi.org/10.5061/dryad.6q3db</span>
</a>
<span class="Z3988" title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rft_id=doi%3A10.5061%2Fdryad.6q3db&amp;rft_id=0962-8452&amp;rft_id=RSPB-2016-2458&amp;rfr_id=info%3Asid%2Fdatadryad.org%3Arepo&amp;rft.contributor=Hiramatsu%2C+Chihiro&amp;rft.contributor=Melin%2C+Amanda&amp;rft.contributor=Allen%2C+William&amp;rft.contributor=Dubuc%2C+Constance&amp;rft.contributor=Higham%2C+James&amp;rft.identifier=doi%3A10.5061%2Fdryad.6q3db&amp;rft.identifier=0962-8452&amp;rft.description=Primate+trichromatic+colour+vision+has+been+hypothesized+to+be+well+tuned+for+detecting+variation+in+facial+coloration%2C+which+could+be+due+to+selection+on+either+signal+wavelengths+or+the+sensitivities+of+the+photoreceptors+themselves.+We+provide+one+of+the+first+empirical+tests+of+this+idea+by+asking+whether%2C+when+compared+to+other+visual+systems%2C+the+information+obtained+through+primate+trichromatic+vision+confers+an+improved+ability+to+detect+the+changes+in+facial+colour+that+female+macaque+monkeys+exhibit+when+they+are+proceptive.+We+presented+pairs+of+digital+images+of+faces+of+the+same+monkey+to+human+observers%2C+and+asked+them+to+select+the+proceptive+face.+We+tested+images+that+simulated+what+would+be+seen+by+common+catarrhine+trichromatic+vision%2C+two+additional+trichromatic+conditions%2C+and+three+dichromatic+conditions.+Performance+under+conditions+of+common+catarrhine+trichromacy%2C+and+trichromacy+with+narrowly+separated+LM+cone+pigments+%28common+in+female+platyrrhines%29%2C+was+better+than+for+evenly-spaced+trichromacy+or+for+any+of+the+dichromatic+conditions.+These+results+suggest+that+primate+trichromatic+colour+vision+confers+excellent+ability+to+detect+meaningful+variation+in+primate+face+colour.+Our+experiments+support+the+hypothesis+that+social+information+detection+has+acted+on+either+primate+signal+spectral+reflectance%2C+cone+photoreceptor+spectral+tuning%2C+or+both.&amp;rft.relation=doi%3A10.5061%2Fdryad.6q3db%2F1&amp;rft.subject=Colour+vision&amp;rft.subject=Primate&amp;rft.subject=Trichromacy&amp;rft.subject=Social+signal&amp;rft.subject=Face+colour+variation&amp;rft.subject=Reproductive+state&amp;rft.title=Data+from%3A+Experimental+evidence+that+primate+trichromacy+is+well+suited+for+detecting+primate+social+colour+signals&amp;rft.type=Article&amp;rft.contributor=Hiramatsu%2C+Chihiro&amp;rft.identifier=RSPB-2016-2458&amp;rft.publicationName=Proceedings+of+the+Royal+Society+B&amp;rft.archive=proceedingsB%40royalsociety.org&amp;rft.archive=automated-messages%40datadryad.org&amp;rft.step=21680&amp;rft.step=53532e69-6c72-458e-9e6f-7338ff27057e&amp;rft.review=automated-messages%40datadryad.org">
                 
</span>
</div>
</li>
<!-- External Metadata URL: cocoon://metadata/handle/10255/dryad.142158/mets.xml?sections=dmdSec,fileSec&fileGrpTypes=THUMBNAIL-->
<li class="ds-artifact-item even">
<div xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:mets="http://www.loc.gov/METS/" xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" style="padding: 6px;" class="artifact-description">
<a href="/resource/doi:10.5061/dryad.tc28h">
<span class="author">Martin J, Tacail T, Balter V</span>
<span class="artifact-title">Data from: Non-traditional isotope perspectives in vertebrate palaeobiology. </span>
<span class="italics">Palaeontology</span> <span class="doi">http://dx.doi.org/10.5061/dryad.tc28h</span>
</a>
<span class="Z3988" title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rft_id=doi%3A10.5061%2Fdryad.tc28h&amp;rft_id=1475-4983&amp;rft_id=PALA-01-17-3927&amp;rfr_id=info%3Asid%2Fdatadryad.org%3Arepo&amp;rft.contributor=Martin%2C+Jeremy&amp;rft.contributor=Tacail%2C+Theo&amp;rft.contributor=Balter%2C+Vincent&amp;rft.coverage=Pleistocene&amp;rft.identifier=doi%3A10.5061%2Fdryad.tc28h&amp;rft.identifier=1475-4983&amp;rft.description=The+recent+development+of+Multi-Collector+Inductively+Coupled+Plasma+Mass+Spectrometry+%28MC-ICPMS%29%2C+notably+in+the+disciplines+of+earth+sciences%2C+now+allows+the+measurement+of+precise+isotope+ratios%2C+even+under+low+concentration.+Non-traditional+isotope+systems%2C+such+as+alkaline+earth+%28Ca%2C+Mg%29+and+transition+%28Cu%2C+Fe%2C+Zn%29+metals+are+now+being+measured+in+a+variety+of+biological+tissues%2C+including+bone+and+teeth.+Although+our+understanding+of+the+environmental+and+biological+mechanisms+behind+the+fractionation+of+such+elements+is+still+in+its+infancy%2C+some+of+these+isotopes+are+suspected+to+fractionate+along+the+food+chain+as+has+been+reported+in+the+literature+for+calcium%2C+magnesium+and+zinc.+Other+geochemical+methods%2C+such+as+concentration+analyses+permit+a+prior+assessment+of+diagenesis+in+the+fossils+to+be+analysed+and+such+an+approach+allows+recognising+that+in+some+circumstances%2C+not+only+enamel+but+also+dentine+or+bone+can+preserve+its+original+biogenic+composition.+The+aims+here+are+to+review+the+current+knowledge+surrounding+these+various+isotopic+tools%2C+address+their+potential+preservation+in+biological+apatite+and+provide+the+palaeobiologist+a+guide+on+the+different+toolkits+available+and+discuss+their+potential+applications+in+vertebrate+palaeobiology+with+a+case+study+involving+two+mammal+assemblages+from+the+Pleistocene+of+Europe.&amp;rft.relation=doi%3A10.5061%2Fdryad.tc28h%2F1&amp;rft.relation=doi%3A10.5061%2Fdryad.tc28h%2F2&amp;rft.relation=doi%3A10.5061%2Fdryad.tc28h%2F5&amp;rft.relation=doi%3A10.5061%2Fdryad.tc28h%2F7&amp;rft.relation=doi%3A10.5061%2Fdryad.tc28h%2F8&amp;rft.relation=doi%3A10.5061%2Fdryad.tc28h%2F9&amp;rft.subject=non-traditional+isotopes&amp;rft.subject=palaeobiology&amp;rft.subject=calcium&amp;rft.subject=cave+bear&amp;rft.title=Data+from%3A+Non-traditional+isotope+perspectives+in+vertebrate+palaeobiology&amp;rft.type=Article&amp;rft.contributor=Martin%2C+Jeremy&amp;rft.identifier=PALA-01-17-3927&amp;rft.publicationName=Palaeontology&amp;rft.archive=editor%40palass.org&amp;rft.archive=automated-messages%40datadryad.org&amp;rft.submit=false&amp;rft.review=editor%40palass.org&amp;rft.review=automated-messages%40datadryad.org">
                 
</span>
</div>
</li>
<!-- External Metadata URL: cocoon://metadata/handle/10255/dryad.145735/mets.xml?sections=dmdSec,fileSec&fileGrpTypes=THUMBNAIL-->
<li class="ds-artifact-item odd">
<div xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:mets="http://www.loc.gov/METS/" xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" style="padding: 6px;" class="artifact-description">
<a href="/resource/doi:10.5061/dryad.fd0gb">
<span class="author">Moura M, Costa H, Argôlo A, Jetz W</span>
<span class="artifact-title">Data from: Environmental constraints on the compositional and phylogenetic beta-diversity of tropical forest snake assemblages. </span>
<span class="italics">Journal of Animal Ecology</span> <span class="doi">http://dx.doi.org/10.5061/dryad.fd0gb</span>
</a>
<span class="Z3988" title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rft_id=doi%3A10.5061%2Fdryad.fd0gb&amp;rft_id=0021-8790&amp;rft_id=JAE-2017-00053&amp;rfr_id=info%3Asid%2Fdatadryad.org%3Arepo&amp;rft.contributor=Moura%2C+Mario&amp;rft.contributor=Costa%2C+Henrique&amp;rft.contributor=Arg%C3%B4lo%2C+Antonio&amp;rft.contributor=Jetz%2C+Walter&amp;rft.coverage=Atlantic+Forest&amp;rft.identifier=doi%3A10.5061%2Fdryad.fd0gb&amp;rft.identifier=0021-8790&amp;rft.description=1.%09The+ongoing+biodiversity+crisis+increases+the+importance+and+urgency+of+studies+addressing+the+role+of+environmental+variation+on+the+composition+and+evolutionary+history+of+species+assemblages%2C+but+especially+the+tropics+and+ectotherms+remain+understudied.%0D%0A2.%09In+regions+with+rainy+summers%2C+coexistence+of+ectothermic+species+may+be+determined+by+the+partitioning+of+the+climatic+niche%2C+since+ectotherms+can+rely+on+water+availability+and+thermoregulatory+behaviour+to+buffer+constraints+along+their+climatic+niche.+Conversely%2C+ectotherms+facing+dry+summers+would+have+fewer+opportunities+to+climatic+niche+partitioning+and+other+processes+rather+than+environmental+filtering+would+mediate+species+coexistence.%0D%0A3.%09We+used+218+snake+assemblages+to+quantify+the+compositional+%28CBD%29+and+phylogenetic+%28PBD%29+beta-diversity+of+snakes+in+the+Atlantic+Forest+%28AF%29+hotspot.++We+identify+two+AF+regions+with+distinct+climatological+regimes%3A+dry+summers+in+the+northern-AF+and+rainy+summers+in+the+southern-AF.+While+accounting+for+the+influence+of+multiscale+spatial+processes%2C+we+disentangle+the+relative+contribution+of+thermal%2C+water-related%2C+and+topographic+conditions+in+structuring+the+CBD+and+PBD+of+snake+assemblages%2C+and+determine+the+extent+in+which+snake+assemblages+under+distinct+climatological+regimes+are+affected+by+environmental+filtering.%0D%0A4.%09Thermal+conditions+best+explain+CBD+and+PBD+of+snakes+for+the+whole+AF%2C+whereas+water-related+factors+best+explain+the+structure+of+snake+assemblages+within+a+same+climatological+regime.+CBD+and+PBD+patterns+are+similarly+explained+by+spatial+factors+but+snake+assemblages+facing+dry+summers+are+more+affected+by+spatial+processes+operating+at+fine+to+intermediate+spatial+scale+whereas+those+assemblages+in+regions+with+rainy+summers+have+a+stronger+signature+of+coarser-scale+processes.+As+expected%2C+environmental+filtering+plays+a+stronger+role+in+southern-AF+than+northern-AF%2C+and+the+synergism+between+thermal+and+water-related+conditions+is+the+key+cause+behind+this+difference.%0D%0A5.%09Differences+in+climatological+regimes+within+the+tropics+may+affect+processes+mediating+species+coexistence.+The+role+of+broad-scale+gradients+%28e.g.+temperature%2C+precipitation%29+in+structuring+tropical+ectothermic+assemblages+is+greater+in+regions+with+rainy+summers+where+climatic+niche+partitioning+is+more+likely.+Our+findings+highlight+the+potential+stronger+role+of+biotic+interactions+and+neutral+processes+in+structuring+ectothermic+assemblages+facing+changes+towards+warmer+and+dryer+climates.&amp;rft.relation=doi%3A10.5061%2Fdryad.fd0gb%2F1&amp;rft.relation=doi%3A10.5061%2Fdryad.fd0gb%2F2&amp;rft.subject=%CE%B2-diversity&amp;rft.subject=climatological+regime&amp;rft.subject=ectotherm&amp;rft.subject=environmental+filtering&amp;rft.subject=multiscale+processes&amp;rft.subject=phylogenetic+structure&amp;rft.subject=reptile&amp;rft.subject=species+composition&amp;rft.subject=turnover&amp;rft.title=Data+from%3A+Environmental+constraints+on+the+compositional+and+phylogenetic+beta-diversity+of+tropical+forest+snake+assemblages&amp;rft.type=Article&amp;rft.contributor=Moura%2C+Mario&amp;rft.identifier=JAE-2017-00053&amp;rft.publicationName=Journal+of+Animal+Ecology&amp;rft.archive=managingeditor%40journalofanimalecology.org&amp;rft.archive=admin%40journalofanimalecology.org&amp;rft.archive=automated-messages%40datadryad.org">
                 
</span>
</div>
</li>
<!-- External Metadata URL: cocoon://metadata/handle/10255/dryad.143356/mets.xml?sections=dmdSec,fileSec&fileGrpTypes=THUMBNAIL-->
<li class="ds-artifact-item even">
<div xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:mets="http://www.loc.gov/METS/" xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" style="padding: 6px;" class="artifact-description">
<a href="/resource/doi:10.5061/dryad.7f0h0">
<span class="author">Ortega-Jimenez VM, Rabenau Lv, Dudley R</span>
<span class="artifact-title">Data from: AGE-DEPENDENT EFFECTS OF WATER STRIDERS MOVING ON PERTURBED WATER SURFACES. </span>
<span class="italics">Journal of Experimental Biology</span> <span class="doi">http://dx.doi.org/10.5061/dryad.7f0h0</span>
</a>
<span class="Z3988" title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rft_id=doi%3A10.5061%2Fdryad.7f0h0&amp;rft_id=0022-0949&amp;rft_id=JEXBIO%2F2017%2F157172&amp;rfr_id=info%3Asid%2Fdatadryad.org%3Arepo&amp;rft.contributor=Ortega-Jimenez%2C+Victor+Manuel&amp;rft.contributor=Rabenau%2C+Lisa+von&amp;rft.contributor=Dudley%2C+Robert&amp;rft.identifier=doi%3A10.5061%2Fdryad.7f0h0&amp;rft.identifier=0022-0949&amp;rft.description=Surface+roughness+is+a+ubiquitous+phenomenon+in+both+oceanic+and+terrestrial+waters.++For+insects+that+live+at+the+air-water+interface%2C+such+as+water+striders%2C+non-linear+and+multi-scale+perturbations+produce+dynamic+surface+deformations+which+may+impair+locomotion.+We+studied+escape+jumps+of+adults%2C+juveniles%2C+and+first-instar+larvae+of+the+water+strider+Aquarius+remigis+on+smooth%2C+wave-dominated%2C+and+bubble-dominated+water+surfaces.+Effects+of+substrate+on+takeoff+jumps+were+substantial%2C+with+significant+reductions+in+take-off+angles%2C+peak+translational+speeds%2C+attained+heights%2C+and+power+expenditure+on+more+perturbed+water+surfaces.+Age+effects+were+similarly+pronounced%2C+with+the+first-instar+larvae+experiencing+the+greatest+degradation+in+performance%3B+age-by-treatment+effects+were+also+significant+for+many+kinematic+variables.++Although+commonplace+in+nature%2C+perturbed+water+surfaces+thus+have+significant+and+age-dependent+effects+on+water+strider+locomotion.&amp;rft.relation=doi%3A10.5061%2Fdryad.7f0h0%2F1&amp;rft.relation=doi%3A10.5061%2Fdryad.7f0h0%2F2&amp;rft.relation=doi%3A10.5061%2Fdryad.7f0h0%2F3&amp;rft.relation=doi%3A10.5061%2Fdryad.7f0h0%2F4&amp;rft.relation=doi%3A10.5061%2Fdryad.7f0h0%2F5&amp;rft.subject=Aquarius+remigis&amp;rft.subject=bubbles&amp;rft.subject=capillary+waves&amp;rft.subject=dynamic+surface&amp;rft.subject=surface+roughness&amp;rft.title=Data+from%3A+AGE-DEPENDENT+EFFECTS+OF+WATER+STRIDERS+MOVING+ON+PERTURBED+WATER+SURFACES&amp;rft.type=Article&amp;rft.contributor=Ortega-Jimenez%2C+Victor+Manuel&amp;rft.identifier=JEXBIO%2F2017%2F157172&amp;rft.publicationName=Journal+of+Experimental+Biology&amp;rft.archive=jeb%40biologists.com%3B+automated-messages%40datadryad.org&amp;rft.step=21300&amp;rft.step=b1a1c60a-2bec-4ac4-b710-6337539cd982&amp;rft.submit=false&amp;rft.review=jeb%40biologists.com%3B+automated-messages%40datadryad.org">
                 
</span>
</div>
</li>
<!-- External Metadata URL: cocoon://metadata/handle/10255/dryad.142582/mets.xml?sections=dmdSec,fileSec&fileGrpTypes=THUMBNAIL-->
<li class="ds-artifact-item odd">
<div xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:mets="http://www.loc.gov/METS/" xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" style="padding: 6px;" class="artifact-description">
<a href="/resource/doi:10.5061/dryad.m82qm">
<span class="author">Jandt J, Suryanarayanan S, Hermanson J, Jeanne R, Toth A</span>
<span class="artifact-title">Data from: Maternal and nourishment factors interact to influence offspring developmental trajectories in social wasps. </span>
<span class="italics">Proceedings of the Royal Society B</span> <span class="doi">http://dx.doi.org/10.5061/dryad.m82qm</span>
</a>
<span class="Z3988" title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rft_id=doi%3A10.5061%2Fdryad.m82qm&amp;rft_id=0962-8452&amp;rft_id=RSPB-2017-0651&amp;rfr_id=info%3Asid%2Fdatadryad.org%3Arepo&amp;rft.contributor=Jandt%2C+Jennifer&amp;rft.contributor=Suryanarayanan%2C+Sainath&amp;rft.contributor=Hermanson%2C+John&amp;rft.contributor=Jeanne%2C+Robert&amp;rft.contributor=Toth%2C+Amy&amp;rft.identifier=doi%3A10.5061%2Fdryad.m82qm&amp;rft.identifier=0962-8452&amp;rft.description=The+social+and+nutritional+environments+during+early+development+have+the+potential+to+affect+offspring+traits%2C+but+the+mechanisms+and+molecular+underpinnings+of+these+effects+remain+elusive.+We+used+%3Ci%3EPolistes+fuscatus%3C%2Fi%3E+paper+wasps+to+dissect+how+maternally+controlled+factors+%28vibrational+signals+and+nourishment%29+interact+to+induce+different+caste+developmental+trajectories+in+female+offspring%2C+leading+to+worker+or+reproductive+%28%E2%80%98gyne%E2%80%99%29+traits.+We+established+a+set+of+caste+phenotype+biomarkers+in+%3Ci%3EP.+fuscatus%3C%2Fi%3E+females%2C+finding+that+gyne-destined+individuals+had+high+expression+of+three+caste-related+genes+hypothesized+to+have+roles+in+diapause+and+mitochondrial+metabolism.+We+then+experimentally+manipulated+maternal+vibrational+signals+%28via+artificial+%E2%80%98antennal+drumming%E2%80%99%29+and+nourishment+levels+%28via+restricted+foraging%29.+We+found+that+these+caste-related+biomarker+genes+were+responsive+to+drumming%2C+nourishment+level%2C+or+their+interaction.+Our+results+provide+a+striking+example+of+the+potent+influence+of+maternal+and+nutritional+effects+in+influencing+transcriptional+activity+and+developmental+outcomes+in+offspring.&amp;rft.relation=doi%3A10.5061%2Fdryad.m82qm%2F1&amp;rft.subject=Antennal+drumming&amp;rft.subject=diapause&amp;rft.subject=gene+expression&amp;rft.subject=reproductive+caste&amp;rft.subject=nutrition&amp;rft.subject=substrate-borne+vibration&amp;rft.title=Data+from%3A+Maternal+and+nourishment+factors+interact+to+influence+offspring+developmental+trajectories+in+social+wasps&amp;rft.type=Article&amp;rft.ScientificName=Polistes+fuscatus&amp;rft.contributor=Jandt%2C+Jennifer&amp;rft.identifier=RSPB-2017-0651&amp;rft.publicationName=Proceedings+of+the+Royal+Society+B&amp;rft.archive=proceedingsB%40royalsociety.org&amp;rft.archive=automated-messages%40datadryad.org&amp;rft.step=3234&amp;rft.step=f8465c36-8cec-4733-8820-c939ef116ff2&amp;rft.review=automated-messages%40datadryad.org&amp;rft.fundingEntity=IOS-1146410%40National+Science+Foundation+%28United+States%29">
                 
</span>
</div>
</li>
<!-- External Metadata URL: cocoon://metadata/handle/10255/dryad.145284/mets.xml?sections=dmdSec,fileSec&fileGrpTypes=THUMBNAIL-->
<li class="ds-artifact-item even">
<div xmlns:xlink="http://www.w3.org/TR/xlink/" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:dim="http://www.dspace.org/xmlns/dspace/dim" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:mets="http://www.loc.gov/METS/" xmlns:dri="http://di.tamu.edu/DRI/1.0/" xmlns:i18n="http://apache.org/cocoon/i18n/2.1" style="padding: 6px;" class="artifact-description">
<a href="/resource/doi:10.5061/dryad.6pn0b">
<span class="author">Smith J, Suraci J, Clinchy M, Crawford A, Roberts D, Zanette L, Wilmers C</span>
<span class="artifact-title">Data from: Fear of the human “super predator” reduces feeding time in large carnivores. </span>
<span class="italics">Proceedings of the Royal Society B</span> <span class="doi">http://dx.doi.org/10.5061/dryad.6pn0b</span>
</a>
<span class="Z3988" title="ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3Adc&amp;rft_id=doi%3A10.5061%2Fdryad.6pn0b&amp;rft_id=0962-8452&amp;rft_id=RSPB-2017-0433&amp;rfr_id=info%3Asid%2Fdatadryad.org%3Arepo&amp;rft.contributor=Smith%2C+Justine&amp;rft.contributor=Suraci%2C+Justin&amp;rft.contributor=Clinchy%2C+Michael&amp;rft.contributor=Crawford%2C+Ayana&amp;rft.contributor=Roberts%2C+Devin&amp;rft.contributor=Zanette%2C+Liana&amp;rft.contributor=Wilmers%2C+Christopher&amp;rft.coverage=California&amp;rft.coverage=Santa+Cruz+Mountains&amp;rft.identifier=doi%3A10.5061%2Fdryad.6pn0b&amp;rft.identifier=0962-8452&amp;rft.description=Large+carnivores%E2%80%99+fear+of+the+human+%E2%80%9Csuper+predator%E2%80%9D+has+the+potential+to+alter+their+feeding+behavior+and+result+in+human-induced+trophic+cascades.+However%2C+it+has+yet+to+be+experimentally+tested+if+large+carnivores+perceive+humans+as+predators+and+react+strongly+enough+to+have+cascading+effects+on+their+prey.+We+conducted+a+predator+playback+experiment+exposing+pumas+to+predator+%28human%29+and+non-predator+control+%28frog%29+sounds+at+puma+feeding+sites+to+measure+immediate+fear+responses+to+humans+and+the+subsequent+impacts+on+feeding.+We+found+that+pumas+fled+more+frequently%2C+took+longer+to+return%2C+and+reduced+their+overall+feeding+time+by+more+than+half+in+response+to+hearing+the+human+%E2%80%9Csuper+predator%E2%80%9D.+Combined+with+our+previous+work+showing+higher+kill+rates+of+deer+in+more+urbanized+landscapes%2C+this+study+reveals+that+fear+is+the+mechanism+driving+an+ecological+cascade+from+humans+to+increased+puma+predation+on+deer.+By+demonstrating+that+the+fear+of+humans+can+cause+a+strong+reduction+in+feeding+by+pumas%2C+our+results+support+that+non-consumptive+forms+of+human+disturbance+may+alter+the+ecological+role+of+large+carnivores.&amp;rft.relation=doi%3A10.5061%2Fdryad.6pn0b%2F1&amp;rft.subject=ecology+of+fear&amp;rft.subject=playback+experiment&amp;rft.subject=Puma+concolor&amp;rft.subject=risk-foraging+tradeoff&amp;rft.subject=indirect+effects&amp;rft.subject=trophic+cascade&amp;rft.title=Data+from%3A+Fear+of+the+human+%E2%80%9Csuper+predator%E2%80%9D+reduces+feeding+time+in+large+carnivores&amp;rft.type=Article&amp;rft.ScientificName=Puma+concolor&amp;rft.contributor=Smith%2C+Justine&amp;rft.identifier=RSPB-2017-0433&amp;rft.publicationName=Proceedings+of+the+Royal+Society+B&amp;rft.archive=proceedingsB%40royalsociety.org&amp;rft.archive=automated-messages%40datadryad.org&amp;rft.step=23547&amp;rft.step=97e3a45a-19ed-4294-8472-123d2c87acf5&amp;rft.review=automated-messages%40datadryad.org&amp;rft.fundingEntity=1255913%40National+Science+Foundation+%28United+States%29">
                 
</span>
</div>
</li>

</ul>
</div>
<!-- End of temp Recently Added -->

</div>

                    <div id="most-viewed-data" class="browse-data-panel">
		      This display is currently unavailable.
                        <xsl:apply-templates select="//dri:document/dri:body/dri:div[@id='aspect.discovery.MostDownloadedBitstream.div.home']"/>

                    </div>

                    <div id="by-author" class="browse-data-panel">
		      This display is currently unavailable.
                        <xsl:apply-templates select="/dri:document/dri:body/dri:div[@id='aspect.discovery.SearchFilterTransformer.div.browse-by-dc.contributor.author_filter']"/>
                        <xsl:apply-templates select="/dri:document/dri:body/dri:div[@id='aspect.discovery.SearchFilterTransformer.div.browse-by-dc.contributor.author_filter-results']"/>

                    </div>
                    <div id="by-journal" class="browse-data-panel">
		      This display is currently unavailable.
                        <xsl:apply-templates select="/dri:document/dri:body/dri:div[@id='aspect.discovery.SearchFilterTransformer.div.browse-by-prism.publicationName_filter']"/>
                        <xsl:apply-templates select="/dri:document/dri:body/dri:div[@id='aspect.discovery.SearchFilterTransformer.div.browse-by-prism.publicationName_filter-results']"/>

                    </div>

                </div>
            </div>

            <!-- START MAILING LIST-->
            <div class="home-col-2">
                <h1 class="ds-div-head">Mailing list</h1>
                <div id="file_news_div_mailing_list" class="ds-static-div primary" style="height: 100px;">
                    <!--This form is modified from the iContact sign-up form for Announcements -->
                    <form id="ic_signupform" method="POST" action="https://app.icontact.com/icp/core/mycontacts/signup/designer/form/?id=96&amp;cid=1548100&amp;lid=23049">
                        <p style="margin-bottom: 0px;">Sign up for announcements:</p>
                        <div class="formEl fieldtype-input required" data-validation-type="1" data-label="Email" style="display: inline-block; width: 100%;">
                            <input type="text" placeholder="Your e-mail" title="Your e-mail" name="data[email]" class="ds-text-field" style="width: 240px; margin-top: 8px;" id="file_news_div_mailing_list_input_email"/>
                        </div>
                        <div class="formEl fieldtype-checkbox required" dataname="listGroups" data-validation-type="1" data-label="Lists" style="display: none;">
                            <label class="checkbox"><input type="checkbox" alt="" name="data[listGroups][]" value="42588" checked="checked"/>
                                Dryad-announce
                            </label>
                        </div>
                        <input value="Subscribe" type="submit" name="submit" class="ds-button-field" id="file_news_div_mailing_list_input_subscribe" />
                    </form>
                    <img src="//app.icontact.com/icp/core/signup/tracking.gif?id=96&amp;cid=1548100&amp;lid=23049"/>
                </div>
            </div>

            <!-- START INTEGRATED JOURNAL-->
            <div class="home-col-2" style="clear: both; margin-left: 25px;">
                <h1 class="ds-div-head">Recently integrated journals</h1>
                <div id="recently_integrated_journals" class="ds-static-div primary">
                    <div class="container">

                        <!-- Evolution Letters -->
		        <a class="single-image-link" href="/discover?field=prism.publicationName_filter&amp;query=&amp;fq=prism.publicationName_filter%3Aevolution%5C+letters%5C%7C%5C%7C%5C%7CEvolution%5C+Letters"><img class="pub-cover" src="/themes/Mirage/images/recentlyIntegrated-EVOL_LETTS.png" alt="Evolution Letters" /></a>

                        <!-- Journal of the American Medical Informatics Association -->
		        <a class="single-image-link" href="/discover?field=prism.publicationName_filter&amp;query=&amp;fq=prism.publicationName_filter%3Ajournal%5C+of%5C+the%5C+american%5C+medical%5C+informatics%5C+association%5C%7C%5C%7C%5C%7CJournal%5C+of%5C+the%5C+American%5C+Medical%5C+Informatics%5C+Association"><img class="pub-cover" src="/themes/Mirage/images/recentlyIntegrated-JAMIA.png" alt="Journal of the American Medical Informatics Association" /></a>

                        <!-- Insect Systematics and Diversity -->
                        <a class="single-image-link" href="/discover?field=prism.publicationName_filter&amp;query=&amp;fq=prism.publicationName_filter%3Ainsect%5C+systematics%5C+and%5C+diversity%5C%7C%5C%7C%5C%7CInsect%5C+Systematics%5C+and%5C+Diversity"><img class="pub-cover" src="/themes/Mirage/images/recentlyIntegrated-ISDIVE.png" alt="Insect Systematics and Diversity" /></a>

                        <!-- Research Ideas and Outcomes -->
		        <a class="single-image-link" href="/discover?field=prism.publicationName_filter&amp;query=&amp;fq=prism.publicationName_filter%3Aresearch%5C+ideas%5C+and%5C+outcomes%5C%7C%5C%7C%5C%7CResearch%5C+Ideas%5C+and%5C+Outcomes"><img class="pub-cover" src="/themes/Mirage/images/recentlyIntegrated-RIO.png" alt="Research Ideas and Outcomes" /></a>

                    </div>
                </div>
            </div>
            <!-- START STATISTICS -->
            <div class="home-col-2" style="margin-left: 25px;">
                <div id="aspect_statistics_StatisticsTransformer_div_home" class="repository">
                    <h1 class="ds-div-head">Stats</h1>
                    <div xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/"
                         id="aspect_statistics_StatisticsTransformer_div_stats" class="ds-static-div secondary stats">
                        <!--remove old static information and add real data-->
                        <!-- <xsl:apply-templates select="/dri:document/dri:body/dri:div[@n='front-page-stats']"/> -->
			<!-- Begin temporary stats -->
			<div xmlns="http://www.w3.org/1999/xhtml" id="org_datadryad_dspace_statistics_SiteOverview_div_front-page-stats" class="ds-static-div">
<table id="org_datadryad_dspace_statistics_SiteOverview_table_list-table" class="ds-table">
<tr class="ds-table-header-row">
<th class="ds-table-header-cell odd">Type</th>
<th xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/" class="ds-table-header-cell even">Total</th>
<th xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/" class="ds-table-header-cell odd">30 days</th>
</tr>
<tr xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/" class="ds-table-row even">
<td class="ds-table-cell odd">Data packages</td>
<td xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/" class="ds-table-cell even">15905</td>
<td class="ds-table-cell odd">305</td>
</tr>
<tr class="ds-table-row odd">
<td class="ds-table-cell odd">Data files</td>
<td xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/" class="ds-table-cell even">50441</td>
<td class="ds-table-cell odd">749</td>
</tr>
<tr class="ds-table-row even">
<td class="ds-table-cell odd">Journals</td>
<td xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/" class="ds-table-cell even">563</td>
<td class="ds-table-cell odd">134</td>
</tr>
<tr class="ds-table-row odd">
<td class="ds-table-cell odd">Authors</td>
<td xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/" class="ds-table-cell even">56647</td>
<td class="ds-table-cell odd">5466</td>
</tr>
<tr class="ds-table-row even">
<td class="ds-table-cell odd">Downloads</td>
<td xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/" class="ds-table-cell even">9951</td>
<td class="ds-table-cell odd">893</td>
</tr>
</table>
			</div>
<!-- End temporary stats -->
                    </div>
                </div>
            </div>
            <!-- START BLOG -->
            <div class="home-col-2">
                <xsl:apply-templates select="dri:div[@id='aspect.dryadinfo.DryadBlogFeed.div.dryad-info-home']"/> 
            </div>
            <div id="SpiderTrap">
                <p>
                    <a href="/spider">Spider.
                    </a>
                </p>
            </div>
        </div>

        <xsl:apply-templates select="dri:div[@id='aspect.eperson.TermsOfService.div.background']"/>
        <xsl:apply-templates select="dri:div[@id='aspect.eperson.TermsOfService.div.modal-content']"/>
    </xsl:template>


    <!--
        The template to handle dri:options. Since it contains only dri:list tags (which carry the actual
        information), the only things than need to be done is creating the ds-options div and applying
        the templates inside it.
        In fact, the only bit of real work this template does is add the search box, which has to be
        handled specially in that it is not actually included in the options div, and is instead built
        from metadata available under pageMeta.
-->

    <xsl:template match="dri:options/dri:list[@n='administrative']"/>
    <xsl:template match="dri:options/dri:list[@n='browse']"/>
    <xsl:template match="dri:options/dri:list[@n='context']"/>
    <xsl:template match="dri:options/dri:list[@n='search']"/>
    <xsl:template match="dri:options/dri:list[@n='account']"/>
    <xsl:template match="dri:options/dri:list[@n='DryadBrowse']"/>
    <!--- Static Navigation Override -->
    <!-- TODO: figure out why i18n tags break the go button -->
    <xsl:template match="dri:options">
        <div id="ds-options-wrapper">
            <div id="ds-options">
                <xsl:variable name="uri" select="string(/dri:document/dri:meta/dri:pageMeta/dri:metadata[@element='request'][@qualifier='URI'])"/>
                <xsl:choose>
                    <!-- on the "My Submissions" page, have the "Submit data now" button at top of sidebar -->
                    <xsl:when test="$uri = 'submissions'">
                        <xsl:apply-templates select="dri:list[@n='DryadSubmitData']"/>
                        <xsl:apply-templates select="dri:list[@n='discovery']|dri:list[@n='DryadSearch']|dri:list[@n='DryadConnect']"/>                        
                    </xsl:when>
                    <!-- on the "My Tasks" page, suppress "Submit data now" -->
                    <xsl:when test="$uri = 'my-tasks'">
                        <xsl:apply-templates select="dri:list[@n='discovery']|dri:list[@n='DryadSearch']|dri:list[@n='DryadConnect']"/>                        
                    </xsl:when>
                    <!-- Once the search box is built, the other parts of the options are added -->
                    <xsl:otherwise>
                        <xsl:apply-templates select="dri:list[@n='discovery']|dri:list[@n='DryadSubmitData']|dri:list[@n='DryadSearch']|dri:list[@n='DryadConnect']"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="dri:list[@n='Payment']"/>
                <xsl:apply-templates select="dri:list[@n='need-help']"/>
                <xsl:apply-templates select="dri:list[@n='human-subjects']"/>
                <xsl:apply-templates select="dri:list[@n='large-data-packages']"/>
            </div>
        </div>
    </xsl:template>
    <!--
    <xsl:template match="dri:options/dri:list[@n='DryadInfo']" priority="3">
        <div id="main-menu">
            <ul class="sf-menu">
                <xsl:apply-templates select="dri:list" mode="nested"/>
                <xsl:apply-templates select="dri:item" mode="nested"/>
            </ul>
        </div>
    </xsl:template>
    -->

    <xsl:template match="dri:list" mode="menu">

        <li>
            <a href="#TODO-MenuList">
                <i18n:text>
                    <xsl:value-of select="dri:head"/>
                </i18n:text>
            </a>
            <ul>
                <xsl:apply-templates select="dri:list|dri:item" mode="menu"/>
            </ul>
        </li>

    </xsl:template>


    <xsl:template match="dri:item" mode="menu">

        <li>
            <a href="#TODO-MenuItem">
                <xsl:attribute name="href">
                    <xsl:value-of select="dri:xref/@target"/>
                </xsl:attribute>
                <xsl:apply-templates select="dri:xref/*|dri:xref/text()"/>
            </a>

        </li>

    </xsl:template>

    <xsl:template match="dri:options/dri:list[@n='DryadSearch']" priority="3">
      <div class="NOT-simple-box">
        <!-- START SEARCH -->
        <div class="home-col-1">
            <h1 class="ds-div-head">Search for data
            </h1>

            <form xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/"
                  id="aspect_discovery_SiteViewer_div_front-page-search" class="ds-interactive-div primary"
                  action="/discover" method="get" onsubmit="javascript:tSubmit(this);" style="overflow: hidden;">
                <p class="ds-paragraph">
                    <input xmlns:i18n="http://apache.org/cocoon/i18n/2.1" xmlns="http://di.tamu.edu/DRI/1.0/"
                           id="aspect_discovery_SiteViewer_field_query" class="ds-text-field" name="query"
                           placeholder="Enter keyword, DOI, etc."
                           title="Enter keyword, author, title, DOI, etc. Example: herbivory"
                           type="text" value="" style="width: 175px;"/><!-- no whitespace between these!
                     --><input xmlns:i18n="http://apache.org/cocoon/i18n/2.1"
                               id="aspect_discovery_SiteViewer_field_submit" class="ds-button-field" name="submit"
                               type="submit" value="Go" style="margin-right: -4px;"/>
                        <a style="float:left; font-size: 95%;" href="/discover?query=&amp;submit=Search">Advanced search</a>
                </p>
            </form>
        </div>
      </div>
    </xsl:template>

    <xsl:template match="dri:options/dri:list[@n='DryadConnect']" priority="3">
      <div class="NOT-simple-box">
        <!-- START CONNECT  -->
        <h1 class="ds-div-head ds_connect_with_dryad_head" id="ds_connect_with_dryad_head">Be part of Dryad
        </h1>
        <div id="ds_connect_with_dryad" class="ds-static-div primary" style="font-size: 14px;">
            <p style="margin-bottom: 0;">
                We encourage organizations to:</p>
				<ul style="list-style: none; margin-left: 1em;">
				<li><a href="/pages/membershipOverview">Become a member</a></li>
				<li><a href="/pages/payment">Sponsor data publishing fees</a></li> 
				<li><a href="/pages/submissionIntegration">Integrate your journal(s)</a>, or</li>
				<li>All of the above</li>
			</ul>
        </div>      
	  </div>
    </xsl:template>

    <xsl:template match="dri:options/dri:list[@n='large-data-packages']" priority="3">
        <div class="NOT-simple-box">
            <h1 class="ds-div-head ds_large_data_package_head" id="ds_large_data_package_head">Large data packages</h1>
            <div id="ds_large_data_package" class="ds-static-div primary" style="font-size: 14px;">
                <p style="margin-bottom: 0;">
                    Note that for data packages over 20GB, submitters will
                    be asked to pay $50 for each additional 10GB, or part thereof.
                </p>
            </div>      
        </div>
    </xsl:template>

    <xsl:template match="dri:options/dri:list[@n='human-subjects']" priority="3">
        <!-- note margin space added to top here -->
        <div class="NOT-simple-box ds-margin-top-20">
            <h1 class="ds-div-head ds_human_subjects_head" id="ds_human_subjects_head">Got human subject data?</h1>
            <div id="ds_human_subjects" class="ds-static-div primary" style="font-size: 14px;">
                <p style="margin-bottom: 0;">
                    Dryad does not accept submissions that contain personally identifiable 
                    human subject information. Human subject data must be properly anonymized. 
                    <a href="/pages/faq#depositing-acceptable-data">Read more about the kinds of data Dryad accepts</a>.
                </p> 
            </div>      
        </div>
    </xsl:template>


    <xsl:template match="dri:options/dri:list[@n='DryadSubmitData']" priority="3">
      <div id="submit-data-sidebar-box" class="simple-box">
        <!-- START DEPOSIT -->
        <div class="ds-static-div primary" id="file_news_div_news">
            <p class="ds-paragraph">
	      <!-- The next line should remain as one piece (without linebreaks) to allow it to be matched and replaced with mod_substitute on read-only servers -->
                <a class="submitnowbutton"><xsl:attribute name="href"><xsl:value-of select="/dri:document/dri:options/dri:list[@n='submitNow']/dri:item[@n='submitnowitem']/dri:xref[@rend='submitnowbutton']/@target"/></xsl:attribute>Submit data now</a>
            </p>
            <p style="margin: 1em 0 4px;">
                <a href="/pages/faq#deposit">How and why?</a>
            </p>
        </div>
      </div>
    </xsl:template>

    <xsl:template match="dri:options/dri:list[@n='DryadMail']" priority="3">
        <!-- START MAILING LIST-->
        <div class="home-col-2">
            <h1 class="ds-div-head">Dryad mailing list</h1>
            <div id="file_news_div_mailing_list" class="ds-static-div primary">
                <p class="ds-paragraph">
                    <xsl:text>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam a nisi sit amet neque vehicula dignissim accumsan non erat. Pellentesque eu ligula a est hendrerit porta a non ligula. Quisque in orci nisl, eu dictum massa. Aenean vitae lorem et risus dapibus fringilla et sit amet nunc. Donec ac sem risus. Cras a magna sapien, vel facilisis lacus. Fusce sed blandit tellus. </xsl:text>

                </p>
            </div>
        </div>
    </xsl:template>

    <xsl:variable name="meta" select="/dri:document/dri:meta/dri:pageMeta/dri:metadata"/>
    <xsl:variable name="pageName" select="$meta[@element='request'][@qualifier='URI']"/>
    <!--xsl:variable name="doc" select="document(concat('pages/', $pageName, '.xhtml'))"/-->

    <xsl:template match="dri:xref[@rend='embed']">
               
        <xsl:variable name="url" select="concat('pages/',@target)"/>
               
        <xsl:copy-of select="document(string($url))/html/*"/>
           
    </xsl:template>

    <!-- description of dataset for 'Submission overview' page -->
    <xsl:template match="dri:hi[@rend='dataset-description']">
        <p>
            <xsl:value-of select="."/>
        </p>
    </xsl:template>

    <xsl:template match="dri:body/dri:div/dri:list[@id='aspect.submission.StepTransformer.list.submit-progress']"/>


    <!-- First submission form: added and rewrote some templates to manage the form using jquery, to lead the user through the submission -->

    <!-- First submission form: Article Status Radios -->
    <xsl:template match="dri:body/dri:div/dri:list/dri:item[@n='jquery_radios']/dri:field">

        <br/>
        <span>
            <i18n:text>
                <xsl:value-of select="dri:help"/>
            </i18n:text>
        </span>
        <br/>
        <br/>
        <div class="radios">
            <xsl:for-each select="dri:option">
                <input type="radio">
                    <xsl:attribute name="id">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:attribute name="name">
                        <xsl:value-of select="../@n"/>
                    </xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="@returnValue"/>
                    </xsl:attribute>
                    <xsl:if test="../dri:value[@type='option'][@option = current()/@returnValue]">
                        <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                </input>
                <label>
                    <xsl:attribute name="for">
                        <xsl:value-of select="."/>
                    </xsl:attribute>
                    <i18n:text>
                        <xsl:value-of select="."/>
                    </i18n:text>
                </label>
                <br/>
            </xsl:for-each>
        </div>
    </xsl:template>



    <!-- First submission form: STATUS: PUBLISHED - journalID Select + Manuscript Number Edit Box -->
    <xsl:template match="dri:list[@n='doi']">
        <li id="aspect_submission_StepTransformer_list_doi">
            <table>
                <tr>
                    <td>
                    <xsl:for-each select="dri:item/dri:field">
                        <xsl:variable name="currentId"><xsl:value-of select="@id"/></xsl:variable>
                        <xsl:variable name="currentName"><xsl:value-of select="@n"/></xsl:variable>
                        <xsl:attribute name="id"><xsl:value-of select="$currentName"/></xsl:attribute>

                        <xsl:if test="$currentName!='unknown_doi'">
                            <div style='padding: 0 8px 8px;'>
                                <label class="ds-form-label-select-publication">
                                    <xsl:attribute name="for">
                                        <xsl:value-of select="translate($currentId,'.','_')"/>
                                    </xsl:attribute>
                                    <i18n:text>
                                        <xsl:value-of select="dri:label"/>
                                    </i18n:text>
                                    <xsl:text>: </xsl:text>
                                </label>

                                <xsl:apply-templates select="../dri:field[@id=$currentId]"/>
                                <xsl:apply-templates select="../dri:field[@id=$currentId]/dri:error"/>
                            </div>
                        </xsl:if>

                        <xsl:if test="$currentName='unknown_doi'">
                            <div style="font-weight:bold; border-top: 2px dotted #ccc; border-bottom: 2px dotted #ccc; padding: 3px 0 1px; text-align: center;">
                                OR
                            </div>
                            <div style="padding: 8px;" id="unknown-doi-panel">
                                <xsl:apply-templates select="../dri:field[@id=$currentId]"/>
                                <xsl:apply-templates select="../dri:field[@id=$currentId]/dri:error"/>
                            </div>
                        </xsl:if>

                    </xsl:for-each>
                    </td>
                </tr>
            </table>
        </li>
    </xsl:template>

    <!-- First submission form: STATUS: ACCEPTED/IN REVIEW/NOT_YET_SUBMITTED -->
    <xsl:template match="dri:list/dri:item[@n='select_publication_new' or @n='select_publication_exist']">
        <li>
            <table id="status_other_than_published">
                    <!--xsl:call-template name="standardAttributes">
                    <xsl:with-param name="class">
                        <xsl:text>ds-form-item </xsl:text>
                        <xsl:choose>
                        <xsl:when test="position() mod 2 = 0 and not(@rend = 'odd')">even</xsl:when>
                        <xsl:otherwise>odd</xsl:otherwise>
                        </xsl:choose>
                    </xsl:with-param>
                    </xsl:call-template>
                    <div class="ds-form-content">
                    <xsl:if test="dri:field[@type='radio']">
                        <xsl:apply-templates select="dri:field[@type='radio']"/>
                        <br/>
                    </xsl:if-->

                    <!-- RENDER:
                        - JournalID_status_not_yet_submitted
                        - journalID_status_in_review
                        - journalID
                        - MANUSCRIPT NUMBER
                    -->
                    <xsl:for-each select="dri:field[@type='composite']/dri:field">
                        <tr class="selectPubSubmitTable"><td>

                            <xsl:variable name="currentId"><xsl:value-of select="@id"/></xsl:variable>
                            <xsl:variable name="currentName"><xsl:value-of select="@n"/></xsl:variable>
                            <xsl:attribute name="id"><xsl:value-of select="$currentName"/></xsl:attribute>


                            <label class="ds-form-label-select-publication">
                                <xsl:attribute name="for"><xsl:value-of select="translate($currentId,'.','_')"/></xsl:attribute>
                                <i18n:text><xsl:value-of select="dri:label"/></i18n:text>
                                <xsl:text>: </xsl:text>
                            </label>
                            <br/>


                            <xsl:apply-templates select="../dri:field[@id=$currentId]"/>
                            <xsl:apply-templates select="../dri:field[@id=$currentId]/dri:error"/>


                        </td></tr>
                    </xsl:for-each>

                    <xsl:for-each select="dri:field[@type!='composite']">
                        <xsl:variable name="currentId"><xsl:value-of select="@id"/></xsl:variable>
                        <xsl:variable name="currentName"><xsl:value-of select="@n"/></xsl:variable>

                        <!-- MANUSCRIPT NUMBER STATUS ACCEPTED-->
                        <xsl:if test="$currentName='manu-number-status-accepted'">
                            <tr id="aspect_submission_StepTransformer_item_manu-number-status-accepted">
                                <td>
                                    <label class="ds-form-label-manu-number-status-accepted">
                                        <xsl:attribute name="for">
                                            <xsl:value-of select="translate($currentId,'.','_')"/>
                                        </xsl:attribute>
                                        <i18n:text>
                                            <xsl:value-of select="dri:label"/>
                                        </i18n:text>
                                        <xsl:text>: </xsl:text>
                                    </label>
                                    <xsl:apply-templates select="../dri:field[@id=$currentId]"/>
                                    <xsl:apply-templates select="../dri:field[@id=$currentId]/dri:error"/>
                                </td>
                            </tr>
                        </xsl:if>
                        <xsl:if test="$currentName='publication_select'">
                            <tr id="aspect_submission_StepTransformer_item_manu-number-publication_select">
                                <td>
                                    <xsl:apply-templates select="../dri:field[@id=$currentId]"/>
                                    <xsl:apply-templates select="../dri:field[@id=$currentId]/dri:error"/>
                                </td>
                            </tr>
                        </xsl:if>

                        <!-- CHECKBOX ACCEPTEANCE STATUS ACCEPTED -->
                        <xsl:if test="$currentName='manu_accepted-cb'">
                            <tr id="aspect_submission_StepTransformer_item_manu_accepted-cb">
                                <td>
                                    <xsl:apply-templates select="../dri:field[@id=$currentId]"/>
                                    <xsl:apply-templates select="../dri:field[@id=$currentId]/dri:error"/>
                                </td>
                            </tr>
                        </xsl:if>



                    </xsl:for-each>
            </table>
        </li>
    </xsl:template>
    <!-- END First submission form: added and rewrote some templates to manage the form using jquery, to lead the user through the submission -->
    <!-- Here we construct Dryad's search results tabs; externally harvested
collections are each given a tab. Collection values of these collections
(l3 for instance... this is just a code assigned by DSpace) are hard-coded
so we need to make sure a collection has the same code across different
Dryad installs (dev, demo, staging, production, etc.) -->
    <xsl:template match="dri:referenceSet[@type = 'summaryList']"
                  priority="2">
        <xsl:apply-templates select="dri:head" />
        <!-- Here we decide whether we have a hierarchical list or a flat one -->
        <xsl:choose>
            <xsl:when
                    test="descendant-or-self::dri:referenceSet/@rend='hierarchy' or ancestor::dri:referenceSet/@rend='hierarchy'">
                <ul>
                    <xsl:apply-templates select="*[not(name()='head')]"
                                         mode="summaryList" />
                </ul>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$meta[@element='request'][@qualifier='URI'][.='discover']">


                    <!-- The tabs display a selected tab based on the location
parameter that is being used (see variable defined above) -->
                </xsl:if>
                <ul class="ds-artifact-list">
                    <xsl:choose>
                        <xsl:when test="$meta[@element='request'][@qualifier='URI'][.='submissions']">
                            <xsl:apply-templates select="*[not(name()='head')]"
                                                 mode="summaryNonArchivedList" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="*[not(name()='head')]"
                                                 mode="summaryList" />
                        </xsl:otherwise>
                    </xsl:choose>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="buildTabs">

        <xsl:for-each select="/dri:document/dri:body/dri:div/dri:div/dri:list[@n='tabs']/dri:item">

            <xsl:element name="li">

                <xsl:if test="dri:field[@n='selected']">
                    <xsl:attribute name="id">selected</xsl:attribute>

                </xsl:if>
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="dri:xref/@target"/>
                    </xsl:attribute>


                    <xsl:value-of select="dri:xref/text()"/>

                </xsl:element>
            </xsl:element>

        </xsl:for-each>

    </xsl:template>




    <!--
<xsl:template match="/dri:document/dri:body/dri:div/dri:div[@id='aspect.discovery.SimpleSearch.div.search-results']/dri:list">
</xsl:template>
-->
    <xsl:template match="/dri:document/dri:body/dri:div/dri:div/dri:list[@n='tabs']">
        <div id="searchTabs">
            <ul>
                <xsl:call-template name="buildTabs"/>


            </ul>
        </div>
    </xsl:template>


    <xsl:template match="/dri:document/dri:body/dri:div/dri:div/dri:list[@n='search-query']/dri:item[position()=1]">
        <li class="ds-form-item">
            <label class="ds-form-label" for="aspect_discovery_SimpleSearch_field_query"><i18n:text><xsl:value-of select="dri:field/dri:label"/></i18n:text></label>
            <div class="ds-form-content">
                <xsl:apply-templates/>
                <!-- Place the 'Go' button beside the search field -->
                <input class="ds-button-field " name="submit" type="submit" i18n:attr="value"
                       value="xmlui.general.go">
                </input>
            </div>
        </li>
        <li class="ds-form-item">
            <a id="advanced-search" href="#">Advanced search</a>
        </li>
    </xsl:template>


    <xsl:template match="/dri:document/dri:body/dri:div/dri:list[@id='aspect.submission.StepTransformer.list.submit-select-publication']/dri:head">
        <legend>
            <i18n:text><xsl:value-of select="."/></i18n:text>
        </legend>
    </xsl:template>
    <xsl:template match="/dri:document/dri:body/dri:div/dri:list[@id='aspect.submission.StepTransformer.list.submit-upload-file']/dri:head">
        <legend>
            <i18n:text><xsl:value-of select="."/></i18n:text>
        </legend>
    </xsl:template>

    <xsl:template match="/dri:document/dri:body/dri:div/dri:list[@id='aspect.submission.StepTransformer.list.submit-describe-dataset']/dri:head">
        <legend>
            <i18n:text><xsl:value-of select="."/></i18n:text>
        </legend>
    </xsl:template>

    <xsl:template match="/dri:document/dri:body/dri:div/dri:list[@id='aspect.submission.StepTransformer.list.submit-overview-file']/dri:head">
        <legend>
            <i18n:text><xsl:value-of select="."/></i18n:text>
        </legend>
    </xsl:template>

    <xsl:template match="dri:list[@id='aspect.submission.StepTransformer.list.submit-upload-file']">
        <fieldset>
            <xsl:call-template name="standardAttributes">
                <xsl:with-param name="class">
                    <!-- Provision for the sub list -->
                    <xsl:text>ds-form-</xsl:text>
                    <xsl:if test="ancestor::dri:list[@type='form']">
                        <xsl:text>sub</xsl:text>
                    </xsl:if>
                    <xsl:text>list </xsl:text>
                    <xsl:if test="count(dri:item) > 3">
                        <xsl:text>thick </xsl:text>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:apply-templates select="dri:head"/>

            <xsl:apply-templates select="dri:item[@id='aspect.submission.StepTransformer.item.data-upload-details']"/>

            <table class="datafiletable">
                <tr>
                    <td>
                        <xsl:apply-templates
                                select="dri:item[@id='aspect.submission.StepTransformer.item.dataset-item']/dri:field[@type='radio']"
                                />
                    </td>
                    <td>
                        <xsl:apply-templates
                                select="dri:item[@id='aspect.submission.StepTransformer.item.dataset-item']/*[not(@type='radio')]"
                                />
                    </td>
                </tr>
                <tr>
                    <td>
                        <xsl:apply-templates
                                select="dri:item[@id='aspect.submission.StepTransformer.item.dataset-identifier']/dri:field[@type='radio']"
                                />
                    </td>
                    <td>
                        <xsl:apply-templates
                                select="dri:item[@id='aspect.submission.StepTransformer.item.dataset-identifier']/*[not(@type='radio')]"
                                />
                    </td>
                </tr>
            </table>
        </fieldset>
    </xsl:template>
    <xsl:template match="dri:item[@id='aspect.submission.StepTransformer.item.data-upload-details']">
        <div class="ds-form-content">
            <i18n:text>
                <xsl:value-of select="."/>
            </i18n:text>
        </div>
    </xsl:template>
    <!-- remove old dryad tooltip style help text-->
    <!--xsl:template match="dri:help" mode="compositeComponent">
        <xsl:if
                test="not(ancestor::dri:div[@id='aspect.submission.StepTransformer.div.submit-describe-publication' or @id= 'aspect.submission.StepTransformer.div.submit-describe-dataset'])">
            <span class="composite-help">
                <xsl:if
                        test="ancestor::dri:div[@id='aspect.submission.StepTransformer.div.submit-describe-publication' or @id= 'aspect.submission.StepTransformer.div.submit-describe-dataset']">
                    <xsl:variable name="translatedParentId">
                        <xsl:value-of select="translate(../@id, '.', '_')"/>
                    </xsl:variable>
                    <xsl:attribute name="connectId">
                        <xsl:value-of select="$translatedParentId"/>
                    </xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$translatedParentId"
                            />_tooltip
                    </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates/>
            </span>
        </xsl:if>
    </xsl:template-->
    <!--add hidden class to help text-->
    <xsl:template match="dri:help" mode="compositeComponent">
        <xsl:choose>
            <xsl:when test="ancestor::dri:div[@id='aspect.dryadfeedback.MembershipApplicationForm.div.membership-form']"/>
            <xsl:otherwise>
                <span class="composite-help">
                    <xsl:if test="ancestor::dri:field[@rend='hidden']">
                        <xsl:attribute name="class">
                            <xsl:text>hidden</xsl:text>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates />
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="dri:help">
        <xsl:choose>
            <!-- only display <help> in tooltip for feedback form -->
            <xsl:when test="ancestor::dri:div[@id='aspect.artifactbrowser.FeedbackForm.div.feedback-form']"/>
            
            <xsl:when test="not(ancestor::dri:div[@id='aspect.submission.StepTransformer.div.submit-describe-publication' or @id= 'aspect.submission.StepTransformer.div.submit-describe-dataset' or @id= 'aspect.submission.StepTransformer.div.submit-select-publication' or @id= 'aspect.dryadfeedback.MembershipApplicationForm.div.membership-form' or @id= 'aspect.artifactbrowser.FeedbackForm.div.feedback-form'])">
                <!--Only create the <span> if there is content in the <dri:help> node-->
                <xsl:if test="./text() or ./node()">
                    <span>
                        <xsl:attribute name="class">
                            <xsl:text>field-help</xsl:text>
                        </xsl:attribute>
                        <xsl:if test="ancestor::dri:field[@rend='hidden']">
                            <xsl:attribute name="class">
                                <xsl:text>hidden</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:apply-templates/>
                    </span>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/dri:document/dri:body/dri:div/dri:div/dri:list[@n='most_recent' or @n='link-to-button']">
        <div class="link-to-button">
            <xsl:apply-templates select="dri:item"/>
        </div>
    </xsl:template>

    <xsl:template match="//dri:document/dri:body/dri:div[@id='aspect.discovery.MostDownloadedBitstream.div.home']">
        <div id="aspect_discovery_MostDownloadedBitstream_table_most-downloaded">
            <xsl:apply-templates select="./dri:div/dri:head"/>
            <table>
                <tr>
                    <th><xsl:apply-templates select="./dri:div/dri:div[@n='items']/dri:head"/></th>
                    <th><xsl:apply-templates select="./dri:div/dri:div[@n='count']/dri:head"/></th>
                </tr>
                <xsl:for-each select="./dri:div/dri:div[@n='items']/dri:referenceSet/dri:reference">
                    <xsl:variable name="position">
                        <xsl:value-of select="position()"/>
                    </xsl:variable>
                    <tr>
                        <td><xsl:apply-templates select="." mode="summaryList"/></td>
                        <td><xsl:apply-templates select="//dri:document/dri:body/dri:div[@id='aspect.discovery.MostDownloadedBitstream.div.home']/dri:div/dri:div[@n='count']/dri:list/dri:item[position()=$position]"/></td>
                    </tr>
                </xsl:for-each>

            </table>
        </div>
    </xsl:template>

    <!--add table for updated file information-->
    <xsl:template match="/dri:document/dri:body/dri:div/dri:list/dri:item[@id='aspect.submission.StepTransformer.item.bitstream-item']">
        <table><tr>
            <xsl:for-each select="./dri:hi[@rend='head']">
                <th>
                    <xsl:apply-templates/>
                </th>
            </xsl:for-each>
        </tr>
            <tr>
                <xsl:for-each select="./dri:hi[@rend='content']">
                    <td>
                        <xsl:apply-templates/>
                    </td>
                </xsl:for-each>
            </tr>
        </table>
        <xsl:apply-templates select="./dri:field"/>
    </xsl:template>

    <!--add table for updated readme file information-->
    <xsl:template match="/dri:document/dri:body/dri:div/dri:list/dri:item[@id='aspect.submission.StepTransformer.item.submission-file-dc_readme']">
        <li class="ds-form-item odd">
            <span class="ds-form-label"><xsl:value-of select="../dri:label[position()=1]"/></span>
            <table style="clear:both"><tr>
                <xsl:for-each select="./dri:hi[@rend='head']">
                    <th>
                        <xsl:apply-templates/>
                    </th>
                </xsl:for-each>
            </tr>
                <tr>
                    <xsl:for-each select="./dri:hi[@rend='content']">
                        <td>
                            <xsl:apply-templates/>
                        </td>
                    </xsl:for-each>
                </tr>
            </table>
            <xsl:apply-templates select="./dri:field"/>
        </li>
    </xsl:template>

    <!-- Add Empty select option if no authors listed.  Prevents Subject Keywords from breaking -->
    <xsl:template match="/dri:document/dri:body/dri:div/dri:list/dri:item/dri:field[@id='aspect.submission.StepTransformer.field.dc_contributor_correspondingAuthor' and @type='select']">
        <select class="ds-select-field">
            <xsl:apply-templates/>
            <xsl:if test="not(dri:option)">
                <option value=""/>
            </xsl:if>
        </select>
    </xsl:template>

     <!--add attribute placeholder and title-->
    <xsl:template match="/dri:document/dri:body/dri:div/dri:list/dri:item/dri:field/dri:field[@id='aspect.submission.StepTransformer.field.datafile_identifier']" mode="normalField">
        <input>
            <xsl:call-template name="fieldAttributes"/>
            <xsl:attribute name="placeholder">
                <xsl:text>External file identifier</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>External file identifier</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="value">
                <xsl:choose>
                    <xsl:when test="./dri:value[@type='raw']">
                        <xsl:value-of select="./dri:value[@type='raw']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./dri:value[@type='default']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="dri:value/i18n:text">
                <xsl:attribute name="i18n:attr">value</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </input>
    </xsl:template>

     <!--add attribute placeholder and title for other repository-->
    <xsl:template match="/dri:document/dri:body/dri:div/dri:list/dri:item/dri:field/dri:field[@id='aspect.submission.StepTransformer.field.other_repo_name']" mode="normalField">
        <input>
            <xsl:call-template name="fieldAttributes"/>
            <xsl:attribute name="placeholder">
                <xsl:text>Repository name</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="title">
                <xsl:text>Repository name</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="value">
                <xsl:choose>
                    <xsl:when test="./dri:value[@type='raw']">
                        <xsl:value-of select="./dri:value[@type='raw']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./dri:value[@type='default']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="dri:value/i18n:text">
                <xsl:attribute name="i18n:attr">value</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates />
        </input>
    </xsl:template>

    <!--payment-->

    <xsl:template match="//dri:item[@id='aspect.paymentsystem.ShoppingCartTransformer.item.country-list' or @id='aspect.paymentsystem.ShoppingCartTransformer.item.voucher-list']">

        <li>
            <xsl:attribute name="name">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:value-of select="@rend"/>
            </xsl:attribute>
            <div class="label">
                <xsl:if test="string-length(dri:field/dri:label)>0">
                    <i18n:text><xsl:value-of select="dri:field/dri:label"/></i18n:text>
                </xsl:if>
            </div>
            <div class="help-title">
                <xsl:if test="string-length(dri:field/dri:help)>0">
                    <img class="label-mark" src="/themes/Mirage/images/help.jpg">
                        <xsl:attribute name="title">
                            <xsl:value-of select="dri:field/dri:help"/>
                        </xsl:attribute>
                    </img>
                </xsl:if>
            </div>
            <xsl:apply-templates select="*"/>
        </li>
    </xsl:template>



    <xsl:template match="//dri:field[@id='aspect.paymentsystem.ShoppingCartTransformer.field.voucher']">
        <input>
            <xsl:attribute name="name">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:attribute name="value">
                <xsl:value-of select="@value"/>
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:value-of select="translate(@id,'.','_')"/>
            </xsl:attribute>
        </input>
    </xsl:template>



    <xsl:template match="//dri:field[@id='aspect.paymentsystem.ShoppingCartTransformer.field.currency' or @id='aspect.paymentsystem.ShoppingCartTransformer.field.country']">
    <select onchange="javascript:updateOrder()">
            <xsl:attribute name="name">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:apply-templates select="*"/>
        </select>
    </xsl:template>
    <xsl:template match="//dri:field[@id='aspect.submission.StepTransformer.field.country']">
        <select onchange="javascript:updateCountry()">
            <xsl:attribute name="name">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:apply-templates select="*"/>
        </select>
    </xsl:template>
    <xsl:template match="//dri:field[@id='aspect.paymentsystem.ShoppingCartTransformer.field.apply']">
        <button onclick="javascript:updateOrder()" class="ds-button-field">
            <xsl:attribute name="name">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:value-of select="@n"/>
        </button>
    </xsl:template>


    <xsl:template match="//dri:list[@id='aspect.paymentsystem.PayPalConfirmationTransformer.list.paypal-form']">
        <form action="https://pilot-payflowpro.paypal.com/" method="post">
            <xsl:apply-templates select="*"/>
        </form>
    </xsl:template>


    <xsl:template match="//dri:div[@n='paypal-iframe']">
        <iframe name="paypal-iframe" scrolling="no" id="paypal-iframe">
            <xsl:attribute name="src">
                <xsl:value-of select="dri:list/dri:item[@n='link']" />
                <xsl:text disable-output-escaping="yes">?MODE=</xsl:text>
                <xsl:value-of select="dri:list/dri:item[@n='testMode']" />
                <xsl:text>&amp;SECURETOKENID=</xsl:text>
                <xsl:value-of select="dri:list/dri:item[@n='secureTokenId']" />
                <xsl:text disable-output-escaping="yes">&amp;SECURETOKEN=</xsl:text>
                <xsl:value-of select="dri:list/dri:item[@n='secureToken']" />
            </xsl:attribute>
            <xsl:attribute name="width">
                <xsl:value-of select="$iframe.maxwidth"/>
            </xsl:attribute>
            <xsl:attribute name="height">
                <xsl:value-of select="$iframe.maxheight"/>
            </xsl:attribute>
              error when load payment form
        </iframe>
    </xsl:template>

    <xsl:template match="//dri:list[@n='voucher-list']">
                 <xsl:apply-templates/>
    </xsl:template>
    
    <!-- make sure search labels appear -->
    <xsl:template name="search_labels">
        <xsl:variable name="currentId">
          <xsl:value-of select="./@id" />
        </xsl:variable>
        <label style="font-weight: normal;">
          <xsl:attribute name="for">
              <xsl:value-of select="translate($currentId,'.','_')"/>
          </xsl:attribute>
          <i18n:text>
              <xsl:value-of select="dri:label"/>
          </i18n:text>
        </label>
        <xsl:apply-templates select="." mode="normalField"/>
    </xsl:template>


    <xsl:template match="dri:table[@id='aspect.discovery.SimpleSearch.table.search-controls']/dri:row/dri:cell/dri:field[@type='select']">
      <xsl:call-template name="search_labels" />
    </xsl:template>

    <xsl:template match="dri:field[@rend='starts_with' and @type='text']">
      <xsl:call-template name="search_labels" />
    </xsl:template>

    <xsl:template match="dri:div[@id='full-stacktrace']">
        <xsl:comment>
            <xsl:value-of select="."/>
        </xsl:comment>
    </xsl:template>
        

    <!-- remove voucher link -->
    <xsl:template match="//dri:item[@id='aspect.paymentsystem.ShoppingCartTransformer.item.remove-voucher']/dri:xref">
        <a id="remove-voucher" href="#">
            <xsl:attribute name="onclick">
                <xsl:text>javascript:removeVoucher()</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="."/>&#160;
        </a>
    </xsl:template>



    <!-- remove country link -->
    <xsl:template match="//dri:item[@id='aspect.paymentsystem.ShoppingCartTransformer.item.remove-country']/dri:xref">
        <a id="remove-country" href="#">
            <xsl:attribute name="onclick">
                <xsl:text>javascript:removeCountry()</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="."/>&#160;
        </a>
    </xsl:template>

    <!-- Add 'return' link to propagate-metadata form-->
    <xsl:template match="dri:field[@id='aspect.administrative.item.PropagateItemMetadataForm.field.submit_return']" mode="normalField">
        <a href="#">
            <xsl:attribute name="onclick">
                <xsl:text>javascript:DryadClosePropagate()</xsl:text>
            </xsl:attribute>
                <i18n:text>
                    <xsl:value-of select="."/>
                </i18n:text>
        </a>
    </xsl:template>

  <xsl:template match="dri:p[@rend='edit-metadata-actions bottom']">
    <xsl:apply-templates />
    <!-- Propagate metadata buttons can be clicked from either admin or curator edit metdata interfaces -->
    <!-- The DRI structure is similar but the elements have different IDs -->
    <xsl:variable name="propagateShowPopupAdmin" select="//dri:field[@id='aspect.administrative.item.EditItemMetadataForm.field.propagate_show_popup']/dri:value[@type='raw']"></xsl:variable>
    <xsl:variable name="propagateShowPopupCurator" select="//dri:field[@id='aspect.submission.submit.CuratorEditMetadataForm.field.propagate_show_popup']/dri:value[@type='raw']"></xsl:variable>
    <xsl:choose>
      <xsl:when test="$propagateShowPopupAdmin = '1'">
        <xsl:call-template name="popupPropagateMetadata">
          <xsl:with-param name="packageDoi" select="//dri:row[@id='aspect.administrative.item.EditItemMetadataForm.row.dc_identifier']/dri:cell/dri:field[@type='textarea']/dri:value[@type='raw']"></xsl:with-param>
          <xsl:with-param name="fileDois" select="//dri:row[@id='aspect.administrative.item.EditItemMetadataForm.row.dc_relation_haspart']/dri:cell/dri:field[@type='textarea']/dri:value[@type='raw']"></xsl:with-param>
          <xsl:with-param name="metadataFieldName" select="//dri:field[@id='aspect.administrative.item.EditItemMetadataForm.field.propagate_md_field']/dri:value[@type='raw']"></xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$propagateShowPopupCurator = '1'">
        <xsl:call-template name="popupPropagateMetadata">
          <xsl:with-param name="packageDoi" select="//dri:row[@id='aspect.submission.submit.CuratorEditMetadataForm.row.dc_identifier']/dri:cell/dri:field[@type='textarea']/dri:value[@type='raw']"></xsl:with-param>
          <xsl:with-param name="fileDois" select="//dri:row[@id='aspect.submission.submit.CuratorEditMetadataForm.row.dc_relation_haspart']/dri:cell/dri:field[@type='textarea']/dri:value[@type='raw']"></xsl:with-param>
          <xsl:with-param name="metadataFieldName" select="//dri:field[@id='aspect.submission.submit.CuratorEditMetadataForm.field.propagate_md_field']/dri:value[@type='raw']"></xsl:with-param>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="popupPropagateMetadata">
    <xsl:param name="fileDois"/>
    <xsl:param name="metadataFieldName"/>
    <xsl:param name="packageDoi"/>
      <xsl:if test="count($fileDois) > 0">
        <script>
          <xsl:attribute name="type"><xsl:text>text/javascript</xsl:text></xsl:attribute>
          <xsl:text>runAfterJSImports.add( function() { DryadShowPropagateMetadata('</xsl:text>
          <xsl:value-of select="concat($context-path,'/admin/item/propagate-metadata')" />
          <xsl:text>','</xsl:text>
          <xsl:value-of select="$metadataFieldName" />
          <xsl:text>','</xsl:text>
          <xsl:value-of select="$packageDoi" />
          <xsl:text>'); } );</xsl:text>
        </script>
      </xsl:if>
  
  </xsl:template>


    <xsl:template match="//dri:item[@rend='total']">
        <li xmlns:i18n="http://apache.org/cocoon/i18n/2.1" class="ds-form-item odd total">
            <xsl:attribute name="id">
                <xsl:value-of select="translate(@id,'.','_')"/>
            </xsl:attribute>
            <span class="ds-form-label">Your total
                <img src="/themes/Mirage/images/help.jpg" class="label-mark">
                    <xsl:attribute name="title">xmlui.PaymentSystem.shoppingcart.order.help.title</xsl:attribute>
                    <xsl:attribute name="attr" namespace="http://apache.org/cocoon/i18n/2.1">title</xsl:attribute>
                </img>
                :
            </span>
            <div class="ds-form-content"><xsl:value-of select="."/></div>
        </li>
    </xsl:template>

    <!-- Confirmations for destructive buttons -->
    <xsl:template name="destructiveSubmitButton">
      <xsl:param name="confirmationText" select="'Are you sure?'" />
        <!-- Adapted from normalField in dri2xhtml-alt/core/forms.xsl -->
        <xsl:variable name="submitButtonId" select="translate(@id,'.','_')"/>
        <input>
            <xsl:call-template name="fieldAttributes"/>
            <xsl:if test="@type='button'">
                <xsl:attribute name="type">submit</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="value">
                <xsl:choose>
                    <xsl:when test="./dri:value[@type='raw']">
                        <xsl:value-of select="./dri:value[@type='raw']"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="./dri:value[@type='default']"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="dri:value/i18n:text">
                <xsl:attribute name="i18n:attr">value</xsl:attribute>
            </xsl:if>
            <xsl:attribute name="onclick">
                <xsl:text>if(confirm('</xsl:text><!--
                --><xsl:value-of select="$confirmationText" /><!--
                --><xsl:text>')){ </xsl:text>
                <xsl:text>  jQuery('#</xsl:text><!--
                --><xsl:value-of select="$submitButtonId" /><!--
                --><xsl:text>').submit(); } else {</xsl:text>
                <xsl:text>return false;</xsl:text>
                <xsl:text>}</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates />
        </input>
    </xsl:template>

    <!-- Confirm before lifting embargo -->
    <xsl:template match="//dri:field[@id='aspect.administrative.item.EditItemEmbargoForm.field.submit_lift_embargo']">
        <xsl:call-template name="destructiveSubmitButton">
            <xsl:with-param name="confirmationText" select="'Are you sure you would like to lift this embargo now?'" />
        </xsl:call-template>
    </xsl:template>

    <!-- Confirm before deleting data files in submission overview -->
    <xsl:template match="//dri:field[starts-with(@id,'aspect.submission.submit.OverviewStep.field.submit_delete_dataset')]">
        <xsl:call-template name="destructiveSubmitButton">
            <xsl:with-param name="confirmationText" select="'Are you sure you would like to delete this Data file?'" />
        </xsl:call-template>
    </xsl:template>

</xsl:stylesheet>
