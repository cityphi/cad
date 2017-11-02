function force = thrust(diameter, pitch, RPM, speed)
d = diameter; % Has to be in
p = pitch; % Has to be in
v = speed; % Has to be m/s
r = RPM;
force = 1.225*pi*(0.0254*d)^2/4*((r*0.0254*p/60)^2-v*(r*0.0254*p/60))* ...
    (d/(p*3.29546))^1.5;