function FocusToFig(ObjH, EventData)  %#ok<INUSD>
% Move focus to figure
% FocusToFig(ObjH, [DummyEventData])
% INPUT:
%   ObjH: Handle of a graphics object. It is tried to move the focus to the
%         parent figure and making it the CurrentFigure of the root object.
%   DummyEventData: The 2nd input is optional and ignored.
%
% Tested: Matlab 6.5, 7.7, 7.8, WinXP
% Author: Jan Simon, Heidelberg, (C) 2009-2011

if any(ishandle(ObjH))   % Catch no handle and empty ObjH
   FigH = ancestor(ObjH, 'figure');
   if strcmpi(get(ObjH, 'Type'), 'uicontrol')
      set(ObjH, 'enable', 'off');
      drawnow;
      set(ObjH, 'enable', 'on');
   end

     % Methods according to the documentation (does not move the focus for
     % keyboard events under Matlab 5.3, 6.5, 2008b, 2009a):
     figure(FigH);
     set(0, 'CurrentFigure', FigH);
end

return;
