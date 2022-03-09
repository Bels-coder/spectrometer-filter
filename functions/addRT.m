function M=datart(M, mk, flag)
cspice_kclear;
if nargin>=2;
    cspice_furnsh({mk});
end


if nargin<3
    flag='no';
end






for h=1:numel(M.SCI_SCET)
    M.RT(h)=cspice_scs2e(-61999,M.SCLK_SCI{h});
    M.AN(h)=segno(M.NADIR_OFFSET_SIGN{h}) * str2num(M.SCI_NADIR_OFFSET{h})*0.003139005632771;
    
end





if strcmp(flag,'force')
    for i=1:numel(M.SCI_SCET)
        TT=[-16:.1:16];
        state = cspice_spkezr( 'Jupiter', M.RT(i)+TT, 'JUNO_JIRAM_S', 'CN+S', 'Juno' );
        x=state(1,:);
        z=state(3,:);
        alfa=-atan2(x,z)*180/pi;
        alfa(abs(diff(alfa))>180)=nan; % elimina il salto all'indietro
        TT=zerocrossing(alfa-M.AN(i),TT);
        M.RT(i)=M.RT(i)+TT(1);
    end
    
    
end







if nargin>=2;
    cspice_kclear
end

function s=segno(v)
switch(v)
    case('1')
        s=-1;
    case('0')
        s=1;
end

