function [ ] = armGraphCrossSection( forces, dimensions, material )
%ARMGRAPHCROSSSECTION graphs the safety factor across the cross section
%   This function is typically used by armFindWorstCase.m to graph the
%   worst case but can be used by anything as long as all the forces acting
%   on the face are given.
%   forces is [ locX locY locZ Fx Fy Fz Mx My Mz ] acting at that point
%   dimensions is [ ri h k ] of the arm
%   material is [density Sut Suc] of the material

% set easy to read variables
h = dimensions(2);
k = dimensions(3);

% change plots for the number of locations to evaluate the safety factor
plots = 50;
plotsCount = plots - 1;

% make the arrays used to store data
X = zeros(plots); Y = zeros(plots); Z = zeros(plots);

% loop to get the safety factor at different locations on the cross-seciton
i = 1; j = 1;
for z = -h/2:h/plotsCount:h/2
    for x = -k/2:k/plotsCount:k/2
        stressTensor = armFailure(forces, dimensions, [x,z]);
        n = cauchy(stressTensor, material(2), material(3));
        X(i, j) = x; Y(i, j) = z; Z(i, j) = n;
        if i == plots
            i = 1;
            j = j + 1;
        else
            i = i + 1;
        end
    end
end

% graph the safety factor across the face
surf(X*10^3, Y*10^3, Z)
title('Safety Factor Across the Cross-Section')
xlabel('X-Distance [mm]')
ylabel('Y-Distance [mm]')
colormap(flipud(winter))
shading interp
colorbar
view(0, 90)

end

