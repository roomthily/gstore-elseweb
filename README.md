#gstore-elseweb

PROV examples for GSTORE datasets made available through the ELSEWeb project. 

The XSLTs are limited to very basic PROV traces, effectively Dataset-Activity-Dataset where Activity can have a piece of software associated with it. They also assume a specific structure that may not be appropriate for general use documentation although it is still valid.

Datasets (entities) are defined in the srcinfo or source elements; Activities are defined by the procstep or processStep elements. The transforms currently support *used*, *wasGeneratedBy* and *wasAssociatedWith* prov elements.

##FGDC Lineage to PROV

Uses lineage_to_rdf.xsl.

###XML Structure

```xml
<lineage>
    <srcinfo>
        <srccite>
            <citeinfo>
                <origin></origin>
                <pubdate>20131212</pubdate>
                <title>InitialDataSet.tif</title>
            </citeinfo>
        </srccite>
        <typesrc></typsrc>
        <srctime>
            <timeinfo>
                <sngdate>
                    <caldate>20131212</caldate>
                </sngdate>
            </timeinfo>
            <srccurr>Unknown</srccurr>
        </srctime>
        <scrcitea>InputDataset</srccitea>
        <srccontr>None</srccontr>
    </srcinfo>
    <srcinfo>
        <srccite>
            <citeinfo>
                <origin>gdal_translate</origin>
                <pubdate>20131212</pubdate>
                <title>ReprojectedDataSet.tif</title>
            </citeinfo>
        </srccite>
        <typesrc></typsrc>
        <srctime>
            <timeinfo>
                <sngdate>
                    <caldate>20131212</caldate>
                </sngdate>
            </timeinfo>
            <srccurr>Unknown</srccurr>
        </srctime>
        <scrcitea>OutputDataset</srccitea>
        <srccontr>None</srccontr>
    </srcinfo>
    <procstep>
        <procdesc>[Reproject] | Reprojected GeoTiff from WGS84 to UTM 13N using gdal_translate.</procdesc>
        <srcused>InputDataset</srcused>
        <procdate>20131212</procdate>
        <srcprod>OutputDataset</srcprod>
    </procstep>
</lineage>
```

The Dataset identifier is the source citation's title. The SoftwareAgent identifier is the source citation's origin. This element can be left blank. The Activity identifier is found in the processing step's description element (procdesc) as \[\{activity identifier\}\] | \{standard process description\}. 

The processing step's srcused element is used in the activity's *used* element. The srcprod is used in the related dataset's *wasGeneratedBy* element. And the srcprod source's origin is used as the activity's *wasAssociatedWith* element. Multiple srcused elements are supported.

The transform contains a parameter to define the ontology for the entities. The concatentation of this parameter and an identifier is used for the *about* and *resource* URIs. 

##ISO Lineage to PROV

Uses iso_lineage_to_rdf.xsl.


###XML Structure

This follows a similar pattern to the FGDC structure; however, the Source Used/Source Produced connections are a little tenuous. As in, there isn't a well-defined location to map FGDC's srcused or srcprod to ISO while maintaining the input -> step -> output order. 

