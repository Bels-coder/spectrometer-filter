function M=selectdata(M,arg)

if ischar(arg)
     type=arg;
     i=strcmp(M.ACQ_TYPE,type) | strcmp(M.mode_id,type);
else
     i=arg;
end
tmt=[M.file '.selected'];
tmt_=M.file_ ;


w=fieldnames(M);
for j=1:numel(w);
     try
          M.(w{j})=M.(w{j})(i);
     end
end

M.file=tmt;
M.file_=tmt_;