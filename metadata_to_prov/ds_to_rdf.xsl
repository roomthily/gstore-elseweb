<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" exclude-result-prefixes="fn xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://gstore.unm.edu/elseweb"
    
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    >
    <xsl:import href="remove-namespaces.xsl" />
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="schema-base" select="'http://gstore.unm.edu/elseweb/'"/>
    
    <!-- strip out the iso namespaces. just makes it easier to read. -->
    <xsl:variable name="cleaned">
        <xsl:call-template name="remove"/>
    </xsl:variable>
    
    <!-- 
    take the lineage (sources + steps) with a few assumptions about the values in it
    and generate some prov
    -->
    
    <xsl:variable name="all-sources" select="$cleaned/DS_Series/composedOf/DS_DataSet/has/MD_Metadata"/> 
    <xsl:variable name="all-steps" select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/dataQualityInfo/DQ_DataQuality/lineage/LI_Lineage/processStep"/> 
    
    <xsl:template match="/">
        <rdf:RDF>
            <owl:Ontology rdf:about="{$schema-base}"/>
            
            <owl:ObjectProperty rdf:about="http://www.w3.org/ns/prov#used"/>
            <owl:ObjectProperty rdf:about="http://www.w3.org/ns/prov#wasAssociatedWith"/>
            <owl:ObjectProperty rdf:about="http://www.w3.org/ns/prov#wasGeneratedBy"/>
            
            <owl:Class rdf:about="http://www.w3.org/ns/dcat#Dataset"/>            
            <owl:Class rdf:about="http://www.w3.org/ns/prov#Activity"/>
            <owl:Class rdf:about="http://www.w3.org/ns/prov#Entity"/>
            <owl:Class rdf:about="http://www.w3.org/ns/prov#SoftwareAgent"/>
            
            <!-- get the software agents (unique) -->
            <xsl:for-each-group select="$all-steps/LE_ProcessStep/processingInformation/LE_Processing/softwareReference/CI_Citation/title/CharacterString[text() !='']" group-by=".">
                <owl:NamedIndividual rdf:about="{fn:concat($schema-base, .)}">
                    <rdf:type rdf:resource="http://www.w3.org/ns/prov#SoftwareAgent"/>
                </owl:NamedIndividual>
            </xsl:for-each-group>
            
            <!-- and the dataset entities -->
            <xsl:for-each select="$all-sources">
                <owl:NamedIndividual rdf:about="{fn:concat($schema-base, identificationInfo/MD_DataIdentification/citation/CI_Citation/title/CharacterString)}">
                    <rdf:type rdf:resource="http://www.w3.org/ns/prov#Entity"/>
                    <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Dataset"/>
                    
                    <!-- source with xlink role = id and description = source produced -->
                    <xsl:variable name="src-id" select="@id"/>
                    <xsl:variable name="step-for-srcprod" >
                        <xsl:call-template name="get-activity">
                            <xsl:with-param name="text" select="$all-steps/LE_ProcessStep[source[@role=fn:concat('#',$src-id) and LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Produced']]/description/CharacterString"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <!-- <prov:wasGeneratedBy rdf:resource="{fn:concat($schema-base, $step-for-srcprod, '#', LI_Source/sourceCitation/CI_Citation/title/CharacterString)}"/>-->
                    <xsl:if test="$step-for-srcprod">
                        <prov:wasGeneratedBy rdf:resource="{fn:concat($schema-base, $step-for-srcprod)}"/>
                    </xsl:if>
                </owl:NamedIndividual>
            </xsl:for-each>
            
            <!-- add the activities -->
            <xsl:for-each select="$all-steps">
                <xsl:variable name="activity">
                    <xsl:call-template name="get-activity">
                        <xsl:with-param name="text" select="LE_ProcessStep/description/CharacterString"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <owl:NamedIndividual rdf:about="{fn:concat($schema-base, $activity)}">
                    <rdf:type rdf:resource="http://www.w3.org/ns/prov#Activity"/>
                    
                    <xsl:variable name="srcused" select="LE_ProcessStep/source[LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Used']"/>
                    <xsl:variable name="source" select="$all-sources[MD_Metadata[fn:concat('#', @id)=$srcused/@role]]"/>
                    
                    <xsl:variable name="software-agent" select="LE_ProcessStep/processingInformation/LE_Processing/softwareReference/CI_Citation/title/CharacterString"/>
                    
                    <!-- TODO: handle the multiple input datasets for one software agent correctly -->
                    <xsl:for-each select="$source">
                        <!-- dataset -->
                        <prov:used rdf:resource="{fn:concat($schema-base, LI_Source/sourceCitation/CI_Citation/title/CharacterString)}"/>
                        <!-- software agent -->
                        <prov:wasAssociatedWith rdf:resource="{fn:concat($schema-base, $software-agent)}"/>
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