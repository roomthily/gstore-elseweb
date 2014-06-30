import os
import json
import glob
import requests

'''
generate the intermediate prism stuff
'''

def convert_date(d):
    return '-'.join([d[:4], d[4:6], d[-2:]])
    
def parse_filename(description, filename):
    '''
    to handle some internal conventions :(

    returns:
        param:
        flag:
        units:
        aggregate:
        frequency:
        year:
        month:
    '''
    #us_ppt_1908.12.asc
    param = ''
    if '_ppt_' in filename:
        param = 'Precipitation'
        units = 'millimeters'
        flag = 'ppt'
    if '_tmax_' in filename:
        param = 'MaximumTemperature'
        units = 'degreesCelsius'
        flag = 'tmax'
    if '_tmin_' in filename:
        param = 'MinimumTemperature'
        units = 'degreesCelsius'
        flag = 'tmin'
    if '_dewpt_' in filename:
        param = 'DewPoint'
        units = 'degreesCelsius'
        flag = 'dewpt'
        
    frequency = 'month'

    if '(Annual/' in description:
        aggregate = 'annual'
        frequency = 'year'
    elif 'Normal' in description:
        aggregate = 'normal'
    else:
        aggregate = 'monthly'
        
    if not param:
        raise Exception('bad parameter')

    parts = filename.split('_')
    flag = parts[1]

    #this is not a good flag for annual
    month = '' if parts[3] == '14' else parts[3]
    
    year = parts[2]

    return param, flag, units, aggregate, frequency, year, month

SERVICE_URL = 'http://gstore.unm.edu/apps/elseweb/datasets/%s/services.json'

OUTPUT_DIR = '../../../prism_json'

with open('../../../elseweb_prism_PRODUCTION_20140620.csv', 'r') as f:
    UUIDS = f.readlines()
UUIDS = [d.strip().split('|')[1] for d in UUIDS[1:]]  

_kinds = {
    'monthly': {
        'url': 'ftp://prism.nacse.org/monthly/%(flag)s/%(year)s/PRISM_%(flag)s_stable_4kmM2_%(year_and_month)s_bil.zip'
    },
    'annual': {
        'url': 'ftp://prism.nacse.org/monthly/%(flag)s/%(year)s/PRISM_%(flag)s_stable_4kmM2_%(year)s_bil.zip'
    },
    'normal_month': {
        'url': 'ftp://prism.nacse.org/normals_4km/%(flag)s/PRISM_%(flag)s_30yr_normal_4kmM2_%(month)s_bil.zip'
    },
    'normal_annual': {
        'url': 'ftp://prism.nacse.org/normals_4km/%(flag)s/PRISM_%(flag)s_30yr_normal_4kmM2_annual_bil.zip'
    }
}

_sprefs = {
    4269: {
        'name': 'NAD83',
        'url': 'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::4269'
    },
    4326: {
        'name': 'WGS 84',
        'url': 'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::4326'
    }
}

