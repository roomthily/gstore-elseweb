import os
import re
import json
import glob
import requests
from compiler.ast import flatten


def convert_date(d):
    return '-'.join([d[:4], d[4:6], d[-2:]])


'''

FOR AQUA:
http://e4ftl01.cr.usgs.gov/MOLA/MYD11A2.005
    http://e4ftl01.cr.usgs.gov/MOLA/MYD13Q1.005/2012.08.20/
        http://e4ftl01.cr.usgs.gov/MOLA/MYD13Q1.005/2012.08.20/MYD13Q1.A2012233.h17v01.005.2012250050715.hdf


FOR TERRA:
http://e4ftl01.cr.usgs.gov/MOLT/MOD11A2.005/
    http://e4ftl01.cr.usgs.gov/MOLT/MOD13Q1.005/2012.05.08/
        http://e4ftl01.cr.usgs.gov/MOLT/MOD13Q1.005/2012.05.08/MOD13Q1.A2012129.h18v02.005.2012146141106.hdf

get julian date: A2012129
get tile: h18v02


Get listing for anything 2012 - 2013 March (beginning of March)
'''

AQUA_START = '2012-01-01'
TERRA_START = '2012-01-01'

TILES = {
    'h08v04': {
        'bbox': [-156.84,39.7081,-117.285,50.1258]
    },
    'h08v05': {
        'bbox': [-130.541,29.8308,-103.7,40.0852]
    },
    'h08v06': {
        'bbox': [-115.47,19.8904,-95.4407,30.0494]
    },
    'h09v04': {
        'bbox': [-140.795,39.7342,-104.235,50.1159]
    },
    'h09v05': {
        'bbox': [-117.487,29.8361,-92.1319,40.0742]
    },
    'h09v06': {
        'bbox': [-103.923,19.8939,-84.8251,30.0438]
    },
    'h10v04': {
        'bbox': [-124.885,39.7557,-91.191,50.1047]
    },
    'h10v05': {
        'bbox': [-104.433,29.8411,-80.5776,40.0638]
    },
    'h10v06': {
        'bbox': [-92.376,19.8973,-74.213,30.0384]
    }
}

_sprefs = {
    6842: {
        'name': 'Sinusoidal', #this is maybe sr-org:6842 and then incorrect in the iso
        'url': 'http://spatialreference.org/ref/sr-org/modis-sinusoidal/'
    },
    4326: {
        'name': 'WGS 84',
        'url': 'http://www.epsg-registry.org/export.htm?gml=urn:ogc:def:crs:EPSG::4326'
    }
}

SERVICE_URL = 'http://gstore.unm.edu/apps/elseweb/datasets/%s/services.json'

AQUA_ROOT = 'http://e4ftl01.cr.usgs.gov/MOLA/MYD11A2.005'
TERRA_ROOT = 'http://e4ftl01.cr.usgs.gov/MOLT/MOD11A2.005/'

#PLATFORM = "AQUA"
PLATFORM='TERRA'

ROOT = AQUA_ROOT if PLATFORM == 'AQUA' else TERRA_ROOT

OUTPUT_DIR = '../../../modis_json'

HTMLDIR = 'modis_lst_listing'
htmls = glob.glob(os.path.join(HTMLDIR, PLATFORM, '*.html'))

#348923|0bb27255-bb8d-4f87-8599-13d3c3384dd5|MODIS Terra 250m 16 days EVI (2012-01-01 - 2012-01-16)|MOD13Q1_2012001_EVI_MOSAIC
#348895|bf7399e9-d667-4bbe-8666-0972bc1edb83|MODIS Aqua 250m 16 days EVI (2012-02-10 - 2012-02-25)|MYD13Q1_2012041_EVI_MOSAIC
with open('../../../modis_lst_PRODUCTION_20140630.csv', 'r') as f:
    datasets = f.readlines()
datasets = [[a.strip().replace('"', '') for a in d.split('|')] for d in datasets[1:]]      

HREF_PTTN = r'<a\s+(?:[^>]*?\s+)?href="([^"]*)'
pattern = re.compile(HREF_PTTN)