Note that this uses the Lineage-Extended schema (gmi:LE_ProcessStep) and not the basic Lineage schema (gmd:LI_ProcessStep). For those playing along at home, the [CSDGM to ISO 19115 transformation](https://github.com/edac/metadata) does not use the LE_ProcessStep structure, but this does carry over some of the assumptions made in that transform.

```xml
<gmd:dataQualityInfo>
    <gmd:DQ_DataQuality>
        <gmd:lineage>
            <gmd:LI_Lineage>
                <gmd:processStep>
                    <gmi:LE_ProcessStep>
                        <gmd:description>
                            <gco:CharacterString>[Reproject] | Reprojected GeoTiff from WGS84 to UTM 13N using gdal_translate.</gco:CharacterString>
                        </gmd:description>
                        <gmd:dateTime>
                            <gco:DateTime>2013-12-12T00:00:00</gco:DateTime>
                        </gmd:dateTime>
                        <gmd:source xlink:role="#InputDataset">
                            <gmd:LI_Source>
                                <gmd:sourceCitation>
                                    <gmd:CI_Citation>
                                        <gmd:title>
                                            <gco:CharacterString>Source Used</gco:CharacterString>
                                        </gmd:title>
                                        <gmd:alternateTitle>
                                            <gco:CharacterString>the input dataset</gco:CharacterString>
                                        </gmd:alternateTitle>
                                        <gmd:date gco:nilReason="unknown"/>
                                    </gmd:CI_Citation>
                                </gmd:sourceCitation>
                            </gmd:LI_Source>
                        </gmd:source>
                        <gmd:source xlink:role="#OutputDataset">
                            <gmd:LI_Source>
                                <gmd:sourceCitation>
                                    <gmd:CI_Citation>
                                        <gmd:title>
                                            <gco:CharacterString>Source Produced</gco:CharacterString>
                                        </gmd:title>
                                        <gmd:alternateTitle>
                                            <gco:CharacterString>the output dataset</gco:CharacterString>
                                        </gmd:alternateTitle>
                                        <gmd:date gco:nilReason="unknown"/>
                                    </gmd:CI_Citation>
                                </gmd:sourceCitation>
                            </gmd:LI_Source>
                        </gmd:source>
                        <gmi:processingInformation>
                            <gmi:LE_Processing>
                                <gmi:identifier></gmi:identifier>
                                <gmi:softwareReference>
                                    <gmd:CI_Citation>
                                        <gmd:title>
                                            <gco:CharacterString>gdal_translate</gco:CharacterString>
                                        </gmd:title>
                                        <gmd:date gco:nilReason="unknown"/>
                                    </gmd:CI_Citation>
                                </gmi:softwareReference>
                            </gmi:LE_Processing>
                        </gmi:processingInformation>
                    </gmi:LE_ProcessStep>
                </gmd:processStep>
                <gmd:source>
                    <gmd:LI_Source id="InputDataset">
                        <gmd:description>
                            <gco:CharacterString></gco:CharacterString>
                        </gmd:description>
                        <gmd:sourceCitation>
                            <gmd:CI_Citation>
                                <gmd:title>
                                    <gco:CharacterString>InitialDataSet.tif</gco:CharacterString>
                                </gmd:title>
                                <gmd:date>
                                    <gmd:CI_Date>
                                        <gmd:date>
                                            <gco:Date>2013-12-12</gco:Date>
                                        </gmd:date>
                                        <gmd:dateType>
                                            <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                         codeListValue="publication"/>
                                        </gmd:dateType>
                                    </gmd:CI_Date>
                                </gmd:date>
                            </gmd:CI_Citation>
                        </gmd:sourceCitation>
                    </gmd:LI_Source>
                </gmd:source>
                <gmd:source>
                    <gmd:LI_Source id="OutputDataset">
                        <gmd:description>
                            <gco:CharacterString></gco:CharacterString>
                        </gmd:description>
                        <gmd:sourceCitation>
                            <gmd:CI_Citation>
                                <gmd:title>
                                    <gco:CharacterString>ReprojectedDataSet.tif</gco:CharacterString>
                                </gmd:title>
                                <gmd:date>
                                    <gmd:CI_Date>
                                        <gmd:date>
                                            <gco:Date>2013-12-12</gco:Date>
                                        </gmd:date>
                                        <gmd:dateType>
                                            <gmd:CI_DateTypeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                         codeListValue="publication"/>
                                        </gmd:dateType>
                                    </gmd:CI_Date>
                                </gmd:date>
                            </gmd:CI_Citation>
                        </gmd:sourceCitation>
                    </gmd:LI_Source>
                </gmd:source>
            </gmd:LI_Lineage>
        </gmd:lineage>
    </gmd:DQ_DataQuality>
</gmd:dataQualityInfo>
```

The Dataset identifier is the source citation's title. Note that this is not from the processing step's embedded source elements. The SoftwareAgent identifier is the processing step's software reference title. The Activity identifier is found in the processing step's description element as \[\{activity identifier\}\] | \{standard process description\}. 

The trace relies on the processing step's embedded source elements to identify the order (input vs. output) and the source definition (lineage sources as opposed to the embedded sources). The input dataset is identified through the @role reference for embedded sources with 'Source Used' as the title. The output dataset is identified through the @role reference for embedded sources with 'Source Produced' as the title.

The processing step's input source is used in the activity's *used* element. The output source is used in the related dataset's *wasGeneratedBy* element. And the software reference is used as the activity's *wasAssociatedWith* element. Multiple input source elements are supported.

The transform contains a parameter to define the ontology for the entities. The concatentation of this parameter and an identifier is used for the *about* and *resource* URIs.  

##Expected PROV Output 

This applies to both examples. As with all things PROV and ISO-19115, the "correct" structure is in the eye of the beholder. 

```xml
<rdf:RDF xmlns="http://a.schema.com/schema/"
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
    xmlns:prov="http://www.w3.org/ns/prov#"
    xmlns:owl="http://www.w3.org/2002/07/owl#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">

    <owl:Ontology rdf:about="http://a.schema.com/schema/"/>
    
    <owl:ObjectProperty rdf:about="http://www.w3.org/ns/prov#used"/>
    <owl:ObjectProperty rdf:about="http://www.w3.org/ns/prov#wasAssociatedWith"/>
    <owl:ObjectProperty rdf:about="http://www.w3.org/ns/prov#wasGeneratedBy"/>
    
    <owl:Class rdf:about="http://www.w3.org/ns/dcat#Dataset"/>
    <owl:Class rdf:about="http://www.w3.org/ns/prov#Activity"/>
    <owl:Class rdf:about="http://www.w3.org/ns/prov#Entity"/>
    <owl:Class rdf:about="http://www.w3.org/ns/prov#SoftwareAgent"/>

    <!-- SOFTWARE AGENTS -->
    <owl:NamedIndividual rdf:about="http://a.schema.com/schema/gdal_translate">
        <rdf:type rdf:resource="http://www.w3.org/ns/prov#SoftwareAgent"/>
    </owl:NamedIndividual>

    <!-- DATASETS -->
    <owl:NamedIndividual rdf:about="http://a.schema.com/schema/InputDataset.tif">
        <rdf:type rdf:resource="http://www.w3.org/ns/prov#Entity"/>
        <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Dataset"/>
    </owl:NamedIndividual>
    
    <owl:NamedIndividual rdf:about="http://a.schema.com/schema/OutputDataset.tif">
        <rdf:type rdf:resource="http://www.w3.org/ns/prov#Entity"/>
        <rdf:type rdf:resource="http://www.w3.org/ns/dcat#Dataset"/>
        <prov:wasGeneratedBy rdf:resource="http://a.schema.com/schema/Reproject"/>
    </owl:NamedIndividual>

    <!-- ACTIVITIES -->
    <owl:NamedIndividual rdf:about="http://a.schema.com/schema/Reproject">
        <rdf:type rdf:resource="http://www.w3.org/ns/prov#Activity"/>
        <prov:used rdf:resource="http://a.schema.com/schema/InputDataset.tif"/>
        <prov:wasAssociatedWith rdf:resource="http://a.schema.com/schema/gdal_translate"/>
    </owl:NamedIndividual>
    
</rdf:RDF>
```




