function varargout = fig_layout(varargin)
% FIG_LAYOUT MATLAB code for fig_layout.fig
%      FIG_LAYOUT, by itself, creates a new FIG_LAYOUT or raises the existing
%      singleton*.
%
%      H = FIG_LAYOUT returns the handle to a new FIG_LAYOUT or the handle to
%      the existing singleton*.
%
%      FIG_LAYOUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIG_LAYOUT.M with the given input arguments.
%
%      FIG_LAYOUT('Property','Value',...) creates a new FIG_LAYOUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fig_layout_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fig_layout_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fig_layout

% Last Modified by GUIDE v2.5 16-Mar-2016 14:20:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fig_layout_OpeningFcn, ...
                   'gui_OutputFcn',  @fig_layout_OutputFcn, ...
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


% --- Executes just before fig_layout is made visible.
function fig_layout_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fig_layout (see VARARGIN)

% Choose default command line output for fig_layout
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fig_layout wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fig_layout_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function editHostIP_Callback(hObject, eventdata, handles)
% hObject    handle to editHostIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editHostIP as text
%        str2double(get(hObject,'String')) returns contents of editHostIP as a double


% --- Executes during object creation, after setting all properties.
function editHostIP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editHostIP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btConnect.
function btConnect_Callback(hObject, eventdata, handles)
% hObject    handle to btConnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in lstChannels.
function lstChannels_Callback(hObject, eventdata, handles)
% hObject    handle to lstChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstChannels contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstChannels


% --- Executes during object creation, after setting all properties.
function lstChannels_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstChannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkFilter.
function chkFilter_Callback(hObject, eventdata, handles)
% hObject    handle to chkFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkFilter


% --- Executes on button press in chkDemod.
function chkDemod_Callback(hObject, eventdata, handles)
% hObject    handle to chkDemod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkDemod



function editFiltFreq_Callback(hObject, eventdata, handles)
% hObject    handle to editFiltFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFiltFreq as text
%        str2double(get(hObject,'String')) returns contents of editFiltFreq as a double


% --- Executes during object creation, after setting all properties.
function editFiltFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFiltFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFiltBW_Callback(hObject, eventdata, handles)
% hObject    handle to editFiltBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFiltBW as text
%        str2double(get(hObject,'String')) returns contents of editFiltBW as a double


% --- Executes during object creation, after setting all properties.
function editFiltBW_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFiltBW (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editRange_Callback(hObject, eventdata, handles)
% hObject    handle to editRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editRange as text
%        str2double(get(hObject,'String')) returns contents of editRange as a double


% --- Executes during object creation, after setting all properties.
function editRange_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editRange (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popFiltOrder.
function popFiltOrder_Callback(hObject, eventdata, handles)
% hObject    handle to popFiltOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popFiltOrder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popFiltOrder


% --- Executes during object creation, after setting all properties.
function popFiltOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popFiltOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editTime_Callback(hObject, eventdata, handles)
% hObject    handle to editTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editTime as text
%        str2double(get(hObject,'String')) returns contents of editTime as a double


% --- Executes during object creation, after setting all properties.
function editTime_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTime (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFiltUpdate_Callback(hObject, eventdata, handles)
% hObject    handle to editFiltUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFiltUpdate as text
%        str2double(get(hObject,'String')) returns contents of editFiltUpdate as a double


% --- Executes during object creation, after setting all properties.
function editFiltUpdate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFiltUpdate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in chkDC.
function chkDC_Callback(hObject, eventdata, handles)
% hObject    handle to chkDC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkDC



function editFMin_Callback(hObject, eventdata, handles)
% hObject    handle to editFMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFMin as text
%        str2double(get(hObject,'String')) returns contents of editFMin as a double


% --- Executes during object creation, after setting all properties.
function editFMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFMax_Callback(hObject, eventdata, handles)
% hObject    handle to editFMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editFMax as text
%        str2double(get(hObject,'String')) returns contents of editFMax as a double


% --- Executes during object creation, after setting all properties.
function editFMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in btnSave.
function btnSave_Callback(hObject, eventdata, handles)
% hObject    handle to btnSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
