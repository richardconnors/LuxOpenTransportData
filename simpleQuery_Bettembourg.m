
%%%%%%%%%%%%%%%%%%%%%%%%%
% Aim: to get departure time info at Bettembourg for one day 
% Edeited by: Haruko
% Last updated: 11 Oct 2023
%%%%%%%%%%%%%%%%%%%%%%%

clear
load luxopendataAPIkey

%%%%%% TO BE SPECIFIED BY USERS%%%%%%
% coordinates to search are (Bettembourg station)
originCoordLat= '49.516769246355345';
originCoordLong = '6.1016479360548725';
maxNo = '50'; % max number of stops to return
r = '500'; % radius around coordinates to search (in metres)

%specify the date and time and duration to extract information 
date = '2023-10-10';
time = '00:00';
dur = '1439';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%Get the location ID for stops wihtin 4 meters radius from the given
%coordinate
baseLocReq = 'https://cdt.hafas.de/opendata/apiserver/location.nearbystops?accessId=<API-KEY>&originCoordLong=<THIS_LONG>&originCoordLat=<THIS_LAT>&maxNo=<MAX_N>&r=<RADIUS>&format=json';

locReq = strrep(baseLocReq,'<API-KEY>',api_key);
locReq = strrep(locReq,'<THIS_LONG>',originCoordLong);
locReq = strrep(locReq,'<THIS_LAT>',originCoordLat);
locReq = strrep(locReq,'<MAX_N>',maxNo);
locReq = strrep(locReq,'<RADIUS>',r);

%get the stops info from API 
Stops = webread(locReq);
S = Stops.stopLocationOrCoordLocation;
N = length(S); % the number of stops within the range 
if N < 1,  return; end

Sinfo = cell(N,2);
for i = 1:N
  Sinfo{i,1} = S(i).StopLocation.extId;
  Sinfo{i,2} = string({S(i).StopLocation.productAtStop.line});
end

%Prepare the table to store the infromation 
depTable = table('Size',[0,6], 'VariableNames',{'StopName', 'Date', 'TimeofReq', 'DepTime', 'Line', 'Status'},...
  'VariableTypes',{'string','string','string','string','string','string'});
for i = 1:N
  % get live data for each stop in turn
  stopID = Sinfo{i,1}; % taken from inside Stops struct above
  baseRealTimeDep = 'https://cdt.hafas.de/opendata/apiserver/departureBoard?accessId=<API-KEY>&lang=en&id=<THIS_STOP>&date=<thisdate>&time=<thistime>&dur=<thisdur>&format=json';
  timeReq = strrep(baseRealTimeDep,'<API-KEY>',api_key);
  timeReq = strrep(timeReq,'<THIS_STOP>',stopID);
  timeReq = strrep(timeReq,'<thisdate>',date);
  timeReq = strrep(timeReq,'<thistime>',time);
  timeReq = strrep(timeReq,'<thisdur>',dur);
  
  thisStopDeps = webread(timeReq);
  currentTime = datestr(now, 'HH:MM:SS');

  % find and store useful data
  m = length(thisStopDeps.Departure);
  for j = 1:m
    thisD = thisStopDeps.Departure(j);
    thisName = thisD.stop;
    thisDate = thisD.date;
    thisTime = thisD.time;
    thisL = thisD.Product.line;
    thisState = thisD.JourneyStatus;

    newRow = {thisName, thisDate, currentTime, thisTime, thisL, thisState};
    depTable = [depTable; newRow];
  end
end

% Display the final table
disp(depTable);

%%%%%%%%%%%%%% SAVE THE OUTPUT  %%%%%%%%%%%%%%%%%
filename = sprintf('Bettembourg_%s.xlsx',date);
filename_mat = sprintf('Bettembourg_%s',date);

writetable(depTable,filename)
save(filename_mat,"depTable")

