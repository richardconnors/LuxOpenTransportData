import requests
import pandas as pd
from datetime import datetime
import scipy.io

# Load the API key from the .mat file
mat_data = scipy.io.loadmat('luxopendataAPIkey.mat')
api_key = mat_data['api_key'][0]


# Coordinates to search around (this is MNO)
originCoordLat = '49.503518'
originCoordLong = '5.947713'
maxNo = '50'  # Max number of stops to return
r = '500'  # Radius around coordinates to search (in meters)

baseLocReq = 'https://cdt.hafas.de/opendata/apiserver/location.nearbystops?accessId=<API-KEY>&originCoordLong=<THIS_LONG>&originCoordLat=<THIS_LAT>&maxNo=<MAX_N>&r=<RADIUS>&format=json'

locReq = baseLocReq.replace('<API-KEY>', api_key)
locReq = locReq.replace('<THIS_LONG>', originCoordLong)
locReq = locReq.replace('<THIS_LAT>', originCoordLat)
locReq = locReq.replace('<MAX_N>', maxNo)
locReq = locReq.replace('<RADIUS>', r)

response = requests.get(locReq)
stops_data = response.json().get('stopLocationOrCoordLocation', [])
N = len(stops_data)
if N < 1:
    exit()

Sinfo = [(stop['StopLocation']['extId'], [line['line'] for line in stop['StopLocation']['productAtStop']]) for stop in stops_data]

dep_table = pd.DataFrame(columns=['StopName', 'Date', 'TimeofReq', 'DepTime', 'Line', 'Status'])

for stop_id, lines in Sinfo:
    base_real_time_dep = 'https://cdt.hafas.de/opendata/apiserver/departureBoard?accessId=<API-KEY>&lang=en&id=<THIS_STOP>&format=json'
    time_req = base_real_time_dep.replace('<API-KEY>', api_key).replace('<THIS_STOP>', stop_id)
    this_stop_deps = requests.get(time_req).json().get('Departure', [])
    current_time = datetime.now().strftime('%H:%M:%S')

    for dep in this_stop_deps:
        this_name = dep['stop']
        this_date = dep['date']
        this_time = dep['time']
        this_l = dep['Product']['line']
        this_state = dep['JourneyStatus']

        new_row = {'StopName': this_name, 'Date': this_date, 'TimeofReq': current_time, 'DepTime': this_time, 'Line': this_l, 'Status': this_state}
        dep_table = dep_table.append(new_row, ignore_index=True)

# Display the final table
print(dep_table)

# Save the table to a text file
dep_table.to_csv('departureTimeTable.txt', sep='\t', index=False)
