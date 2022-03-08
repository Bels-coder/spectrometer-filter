function M=jiramdati(varargin)


% se serve trasferire prima in locale per esempio:
% elena:161019_025913_JUNO_SPE_00 user$ rsync -a --include '*/' --include '*.txt' --exclude '*' /Volumes/ftp/JIRAM_ARCHIVE/JM_GSS/ /arc/jiram/
% elena:161019_025913_JUNO_SPE_00 user$ rsync -a --include '*/' --include '*.mat' --exclude '*' /Volumes/ftp/JIRAM_ARCHIVE/JM_GSS/ /arc/jiram/
N=nargin;

if any (strcmp(varargin,'-header'))
    varargin=setdiff(varargin,'-header');
    N=N-1;
    header=true;
elseif any (strcmp(varargin,'-h'))
    varargin=setdiff(varargin,'-h');
    N=N-1;
    header=true;
else
    header=false; % da usarsi nel futuro
end

if N==1
    M=myjiramdati(header,varargin{1});
elseif ischar(varargin{2})
    M=myjiramdati(header,varargin{1});
    for i=2:N
        while (1)
            try
                
                E=myjiramdati(header,varargin{i});
                break
            catch
                keyboard
            end
        end
        fi=fieldnames(E);
        for j=1:numel(fi)
            if size(E.(fi{j}),1)==1
                try % perche' RT a volte ce altre no
                    M.(fi{j})=[M.(fi{j}) E.(fi{j})];
			 catch
                end
            elseif size(E.(fi{j}),2)==1
                M.(fi{j})=[M.(fi{j}); E.(fi{j})];
                
            else
                
            end
            
        end
    end
else
    
    M=myjiramdati(header,varargin{:});
end


% =============================================================================================================
















