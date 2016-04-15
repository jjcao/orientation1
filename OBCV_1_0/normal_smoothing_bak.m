%
% Smoothing orientation by Laplacian smoothing
% create: 2010-11-08
% by: JJCAO
%
%% setting
clear;clc;close all;
path('toolbox',path);

sk_filename='../data/Laurana_v15133_contract_t(1)_nn(30)_WL(11.459928)_WH(2.000000)_sl(2.000000).mat';
load(sk_filename,'P');

tag = P.tag(:,2)-P.tag(:,1);
WH = tag.^(2);
A = [P.L0;sparse(1:P.npts,1:P.npts, WH)];

for j = 1:1
    b = [zeros(P.npts,3);sparse(1:P.npts,1:P.npts, WH)*P.normal3];
    nnormal=(A'*A)\(A'*b); 

    %% adjust initial normal by smoothed orientation
    for i=1:P.npts  
        % how to determin this parameter, both angle relative the P.normal1 and size of nnormal 
        % reflect whether should we flip the P.normal1!!!!!!!!!!!!!!!!!!!!!
        if dot(P.normal1(i,:),nnormal(i,:)) < 0.6 
            P.normal3(i,:) = -P.normal1(i,:);
        else
            P.normal3(i,:) = P.normal1(i,:);        
        end
    end
end

write_mesh('../result/result.off', P.pts,[],P.normal3);
write_mesh('../result/result_c.off',  P.cpts{P.contrno},[],-P.normal1);


