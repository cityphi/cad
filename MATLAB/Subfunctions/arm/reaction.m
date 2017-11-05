function [ reactionForces ] = reaction( forces, react)
%REACTION Takes the input forces and locations and gives reaction forces
%   BUILDING FOR 1 REACTION FOR NOW

% Forces is [ locX locY locZ Fx Fy Fz Mx My Mz ] 
% Reaction is [ locX locY locZ Fx? Fy? Fz? Mx? My? Mz? ]

FRx = -sum(forces(:, 4));
FRy = -sum(forces(:, 5));
FRz = -sum(forces(:, 6));

MRx = dot(forces(:, 2) - react(1,2), forces(:, 6)) + ...
      dot(forces(:, 3) - react(1,3), forces(:, 5)) + sum(forces(:, 7));
MRy = dot(forces(:, 1) - react(1,1), forces(:, 6)) + ...
      dot(forces(:, 3) - react(1,3), forces(:, 4)) + sum(forces(:, 8));
MRz = dot(forces(:, 1) - react(1,2), forces(:, 5)) + ...
      dot(forces(:, 2) - react(1,2), forces(:, 4)) + sum(forces(:, 9));

reactionForces = [react(1) react(2) react(3) FRx FRy FRz MRx MRy MRz];
end