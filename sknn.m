function varargout = sknn(varargin)
% SKNN MATLAB code for sknn.fig
%      SKNN, by itself, creates a new SKNN or raises the existing
%      singleton*.
%
%      H = SKNN returns the handle to a new SKNN or the handle to
%      the existing singleton*.
%
%      SKNN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SKNN.M with the given input arguments.
%
%      SKNN('Property','Value',...) creates a new SKNN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sknn_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sknn_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sknn

% Last Modified by GUIDE v2.5 25-Jan-2017 15:14:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sknn_OpeningFcn, ...
                   'gui_OutputFcn',  @sknn_OutputFcn, ...
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


% --- Executes just before sknn is made visible.
function sknn_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sknn (see VARARGIN)

% Choose default command line output for sknn
handles.output = hObject;
warning('off','all')
movegui('center');
% Update handles structure
guidata(hObject, handles);
set(handles.cmdTest,'Enable','off');
dfd = get(handles.txtTF,'String');
if isempty(dfd)
    set(handles.listbox3,'String','');
end 

% UIWAIT makes sknn wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sknn_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function pushbutton1_Callback(hObject, eventdata, handles)
set(handles.listbox3,'String','');
dfd = get(handles.txtTF,'String');
dname = uigetdir(dfd);
if ~isempty(dname) && ~isequal(dname,0)
    set(handles.checkbox1,'Value',0);
    set(handles.cmdTest,'Enable','off');
    set(handles.txtTF,'String',dname);
    d = dir(dname);
    isub = [d(:).isdir]; %# returns logical vector
    dirNames = {d(isub).name};
    dirNames(ismember(dirNames,{'.','..'})) = [];
    if ~isempty(dirNames)
        if length(dirNames)>1
        for i=1:length(dirNames)
            nmdt{i} = dirNames{i};
        end
        set(handles.listbox3,'String',nmdt);
        else
        set(handles.listbox3,'String',dirNames{1});
        end
    end
    if exist(strcat(dname,'\groups.dat'),'file')
        delete(strcat(dname,'\groups.dat'));
    end
    alis = get(handles.listbox3,'String');
    nalis = length(alis);
    dcid = fopen(strcat(dname,'\groups.dat'),'w');
    if nalis>0
        for j=1:nalis
            fprintf(dcid,'%s\n',strcat(alis{j},''));
        end    
    end
    fclose(dcid);
    ctf = strcat(dname,'\train.dat');
    if exist(ctf,'file')
       set(handles.checkbox1,'Value',1);
    end
    ftest = get(handles.txtDF,'String');
    if ~isempty(ftest) && exist(ftest,'file')
        set(handles.cmdTest,'Enable','on');
    end

end

function cmdLoad_Callback(hObject, eventdata, handles)
ftf = get(handles.txtDF,'String');
set(handles.cmdTest,'Enable','off');
[filename, pathname] = uigetfile( ...
  {'*.jpg;*.jpeg','JPG/JPEG-files (*.jpg, *.jpeg)'; ...
   '*.*',  'All Files (*.*)'}, ...
   'Pick a file', ...
   ftf);
set(handles.txtDF,'String',fullfile(pathname,filename));
I = imread(fullfile(pathname,filename));
imshow(I);
set(gca,'xtick',[]);
set(gca,'xticklabel',[]);
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
get( get(gca,'XLabel') );
set( get(gca,'XLabel'), 'HorizontalAlignment', 'center' );
set( get(gca,'XLabel'), 'FontSize', 8 );
set( get(gca,'XLabel'), 'String', filename );
cbx = get(handles.checkbox1,'Value');
set(handles.uitable1,'Data',{'Contrast',0.00;'Correlation',0.00;'Energy',0.00; ...
    'Homogeneity',0.00;'Entropy',0.00;'PSNR',0.00;});
if cbx == 1
   set(handles.cmdTest,'Enable','on');
end


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cmdTD.
function cmdTD_Callback(hObject, eventdata, handles)
% hObject    handle to cmdTD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dfd = get(handles.txtTF,'String');
ctf = strcat(dfd,'\train.dat');
if exist(ctf,'file')
   delete(strcat(dfd,'\train.dat')) 
end
set(handles.checkbox1,'Value',0);
e = td(dfd);
drawnow;
try
    waitfor(e>0);
    if exist(ctf,'file')
       set(handles.checkbox1,'Value',1);
    end
    ftest = get(handles.txtDF,'String');
    if ~isempty(ftest) && exist(ftest,'file')
        set(handles.cmdTest,'Enable','on');
    end 
