function force = thrust(D, P, n, V)
%THRUST Calculates thrust force
%   F = THRUST(d, pitch, rpm, v) returns the amount of force exherted by
%   the propeller based on the inputs
%
%   diameter (m)   - total diamter of the propellers   
%   pitch    (m)   - pitch of the propellers
%   n        (rpm) - rpm of the propellers
%   v        (m/s) - forward speed of the airship

force = 0.20477 * (pi*D^2)/4 * (D/P)^1.5 * ((P * n/60)^2 - V*P * n/60);
end