function [ volume, weight, radius, CD ] = airship( l, FR )
%AIRSHIP Summary of this function goes here
%   Detailed explanation goes here

% engineeringtoolbox - STP
rhoH = 0.1664;

alpha = 15*pi()/180;

% Diameter and radius of front
D = l/FR;
rf = D/2;

a = 0.5;

while 1
    % values of the back hemisphere
    re = rf - a*sin(alpha);
    r = sqrt((re/tan(pi()/2-alpha))^2+re^2);
    h = r*(1 - cos(pi()/2-alpha));
    
    approx = (rf + a*(1 + cos(alpha)) + h);
    % length of the cylinder and cone
    error = (l - approx)/l;
    if abs(error) > 0.0001
        a = a + error;
    else
        break
    end
end

% volume of the system
vol(1, 1) = 2*pi()*rf^3 / 3;
vol(2, 1) = rf^2*pi()*a;
vol(3, 1) = pi()*a*cos(alpha)*(rf^2 + rf*re + re^2) / 3;
vol(4, 1) = pi()*h*(3*re^2 + h^2) / 6;

% CGs ref at centre of cylinder
x(1, 1) = a/2 + 4*rf/(3*pi());
x(2, 1) = 0; % reference point
x(3, 1) = -(a/2 + a*cos(alpha)/4 * (rf^2 + 2*rf*re + 3*rf^2)/(rf^2 + rf*re + rf^2));
x(4, 1) = -(a/2 + a*cos(alpha) + 3/4*(2*r - h)^2/(3*r - h) + h - r);

% SA to estiamte weight
SA(1, 1) = 2*pi()*rf^2;
SA(2, 1) = 2*pi()*rf*a;
SA(3, 1) = pi()*(rf + re)*sqrt((rf - re)^2 + a*cos(alpha));
SA(4, 1) = pi()*(re^2 + h^2);

% original approximation of airship
SAOrig = 4*pi()*0.637 + 2*2*pi()*0.637;
areaWeight = 0.525/SAOrig;

heliumWeight = vol(:)*rhoH;
plasticWeight = SA(:)*areaWeight;

weight = [ (heliumWeight + plasticWeight) x zeros(4, 1) zeros(4, 1)];

%--LOG

%--OUTPUTS
switch FR
	case 3.5
		CD = 0.254;
	case 4
		CD = 0.189;
	case 4.5
		CD = 0.159;
	otherwise
		CD = 0.254;
end

volume = sum(vol);
weight = centreMass(weight);
radius = rf;

%--SOLIDWORKS
airshipSW(radius, a)
end

function airshipLog(n, nReq, weight, thread)
%SHAFTLOG Outputs useful data to the log file
%   SHAFTLOG(n, nReq, weight, thread) returns nothing

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

cd(logFolder)
fid = fopen(logFile, 'a+');

% lines of the file
fprintf(fid, '\n***Thruster Shaft***\n');
fprintf(fid, ['Safety Factor: ' num2str(n) ]);

% display a message if the safety factor couldn't be acheived
if n < nReq
    fprintf(fid, ' ****This does not meet safety Factor\n');
else
    fprintf(fid, '\n');
end

fprintf(fid, ['Weight:        ' num2str(weight) ' g\n']);
fprintf(fid, ['Thread size:   M' num2str(thread) '\n']);

fclose(fid);
cd(MATLABFolder)
end

function airshipSW(radius, length)
%AIRSHIPSW Outputs data to solidworks for the envelope
%   AIRSHIPSW(radius, length) returns nothing

SWEnvFile = '1001-ENVELOPE-EQUATIONS.txt';
MATLABFolder = fullfile('../MATLAB');
SWFolder = fullfile('../Solidworks/Equations');

% write to the different solidworks files
cd(SWFolder)
fid = fopen(SWEnvFile, 'w+t');
fprintf(fid, ['"rblimp" = ' num2str(radius*1000) 'mm\n']);
fprintf(fid, ['"lblimpcylinder"= ' num2str(length*1000) 'mm\n']);
fclose(fid);
cd ..
cd(MATLABFolder)

disp('Envelope Parameterized in Solidworks');
end