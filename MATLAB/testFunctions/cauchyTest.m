function [ result ] = cauchyTest( )
%CAUCHYTEST Summary of this function goes here
%   Detailed explanation goes here

result = 'Pass';

%---Scenario 1 - Shigley (simple)
tensor = [ 23814.2 12758.8 0 ;
           12758.8 0       0 ;
           0       0       0 ];
       
Sut = 31000;
Suc = 109000;
       
expected = 1.20;
output = cauchy(tensor, Sut, Suc);

if  isequal(round(output, 3), round(expected, 3)) == 0
     result = 'Fail';  
end
end