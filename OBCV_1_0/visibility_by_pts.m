function P = visibility_by_pts(P, sk_filename)
%
% create: 2010-11-02
% by: JJCAO
%
%% setting
IS_DEBUG = 1;
SHOW_RESULT = 1;
SAVE_RESULT=1;
if ~exist('sk_filename','var')
    path('toolbox',path);
    sk_filename='../data/Moai_contract_nn(10)_WL(7.212904)_WH(2.000000).mat';
    load(sk_filename,'P');
end

% camposi = [1,0,0;];%1
% camposi = [1,0,0;-1,0,0;0,1,0;0,-1,0;];%4
%% camposi = [1,0,0;-1,0,0;0,1,0;0,0,1;0,0,-1;];% 5 face: 6 - -Y axis
% camposi = [1,0,0;-1,0,0;0,1,0;0,-1,0;0,0,1;0,0,-1;];% 6 face
camposi = [1,0,0;-1,0,0;0,1,0;0,-1,0;0,0,1;0,0,-1;% 6 face
    1,-1,-1;  1,-1,1; 1,1,-1; 1,1,1; 
    -1,-1,-1;-1,-1,1;-1,1,-1; -1,1,1% 8 corner
    ];% 14
% camposi = [0,1,0; 0,1,1; 0,0,1; 0,-1,1; 0,-1,0; 0,-1,-1; 0,0,-1; 0,1,-1;%x=0 plane
%            1,0,0; 1,0,1;        -1,0,1; -1,0,0; -1,0,-1;         1,0,-1;
%                   1,1,0;        1,-1,0;         -1,-1,0;         -1,1,0;
%     ];%18
% camposi = [0,1,0; 0,1,1; 0,0,1; 0,-1,1; 0,-1,0; 0,-1,-1; 0,0,-1; 0,1,-1;%x=0 plane
%            1,0,0; 1,0,1;        -1,0,1; -1,0,0; -1,0,-1;         1,0,-1;
%                   1,1,0;        1,-1,0;         -1,-1,0;         -1,1,0;
%     1,-1,-1;  1,-1,1; 1,1,-1; 1,1,1; 
%     -1,-1,-1;-1,-1,1;-1,1,-1; -1,1,1% 8 corner
%     ];%26
contrno = 1;% only use the contraction of 1st time.
param = 2;% large value for large view,5 is too large
ncam = size(camposi,1);
fprintf('visibility_by_pts: %d view \n', ncam);

P.contrno = contrno;
p= [P.pts; P.cpts{contrno}];

% if SHOW_RESULT
%     figure('Name','Original point cloud and its contraction');movegui('northwest');set(gcf,'color','white');
%     scatter3(P.pts(:,1),P.pts(:,2),P.pts(:,3),10,'.','MarkerEdgeColor',GS.PC_COLOR); axis off;axis equal; hold on;
%     cpts=P.cpts{contrno};
%     scatter3(cpts(:,1),cpts(:,2),cpts(:,3),30,'.r');
%     view3d rot;
% end 

tic
P.tag = zeros(P.npts, 2);
for i=1:ncam
    visiblePtInds=HPR(p,camposi(i,:),param);
    vp = visiblePtInds(visiblePtInds>P.npts)-P.npts;%visible points of contracted points
    vptp = visiblePtInds(visiblePtInds<(P.npts+1));%visible points of original points
    
    P.tag(vp,1) = P.tag(vp,1) + 1;
    P.tag(vptp,2) = P.tag(vptp,2) + 1;    
end
fprintf('visibility checking: ');
toc

tic
%% normal by contraction, which is slanted than by tangent plane
P.normal2 = P.pts-P.cpts{contrno};
P.normal2 = normalize(P.normal2);
P.normal3=P.normal2;
%% adjust normal1 estimated by tangent plane
% Do not change initial normal if we do not see the point or contracted
% point
tag = sign( P.tag(:,2)-P.tag(:,1) );
% write_mesh('../result/result.off', P.pts(tag~=0,:),[],P.normal1(tag~=0,:));

for i=1:P.npts
    P.normal3(i,:) = P.normal3(i,:)*tag(i);
    if dot(P.normal1(i,:),P.normal3(i,:)) < 0.0
        P.normal3(i,:) = -P.normal1(i,:);
    else % tag(i) == 0 % not visible or the contraction vector consistent with the normal
        P.normal3(i,:) = P.normal1(i,:);        
    end
end
fprintf('normal filpping: ');
toc
%% save results
if SAVE_RESULT
    save(sk_filename,'P');
    filename = sprintf('../result/result_%d_view.off', size(camposi,1));
    write_mesh(filename, P.pts,[],P.normal3);
    write_mesh('../result/result_c.off',  P.cpts{contrno},[],P.normal1);
end

%%--------------------------------------------------------
tag=abs(tag);
fprintf('visible points number: %d', sum(tag));
if SHOW_RESULT
    figure('Name','visible vs not visible');movegui('northeast');set(gcf,'color','white'); axis off;axis equal;set(gcf,'Renderer','OpenGL');axis vis3d;view3d rot;hold on;
    scatter3(P.pts(:,1),P.pts(:,2),P.pts(:,3),60,tag,'filled');  

    color = zeros(P.npts,3);
    for i = 1:P.npts   
        if tag(i)
            color(i,:) = [1,0,0];
        else
            color(i,:)=[0,0,1];
        end
    end
end
if SAVE_RESULT
    filename = sprintf('../result/result_%d_view_%d_color.off', size(camposi,1), sum(tag));
    write_mesh(filename, P.pts,[], P.normal3, color);
end
