function varargout = VoltageInputs(varargin)
% VOLTAGEINPUTS MATLAB code for VoltageInputs.fig
%      VOLTAGEINPUTS, by itself, creates a new VOLTAGEINPUTS or raises the existing
%      singleton*.
%
%      H = VOLTAGEINPUTS returns the handle to a new VOLTAGEINPUTS or the handle to
%      the existing singleton*.
%
%      VOLTAGEINPUTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VOLTAGEINPUTS.M with the given input arguments.
%
%      VOLTAGEINPUTS('Property','Value',...) creates a new VOLTAGEINPUTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VoltageInputs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VoltageInputs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VoltageInputs

% Last Modified by GUIDE v2.5 11-Jun-2018 11:45:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VoltageInputs_OpeningFcn, ...
                   'gui_OutputFcn',  @VoltageInputs_OutputFcn, ...
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


% --- Executes just before VoltageInputs is made visible.
function VoltageInputs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VoltageInputs (see VARARGIN)

% Choose default command line output for VoltageInputs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VoltageInputs wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VoltageInputs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Min_Ii_Callback(hObject, eventdata, handles)
% hObject    handle to Min_Ii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Min_Ii as text
%        str2double(get(hObject,'String')) returns contents of Min_Ii as a double


% --- Executes during object creation, after setting all properties.
function Min_Ii_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Min_Ii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Max_Ii_Callback(hObject, eventdata, handles)
% hObject    handle to Max_Ii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Max_Ii as text
%        str2double(get(hObject,'String')) returns contents of Max_Ii as a double


% --- Executes during object creation, after setting all properties.
function Max_Ii_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max_Ii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Min_Ipe_Callback(hObject, eventdata, handles)
% hObject    handle to Min_Ipe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Min_Ipe as text
%        str2double(get(hObject,'String')) returns contents of Min_Ipe as a double


% --- Executes during object creation, after setting all properties.
function Min_Ipe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Min_Ipe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Max_Ipe_Callback(hObject, eventdata, handles)
% hObject    handle to Max_Ipe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Max_Ipe as text
%        str2double(get(hObject,'String')) returns contents of Max_Ipe as a double


% --- Executes during object creation, after setting all properties.
function Max_Ipe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max_Ipe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Min_Ie_Callback(hObject, eventdata, handles)
% hObject    handle to Min_Ie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Min_Ie as text
%        str2double(get(hObject,'String')) returns contents of Min_Ie as a double


% --- Executes during object creation, after setting all properties.
function Min_Ie_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Min_Ie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Max_Ie_Callback(hObject, eventdata, handles)
% hObject    handle to Max_Ie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Max_Ie as text
%        str2double(get(hObject,'String')) returns contents of Max_Ie as a double


% --- Executes during object creation, after setting all properties.
function Max_Ie_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max_Ie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Update.
function Update_Callback(hObject, eventdata, handles)
% hObject    handle to Update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    uiresume    

% --- Executes on button press in Continue.
function Continue_Callback(hObject, eventdata, handles)
% hObject    handle to Continue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global flagContinue
    flagContinue = 1;
    uiresume


% --- Executes on button press in ContinueRun.
function ContinueRun_Callback(hObject, eventdata, handles)
% hObject    handle to ContinueRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global flagContinue UI_off
    UI_off = true;
    flagContinue = 1;
    uiresume

% --- Executes on button press in ContinueAllRuns.
function ContinueAllRuns_Callback(hObject, eventdata, handles)
% hObject    handle to ContinueAllRuns (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global UI_off ContinueRuns flagContinue
    UI_off = true;
    flagContinue = 1;
    ContinueRuns = true;
    uiresume