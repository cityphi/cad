function force = centreMass( weights, a )
%CENTREMASS Change masses into a point force
%   F = CENTREMASS(W, a) returns a force vector which is a point force from
%   all the weights given to the function. It uses the pitch angle of the
%   airship to create the forces in the primary coordinate system. The
%   location of the force will be in relation to the reference point of the
%   weights array.
%   This function will not work for roll.
%
%   W [ weight locX locY locZ ] - weights
%   a [ pitchAngle ] - current pitch angle of the airship
%   
%   Output:
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - point force output

% total weight of the system
M = sum(weights(:, 1));

% location of the centre of mass
CM = transp(weights(:, 1)) * weights(:, 2:4)/M;

% build the point force
force = [ CM M*sin(a) 0 -M*cos(a) 0 0 0];
end