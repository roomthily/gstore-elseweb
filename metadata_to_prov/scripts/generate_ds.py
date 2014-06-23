import os
import json
import glob
from string import Template
from lxml import etree


'''
generate dataseries xml using pre-built json files.

note: the json should have the values necessary
    for whichever ontology is to be used. this has no logic
    for ontology-specific modifications (nor do the
    templates).

process:
    load the templates

    grab any *.json files

    for each json, start compiling the xml components
        until the final ds is built

    strip out any comments from the ds

    save to disk
'''

JSON_DIR = 'jsons'
OUTPUT_DIR = 'ds'


'''
$unique_md_id
$filename
$spatial_reference
$pubdate
$manifestation
$additional_identifier_code
$provider
$external_link
$provider_role
$file_type
$file_type_version
$parameter
$westbc, $eastbc, $northbc, $southbc
$timeextent_unique_id
$start_date, $end_date
$band_identification
'''
with open('../templates/ds_to_prov_md_template.xml', 'r') as f:  
    MD_TEMPLATE = Template(f.read())

'''
$spref_name
$spref_url
$spref_epsg
'''
with open('../templates/ds_to_prov_spref_template.xml', 'r') as f:
    SPREF_TEMPLATE = Template(f.read())

'''
$provider: output of the provider template
$external_link: output of the external link template
$provider_role: output of the provider role template
'''
with open('../templates/ds_to_prov_citedparty_template.xml', 'r') as f:
    CITED_PARTY_TEMPLATE = Template(f.read())

'''
$provider: name of the organization if the data source is external source
'''
with open('../templates/ds_to_prov_provider_template.xml', 'r') as f:
    PROVIDER_TEMPLATE = Template(f.read())  

'''
$role_code: if provider, include a valid role code from the ISO CI_RoleCode codelist
'''    
with open('../templates/ds_to_prov_providerrole_template.xml', 'r') as f:
    PROVIDER_ROLE_TEMPLATE = Template(f.read())  

'''
$external_link: URL to the actual external data source
'''
with open('../templates/ds_to_prov_externallink_template.xml', 'r') as f:
    LINK_TEMPLATE = Template(f.read())  

'''
$band_name: name of the raster band
$band_unique_id: unique identifer (start with [a-z]) just to get valid iso
$band_units: valid ISO units value AND should match a units definition in the ontology
'''
with open('../templates/ds_to_prov_contentinfo_template.xml', 'r') as f:
    BAND_TEMPLATE = Template(f.read())

'''
$step_unique_id
$step_name
$step_description
$proc_date
$input_sources
$source_produced_id
$source_type #for source produced
$source_description #for source produced
$software_name
'''
with open('../templates/ds_to_prov_processStep_template.xml', 'r') as f:
    STEP_TEMPLATE = Template(f.read())

'''
$source_used_id: # + md.id 
$source_type
$source_description
'''
with open('../templates/ds_to_prov_sourceused_template.xml', 'r') as f:
    INPUT_SOURCE_TEMPLATE = Template(f.read())  

'''
$md_elements
$mi_unique_id
$file_identifier
$uuid
$spatial_reference
$description
$pubdate
$manifestation
$additional_identifier_code
$abstract
$purpose
$file_type
$file_type_version
$parameter
$westbc
$eastbc
$northbc
$southbc
$timeextent_unique_id
$wcs_link
$band_identification
$json_link
$process_steps
'''
with open('../templates/ds_to_prov_dsseries_template.xml', 'r') as f:
    DS_TEMPLATE = Template(f.read())

def clean_ds(ds):
    '''
    strip out any comments from the ds

    template documentation is not necessary in the output
    and may be a little confusing (i.e. example value from
    the wrong data collection or something)

    returns:
        unicode encoded comment free string of the dataseries xml
    '''
    parser = etree.XMLParser(ns_clean=True, recover=True, encoding='utf-8')
    xml = etree.fromstring(ds.encode('utf-8'), parser=parser)
    comments = xml.xpath('//comment()')
    for c in comments:
        parent = c.getparent()
        parent.remove(c)
    return etree.tostring(xml, encoding=unicode, pretty_print=True)

def get_output_dir(uuid):
    '''
    check for output_dir + uuid[0:2],
    make it if doesn't exist, return path

    returns:
        subdir: path to the partial uuid subdirectory that should now exist
    '''
    subdir = os.path.join(OUTPUT_DIR, uuid[:2])
    if not os.path.exists(subdir):
        os.mkdir(subdir)
    return subdir

'''   
MAIN PROCESS
run through a set of json files and
convert to ds using templates.

it is low-tech and goofy.

'''
json_files = glob.glob(os.path.join(JSON_DIR, '*.json'))

