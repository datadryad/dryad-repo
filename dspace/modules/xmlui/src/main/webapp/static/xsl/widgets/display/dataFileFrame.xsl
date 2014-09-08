<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:ddf="http://purl.org/dryad/schema/terms/v3.1"
    xmlns:dwc="http://rs.tdwg.org/dwc/terms/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:bibo="http://purl.org/dryad/schema/dryad-bibo/v3.1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:ex="http://apache.org/cocoon/exception/1.0"
    version="1.0">
    
    <xsl:output method="text"/>
    
    <xsl:param name="ddwcss"/>          <!-- large_widget.css -->
    <xsl:param name="jqlib"/>           <!-- jquery.min.js -->
    <xsl:param name="lblib"/>           <!-- jquery.magnific-popup.js -->
    <xsl:param name="frame-url"/>       <!-- url for file contents request -->
    <xsl:param name="wrapper-id"/>      <!-- @id of element wrapping JS call -->
    <xsl:param name="frame-height"/>    <!-- -->
    <xsl:param name="frame-width"/>     <!-- -->
    <xsl:param name="doi"/>             <!-- data file Dryad DOI value -->

    <xsl:template match="/">
        <xsl:choose>
            <!-- DataOne-MN responded with an <error> document -->
            <xsl:when test="error">
                <xsl:call-template name="d1-error"/>
            </xsl:when>
            <!-- Cocoon not-found exception XML -->
            <xsl:when test="ex:exception-report">
                <xsl:call-template name="cocoon-exception"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="js"/>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>
    
    <xsl:template name="js-error-logger">
        <xsl:param name="message" select="''"/>
        <![CDATA[
        (function(w){
            if (w.hasOwnProperty('console') && w.console.hasOwnProperty('log')) {
                console.log(']]><xsl:value-of select="$message"/><![CDATA[');
            }
        })(window);
        ]]>
    </xsl:template>

    <xsl:template name="d1-error">
        <xsl:call-template name="js-error-logger">
            <xsl:with-param name="message" select="concat('Dryad request error: no resource available for resource with DOI ', $doi)"/>
        </xsl:call-template>
    </xsl:template>
            
    <xsl:template name="cocoon-exception">
        <xsl:call-template name="js-error-logger">
            <xsl:with-param name="message" select="concat('Dryad request error: service retuned to content for DOI ', $doi)"/>
        </xsl:call-template>        
    </xsl:template>
    

    <xsl:template name="js">
        <![CDATA[
(function(w, d) {
'use strict';
]]>
var ddwcss = '<xsl:value-of select="$ddwcss"/>'
, jqlib    = '<xsl:value-of select="$jqlib"/>'
, lblib    = '<xsl:value-of select="$lblib"/>'
, wid      = '<xsl:value-of select="$wrapper-id"/>'
, bssrc    = '<xsl:value-of select="$frame-url"/>'
, height   = '<xsl:value-of select="$frame-height"/>'
, width    = '<xsl:value-of select="$frame-width"/>'<![CDATA[
, minJQ = ['1.7.2',1,7,2] // jQuery 1.7.2+ required for lightbox library
, pudel = 150  // lightbox close delay, ms.
, pucls = 'mfp-zoom-in' // css class for lightbox
, frcls = 'dryad-ddw'
, jQuery;
if (wid === undefined || wid === '') return;
if (w.jQuery === undefined || !testJQversion(w.jQuery.fn.jquery)) {
    load_js(jqlib, function(script) { 
        if (script.readyState) {        // IE
            script.readystatechange = function() {
                if (this.readyState === 'complete' || this.readyState == 'loaded') {
                    noConflictHandler();                
                }
            }
        } else {
            script.onload = noConflictHandler;
        }
    });
} else {
    jQuery = w.jQuery;
    dryadJQLoaded();
}
function testJQversion(jqv) {
    if (jqv === undefined) return false;
    var vs = jqv.match(/(\d+)\.(\d+)\.(\d+)/); // e.g., ["1.3.2", "1", "3", "2"]
    return    (parseInt(vs[1]) == minJQ[1] && parseInt(vs[2]) >= minJQ[2])  // jQuery 1.*
           || (parseInt(vs[1]) > minJQ[1])                                  // jQuery 2.*
}
function noConflictHandler() {
    jQuery = w.jQuery.noConflict();
    dryadJQLoaded();
}
function open_popup(content) {
    if (jQuery === undefined || !jQuery.hasOwnProperty('magnificPopup')) return;
    jQuery.magnificPopup.open({
        removalDelay: pudel,
        mainClass: pucls,
        items: {
            src: content,
            type: 'inline'
        }
    });
}
// download a URL using a hidden iframe element
function download_url(url) {
    var hiddenIFrameID = 'hiddenDownloader',
    iframe = document.getElementById(hiddenIFrameID);
    if (iframe === null) {
        iframe = document.createElement('iframe');
        iframe.id = hiddenIFrameID;
        iframe.style.display = 'none';
        document.body.appendChild(iframe);
    }
    iframe.src = url;
}
function handle_message(e) {
    if (e.origin !== d.location.protocol + '//' + d.location.host) return;
    if (e.data.hasOwnProperty('action')) {
        if (e.data.action === 'download') {
            if (!e.data.hasOwnProperty('data')) return;
            download_url(e.data.data);
        } else if (e.data.action === 'cite') {
            if (!e.data.hasOwnProperty('data')) return;
            open_popup(e.data.data);
        } else if (e.data.action === 'share') {
            if (!e.data.hasOwnProperty('data')) return;
            open_popup(e.data.data);      
        } else if (e.data.action === 'zoom') {
            if (!e.data.hasOwnProperty('data')) return;
            open_popup(e.data.data);
        }
    }
};
function load_js(url, cb) {
    var script = d.createElement('script');
    script.setAttribute('type', 'text/javascript');
    script.setAttribute('src', url);
    if (cb !== undefined) cb(script);
    (d.getElementsByTagName('script')[0]).insertBefore(script, null);
}
function load_css(url) {
    var link = d.createElement('link');
    link.setAttribute('rel', 'stylesheet');
    link.setAttribute('type', 'text/css');
    link.setAttribute('href', url);
    (d.getElementsByTagName('script')[0]).insertBefore(link, null);
}
function dryadJQLoaded() {
    jQuery(d).ready(function($) {
        var wrapper = document.getElementById(wid);
        if (wrapper === null) return;
        var frame = document.createElement('iframe');
        frame.setAttribute('class', frcls);
        frame.setAttribute('src', bssrc);
        frame.setAttribute('width', width);
        frame.setAttribute('height', height);
        w.addEventListener('message', handle_message, false);
        load_css(ddwcss);
        load_js(lblib);
        wrapper.appendChild(frame);
    });
}
})(window,document);
]]>
    </xsl:template>
    
    
</xsl:stylesheet>
