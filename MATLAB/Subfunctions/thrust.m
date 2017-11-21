function force = thrust(diameter, pitch, rpm, v)
%THRUST Calculates thrust force
%   F = THRUST(d, pitch, rpm, v) returns the amount of force exherted by
%   the propeller based on the inputs
%
%   diameter (m)   - total diamter of the propellers   
%   pitch    (m)   - pitch of the propellers
%   rpm            - rpm of the propellers
%   v        (m/s) - forward speed of the airship

% need to use in for the equation
d = diameter / 25.4 * 1000; 
p = pitch / 25.4 * 1000;

force = 1.225*pi * ((0.0254 * d)^2)/4 * ((rpm * 0.0254 * p/60)^2 - v * ...
    (rpm * 0.0254 * p/60)) * (d/(p*3.29546))^1.5;
end