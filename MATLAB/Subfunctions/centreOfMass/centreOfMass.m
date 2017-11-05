function CM = centreOfMass(M, loc, keelDist, radius)
%Finds the Centre of Mass using location of the Gondola

%Get the total mass of system
total = sum(M);
MTotal = total(1);

%Get the x-z position of gondola
pos = gondola(loc, keelDist, radius);

%Calculate the Centre of Mass
CM  = [((M(1, 2) + pos(1))*M(1, 1) + M(2, 2)*M(2, 1))/MTotal, ...
       ((M(1, 3) + pos(2))*M(1, 1) + M(2, 3)*M(2, 1))/MTotal];


function [x, z] = gondola(loc, keelDist, radius)
%Finds a x-z coordinate based on distance traveled along the keel
arcLength = radius*pi/2;

%Flat section of the keel
if loc <= 2000;
    x = loc - 1000;
    z = -(radius+keelDist);

%Curved section of the keel
elseif (loc > 2000) && (loc <= (2000 + arcLength));
    x = 1000 + radius*sin((loc-2000)/radius);
    z = -(radius*cos((loc-2000)/radius) + 25);

%Straight section above the curved part
elseif loc > (2000 + arcLength);
    x = 1000 + radius;
    z = loc - (2000 + arcLength + keelDist);
    
%Incase of weird scenario
else
    x = 0; z = 0;
    
end