for json_file in json_files:
    with open(json_file, 'r') as f:
        data = json.loads(f.read())

    # initialize the unique id values
    # these must be unique for each xml but aren't used for 
    # any ds/prov processing
    time_id = 200
    band_id = 300

    md_jsons = data['ds']['mds']
    if not md_jsons:
        print 'INVALID data series: ', json_file
        continue

    mds = []
    for md_json in md_jsons:    
        # convert the dict to has.md xml
        cited_party = CITED_PARTY_TEMPLATE.substitute({
            "provider": PROVIDER_TEMPLATE.substitute({
                "provider": md_json['provider']['name'] if 'provider' in md_json else ''
            }),
            "provider_role": PROVIDER_ROLE_TEMPLATE.substitute(rolecode=md_json['provider']['role']) if 'provider' in md_json else '',
            "external_link": LINK_TEMPLATE.substitute(external_link=md_json['external_link']) if 'external_link' in md_json else ''
        }) if 'provider' in md_json else ''
        
        md = MD_TEMPLATE.substitute({
            "unique_md_id": md_json['id'],
            "filename": md_json['filename'],
            "pubdate": md_json['pubdate'],
            "manifestation": md_json['manifestation']['type'],
            "additional_identifier_code": md_json['manifestation']['description'],
            "cited_party": cited_party,
            "file_type": md_json['file_type'],
            "file_type_version": md_json['file_type_version'],
            "parameter": md_json['parameter'],
            "westbc": md_json['bbox']['minx'],
            "eastbc": md_json['bbox']['maxx'],
            "northbc": md_json['bbox']['maxy'],
            "southbc": md_json['bbox']['miny'],
            "timeextent_unique_id": 't%s' % time_id,
            "start_date": md_json['start_date'],
            "end_date": md_json['end_date'],
            "band_identification": BAND_TEMPLATE.substitute({
                "band_name": md_json['band']['name'],
                "band_unique_id": 'b%s' % band_id,
                "band_units": md_json['band']['units']
            }),
            "spatial_reference": SPREF_TEMPLATE.substitute({
                "spref_name": md_json['spref']['name'],
                "spref_url": md_json['spref']['url'],
                "spref_epsg": md_json['spref']['epsg']
            })  
        })

        mds.append(md)
        
        time_id += 1
        band_id += 1

    step_jsons = data['ds']['steps']
    steps = [] 
    if not step_jsons:
        print 'INVALID lineage:', json_file
        continue   

    for step_json in step_jsons:
        #build the processing steps
        input_sources = step_json['inputs']
        inputs = []
        for input_source in input_sources:
            inputs.append(INPUT_SOURCE_TEMPLATE.substitute({
                "source_used_id": "#" + input_source['id'],
                "source_type": input_source['type'],
                "source_description": input_source['description']
            }))
            
        steps.append(STEP_TEMPLATE.substitute({
            "step_unique_id": step_json['id'],
            "step_name": step_json['name'],
            "step_description": step_json['description'],
            "proc_date": step_json['procdate'],
            "input_sources": '\n'.join(inputs),
            "source_produced_id": "#" + step_json['source_produced_id'],
            "source_type": step_json['source_type'],
            "source_description": step_json['source_description'],
            "software_name": step_json['software']
        }))


    ds_json = data['ds']
    ds = DS_TEMPLATE.substitute({
        "mi_unique_id": ds_json['id'],
        "file_identifier": ds_json['file_identifier'],
        "uuid": ds_json['uuid'],
        "description": ds_json['description'],
        "abstract": ds_json['abstract'],
        "purpose": ds_json['purpose'],
        "pubdate": ds_json['pubdate'],
        "wcs_link": ds_json['service_link'],
        "json_link": ds_json['json_link'],
        "process_steps": '\n'.join(steps),
        "md_elements": '\n'.join(mds),
        "file_type": ds_json['file_type'],
        "file_type_version": ds_json['file_type_version'],
        "parameter": ds_json['parameter'],
        "westbc": ds_json['bbox']['minx'],
        "eastbc": ds_json['bbox']['maxx'],
        "northbc": ds_json['bbox']['maxy'],
        "southbc": ds_json['bbox']['miny'],
        "timeextent_unique_id": 't%s' % time_id,
        "start_date": ds_json['start_date'],
        "end_date": ds_json['end_date'],
        "manifestation": ds_json["manifestation"]["type"],
        "additional_identifier_code": ds_json["manifestation"]["description"],
        "band_identification": BAND_TEMPLATE.substitute({
            "band_name": ds_json['band']['name'],
            "band_unique_id": 'b%s' % band_id,
            "band_units": ds_json['band']['units']
        }),
        "spatial_reference": SPREF_TEMPLATE.substitute({
            "spref_name": ds_json['spref']['name'],
            "spref_url": ds_json['spref']['url'],
            "spref_epsg": ds_json['spref']['epsg']
        }) 
    })

    ds = clean_ds(ds)

    #named according to our internal file convention, with DS appended
    output_dir = get_output_dir(ds_json['uuid'])
    with open(os.path.join(output_dir, '%s_ISO19115DS.xml' % ds_json['uuid']), 'w') as f:
        f.write(ds)









