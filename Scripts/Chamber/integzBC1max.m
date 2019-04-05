function [xmax,OrigIntervals] = integz2max(tx,cx,td,days)
%
%   [xsum,xmean,OrigIntervals] = integz2(tx,cx,td,days)
%
%       tx      time vector in 1/48 parts per day
%       cx      data vector corresponding to tx
%       td      time vector in days
%       days    interval of integration in days (INTEGER) 
%
% (c) Zoran Nesic           File created:                 , 1996
%                           Last modification:      Jan 14, 1998
%
%Revisions:
%
%	Jan 14, 1998 by Bill Chen
%			-	change OrigIntervals, maxNonZeroTime, minNonZeroTime
%
if nargin < 4
    days = 1;                                   % default interval of integration is 1 day
end

xmax =  zeros(1,ceil(length(td)/days));         % fill the output vectors with zeros

st = min(td);                                   % find first
ed = max(td);                                   % and last time stamp
%OrigIntervals = st:days:ceil((ed-st)/days)*days;% create intervals of integration
OrigIntervals = st:days:ceil((ed-st+1)/days)*days;% create intervals of integration

indZero = find( cx ~= 0 );                      % find indexes for all cx ~= 0
%maxNonZeroTime = tx(max(indZero));
%minNonZeroTime = tx(min(indZero));
maxNonZeroTime = ceil(tx(max(indZero)));
minNonZeroTime = floor(tx(min(indZero)));

stNew = find(OrigIntervals >= minNonZeroTime );
stNew = min(stNew);
edNew = find(OrigIntervals <= maxNonZeroTime );
edNew = max(edNew);
NewIntervals = OrigIntervals(stNew):days:OrigIntervals(edNew);
len   = length(NewIntervals);

RoundTime = floor(tx);
k = 1;
for i=NewIntervals;
    ind = find( (RoundTime >=i) & (RoundTime <= i + days-1) );
    
    xmax(k) = max(cx(ind));
    
    nn = length(ind);
    if nn > 24*days
        xmax(k) = xmax(k);
%    elseif k > 1
%        xmax(k) = xmax(k-1);
    else
%        xmax(k) = 0;
			xmax(k) = NaN;
	end
    k = k+1;
%    fprintf('%d',i);
end
%
% Fill up the non-existant data with NaN's
%
xmaxTmp = xmax;
xmax = NaN * zeros(size(OrigIntervals));

xmax(stNew:stNew + len -1) = xmaxTmp(1:len);

