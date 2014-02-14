function [bottom, top, button, flag] = zoom_y(varargin)

%zoom in to y axes of current axes
%select top and bottom boundaries with left and right mouse buttons
%hit any key when done (q to quit without updating)
%returns flag of 0 if there has been no change, else 1
%returns the key that was used on exit in "button" 
%returns new top and bottom axis values

if nargin == 0
  do_patch = 1;
  h_axis_zoom = gca;
elseif nargin == 1
  do_patch = varargin{1};
  h_axis_zoom = gca;
elseif nargin > 1
  do_patch = varargin{1};
  h_axis_zoom = varargin{2};
end

%get new top and bottom values
[bottom, top, button, flag] = get_yrange(do_patch, h_axis_zoom);

%if there are changes, redisplay
 if flag == 1;
   ylim=[bottom, top];
   set(gca,'ylim', ylim)
 end
 

            
   
