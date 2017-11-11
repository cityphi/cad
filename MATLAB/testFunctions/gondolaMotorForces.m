%Forces is [locX locY locZ Fx Fy Fz Mx My Mz] 
%Test for forces acting on gondola driving motor

Tw = 4;   %motor torque
Ls = 4;   %distance between screws
Lhs = 5;  %length from motor hinge axle to motor mount screws
Lsw = 1;  %length from motor mount screw to friction wheel contact point
La = 1;   %length from motor hinge axle to gondola screw a 
Lb = 3;   %length from motor hinge axle to gondola screw b 
Hsw = 2;  %height of friction wheel contact point off hinge
rFw = 1;  %friction wheel radius
Mu = 0.5; %frictionwheel to keel coefficient of friction

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

hingeReactions = [ %-0.5*Ls Lhs 0 1 1 0 0 0 0; 
                   % 0.5*Ls Lhs 0 0 1 0 0 0 0;
                    0 0 0 1 1 1 1 1 1;];

hingeForce = -forceSolver(motorForces, hingeReactions)

%gondola screw reactions

gondScrewReactions = [ -0.5*Ls La 0 1 1 1 0 0 0; 
                       0.5*Ls Lb 0 1 1 1 0 0 0;];

gondScrewReactionsFixed = forceSolver(hingeForce, gondScrewReactions);



%adjusting for proper reactions 

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