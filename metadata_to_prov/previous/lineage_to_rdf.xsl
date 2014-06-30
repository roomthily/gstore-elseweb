<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" exclude-result-prefixes="fn xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://gstore.unm.edu/elseweb"
    xml:base="http://gstore.unm.edu/elseweb"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    >
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="schema-base" select="'http://gstore.unm.edu/elseweb/'"/>
    
    <!-- 
    take the lineage (sources + steps) with a few assumptions about the values in it
    and generate some prov
    -->
    <xsl:variable name="sources" select="/metadata/dataqual/lineage/srcinfo"/>
    <xsl:variable name="steps" select="/metadata/dataqual/lineage/procstep"/>
    
    <xsl:template match="/metadata">
        <rdf:RDF>
            <owl:Ontology rdf:about="{$schema-base}"/>
            
            <owl:ObjectProperty rdf:about="http://www.w3.org/ns/prov#used"/>
            <owl:ObjectProperty rdf:about="http://www.w3.org/ns/prov#wasAssociatedWith"/>
            <owl:ObjectProperty rdf:about="http://www.w3.org/ns/prov#wasGeneratedBy"/>
            
            <owl:Class rdf:about="http://www.w3.org/ns/dcat#Dataset"/>            
            <owl:Class rdf:about="http://www.w3.org/ns/prov#Activity"/>
            <owl:Class rdf:about="http://www.w3.org/ns/prov#Entity"/>
            <owl:Class rdf:about="http://www.w3.org/ns/prov#SoftwareAgent"/>
            
            <!-- get the software agents -->
            <xsl:for-each select="$sources/srccite/citeinfo/origin[text() !='']">
                <owl:NamedIndividual rdf:about="{fn:concat($schema-base, .)}">
                    <rdf:type rdf:resource="http://www.w3.org/ns/prov#SoftwareAgent"/>
                </owl:NamedIndividual>
            </xsl:for-each>
            
            <!-- and the dataset entities -->
            <xsl:for-each select="$sources">
                <owl:NamedIndividual rdf:about="{fn:concat($schema-base, srccite/citeinfo/title)}">
                    <rdf:type rdf:resource="http://www.w3.org/ns/prov#Entity"/>
                    <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Dataset"/>
                    
                    <xsl:variable name="srccitea" select="srccitea"/>
                    <xsl:variable name="step-for-srcprod">
                        <xsl:call-template name="get-activity">
                            <xsl:with-param name="text" select="$steps[srcprod=$srccitea]/procdesc"/>
                        </xsl:call-template>
                    </xsl:variable>
                   
                    <xsl:if test="$step-for-srcprod">
                        <prov:wasGeneratedBy rdf:resource="{fn:concat($schema-base, $step-for-srcprod, '#', srccite/citeinfo/title)}"/>
                    </xsl:if>
                </owl:NamedIndividual>
            </xsl:for-each>
            
            <!-- add the activities -->
            <xsl:for-each select="$steps">
                <xsl:variable name="activity">
                    <xsl:call-template name="get-activity">
                        <xsl:with-param name="text" select="procdesc"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <owl:NamedIndividual rdf:about="{fn:concat($schema-base, $activity)}">
                    <rdf:type rdf:resource="http://www.w3.org/ns/prov#Activity"/>
                    
                    <xsl:variable name="srcused" select="srcused"/>
                    <xsl:variable name="source" select="$sources[srccitea=$srcused]/srccite/citeinfo"/>
                    
                    <!-- TODO: handle the multiple input datasets for one software agent correctly -->
                    <xsl:for-each select="$source">
                        <!-- dataset -->
                        <prov:used rdf:resource="{fn:concat($schema-base, title)}"/>
                        <!-- software agent -->
                        <prov:wasAssociatedWith rdf:resource="{fn:concat($schema-base, origin)}"/>
                    </xsl:for-each>
                </owl:NamedIndividual>
            </xsl:for-each>
        </rdf:RDF>
    </xsl:template>
    
    <xsl:template name="get-activity">
        <xsl:param name="text" select="()"/>
        <!-- split the processing step text at the | to get the [NAME] -->
        <xsl:value-of select="fn:replace(fn:replace(fn:normalize-space(fn:substring-before($text, '|')), '\[', ''), '\]', '')"/>
    </xsl:template>
    
</xsl:stylesheet>