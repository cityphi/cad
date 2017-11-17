%Forces is [locX locY locZ Fx Fy Fz Mx My Mz] 
%Test for forces acting on gondola driving motor

Tw = 0.1;             %motor torque
Ls = 0.04;             %distance between screws
Lhs = 0.05;            %length from motor hinge axle to motor mount screws
Lsw = 0.015;            %length from motor mount screw to friction wheel contact point
La = 0.01;             %length from motor hinge axle to gondola screw a 
Lb = 0.03;             %length from motor hinge axle to gondola screw b 
Hsw = 0.024;            %height of friction wheel contact point off hinge
rFw = 0.0127;       %friction wheel radius
Mu = 0.65;          %frictionwheel to keel coefficient of friction
Muwasher = 0.2;     %washer to gondola coefficent of friction
Dscrew = 0.003;     %gondola/hinge screw diameter 
Dwashero = 0.005;   %outer washer diameter
Dwasheri = 0.003;   %inner washer diameter
Scompressive = 55;  %The compressive yield strength of Nylon 6 [Mpa]
Lgond = 0.15        %length of one gondola car
Wgond = 0.075       %width of gondola 

Tspring = 1.5 * (Tw * (Lhs+Lsw))/(rFw * Mu); %spring torque

Fspring =  Tspring /(Lhs); %force of spring acting on friction wheel
Fnfric =  -Fspring; % normal force of frction wheel equal to spring for
Fw = Tw/rFw;

% position with reference to center of hinge axle 
motorForces = [
    0 Lhs+Lsw Hsw Fw 0 Fnfric 0 0 0;     %friction owheel contact point forces
  %  -0.5*Ls Lhs 0 0 0 0.5*Fspring 0 0 0;  %spring forces acting on screw 1
  %   0.5*Ls Lhs 0 0 0 0.5*Fspring 0 0 0;  %spring forces acting on screw 2 
  %  0 0 0 0 0 0 Tw 0 0;
    ];

 hingeReactions = [ %-0.5*Ls La 0 1 1 1 0 1 0; 
                   %0.5*Ls Lb 0 1 0 1 0 0 0;];
                    0 0 0 1 1 1 1 1 1;];

 hingeForce = -forceSolver(motorForces, hingeReactions)

 %rotating hinge force to gondola coordinate system
    hingeForce(1,4) = hingeForce(1,4);
    hingeForce(1,5) = ((sqrt(2)/2)*(hingeForce(1,5)+hingeForce(1,6)));
    hingeForce(1,6) = ((sqrt(2)/2)*(hingeForce(1,5)+hingeForce(1,6)));
    hingeForce(1,7) = hingeForce(1,7);
    hingeForce(1,8) = ((sqrt(2)/2)*(hingeForce(1,8)+hingeForce(1,9)));
    hingeForce(1,9) = ((sqrt(2)/2)*(hingeForce(1,8)+hingeForce(1,9)));
    

gondScrewReactionsWorst = [ -0.5*Ls La 0 1 1 1 2 2 0; 
                        0.5*Ls Lb 0 0 1 0 2 2 0;];

gondScrewReactionsWorstSolved = forceSolver(hingeForce, gondScrewReactionsWorst)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating compressive safety factor for screw
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Fbolt = sqrt(gondScrewReactionsWorstSolved(1,4)^2+gondScrewReactionsWorstSolved(1,5)^2)... 
    /Muwasher + gondScrewReactionsWorstSolved(1,6);

Ncompressive = Scompressive*10^6/ (Fbolt/(pi*(0.5*(Dwashero-Dwasheri))^2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating Gondola arm forces 
%assumptions: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Calculating Gondola acceleration 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% screwReactionsFixed(1,4) = 0.5*screwReactionsFixed(1,4);
% screwReactionsFixed(2,4) = screwReactionsFixed(1,4);
% screwReactionsFixed(1,7) = 0.5*screwReactionsFixed(1,7);
% screwReactionsFixed(2,7) = screwReactionsFixed(1,7);
% screwReactionsFixed(1,6) = screwReactionsFixed(1,6);
% screwReactionsFixed(2,6) = screwReactionsFixed(2,6);
% 
% fprintf ('displaying screwReactionsFixed\n');
% disp(screwReactionsFixed)
% 
% %rotating for hinge coordinate system 
% 
% screwForce = zeros(3,9);
% 
% for n = 1:2
%     screwForce(n,1) = screwReactionsFixed(n,1);
%     for i = 2:3
%         screwForce(n,i) = (sqrt(2)/2)*screwReactionsFixed(n,2);
%     end
%     screwForce(n,4) = -screwReactionsFixed(n,4);
%     screwForce(n,5) = -((sqrt(2)/2)*(screwReactionsFixed(n,5)+screwReactionsFixed(n,6)));
%     screwForce(n,6) = -((sqrt(2)/2)*(screwReactionsFixed(n,5)+screwReactionsFixed(n,6)));
%     screwForce(n,7) = -screwReactionsFixed(n,7);
%     screwForce(n,8) = -((sqrt(2)/2)*(screwReactionsFixed(n,8)+screwReactionsFixed(n,9)));
%     screwForce(n,9) = -((sqrt(2)/2)*(screwReactionsFixed(n,8)+screwReactionsFixed(n,9)));
% end
%     screwForce(3,7) = -screwReactionsFixed(3,7);
%     
% fprintf ('displaying screwForce\n');
% disp(screwForce)

%gondola screw reactions
% 
% gondScrewReactions = [ -0.5*Ls La 0 1 1 1 0 0 0; 
%                        0.5*Ls Lb 0 1 1 1 0 0 0;
%                        0 0 0 0 0 0 1 0 0 ];
% 
% gondScrewReactionsFixed = forceSolver(screwForce, gondScrewReactions)