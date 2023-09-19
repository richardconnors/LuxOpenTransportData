
load luxopendataAPIkey

% coordinates to search around (this is MNO)
originCoordLat= '49.503518';
originCoordLong = '5.947713';
maxNo = '50'; % max number of stops to return
r = '500'; % radius around coordinates to search (in metres)

baseLocReq = 'https://cdt.hafas.de/opendata/apiserver/location.nearbystops?accessId=<API-KEY>&originCoordLong=<THIS_LONG>&originCoordLat=<THIS_LAT>&maxNo=<MAX_N>&r=<RADIUS>&format=json';

locReq = strrep(baseLocReq,'<API-KEY>',api_key);
locReq = strrep(locReq,'<THIS_LONG>',originCoordLong);
locReq = strrep(locReq,'<THIS_LAT>',originCoordLat);
locReq = strrep(locReq,'<MAX_N>',maxNo);
locReq = strrep(locReq,'<RADIUS>',r);

Stops = webread(locReq);
S = Stops.stopLocationOrCoordLocation;
N = length(S);
if N < 1,  return; end

Sinfo = cell(N,2);
for i = 1:N
  Sinfo{i,1} = S(i).StopLocation.extId;
  Sinfo{i,2} = string({S(i).StopLocation.productAtStop.line});
end

for i = 1:N
% get live data for each stop in turn
stopID = Sinfo{i,1}; % taken from inside Stops struct above
baseRealTimeDep = 'https://cdt.hafas.de/opendata/apiserver/departureBoard?accessId=<API-KEY>&lang=en&id=<THIS_STOP>&format=json';
timeReq = strrep(baseRealTimeDep,'<API-KEY>',api_key);
timeReq = strrep(timeReq,'<THIS_STOP>',stopID);
Deps = webread(timeReq);


% find and store useful data
m = length(Deps.Departure);
for j = 1:m
thisD = Deps.Departure{j}





end
end