for uuid in UUIDS:
    print uuid
    rsp = requests.get(SERVICE_URL % uuid)
    if rsp.status_code != 200:
        continue

    service_rsp = rsp.json()

    #get the dataset details from the service description
    basename = service_rsp['name']
    description = service_rsp['description']
    bbox = service_rsp['spatial']['bbox']
    
    start_date = service_rsp['valid_dates']['start']
    start_date = convert_date(start_date)
    
    end_date = service_rsp['valid_dates']['end']
    end_date = convert_date(end_date)
    
    pubdate = service_rsp['lastupdate']
    pubdate = convert_date(pubdate)
    
    #use our knowledge of the data collection to get 
    #info we need for the ontology
    try:
        param, flag, units, aggregate, frequency, year, month = parse_filename(description, basename)
    except Exception as ex:
        print '\t', ex, description, basename
        continue

    #regenerate the original source 
    #note: this might not be the original original since osu deployed a new website
    if aggregate != 'normal':
        download_pttn = _kinds[aggregate]['url']
        if frequency == 'month':
            download = download_pttn % {'year': year, 
                'year_and_month': ''.join([year, month.zfill(2)]),
                'flag': flag
                }
        elif frequency == 'year':
            download = download_pttn % {'year': year, 'flag': flag}
    else:
        if frequency == 'month':
            download_pttn = _kinds['normal_month']['url']
            download = download_pttn % {
                'month': month.zfill(2),
                'flag': flag
            }
        else:
            download_pttn = _kinds['normal_annual']['url']  
            download = download_pttn % {'flag': flag}  

    filename = download.split('/')[-1]

    mds = [
        {
            "id": "RemotePrism",
            "filename": filename,
            "parameter": param,
            "provider": {
                "name": "PRISM Climate Group", 
                "role": "originator"
            },
            "external_link": download,
            "spref": {
                "name": _sprefs[4269]['name'], 
                "url": _sprefs[4269]['url'], 
                "epsg": 4269
            },
            "pubdate": pubdate,
            "manifestation": {"type": "FileDownload", "description": "Downloadable Data"},
            "file_type": "ASCII",
            "file_type_version": "1",
            "bbox": {
                "minx": str(bbox[0]),
                "miny": str(bbox[1]), 
                "maxx": str(bbox[2]),
                "maxy": str(bbox[3])
            },
            "start_date": start_date,
            "end_date": end_date,
            "band": {
                "name": "SingleBand",
                "units": units
            }
        },
        {
            "id": "LocalASCII",
            "filename": filename,
            "parameter": param,
            "spref": {
                "name": _sprefs[4269]['name'], 
                "url": _sprefs[4269]['url'], 
                "epsg": 4269
            },
            "pubdate": pubdate,
            "manifestation": {"type": "FileManifestation", "description": "Downloadable Data"},
            "file_type": "ASCII",
            "file_type_version": "1",
            "bbox": {
                "minx": str(bbox[0]),
                "miny": str(bbox[1]), 
                "maxx": str(bbox[2]),
                "maxy": str(bbox[3])
            },
            "start_date": start_date,
            "end_date": end_date,
            "band": {
                "name": "SingleBand",
                "units": units
            }
        },
        {
            "id": "LocalTIFF",
            "filename": filename.replace('_bil.zip', '.tif'),
            "parameter": param,
            "spref": {
                "name": _sprefs[4269]['name'], 
                "url": _sprefs[4269]['url'], 
                "epsg": 4269
            },
            "pubdate": pubdate,
            "manifestation": {"type": "FileManifestation", "description": "Downloadable Data"},
            "file_type": "GeoTIFF",
            "file_type_version": "1",
            "bbox": {
                "minx": str(bbox[0]),
                "miny": str(bbox[1]), 
                "maxx": str(bbox[2]),
                "maxy": str(bbox[3])
            },
            "start_date": start_date,
            "end_date": end_date,
            "band": {
                "name": "SingleBand",
                "units": units
            }
        },
        {
            "id": "LocalTIFF-WGS84",
            "filename": filename.replace('_bil.zip', '_wgs84.tif'),
            "parameter": param,
            "spref": {
                "name": _sprefs[4326]['name'], 
                "url": _sprefs[4326]['url'], 
                "epsg": 4326
            },
            "pubdate": pubdate,
            "manifestation": {"type": "FileManifestation", "description": "Downloadable Data"},
            "file_type": "GeoTIFF",
            "file_type_version": "1",
            "bbox": {
                "minx": str(bbox[0]),
                "miny": str(bbox[1]), 
                "maxx": str(bbox[2]),
                "maxy": str(bbox[3])
            },
            "start_date": start_date,
            "end_date": end_date,
            "band": {
                "name": "SingleBand",
                "units": units
            }
        }
    ]

    steps = [
        {
            "id": "download-1",
            "name": "Download",
            "description": "Download ASCII from PRISM (OSU)",
            "procdate": pubdate + 'T00:00:00',
            "source_produced_id": "LocalASCII",
            "source_type": "DownloadedPRISMDataset",
            "source_description": "Local copy of the downloaded PRISM file",
            "software": "curl",
            "inputs": [
                {
                    "id": "RemotePrism",
                    "type": "PRISMDataset",
                    "description": "Download link for the PRISM"
                }
            ]
        },
        {
            "id": "convert-to-geotiff-1",
            "name": "ConvertASCIIToTiff",
            "description": "Convert the ASCII to a GeoTIFF",
            "procdate": pubdate + 'T00:00:00',
            "source_produced_id": "LocalTIFF",
            "source_type": "ConvertedDataset",
            "source_description": "Local ASCII converted to GeoTIFF",
            "software": "gdal_translate",
            "inputs": [
                {
                    "id": "LocalASCII",
                    "type": "DownloadedPRISMDataset",
                    "description": "Local copy of the downloaded ASCII"
                }
            ]
        },
        {
            "id": "reproject-1",
            "name": "Reproject",
            "description": "Reproject to WGS 84",
            "procdate": pubdate + 'T00:00:00',
            "source_produced_id": "LocalTIFF-WGS84",
            "source_type": "ReprojectedDataset",
            "source_description": "Reprojected GeoTIFF",
            "software": "gdalwarp",
            "inputs": [
                {
                    "id": "LocalTIFF",
                    "type": "ConvertedDataset",
                    "description": "Local ASCII"
                }
            ]
        },
        {
            "id": "publish-1",
            "name": "PUBLISH",
            "description": "Publish the repojected TIFF to GSTORE as WCS",
            "procdate": pubdate + 'T00:00:00',
            "source_produced_id": "Published-WCS",
            "source_type": "PublishedPRISMDataset",
            "source_description": "WCS for PRISM GeoTIFF",
            "software": "gstore",
            "inputs": [
                {
                    "id": "LocalTIFF-WGS84",
                    "type": "ReprojectedDataset",
                    "description": "Reprojected GeoTIFF"
                }
            ]
        }
    ]

    data = {
        "id": "Published-WCS",
        "uuid": uuid,
        "file_identifier": "ELSEWEB::%s::ISO-19115:2003" % uuid,
        "parameter": param,
        "description": "",
        "abstract": "", 
        "purpose": "",
        "spref": {
            "name": _sprefs[4326]['name'], 
            "url": _sprefs[4326]['url'], 
            "epsg": 4326
        },
        "pubdate": pubdate,
        "manifestation": {"type": "WCSManifestation", "description": "Published WCS from GSTORE"},
        "file_type": "GeoTIFF",
        "file_type_version": "1",
        "service_link": 'http://gstore.unm.edu/apps/elseweb/datasets/%s/services/ogc/wcs?SERVICE=wcs&amp;REQUEST=GetCapabilities&amp;VERSION=1.1.2' % uuid,
        "json_link": 'http://gstore.unm.edu/apps/elseweb/datasets/%s/services.json' % uuid,
        "bbox": {
            "minx": str(bbox[0]),
            "miny": str(bbox[1]), 
            "maxx": str(bbox[2]),
            "maxy": str(bbox[3])
        },
        "start_date": start_date,
        "end_date": end_date,
        "band": {
            "name": "OutputBand",
            "units": units
        },
        "mds": mds,
        "steps": steps
    }

    with open(os.path.join(OUTPUT_DIR, '%s.json' % uuid), 'w') as f:
        f.write(json.dumps({"ds": data}, indent=4))