for html in htmls:
    with open(html, 'r') as f:
        lines = f.read().split('\n')

    modis_date = html.split('/')[-1].replace('.html', '')

    #get any line with .hdf but not .hdf.xml in it and any of the tiles  
    hdfs = [i.strip() for i in lines if '.hdf' in i and not '.hdf.xml' in i and any(t in i for t in TILES.keys())]

    if len(hdfs) < 9:
        print 'short hdf list: ', html, hdfs
        continue

    #clean up some stuff because ew
    hrefs = flatten([pattern.findall(h) for h in hdfs])

    #MYD13Q1.A2012009.h01v09.005.2012026022110.hdf
    # get the data product, julian date bit, tile bit so we can match to a dataset
    hdfs = [(h.split('.')[0:3] + [h]) for h in hrefs]

    found_datasets = [d for d in datasets if  hdfs[0][0] in d[3] and hdfs[0][1][1:] in d[3] and 'MOSAIC' in d[3]]
    if not found_datasets or len(found_datasets) < 4:
        print 'bad dataset', hdfs[0], len(found_datasets)
        continue

    for dataset in found_datasets:
        uuid = dataset[1]

        #get the datajset json
        rsp = requests.get(SERVICE_URL % uuid)
        if rsp.status_code != 200:
            continue

        service_rsp = rsp.json()

        #get the dataset details from the service description
        basename = service_rsp['name']
        description = service_rsp['description']
        dataset_bbox = service_rsp['spatial']['bbox']
        
        start_date = service_rsp['valid_dates']['start']
        start_date = convert_date(start_date)
        
        end_date = service_rsp['valid_dates']['end']
        end_date = convert_date(end_date)
        
        pubdate = service_rsp['lastupdate']
        pubdate = convert_date(pubdate)

        if 'DAY_' in basename:         
            param = 'DaytimeSurfaceTemperature'
            index_band = 'LST_Day_1km'
            units = 'degreesCelsius'
        elif 'NIGHT_' in basename:
            param = 'NighttimeSurfaceTemperature'
            index_band = 'LST_Night_1km'
            units = 'degreesCelsius'
        else:
            param = 'QualityControl'
            index_band = 'QC_Day' if 'DAY' in basename else 'QC_Night'
            units = 'unitless'
        index_name = basename.split('_')[2]

        #mds for the initial download
        mds = []
        download_steps = []
        extract_steps = []
        mosaic_inputs = []
        for hdf in hdfs:
            #build the url
            href = '/'.join([ROOT, modis_date, hdf[3]])

            bbox = TILES[hdf[2]]['bbox']

            md = {
                "id": "RemoteHDF-%s" % hdf[2],
                "filename": hdf[3],
                "parameter": param,
                "provider": {
                    "name": "NASA LPDAAC",
                    "role": "originator"
                },
                "external_link": href,
                "spref": {
                    "name": _sprefs[6842]['name'], 
                    "url": _sprefs[6842]['url'], 
                    "epsg": 6842
                },
                "pubdate": pubdate,
                "manifestation": {"type": "FileDownload", "description": "Downloadable Data"},
                "file_type": "HDF",
                "file_type_version": "4",
                "bbox": {
                    "minx": str(bbox[0]),
                    "miny": str(bbox[1]), 
                    "maxx": str(bbox[2]),
                    "maxy": str(bbox[3])
                },
                "start_date": start_date,
                "end_date": end_date,
                "band": {
                    "name": "Multiband",
                    "units": "unitless"
                }
            }

            mds.append(md)

            #mds for the local file
            md = {
                "id": "LocalHDF-%s" % hdf[2],
                "filename": hdf[3],
                "parameter": param,
                "spref": {
                    "name": _sprefs[6842]['name'], 
                    "url": _sprefs[6842]['url'], 
                    "epsg": 6842
                },
                "pubdate": pubdate,
                "manifestation": {"type": "FileManifestation", "description": "Downloadable Data"},
                "file_type": "HDF",
                "file_type_version": "4",
                "bbox": {
                    "minx": str(bbox[0]),
                    "miny": str(bbox[1]), 
                    "maxx": str(bbox[2]),
                    "maxy": str(bbox[3])
                },
                "start_date": start_date,
                "end_date": end_date,
                "band": {
                    "name": "Multiband",
                    "units": "unitless"
                }
            }

            mds.append(md)

            #mds for extract/reproject (need band name) gdal_warp, band name = 250m 16 days EVI or 250m 16 days NDVI
            md = {
                "id": "LocalTIFF-%s" % hdf[2],
                "filename": '_'.join([hdf[0], hdf[1][1:], param]) + '.tif',
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
                    "name": "MODIS_Grid_8Day_1km_LST:%s" % index_band,
                    "units": units
                }
            }

            mds.append(md)

            download_steps.append({
                "id": "download-%s" % hdf[2],
                "name": "Download-%s" % hdf[2],
                "description": "Download MODIS %s Land Surface Temperature HDF from LPDAAC" % PLATFORM,
                "procdate": pubdate + 'T00:00:00',
                "source_produced_id": "LocalHDF-%s" % hdf[2],
                "source_type": "DownloadedMODISDataset",
                "source_description": "Local copy of the downloaded MODIS file",
                "software": "curl",
                "inputs": [
                    {
                        "id": "RemoteHDF-%s" % hdf[2],
                        "type": "MODISDataset",
                        "description": "Download link for the MODIS %s Land Surface Temperature HDF" % PLATFORM
                    }
                ]
            })

            extract_steps.append({
                "id": "extract-%s" % hdf[2],
                "name": "ExtractReproject-%s" % hdf[2],
                "description": "Extract and reproject the %s from the %s HDF" % (param, PLATFORM),
                "procdate": pubdate + 'T00:00:00',
                "source_produced_id": "LocalTIFF-%s" % hdf[2],
                "source_type": "ExtractedDataset",
                "source_description": "WGS84 GeoTIFF of the %s from the %s HDF" % (param, PLATFORM),
                "software": "gdal_warp",
                "inputs": [
                    {
                        "id": "LocalHDF-%s" % hdf[2],
                        "type": "DownloadedMODISDataset",
                        "description": "Local copy of the downloaded MODIS file"
                    }
                ]
            })

            mosaic_inputs.append({
                "id": "LocalTIFF-%s" % hdf[2],
                "type": "ExtractedDataset",
                "description": "WGS84 GeoTIFF of the %s from the %s HDF" % (param, PLATFORM)
            })


        #md for merge    (gdal_merge)
        mds.append({
            "id": "MOSAIC",
            "filename": '_'.join([hdf[0], hdf[1][1:], index_name, 'MOSAIC']) + '.tif',
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
                "minx": str(dataset_bbox[0]),
                "miny": str(dataset_bbox[1]), 
                "maxx": str(dataset_bbox[2]),
                "maxy": str(dataset_bbox[3])
            },
            "start_date": start_date,
            "end_date": end_date,
            "band": {
                "name": "Singleband",
                "units": units
            }
        })

        #steps
        steps = download_steps + extract_steps
        
        #the one mosaic
        steps.append({
            "id": "mosaic-1",
            "name": "Mosaic",
            "description": "Mosaic the %s tiles into one GeoTIFF" % param,
            "procdate": pubdate + 'T00:00:00',
            "source_produced_id": "MOSAIC",
            "source_type": "MosaicDataset",
            "source_description": "Mosaicked GeoTIFF for the %s band" % param,
            "software": "gdal_merge",
            "inputs": mosaic_inputs
        })

        #and the one publish
        steps.append({
            "id": "publish-1",
            "name": "Publish",
            "description": "Publish the mosaic to GSTORE",
            "procdate": pubdate + 'T00:00:00',
            "source_produced_id": "Published-WCS",
            "source_type": "PublishedMODISDataset",
            "source_description": "WCS for the MODIS %s %s dataset" % (PLATFORM, param),
            "software": "GSTORE",
            "inputs": [
                {
                    "id": "mosaic-1",
                    "type": "MosaicDataset",
                    "description": "Mosaicked GeoTIFF for the %s band" % param
                }
            ]   
        })

        #ds for published
        ds = {
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
                "minx": str(dataset_bbox[0]),
                "miny": str(dataset_bbox[1]), 
                "maxx": str(dataset_bbox[2]),
                "maxy": str(dataset_bbox[3])
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
            f.write(json.dumps({"ds": ds}, indent=4))














    
