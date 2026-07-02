%% ============================================================
% Statistical analysis of corpus callososum subregions
%
% Author: Zhou Zhou
% Version: Matlab R2023b
% Data format (Excel)
% --------------------------------------------------------------
% Case | Falx | Region | Strain | Strain rate | Stress (kPa)
%
% Falx:
%   with
%   without
%
% Region:
%   genu
%   midbody
%   splenium
%% ============================================================

clear;
clc;

%% Read data

T = readtable('CorpusCallosumSubregionalResponse.xlsx');

%% Convert variables

T.Case   = categorical(T.Case);
T.Falx   = categorical(T.Falx);
T.Region = categorical(T.Region);

%% ============================================================
%% Linear mixed-effects model
%% ============================================================

responses = {'Strain','Strain_rate','Stress_kPa'};

% MATLAB variable names
T.Properties.VariableNames = ...
    {'Case','Falx','Region','Strain','Strain_rate','Stress_kPa'};

disp(' ');
disp('===============================')
disp('LINEAR MIXED-EFFECTS MODELS')
disp('===============================')

for i = 1:length(responses)

    response = responses{i};

    fprintf('\n=======================================\n');
    fprintf('%s\n',response);
    fprintf('=======================================\n');

    formula = sprintf('%s ~ Falx*Region + (1|Case)',response);

    lme = fitlme(T,formula);

    disp(anova(lme))
end

%% ============================================================
%% Calculate falx-induced changes
%% Delta = With - Without
%% ============================================================

cases = categories(T.Case);

nCase = length(cases);

deltaStrain = zeros(nCase,3);
deltaRate   = zeros(nCase,3);
deltaStress = zeros(nCase,3);

regions = {'genu','midbody','splenium'};

for i = 1:nCase

    for j = 1:3

        idxWith = T.Case==cases{i} & ...
                  T.Region==regions{j} & ...
                  T.Falx=="with";

        idxWithout = T.Case==cases{i} & ...
                     T.Region==regions{j} & ...
                     T.Falx=="without";

        deltaStrain(i,j) = ...
            T.Strain(idxWith) - T.Strain(idxWithout);

        deltaRate(i,j) = ...
            T.Strain_rate(idxWith) - T.Strain_rate(idxWithout);

        deltaStress(i,j) = ...
            T.Stress_kPa(idxWith) - T.Stress_kPa(idxWithout);

    end

end

%% ============================================================
%% Paired comparisons
%% Splenium vs Genu
%% Splenium vs Midbody
%% ============================================================

disp(' ')
disp('===========================================')
disp('PAIRED COMPARISONS OF FALX-INDUCED CHANGES')
disp('===========================================')

names = {'Peak strain','Peak strain rate','Peak shear stress'};

datasets = {deltaStrain,deltaRate,deltaStress};

for k = 1:3

    X = datasets{k};

    % Splenium vs genu
    [~,p1,~,stats1] = ttest(X(:,3),X(:,1));

    % Splenium vs midbody
    [~,p2,~,stats2] = ttest(X(:,3),X(:,2));

    fprintf('Splenium vs Genu\n');
    fprintf('p = %.4f\n',p1);
    fprintf('t = %.3f\n\n',stats1.tstat);

    fprintf('Splenium vs Midbody\n');
    fprintf('p = %.4f\n',p2);
    fprintf('t = %.3f\n',stats2.tstat);

end