clear;clc;close all;
path('toolbox',path);
extension='.off';
filename = 'E:\jjcao_paper\PCD_Orientation\result\2-3-2.14-50';
P.filename = [filename extension];
[P.pts,P.faces, P.normal1] = read_mesh(P.filename);
P.npts = size(P.pts,1);
P.pts = GS.normalize(P.pts);

figure('Name','Original point cloud');movegui('northwest');set(gcf,'color','white');
scatter3(P.pts(:,1),P.pts(:,2),P.pts(:,3),10,'.','MarkerEdgeColor',GS.PC_COLOR); axis off;axis equal; hold on;
view3d rot;
write_mesh([filename '.xyz'], P.pts,[], []);

%% from point set off to point set obj
extension='.off';
filename = 'E:\jjcao_paper\PCD_Orientation\result\result_14_view';% which file we should run on
P.filename = [filename extension];
[P.pts,P.faces, P.normal1] = read_mesh(P.filename);
P.npts = size(P.pts, 1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P.normal1 = compute_vertex_normal(P.pts,P.faces);
% P.k_knn = 10;
% kdtree = kdtree_build(P.pts);% kdtree,”√¿¥’“kΩ¸¡⁄
% index = zeros(P.npts, P.k_knn);
% P.normal1 = zeros(P.npts, 3);
% for i = 1:P.npts
%     index(i,:)  = kdtree_k_nearest_neighbors(kdtree,P.pts(i,:),P.k_knn)';
%     P.normal1(i,:) = compute_lsp_normal(P.pts(index(i,:),:));
% end
% kdtree_delete(kdtree);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P.pts = GS.normalize(P.pts);
% write_mesh([filename '.off'], P.pts,[], -P.normal1);
write_mesh([filename '.pwn'], P.pts,[], P.normal1);

%% draw result
sk_filename='../data/Venus-half-noisy_contract_nn(10)_WL(18.087267)_WH(2.000000).mat';
filename='../data/Venus-half-noisy_contract';
load(sk_filename,'P');
cpts=P.cpts{end};
write_mesh([filename '.off'], cpts,[], -P.normal1);

figure;movegui('northeast');set(gcf,'color','white');
% if isfield(P,'faces') && ~isempty(P.faces)
%     options.face_color = [0 1 0];
%     h = plot_mesh(P.pts, P.faces, options); hold on;colorbar('off');alpha(0.5);
%     set(h, 'edgecolor', 'none'); % cancel display of edge.
% else
%     scatter3(P.pts(:,1),P.pts(:,2),P.pts(:,3),30,'.','MarkerEdgeColor',GS.PC_COLOR);  hold on;
% end

scatter3(cpts(:,1),cpts(:,2),cpts(:,3),30,'.','MarkerEdgeColor',GS.PC_COLOR); axis off;axis equal;set(gcf,'Renderer','OpenGL');
camorbit(0,0,'camera'); axis vis3d; view(0,90);view3d rot;

%%
x=[1,4,6,14,18,26];y=[2451,8263,10050,16687,18239,20162]/25411.0;%pelvis 50k
y2=[1884,4617,7189,14830,15959,17893]/23889.0;%675_lion_fine
y3=[2345,5935,9114,18400,18899,21154]/25126.0;% Laurana50k
y4=[2257,8449,43870,64571,65390,69779]/88374.0;% filigree
p=plot(x,y,'r',x,y2,'g',x,y3,'b');
set(p,'LineWidth', 4);
legend('Pelvis','Lion','Laurana','fontsize',12,'fontweight','b')

xlabel('number of viewpoints','fontsize',12,'fontweight','b')
ylabel('percent of reliable visible points','fontsize',12,'fontweight','b')
set(gcf,'color','white');
axis([0 27 0 0.9]);
% title('Plot of the Sine Function','FontSize',12)
