function CG = centreOfMass(M, loc, keelDist, radius)
total = sum(M);
MTotal = total(1);
pos = [gondola(loc, 'x', keelDist, radius) ...
    gondola(loc, 'z', keelDist, radius)];

DistX = (M(1, 2) + pos(1))*M(1, 1) + M(2, 2)*M(2, 1);
DistZ = (M(1, 3) + pos(2))*M(1, 1) + M(2, 3)*M(2, 1);

CG = [DistX/MTotal DistZ/MTotal];
