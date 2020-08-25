function varargout = NumericInputs(varargin)
% NUMERICINPUTS MATLAB code for NumericInputs.fig
%      NUMERICINPUTS, by itself, creates a new NUMERICINPUTS or raises the existing
%      singleton*.
%
%      H = NUMERICINPUTS returns the handle to a new NUMERICINPUTS or the handle to
%      the existing singleton*.
%
%      NUMERICINPUTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUMERICINPUTS.M with the given input arguments.
%
%      NUMERICINPUTS('Property','Value',...) creates a new NUMERICINPUTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NumericInputs_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NumericInputs_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NumericInputs

% Last Modified by GUIDE v2.5 11-Jun-2018 11:39:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NumericInputs_OpeningFcn, ...
                   'gui_OutputFcn',  @NumericInputs_OutputFcn, ...
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


% --- Executes just before NumericInputs is made visible.
function NumericInputs_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NumericInputs (see VARARGIN)

% Choose default command line output for NumericInputs
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes NumericInputs wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = NumericInputs_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function PolyOrder_Callback(hObject, eventdata, handles)
% hObject    handle to PolyOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of PolyOrder as text
%        str2double(get(hObject,'String')) returns contents of PolyOrder as a double


% --- Executes during object creation, after setting all properties.
function PolyOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PolyOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function WinLen_Callback(hObject, eventdata, handles)
% hObject    handle to WinLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WinLen as text
%        str2double(get(hObject,'String')) returns contents of WinLen as a double


% --- Executes during object creation, after setting all properties.
function WinLen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WinLen (see GCBO)
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


% --- Executes on button press in Abort.
function Abort_Callback(hObject, eventdata, handles)
% hObject    handle to Abort (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global flagAbort
    flagAbort = 1;
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


% --- Executes on button press in ContinueRun.
function ContinueRun_Callback(hObject, eventdata, handles)
% hObject    handle to ContinueRun (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global flagContinue UI_off
    UI_off = true;
    flagContinue = 1;
    uiresume