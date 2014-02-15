<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0" exclude-result-prefixes="fn xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns="http://ontology.cybershare.utep.edu/ELSEWeb/edac/publishing/modis/modis.owl#"
    
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:elseweb-data="http://ontology.cybershare.utep.edu/ELSEWeb/elseweb-data.owl#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:elseweb-edac="http://ontology.cybershare.utep.edu/ELSEWeb/elseweb-edac.owl#"
    >
    
    <!-- removed: xml:base="http://ontology.cybershare.utep.edu/ELSEWeb/edac/publishing/modis/modis.owl" -->
    
    
    <xsl:import href="remove-namespaces.xsl" />
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:param name="schema-base" select="'http://gstore.unm.edu/elseweb/'"/>
    <!-- this is not a long-, medium- or short-term solution. i don't see a reasonable generic structure right now, though. -->
    <xsl:param name="schema-base-data" select="'http://ontology.cybershare.utep.edu/ELSEWeb/elseweb-data.owl'"/>
    <xsl:param name="schema-base-edac" select="'http://ontology.cybershare.utep.edu/ELSEWeb/elseweb-edac.owl'"/>
    <xsl:param name="instance" select="'http://ontology.cybershare.utep.edu/ELSEWeb/edac/publishing/modis/instance/'"/>
    
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
            <!-- NOTE: not sure if this should change according to something -->
            <owl:Ontology rdf:about="http://ontology.cybershare.utep.edu/ELSEWeb/edac/publishing/modis/modis.owl"/>
            
            <!-- and the stupidest xslt to date -->
            <xsl:comment>

      ///////////////////////////////////////////////////////////////////////////////////////
      //
      // Datatypes
      //
      ///////////////////////////////////////////////////////////////////////////////////////

            </xsl:comment>
            
            <rdfs:Datatype rdf:about="http://www.w3.org/2001/XMLSchema/anyURI"/>
            <rdfs:Datatype rdf:about="http://www.w3.org/2001/XMLSchema/dateTime"/>
            
            <xsl:comment>

    ///////////////////////////////////////////////////////////////////////////////////////
    //
    // Object Properties
    //
    ///////////////////////////////////////////////////////////////////////////////////////
            
            </xsl:comment>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#coversRegion')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#coversTimePeriod')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#encodedInFormat')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#encodingOfCharacteristic')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#hasBandIdentification')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#hasDataBand')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#hasEndDate')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#hasGeospatialProjection')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#hasManifestation')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#hasStartDate')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-data, '#representsEntity')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-edac, '#hadInput')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-edac, '#hadInputBandID')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-edac, '#wasAssociatedWith')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-edac, '#wasOutputBy')}"/>
            
            <owl:ObjectProperty rdf:about="{concat($schema-base-edac, '#wasPublishedBy')}"/>
            
            <!-- TODO: replace this with the correct UNITS element from N. -->
            <xsl:comment>temporary solution for the units</xsl:comment>
            <owl:ObjectProperty rdf:about="{concat($schema-base-edac, '#hasUnits')}"/>
            <owl:ObjectProperty rdf:about="{concat($schema-base-edac, '#hasUnitName')}"/>
            
            <xsl:comment>

    ///////////////////////////////////////////////////////////////////////////////////////
    //
    // Data properties
    //
    ///////////////////////////////////////////////////////////////////////////////////////
               
            </xsl:comment>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-data, '#hasBandName')}"/>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-data, '#hasCapabilitiesDocumentURL')}"/>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-data, '#hasDateTime')}"/>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-data, '#hasEPSGCode')}"/>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-data, '#hasFileDownloadURL')}"/>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-data, '#hasLeftLongitude')}"/>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-data, '#hasLowerLatitude')}"/>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-data, '#hasRightLongitude')}"/>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-data, '#hasUpperLatitude')}"/>
            
            <xsl:comment>

    ///////////////////////////////////////////////////////////////////////////////////////
    //
    // Classes
    //
    ///////////////////////////////////////////////////////////////////////////////////////
                
            </xsl:comment>
            
            <owl:Class rdf:about="{concat($schema-base-data, '#BandIdentification')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-data, '#BoxedGeographicRegion')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-data, '#Date')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-data, '#DateRange')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-data, '#FileManifestation')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-data, '#PayloadFormat')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-data, '#Projection')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-data, '#WCSManifestation')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#DatasetManipulationSoftware')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#Download')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#DownloadedMODISDataset')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#ExtractAndReproject')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#ExtractedDataset')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#Index')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#MODISDataset')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#Mosaic')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#MosaicDataset')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#Publish')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#PublishedMODISDataset')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#RGISDataBand')}"/>
            
            <owl:Class rdf:about="{concat($schema-base-edac, '#Vegetation')}"/>
            
            <owl:DatatypeProperty rdf:about="{concat($schema-base-edac, '#getJSONCapabilitiesDigestURL')}"/>
            
            <!-- TODO: replace this with the correct UNITS element from N. -->
            <xsl:comment>temporary solution for the units</xsl:comment>
            <owl:Class rdf:about="{concat($schema-base-edac, '#Units')}"/>
            
            <xsl:comment>
                individuals
            </xsl:comment>
            
            <!-- what is this date? -->
            <owl:NamedIndividual rdf:about="date">
                <rdf:type rdf:resource="{concat($schema-base-data, '#Date')}"/>
                <elseweb-data:hasDateTime rdf:datatype="http://www.w3.org/2001/XMLSchema/dateTime">
                    <xsl:value-of select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/dateStamp/Date"/>
                </elseweb-data:hasDateTime>
            </owl:NamedIndividual>
            
            
            <!-- get the software agents (unique) -->
            <xsl:for-each-group select="$all-steps/LE_ProcessStep/processingInformation/LE_Processing/softwareReference/CI_Citation/title/CharacterString[text() !='']" group-by=".">
                <owl:NamedIndividual rdf:about="{fn:concat($schema-base, .)}">
                    <rdf:type rdf:resource="{concat($schema-base-edac, '#DatasetManipulationSoftware')}"/>
                </owl:NamedIndividual>
            </xsl:for-each-group>
            
            <xsl:comment>wcs modis dataset</xsl:comment>
            <!-- the final output file (wcs representation) -->
            <xsl:variable name="output-uri" select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/dataSetURI/CharacterString"/>
            
            <!-- the last processing step -->
            <xsl:variable name="last-step" select="$all-steps/LE_ProcessStep[source[@role = '#SELF' and LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Produced']]"/>
            
            <!-- final object-type -->
            <xsl:variable name="last-type">
                <xsl:call-template name="get-identifier">
                    <xsl:with-param name="text" select="$last-step/source[@role = '#SELF' and LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Produced']/LI_Source/sourceCitation/CI_Citation/alternateTitle/CharacterString"/>
                </xsl:call-template>
            </xsl:variable>
            
            <!-- output band -->
            <xsl:variable name="output-band-identifier" select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/contentInfo/MD_CoverageDescription/dimension/MD_Band/descriptor/CharacterString"/>
            
            <owl:NamedIndividual rdf:about="{$output-uri}">
                <rdf:type rdf:type="{fn:concat($schema-base-edac, '#', $last-type)}"/>
                <elseweb-data:coversTimePeriod rdf:resource="{fn:concat($instance, 'duration-', $output-uri)}"/>
                <elseweb-data:hasGeospatialProjection rdf:resource="{fn:concat($instance, 'projection-', $output-uri)}"/>
                <!-- so go get the last processing step and its id to use that -->
                <elseweb-edac:wasPublishedBy rdf:resource="{fn:concat($instance, $all-steps[last()]/LE_ProcessStep/@id)}"/>
                
                <elseweb-data:coversRegion rdf:resource="{fn:concat($instance, 'region-', $output-uri)}"/>
                <elseweb-data:hasUnits rdf:resource="{fn:concat($instance, 'units-', $output-uri)}"/>
                <elseweb-data:hasManifestation rdf:resource="{fn:concat($instance, 'wcs-modis-manifestion-', $output-uri)}"/>
                
                <xsl:if test="$output-band-identifier">
                    <elseweb-data:hasDataBand rdf:resource="{fn:concat($instance, 'band-', $output-uri)}"/>
                </xsl:if>
            </owl:NamedIndividual>
            
            <xsl:comment>the wcs</xsl:comment>
            <!-- coversTimePeriod -->
            <owl:NamedIndividual rdf:about="{fn:concat($instance, 'duration-', $output-uri)}">
                <rdf:type rdf:type="{fn:concat($schema-base-data, '#DateRange')}"/>
                <elseweb-data:hasEndDate rdf:resource="{fn:concat($instance, 'date-1')}"/>
                <elseweb-data:hasStartDate rdf:resource="{fn:concat($instance, 'date-2')}"/>
            </owl:NamedIndividual>
            <!-- hasGeospatialProjection -->
            <xsl:comment>
                this is somewhat problematic in iso, particularly for utm (here), where you can't identify the datum vs the projection.
                also can't really always be sure it's epsg rather than esri, etc
            </xsl:comment>
            <owl:NamedIndividual rdf:about="{fn:concat($instance, 'projection-', $output-uri)}">
                <rdf:type rdf:type="{fn:concat($schema-base-data, '#Projection')}"/>
                <elseweb-data:hasEPSGCode rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">
                    <xsl:value-of select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/referenceSystemInfo/MD_ReferenceSystem/referenceSystemIdentifier/RS_Identifier/code/CharacterString"/>
                </elseweb-data:hasEPSGCode>
            </owl:NamedIndividual>
            <!-- coversRegion -->
            <owl:NamedIndividual rdf:about="{fn:concat($instance, 'region-', $output-uri)}">
                <rdf:type rdf:type="{fn:concat($schema-base-data, '#BoxedGeographicRegion')}"/>
                <elseweb-data:hasRightLongitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
                    <xsl:value-of select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/eastBoundLongitude/Decimal"/>
                </elseweb-data:hasRightLongitude>
                <elseweb-data:hasLeftLongitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
                    <xsl:value-of select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/westBoundLongitude/Decimal"/>
                </elseweb-data:hasLeftLongitude>
                <elseweb-data:hasLowerLatitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
                    <xsl:value-of select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/southBoundLatitude/Decimal"/>
                </elseweb-data:hasLowerLatitude>
                <elseweb-data:hasUpperLatitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
                    <xsl:value-of select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/northBoundLatitude/Decimal"/>
                </elseweb-data:hasUpperLatitude>
            </owl:NamedIndividual>
            <!-- hasManifestation -->
            <owl:NamedIndividual rdf:about="{fn:concat($instance, 'wcs-modis-manifestion-', $output-uri)}">
                <rdf:type rdf:type="{fn:concat($schema-base-data, '#WCSManifestation')}"/>
                <elseweb-data:hasCapabilitiesDocumentURL rdf:datatype="http://www.w3.org/2001/XMLSchema/anyURI">
                    <xsl:value-of select="fn:concat('http://gstore.unm.edu/apps/epscor/datasets/', $output-uri, '/services/ogc/wcs?SERVICE=wcs&amp;REQUEST=GetCapabilities&amp;VERSION=1.1.2')"/>
                </elseweb-data:hasCapabilitiesDocumentURL>
                <elseweb-edac:GetJSONCapabilitiesDigest rdf:datatype="http://www.w3.org/2001/XMLSchema/anyURI">
                    <xsl:value-of select="fn:concat('http://gstore.unm.edu/apps/epscor/datasets/', $output-uri, '/services.json')"/>
                </elseweb-edac:GetJSONCapabilitiesDigest>
            </owl:NamedIndividual>
            
            <!-- hasDataBand -->
            <xsl:if test="$output-band-identifier">
                <owl:NamedIndividual rdf:about="{fn:concat($instance, 'band-', $output-uri)}">
                    <rdf:type rdf:resource="{fn:concat($schema-base-edac, '#RGISDataBand')}"/>
                    <elseweb-data:encodingOfCharacteristic rdf:resource="{fn:concat($instance, 'characteristic-', $output-uri)}"/>
                    <elseweb-data:hasBandIdentification rdf:resource="{fn:concat($instance, 'bandid-', $output-uri)}"/>
                    <elseweb-data:representsEntity rdf:resource="{fn:concat($instance, 'entity-', $output-uri)}"/>
                </owl:NamedIndividual>
                
                <owl:NamedIndividual rdf:about="{fn:concat($instance, 'bandid-', $output-uri)}">
                    <rdf:type rdf:resource="{fn:concat($schema-base-edac, '#BandIdentification')}"/>
                    <elseweb-data:hasBandName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
                        <xsl:value-of select="$output-band-identifier"/>
                    </elseweb-data:hasBandName>
                </owl:NamedIndividual>
                
                <owl:NamedIndividual rdf:about="{fn:concat($instance, 'entity-', $output-uri)}">
                    <xsl:variable name="entity-type" select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/identificationInfo/MD_DataIdentification/descriptiveKeywords/MD_Keywords[thesaurusName/CI_Citation/title/CharacterString = 'OBOE']/keyword[1]/CharacterString"/>
                    <rdf:type rdf:resource="{fn:concat($schema-base-edac, '#', $entity-type)}"/>
                </owl:NamedIndividual>
                
                <!-- punting to some default? -->
                <owl:NamedIndividual rdf:about="{fn:concat($instance, 'characteristic-', $output-uri)}">
                    <rdf:type rdf:resource="http://ontology.cybershare.utep.edu/ELSEWeb/elseweb-edac.owl#Index"/>
                </owl:NamedIndividual>
            </xsl:if>
            
            <!-- the units -->
            
            <owl:NamedIndividual rdf:about="{fn:concat($instance, 'units-', $output-uri)}">
                <rdf:type rdf:resource="{fn:concat($schema-base-edac, '#Units')}"/>
                <elseweb-data:hasUnitName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
                    <xsl:value-of select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/contentInfo/MD_CoverageDescription/dimension/MD_Band/units/UnitDefinition/name"/>
                </elseweb-data:hasUnitName>
            </owl:NamedIndividual>
            
            <!-- the wcs modis date range -->
            <owl:NamedIndividual rdf:about="{fn:concat($instance, 'date-1')}">
                <rdf:type rdf:type="{fn:concat($schema-base-data, '#Date')}"/>
                <elseweb-data:hasDateTime rdf:datatype="http://www.w3.org/2001/XMLSchema/dateTime">
                    <xsl:value-of select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/endPosition"/>
                </elseweb-data:hasDateTime>
            </owl:NamedIndividual>
            <owl:NamedIndividual rdf:about="{fn:concat($instance, 'date-2')}">
                <rdf:type rdf:type="{fn:concat($schema-base-data, '#Date')}"/>
                <elseweb-data:hasDateTime rdf:datatype="http://www.w3.org/2001/XMLSchema/dateTime">
                    <xsl:value-of select="$cleaned/DS_Series/seriesMetadata/MI_Metadata/identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/beginPosition"/>
                </elseweb-data:hasDateTime>
            </owl:NamedIndividual>

            <!-- 
            
            what's left:
            
            three modis hdf5 access points from nasa
                nasa-hdf-1
                nasa-hdf-2
                nasa-hdf-3
            three local files
                local-hdf-1
                local-hdf-2
                local-hdf-3
            extract/reproject three bands
                local-band-1
                local-band-2
                local-band-3
            mosaic three bands
                local-mosaic
            publish mosaic
                wcs-thing
            -->
            
            <xsl:comment>
                all of the entities
            </xsl:comment>
            
            <xsl:for-each select="$all-sources">
                <xsl:variable name="source-id" select="@id"/>
                
                <xsl:variable name="url-manifestation" select="identificationInfo/MD_DataIdentification/citation/CI_Citation/citedResponsibleParty/CI_ResponsibleParty/contactInfo/CI_Contact/onlineResource/CI_OnlineResource/linkage/URL"/>
                <xsl:variable name="file-manifestation" select="identificationInfo/MD_DataIdentification/citation/CI_Citation/title/CharacterString"/>
                
                <xsl:variable name="generated-by">
                    <!-- i.e. is it in a step with "Source Produced" -->
                    <xsl:value-of select="$all-steps/LE_ProcessStep[source[@role=concat('#', $source-id) and LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Produced']]/@id"/>
                </xsl:variable>
                
                <!-- check for a band identifier -->
                <xsl:variable name="band-identifier" select="contentInfo/MD_CoverageDescription/dimension/MD_Band/descriptor/CharacterString"/>
                
                <!-- and the units -->
                <xsl:variable name="units-identifier" select="contentInfo/MD_CoverageDescription/dimension/MD_Band/units/UnitDefinition/name"/>
                
                <!-- get the type of object from the alternative name string -->
                <xsl:variable name="object-type">
                    <xsl:choose>
                        <!-- produced by some intermediate step -->
                        <xsl:when test="$generated-by != ''">
                            <xsl:call-template name="get-identifier">
                                <xsl:with-param name="text" select="$all-steps/LE_ProcessStep[source[@role=concat('#', $source-id) and LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Produced']]/source[LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Produced']/LI_Source/sourceCitation/CI_Citation/alternateTitle/CharacterString"/>
                            </xsl:call-template>
                        </xsl:when>
                        
                        <!-- not produced by a step, but used by a step (i.e. and initial object) -->
                        <xsl:when test="$generated-by = '' and $all-steps/LE_ProcessStep[source[@role=concat('#', $source-id) and LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Used']]">
                            <xsl:call-template name="get-identifier">
                                <xsl:with-param name="text" select="$all-steps/LE_ProcessStep[source[@role=concat('#', $source-id) and LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Used']]/source[LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Used']/LI_Source/sourceCitation/CI_Citation/alternateTitle/CharacterString"/>
                            </xsl:call-template>
                        </xsl:when>
                        
                        <!-- no idea where it came from but we need something -->
                        <xsl:otherwise>
                            <xsl:value-of select="'Dataset'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <owl:NamedIndividual rdf:about="{@id}">
                    <rdf:type rdf:resource="{fn:concat($schema-base-edac, '#Dataset')}"/>
                    <elseweb-data:coversTimePeriod rdf:resource="{fn:concat($instance, 'duration-', $source-id)}"/>
                    <elseweb-data:hasGeospatialProjection rdf:resource="{fn:concat($instance, 'projection-', $source-id)}"/>
                    <!--<elseweb-edac:wasPublishedBy rdf:resource="{fn:concat($instance, 'publish-', $source-id)}"/>-->
                    <elseweb-data:coversRegion rdf:resource="{fn:concat($instance, 'region-', $source-id)}"/>
                    <xsl:if test="$file-manifestation or $url-manifestation">
                        <elseweb-data:hasManifestation rdf:resource="{fn:concat($instance, 'manifestion-', $source-id)}"/>
                    </xsl:if>
                    
                    <xsl:if test="$generated-by != ''">
                        <elseweb-edac:wasOutputBy rdf:resource="{fn:concat($instance, $generated-by)}"/>
                    </xsl:if>
                    
                    <xsl:if test="$units-identifier">
                        <elseweb-edac:hasUnits rdf:resource="{fn:concat($instance, 'units-', $source-id)}"/>
                    </xsl:if>
                    
                    <xsl:if test="$band-identifier">
                        <elseweb-edac:hasDataBand rdf:resource="{fn:concat($instance, 'band-', $source-id)}"/>
                    </xsl:if>
                    
                </owl:NamedIndividual>
                
                <!-- the manifestation if there is one? also the logic is wrong but who cares today -->
                <xsl:if test="$file-manifestation">
                    <owl:NamedIndividual rdf:about="{fn:concat($instance, 'manifestion-', $source-id)}">
                        <rdf:type rdf:resource="{fn:concat($schema-base-data, '#FileManifestation')}"/>
                        <xsl:if test="$url-manifestation">
                            <elseweb-data:hasFileDownloadURL rdf:datatype="http://www.w3.org/2001/XMLSchema/anyURI">
                                <xsl:value-of select="$url-manifestation"/>
                            </elseweb-data:hasFileDownloadURL>
                        </xsl:if>
                        <elseweb-data:encodedInFormat rdf:resource="{fn:concat($schema-base-data, '#', identificationInfo/MD_DataIdentification/resourceFormat/MD_Format/name/CharacterString)}"/>
                    </owl:NamedIndividual>
                </xsl:if>
                
                <!-- the data band -->
                <!-- TODO: handle mutliple bands?????? maybe not - that would actually be building a different dataset -->
                <xsl:if test="$band-identifier">
                    <owl:NamedIndividual rdf:about="{fn:concat($instance, 'band-', $source-id)}">
                        <rdf:type rdf:resource="{fn:concat($schema-base-edac, '#DataBand')}"/>
                        <elseweb-data:encodingOfCharacteristic rdf:resource="{fn:concat($instance, 'characteristic-', $source-id)}"/>
                        <elseweb-data:hasBandIdentification rdf:resource="{fn:concat($instance, 'bandid-', $source-id)}"/>
                        <elseweb-data:representsEntity rdf:resource="{fn:concat($instance, 'entity-', $source-id)}"/>
                    </owl:NamedIndividual>
                    
                    <owl:NamedIndividual rdf:about="{fn:concat($instance, 'bandid-', $source-id)}">
                        <rdf:type rdf:resource="{fn:concat($schema-base-edac, '#BandIdentification')}"/>
                        <elseweb-data:hasBandName rdf:datatype="http://www.w3.org/2001/XMLSchema#string">
                            <xsl:value-of select="$band-identifier"/>
                        </elseweb-data:hasBandName>
                    </owl:NamedIndividual>
                    
                    <xsl:comment>
                        this is also maybe tricky if we are relying on the keywords (and we still are)
                    </xsl:comment>
                    <owl:NamedIndividual rdf:about="{fn:concat($instance, 'entity-', $source-id)}">
                        <xsl:variable name="entity-type" select="identificationInfo/MD_DataIdentification/descriptiveKeywords/MD_Keywords[thesaurusName/CI_Citation/title/CharacterString = 'OBOE']/keyword[1]/CharacterString"/>
                        <rdf:type rdf:resource="{fn:concat($schema-base-edac, '#', $entity-type)}"/>
                    </owl:NamedIndividual>
                    
                    <!-- punting to some default? -->
                    <owl:NamedIndividual rdf:about="{fn:concat($instance, 'characteristic-', $source-id)}">
                        <rdf:type rdf:resource="http://ontology.cybershare.utep.edu/ELSEWeb/elseweb-edac.owl#Index"/>
                    </owl:NamedIndividual>
                </xsl:if>
                
                <!-- its region -->
                <owl:NamedIndividual rdf:about="{fn:concat($instance, 'region-', $source-id)}">
                    <rdf:type rdf:type="{fn:concat($schema-base-data, '#BoxedGeographicRegion')}"/>
                    <elseweb-data:hasRightLongitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
                        <xsl:value-of select="identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/eastBoundLongitude/Decimal"/>
                    </elseweb-data:hasRightLongitude>
                    <elseweb-data:hasLeftLongitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
                        <xsl:value-of select="identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/westBoundLongitude/Decimal"/>
                    </elseweb-data:hasLeftLongitude>
                    <elseweb-data:hasLowerLatitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
                        <xsl:value-of select="identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/southBoundLatitude/Decimal"/>
                    </elseweb-data:hasLowerLatitude>
                    <elseweb-data:hasUpperLatitude rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">
                        <xsl:value-of select="identificationInfo/MD_DataIdentification/extent/EX_Extent/geographicElement/EX_GeographicBoundingBox/northBoundLatitude/Decimal"/>
                    </elseweb-data:hasUpperLatitude>
                </owl:NamedIndividual>
                
                <!-- its dates -->
                <owl:NamedIndividual rdf:about="{fn:concat($instance, 'begdate-', $source-id)}">
                    <rdf:type rdf:type="{fn:concat($schema-base-data, '#Date')}"/>
                    <elseweb-data:hasDateTime rdf:datatype="http://www.w3.org/2001/XMLSchema/dateTime">
                        <xsl:value-of select="identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/beginPosition"/>
                    </elseweb-data:hasDateTime>
                </owl:NamedIndividual>
                <owl:NamedIndividual rdf:about="{fn:concat($instance, 'enddate-', $source-id)}">
                    <rdf:type rdf:type="{fn:concat($schema-base-data, '#Date')}"/>
                    <elseweb-data:hasDateTime rdf:datatype="http://www.w3.org/2001/XMLSchema/dateTime">
                        <xsl:value-of select="identificationInfo/MD_DataIdentification/extent/EX_Extent/temporalElement/EX_TemporalExtent/extent/TimePeriod/endPosition"/>
                    </elseweb-data:hasDateTime>
                </owl:NamedIndividual>
                
                <!-- its time period -->
                <owl:NamedIndividual rdf:about="{fn:concat($instance, 'duration-', $source-id)}">
                    <rdf:type rdf:type="{fn:concat($schema-base-data, '#DateRange')}"/>
                    <elseweb-data:hasEndDate rdf:resource="{fn:concat($instance, 'enddate-', $source-id)}"/>
                    <elseweb-data:hasStartDate rdf:resource="{fn:concat($instance, 'begdate-', $source-id)}"/>
                </owl:NamedIndividual>
                
                <!-- its proj -->
                <owl:NamedIndividual rdf:about="{fn:concat($instance, 'projection-', $source-id)}">
                    <rdf:type rdf:type="{fn:concat($schema-base-data, '#Projection')}"/>
                    <elseweb-data:hasEPSGCode rdf:datatype="http://www.w3.org/2001/XMLSchema#integer">
                        <xsl:value-of select="referenceSystemInfo/MD_ReferenceSystem/referenceSystemIdentifier/RS_Identifier/code/CharacterString"/>
                    </elseweb-data:hasEPSGCode>
                </owl:NamedIndividual>
            </xsl:for-each>
            
            <xsl:comment>
                all of the activities
            </xsl:comment>
            
            <!-- about = unique id for that instance of the activity, type = the activity type -->
            <xsl:for-each select="$all-steps">
                <owl:NamedIndividual rdf:about="{fn:concat($instance, LE_ProcessStep/@id)}">
                    <!-- get the thing from the other thing -->
                    <xsl:variable name="step-name">
                        <xsl:call-template name="get-identifier">
                            <xsl:with-param name="text" select="LE_ProcessStep/description/CharacterString"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <rdf:type rdf:resource="{fn:concat($schema-base-edac, '#', $step-name)}"/>
                    <elseweb-edac:wasAssociatedWith rdf:resource="{fn:concat($schema-base, LE_ProcessStep/processingInformation/LE_Processing/softwareReference/CI_Citation/title/CharacterString)}"/>
                    
                    <!-- any input data objects -->
                    <xsl:for-each select="LE_ProcessStep/source[LI_Source/sourceCitation/CI_Citation/title/CharacterString = 'Source Used']">
                        <xsl:variable name="role" select="fn:translate(@role, '#', '')"/>
                        <elseweb-edac:hadInput rdf:resource="{$role}"/>
                        
                        <!-- add the input band if there is one -->
                        <xsl:variable name="used" select="$all-sources[@id = $role]"/>
                        <xsl:if test="$used/contentInfo/MD_CoverageDescription/dimension/MD_Band/descriptor/CharacterString">
                            <elseweb-edac:hadInputBandID rdf:resource="{fn:concat($instance, 'bandid-', $used/@id)}"/>
                        </xsl:if>
                    </xsl:for-each>
                    
                </owl:NamedIndividual>
            </xsl:for-each>
        </rdf:RDF>
    </xsl:template>
    
    <xsl:template name="get-identifier">
        <xsl:param name="text" select="()"/>
        <!-- split the processing step text at the | to get the [NAME] -->
        <xsl:value-of select="fn:replace(fn:replace(fn:normalize-space(fn:substring-before($text, '|')), '\[', ''), '\]', '')"/>
    </xsl:template>
    
</xsl:stylesheet>