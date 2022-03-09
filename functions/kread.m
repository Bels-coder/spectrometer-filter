function kread(fil)
[d,f,e]=fileparts(fil);
[file, filtyp, source, handle, found] = cspice_kdata(1, 'meta');


count = cspice_ktotal( 'ALL' );


if count>0
    
    for i = 1:count+1
        
        [ file, type, source, handle, found ] = ...
            cspice_kdata( i, 'ALL');
        
        if ( found )
            % 	  fprintf( 'Index : %d\n', i     );
            % 	  fprintf( 'File  : %s\n', file  );
            % 	  fprintf( 'Type  : %s\n', type  );
            % 	  fprintf( 'Source: %s\n\n', source);
            if strcmp([d filesep f e],file)
                warning('Already loaded')
                % 	      fprintf( 'Already loaded \n\n');
                return
            end
            
        else
            
            fprintf( 'No kernel found with index: %d\n', i );
            
        end
        
    end
end
fil = char(fil);
cspice_furnsh({fil})
