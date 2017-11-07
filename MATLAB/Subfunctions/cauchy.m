function [ n ] = cauchy( s, Sut, Suc )
%CAUCHY uses cauchy tensor to get a safety factor
%   n = cauchy(s, Sut, Suc) takes the cauchy tensor s and material
%   information (Ultimate tensile and compression) to calculate the safety
%   factor.
%   The method this is using the the Mohr-Coulomb failure model adapted for
%   brittle materials. It uses the cauchy tensor to get the three
%   principal stresses then uses them to find the safety factor.
%
%   Tensor is of form (S is sigma, t is tau):
%   | Sx  txy txz |
%   | txy Sy  tyz |
%   | txz tyz Sz  |

% coefficients of the charateristic equation
I1 = trace(s);
I3 = det(s);
I2 = s(1, 1)*s(2, 2) + s(2, 2)*s(3, 3) + s(1, 1)*s(3, 3) - s(1, 2)^2 - ...
    s(2, 3)^2 - s(3, 1)^2;

% characteristic equation
char = [-1 I1 -I2 I3];

% get the sigmas and find the ones needed
sigmas = roots(char);

sigma1 = max(sigmas);
sigma3 = min(sigmas);

% brittle-mohr-coulomb
if sigma1 >= 0 && sigmaB3 >= 0
    n = Sut/sigma1;
    
elseif sigma1 >= 0 && sigma3 <= 0
    n = Sut*Suc/(Suc*sigma1-Sut*sigma3);
    
else
    n = -Suc/sigma3;
end