catch ME
     msgbox(ME.message);
end

% --- Executes on button press in cmdTest.
function cmdTest_Callback(hObject, eventdata, handles)
wbar = waitbar(0,'Initializing, please wait...');
set(handles.txtResult,'String','');
FN = get(handles.txtTF,'String');
PF = get(handles.txtDF,'String');
if ~isempty(FN) && exist(PF,'file')
    DT = imread(PF);
    waitbar(ceil(1/6),wbar,sprintf('Converting to greyscale  %d%%...',ceil((1/6)*100)));
    G1 = rgb2gray(DT);
    waitbar(ceil(2/6),wbar,sprintf('Analyzing Image and Object Dimension  %d%%...',ceil((2/6)*100)));
    G2 = dimension(G1);
    waitbar(ceil(3/6),wbar,sprintf('Create temporary new image  %d%%...',ceil((3/6)*100)));
    G3 = clipping(G2);
    waitbar(ceil(4/6),wbar,sprintf('GLCM Proccess  %d%%...',ceil((4/6)*100)));
    O = getoffset;
    GLCMT = graycomatrix(G3,'Offset',O);
    statt = graycoprops(GLCMT);
    dt1 = mean(statt.Contrast);
    dt2 = mean(statt.Correlation);
    dt3 = mean(statt.Energy);
    dt4 = mean(statt.Homogeneity);
    dt5 = mean(entropy(G3));
    dt6 = mean(psnr_value(G3));
    %dt7 = mean(DT);
    set(handles.uitable1,'Data',{'Contrast',dt1;'Correlation',dt2;'Energy',dt3; ...
        'Homogeneity',dt4;'Entropy',dt5;'PSNR',dt6;});
    SM = [dt1,dt2,dt3,dt4,dt5,dt6,dt7];
    waitbar(ceil(5/6),wbar,sprintf('Generate matrix  %d%%...',ceil((5/6)*100)));
    [~,name,ext] = fileparts(PF);
    WD = strcat(FN,'\',name,'_data.dat');
    if exist(WD,'file')
        delete(WD);
    end
    KF = strcat(FN,'\',name,'_knn.dat');
    if exist(KF,'file')
        delete(KF);
    end    
    fid = fopen(WD,'w');
    fprintf(fid,'%d\t%d\t%d\t%d\t%d\t%d\n',SM);
    fclose(fid);
    waitbar(ceil(6/6),wbar,sprintf('KNN Classification  %d%%...',ceil((6/6)*100)));
    WG = strcat(FN,'\groups.dat');
    fid2 = fopen(WG);
    GS = textscan(fid2,'%s','Delimiter','\n');
    fclose(fid2);
    G=GS{1};
    WT = strcat(FN,'\train.dat');
    R = dlmread('KNN_RULE.dat');
    %disp(R(1))
    switch R(1)
        case 1
            METH = 'euclidean';
        case 2
            METH = 'cityblock';
        case 3
            METH = 'cosine';
        case 4
            METH = 'correlation';
        case 5
            METH = 'hamming';
        otherwise
            METH = 'euclidean';
    end
    switch R(2)
        case 1
            RULE = 'nearest';
        case 2
            RULE = 'random';
        case 3
            RULE = 'consensus';
        otherwise
            RULE = 'nearest';
    end
    if exist(WT, 'file')
        B = dlmread (WT);
        fidg = fopen(WG, 'rb');
        fseek(fidg, 0, 'eof');
        fileSize = ftell(fidg);
        frewind(fidg);
        data = fread(fidg, fileSize, 'uint8');
        VK = sum(data == 10);
        fclose(fidg);
        %disp(VK)
        xclass = knnclassify(SM, B, G, VK, METH, RULE, KF);
    end
    if exist(strcat(FN,'\',name,'.',ext),'file')
    else
        try
            copyfile(PF,FN);
        catch ME
             msgbox(ME.message);
        end
    end
    set(handles.txtResult,'String',xclass);
end
close(wbar);

% --- Executes on button press in cmdDock.
function cmdDock_Callback(hObject, eventdata, handles)
% hObject    handle to cmdDock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
PF = get(handles.txtDF,'String');
[~,name,ext] = fileparts(PF);
CI = getimage;
figure,imshow(CI),title(strcat(name,ext));

