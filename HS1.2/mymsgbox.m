function msgHandle = mymsgbox(msg,varargin)
fontName = 'Arial';
fontSize = 18;
msgHandle = msgbox( msg, varargin{:});
% fprintf('%s\n',msg);

%set( msgHandle, 'Visible', 'off' );
% get handles to the UIControls ([OK] PushButton) and Text
kids0 = findobj( msgHandle, 'Type', 'UIControl' );
kids1 = findobj( msgHandle, 'Type', 'Text' );
set(msgHandle,'color',[0.3 0.3 0.3]);

% change the font and fontsize
extent0 = get( kids1, 'Extent' );       % text extent in old font
set( [kids0(:)', kids1], 'FontName', fontName, 'FontSize', fontSize ,'Fontweight', 'bold');
set(kids0,'units','normalized','backgroundcolor',[0.831373 0.815686 0.784314]);
set(kids1,'color',[0.831373 0.815686 0.784314]);
extent1 = get( kids1, 'Extent' );       % text extent in new font

pos = get(kids0,'position');
set(kids0,'units','normalized','position',[0.9-pos(3) pos(2) pos(3) pos(4)]);

% need to resize the msgbox object to accommodate new FontName
% and FontSize
delta = extent1 - extent0;              % change in extent
pos = get( msgHandle, 'Position' );     % msgbox current position
pos = pos + delta;                      % change size of msgbox
set( msgHandle, 'Position', pos );      % set new position
centerfig(msgHandle,1);
set( msgHandle, 'Visible', 'on' ); 
