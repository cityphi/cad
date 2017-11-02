function pos = gondola(loc, dim, keelDist, radius)
arcLength = radius*pi/2;
if dim == 'x';
    if loc <= 2000;
        pos = loc - 1000;
    elseif (loc > 2000) && (loc <= (2000 + arcLength));
        pos = 1000 + radius*sin((loc-2000)/radius);
    elseif loc > (2000 + arcLength);
        pos = 1000 + radius;
    else
        pos = 0; 
    end
elseif dim == 'z';
    if loc <= 2000;
        pos = -(radius+keelDist);
    elseif (loc > 2000) && (loc <= (2000 + arcLength));
        pos = -(radius*cos((loc-2000)/radius) + 25);
    elseif loc > (2000 + arcLength);
        pos = loc - (2000 + arcLength + keelDist);
    else
        pos = 0;
    end
else
    pos = 0;
end
