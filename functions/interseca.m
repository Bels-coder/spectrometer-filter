function [flag,pclon, pclat, phase, solar, emissn, r, x,y,z]=interseca(vec, et, satnm, scnm, fixref, iframe, method)

% trova le coordinate geografiche di intersezione tra

if nargin < 7
    method='Ellipsoid';
end
M=numel(et);
N=numel(vec)/3;


x=nan(M,N);
y=nan(M,N);
z=nan(M,N);
pclon=nan(M,N);
pclat=nan(M,N);
phase=nan(M,N);
solar=nan(M,N);
emissn=nan(M,N);
r=nan(M,N);
% pdlon=nan(M,N);
% pdlat=nan(M,N);
% alt=nan(M,N);
flag=false(M,N);

radii = cspice_bodvrd( satnm, 'RADII', 3 );
for j=1:M
    for i=1:N

        
        [point, trgepc, srfvec, found] = cspice_sincpt( ...
            method, satnm, et(j), fixref, 'CN+S',  scnm, iframe, vec(:,i) );
        % If an intercept is found, compute planetocentric and planetodetic
        % latitude and longitude of the point.
        
        if ( found )
            [r(j,i), pclon(j,i), pclat(j,i)] = cspice_reclat( point );
            % Let re, rp, and f be the satellite's longer equatorial
            % radius, polar radius, and flattening factor.
%             re =  radii(1);
%             rp =  radii(3);
%             f = ( re - rp ) / re;
            
%             [pdlon(j,i), pdlat(j,i), alt(j,i)] = cspice_recgeo( point, re, f );

            % Compute illumination angles at the surface point.
            [trgepc, srfvec, phase(j,i), solar(j,i), emissn(j,i)] = cspice_ilumin( ...
                'Ellipsoid',  satnm, et(j),  fixref, 'CN+S',  scnm, point );
            flag(j,i)=true;
            x(j,i)=point(1);
            y(j,i)=point(2);
            z(j,i)=point(3);
        else
            
            
            %     time=cspice_timout( et(i), pic );
            %     disp( ['No intercept point found at ' time ])
        end
    end
end

 
pclon=pclon*180/pi;
pclat=pclat*180/pi;
phase= phase*180/pi;
solar=solar*180/pi;
emissn=emissn *180/pi;
% pdlon=pdlon*180/pi;
% pdlat=pdlat*180/pi;
