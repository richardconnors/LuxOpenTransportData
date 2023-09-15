
rc_api_key = '027dfc88-dfcf-4b4a-9f0c-af951476880e';

% coordinates to search around (this is MNO)
originCoordLat= '49.503518';
originCoordLong = '5.947713';
maxNo = '50'; % max nnumber of stops to return
r = '500'; % radius around coordinates to search (in metres)

baseLocReq = 'https://cdt.hafas.de/opendata/apiserver/location.nearbystops?accessId=<API-KEY>&originCoordLong=<THIS_LONG>&originCoordLat=<THIS_LAT>&maxNo=<MAX_N>&r=<RADIUS>&format=json';

locReq = strrep(baseLocReq,'<API-KEY>',rc_api_key);
locReq = strrep(locReq,'<THIS_LONG>',originCoordLong);
locReq = strrep(locReq,'<THIS_LAT>',originCoordLat);
locReq = strrep(locReq,'<MAX_N>',maxNo);
locReq = strrep(locReq,'<RADIUS>',r);

Stops = webread(locReq);

% example data encoded inside
Stops.stopLocationOrCoordLocation.StopLocation
Stops.stopLocationOrCoordLocation(1).StopLocation.productAtStop.name

stopID = '220402129'; % taken from inside Stops struct above
baseRealTimeDep = 'https://cdt.hafas.de/opendata/apiserver/departureBoard?accessId=<API-KEY>&lang=en&id=<THIS_STOP>&format=json';

timeReq = strrep(baseRealTimeDep,'<API-KEY>',rc_api_key);
timeReq = strrep(timeReq,'<THIS_STOP>',stopID);
Deps = webread(timeReq);
% example output encoded in D
Deps.Departure{:}