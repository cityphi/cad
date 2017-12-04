function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 04-Dec-2017 17:16:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%Set the default values on the GUI. It is recommended to choose a valid set 
%of default values as a starting point when the program launches.
%clc

defaultSpeed  = 8;
defaultWeight = 200;
defaultTime   = 30;
defaultLength = 3.5;

% set sliders
set(handles.sliderReqTime,'Value',defaultTime);
set(handles.sliderReqWeight,'Value',defaultWeight);
set(handles.sliderReqSpeed,'Value',defaultSpeed);

% set slider values
set(handles.textTimeValue,'String',num2str(defaultTime));
set(handles.textWeightValue,'String',num2str(defaultWeight));
set(handles.textSpeedValue,'String',num2str(defaultSpeed));

% set length
set(handles.editLength, 'String', num2str(defaultLength));

%Set the window title with the group identification:
set(handles.figure1,'Name','Group RE3 // CADCAM 2017');

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Executes on button press in generate.
function generate_Callback(hObject, eventdata, handles)
% hObject    handle to generate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(isempty(handles))
    Wrong_File();
else
    %Get the design parameters from the interface
    
    addpath(genpath(pwd));
    
    reqTime = get(handles.sliderReqTime, 'Value');
    reqWeight = get(handles.sliderReqWeight, 'Value');
    reqSpeed = get(handles.sliderReqSpeed, 'Value');
    
    kill = calculate_Callback(0, 0, handles);
    if kill
        return
    end
    
    airshipLength = str2double(get(handles.editLength, 'String'));
    finessRatio = str2double(get(handles.editFinenessRatio,'String'));
    
    % check that the blimp geometry is sovleable.
    rf = airshipLength/finessRatio/2;
    alpha = 10*pi()/180;
    L = @(a) rf - (-(rf - a*sin(alpha))^2/(sin(alpha)^2 - 1))^(1/2) ...
        *(sin(alpha) - 1) + a*(cos(alpha) + 1); % used matlab to simplify
    a = fzero(@(a) L(a) - airshipLength, 0);
    backRadius = (rf - a*sin(alpha))*1000;
    
    if isnan(airshipLength) || (airshipLength <=0) || (backRadius < 50)
        msgbox('Shaft length and/or Fineness results in an invalid value.','Cannot generate!','error');
        return;
    end
    
    scenario = get(handles.buttonWeight, 'Value') + get(handles.buttonSpeed, 'Value')*2 + get(handles.buttonTime, 'Value')*3;
    
    %The design calculations are done within this function. This function is in
    %the file Design_code.m
    
    designCode([reqSpeed, reqTime, reqWeight], scenario, airshipLength, finessRatio);
    
end

% --- Executes on button press in calculate.
function kill = calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% kill       value to pass back to generate if there are issues

kill = 0;

L = str2double(get(handles.editLength, 'String'));
FR = str2double(get(handles.editFinenessRatio,'String'));
D = str2double(get(handles.editDiameter, 'String'));

if isnan(L) || isnan(FR) || isnan(D)
    if ~isnan(L) && ~isnan(FR)
        set(handles.editDiameter, 'String', num2str(L/FR))
    elseif ~isnan(L) && ~isnan(D)
        set(handles.editFinenessRatio, 'String', num2str(L/D))
    elseif ~isnan(FR) && ~isnan(D)
        set(handles.editLength, 'String', num2str(FR*D))
    else
        msgbox('Enter atleast two of Length, Diameter, or Fineness Ratio.','Missing Inputs','error');
        kill = 1;
        return
    end
else
    set(handles.editFinenessRatio, 'String', num2str(L/D))
end

L = str2double(get(handles.editLength, 'String'));
FR = str2double(get(handles.editFinenessRatio,'String'));
D = str2double(get(handles.editDiameter, 'String'));

rf = D/2;
alpha = 10*pi()/180;
length = @(a) rf - (-(rf - a*sin(alpha))^2/(sin(alpha)^2 - 1))^(1/2) ...
    *(sin(alpha) - 1) + a*(cos(alpha) + 1); % used matlab to simplify
a = fzero(@(a) length(a) - L, 0);

set(handles.textSectionLength, 'String', ['Section Length: ' num2str(a) 'm'])
if a > convlength(60, 'in', 'm')
    msgbox('Section length greater than specified maximum of 60" (1524mm). Can still generate, but may have some issues or incorrect values','Envelope Dimensions out of Range','warn');
elseif a < 1.093
    msgbox('Section length too small. SolidWorks will have a build error. Analysis may still work depending on the values.','Section Length too Small','error');
elseif FR > 4 || FR < 3.4
    msgbox('Fineness Ratio outside of range (3.4 - 4). Drag data is not specified outside this range and there may be issues with volume', 'Fineness Ratio out of range', 'warn');
end

% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderReqWeight_Callback(hObject, eventdata, handles)
% hObject    handle to sliderReqWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(isempty(handles))
    Wrong_File();
else
    value = round(get(hObject,'Value'));
    set(handles.textWeightValue,'String',num2str(value));
end


% --- Executes during object creation, after setting all properties.
function sliderReqWeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderReqWeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderReqSpeed_Callback(hObject, eventdata, handles)
% hObject    handle to sliderReqSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(isempty(handles))
    Wrong_File();
else
    value = round(get(hObject,'Value'), 1);
    set(handles.textSpeedValue,'String',num2str(value));
end


% --- Executes during object creation, after setting all properties.
function sliderReqSpeed_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderReqSpeed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderReqTime_Callback(hObject, eventdata, handles)
% hObject    handle to sliderReqTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
if(isempty(handles))
    Wrong_File();
else
    value = round(get(hObject,'Value'));
    set(handles.textTimeValue,'String',num2str(value));
end


% --- Executes during object creation, after setting all properties.
function sliderReqTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderReqTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function groupDriving_CreateFcn(hObject, eventdata, handles)
% hObject    handle to butttttton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function editDiameter_Callback(hObject, eventdata, handles)
% hObject    handle to editDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDiameter as text
%        str2double(get(hObject,'String')) returns contents of editDiameter as a double

% --- Executes during object creation, after setting all properties.
function editLength_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editLength (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function editDiameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function editFinenessRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFinenessRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function editLength_Callback(hObject, eventdata, handles)
% hObject    handle to editDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDiameter as text
%        str2double(get(hObject,'String')) returns contents of editDiameter as a double

function editFinenessRatio_Callback(hObject, eventdata, handles)
% hObject    handle to editDiameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editDiameter as text
%        str2double(get(hObject,'String')) returns contents of editDiameter as a double
