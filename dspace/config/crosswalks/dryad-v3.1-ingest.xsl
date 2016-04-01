<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:dim="http://www.dspace.org/xmlns/dspace/dim"
        xmlns:dcterms="http://purl.org/dc/terms/"
        xmlns:dwc="http://rs.tdwg.org/dwc/terms/"
        xmlns:dryad="http://purl.org/dryad/schema/terms/v3.1"
        xmlns="http://purl.org/dryad/schema/terms/v3.1"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://datadryad.org/profile/v3.1/dryad.xsd"
        exclude-result-prefixes="xsl dcterms dwc dryad"
        version="1.0">

    <xsl:strip-space elements="*"/>
    <xsl:output indent="no" />

    <xsl:template match="dryad:DryadDataPackage">
      <dim:dim>
        <xsl:apply-templates/>
      </dim:dim>
    </xsl:template>

    <xsl:template match="dcterms:references">
      <dim:field mdschema="dc" element="relation" qualifier="isreferencedby">
        <xsl:apply-templates/>
      </dim:field>
    </xsl:template>

    <xsl:template match="*">
      <!-- catch and ignore what we don't explictly crosswalk -->
    </xsl:template>

</xsl:stylesheet>
