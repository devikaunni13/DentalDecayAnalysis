function outClass = knnclassify(sample, TRAIN, group, K, distance,rule,base)
%KNNCLASSIFY classifies data using the nearest-neighbor method
%
%   CLASS = KNNCLASSIFY(SAMPLE,TRAINING,GROUP) classifies each row of the
%   data in SAMPLE into one of the groups in TRAINING using the nearest-
%   neighbor method. SAMPLE and TRAINING must be matrices with the same
%   number of columns. GROUP is a grouping variable for TRAINING. Its
%   unique values define groups, and each element defines the group to
%   which the corresponding row of TRAINING belongs. GROUP can be a
%   numeric vector, a string array, or a cell array of strings. TRAINING
%   and GROUP must have the same number of rows. CLASSIFY treats NaNs or
%   empty strings in GROUP as missing values and ignores the corresponding
%   rows of TRAINING. CLASS indicates which group each row of SAMPLE has
%   been assigned to, and is of the same type as GROUP.
%
%   CLASS = KNNCLASSIFY(SAMPLE,TRAINING,GROUP,K) allows you to specify K,
%   the number of nearest neighbors used in the classification. The default
%   is 1.
%
%   CLASS = KNNCLASSIFY(SAMPLE,TRAINING,GROUP,K,DISTANCE) allows you to
%   select the distance metric. Choices are
%             'euclidean'    Euclidean distance (default)
%             'cityblock'    Sum of absolute differences, or L1
%             'cosine'       One minus the cosine of the included angle
%                            between points (treated as vectors)
%             'correlation'  One minus the sample correlation between
%                            points (treated as sequences of values)
%             'Hamming'      Percentage of bits that differ (only
%                            suitable for binary data)
%
%   CLASS = KNNCLASSIFY(SAMPLE,TRAINING,GROUP,K,DISTANCE,RULE) allows you
%   to specify the rule used to decide how to classify the sample. Choices
%   are:
%             'nearest'   Majority rule with nearest point tie-break
%             'random'    Majority rule with random point tie-break
%             'consensus' Consensus rule
%
%   The default behavior is to use majority rule. That is, a sample point
%   is assigned to the class from which the majority of the K nearest
%   neighbors are from. Use 'consensus' to require a consensus, as opposed
%   to majority rule. When using the consensus option, points where not all
%   of the K nearest neighbors are from the same class are not assigned
%   to one of the classes. Instead the output CLASS for these points is NaN
%   for numerical groups or '' for string named groups. When classifying to
%   more than two groups or when using an even value for K, it might be
%   necessary to break a tie in the number of nearest neighbors. Options
%   are 'random', which selects a random tiebreaker, and 'nearest', which
%   uses the nearest neighbor among the tied groups to break the tie. The
%   default behavior is majority rule, nearest tie-break.
%
%   Examples:
%
%      % training data: two normal components
%      training = [mvnrnd([ 1  1],   eye(2), 100); ...
%                  mvnrnd([-1 -1], 2*eye(2), 100)];
%      group = [ones(100,1); 2*ones(100,1)];
%      gscatter(training(:,1),training(:,2),group);hold on;
%
%      % some random sample data
%      sample = unifrnd(-5, 5, 100, 2);
%      % classify the sample using the nearest neighbor classification
%      c = knnclassify(sample, training, group);
%
%      gscatter(sample(:,1),sample(:,2),c,'mc'); hold on;
%      c3 = knnclassify(sample, training, group, 3);
%      gscatter(sample(:,1),sample(:,2),c3,'mc','o');
%
%   See also CLASSIFY, CLASSPERF, CROSSVALIND, KNNIMPUTE, SVMCLASSIFY,
%   SVMTRAIN.

%   Copyright 2004-2008 The MathWorks, Inc.
%   $Revision: 1.1.12.8 $  $Date: 2008/12/21 01:50:22 $

%   References:
%     [1] Machine Learning, Tom Mitchell, McGraw Hill, 1997

bioinfochecknargin(nargin,3,mfilename)
% grp2idx sorts a numeric grouping var ascending, and a string grouping
% var by order of first occurrence
[gindex,groups] = grp2idx(group);
nans = find(isnan(gindex));
if ~isempty(nans)
    TRAIN(nans,:) = [];
    gindex(nans) = [];
end
ngroups = length(groups);

[n,d] = size(TRAIN);
if size(gindex,1) ~= n
    error('Bioinfo:knnclassify:BadGroupLength',...
        'The length of GROUP must equal the number of rows in TRAINING.');
elseif size(sample,2) ~= d
    error('Bioinfo:knnclassify:SampleTrainingSizeMismatch',...
        'SAMPLE and TRAINING must have the same number of columns.');
end
m = size(sample,1);

if nargin < 4
    K = 1;
elseif ~isnumeric(K)
    error('Bioinfo:knnclassify:KNotNumeric',...
        'K must be numeric.');
end
if ~isscalar(K)
    error('Bioinfo:knnclassify:KNotScalar',...
        'K must be a scalar.');
end

if K<1
    error('Bioinfo:knnclassify:KLessThanOne',...
        'K must be greater than or equal to 1.');
end

if isnan(K)
    error('Bioinfo:knnclassify:KNaN',...
        'K cannot be NaN.');
end

if nargin < 5 || isempty(distance)
    distance  = 'euclidean';
end

if ischar(distance)
    distNames = {'euclidean','cityblock','cosine','correlation','hamming'};
    i = find(strncmpi(distance, distNames,numel(distance)));
    if length(i) > 1
        error('Bioinfo:knnclassify:AmbiguousDistance', ...
            'Ambiguous ''distance'' parameter value:  %s.', distance);
    elseif isempty(i)
        error('Bioinfo:knnclassify:UnknownDistance', ...
            'Unknown ''distance'' parameter value:  %s.', distance);
    end
    distance = distNames{i};
else
    error('Bioinfo:knnclassify:InvalidDistance', ...
        'The ''distance'' parameter value must be a string.');
end

if nargin < 6
    rule = 'nearest';
elseif ischar(rule)
    
    % lots of testers misspelled consensus.
    if strncmpi(rule,'conc',4)
        rule(4) = 's';
    end
    ruleNames = {'random','nearest','farthest','consensus'};
    i = find(strncmpi(rule, ruleNames,numel(rule)));
    % %   May need this if we add more rules and introduce the possibility of
    % %   ambiguity.
    %     if length(i) > 1
    %         error('Bioinfo:knnclassify:AmbiguousRule', ...
    %             'Ambiguous ''Rule'' parameter value:  %s.', rule);
    %     else
    if isempty(i)
        error('Bioinfo:knnclassify:UnknownRule', ...
            'Unknown ''Rule'' parameter value:  %s.', rule);
    end
    rule = ruleNames{i};
    %     end
else
    error('Bioinfo:knnclassify:InvalidRule', ...
        'The ''rule'' parameter value must be a string.');
end

% Calculate the distances from all points in the training set to all points
% in the test set.

[dSorted,dIndex] = distfun(sample,TRAIN,distance,K);

% find the K nearest

if K >1
    classes = gindex(dIndex);
    % special case when we have one input -- this gets turned into a
    % column vector, so we have to turn it back into a row vector.
    if size(classes,2) == 1
        classes = classes';
    end
    % count the occurrences of the classes
    
    counts = zeros(m,ngroups);
    for outer = 1:m
        for inner = 1:K
            counts(outer,classes(outer,inner)) = counts(outer,classes(outer,inner)) + 1;
        end
    end
    
    [L,outClass] = max(counts,[],2);
    
    % Deal with consensus rule
    if strcmp(rule,'consensus')
        noconsensus = (L~=K);
        
        if any(noconsensus)
            outClass(noconsensus) = ngroups+1;
            if isnumeric(group) || islogical(group)
                groups(end+1) = {'NaN'};
            else
                groups(end+1) = {''};
            end
        end
    else    % we need to check case where L <= K/2 for possible ties
        checkRows = find(L<=(K/2));
        
        for i = 1:numel(checkRows)
            ties = counts(checkRows(i),:) == L(checkRows(i));
            numTies = sum(ties);
            if numTies > 1
                choice = find(ties);
                switch rule
                    case 'random'
                        % random tie break
                        
                        tb = randsample(numTies,1);
                        outClass(checkRows(i)) = choice(tb);
                    case 'nearest'
                        % find the use the closest element of the equal groups
                        % to break the tie
                        for inner = 1:K
                            if ismember(classes(checkRows(i),inner),choice)
                                outClass(checkRows(i)) = classes(checkRows(i),inner);
                                break
                            end
                        end
                    case 'farthest'
                        % find the use the closest element of the equal groups
                        % to break the tie
                        for inner = K:-1:1
                            if ismember(classes(checkRows(i),inner),choice)
                                outClass(checkRows(i)) = classes(checkRows(i),inner);
                                break
                            end
                        end
                end
            end
        end
    end
    
else
    outClass = gindex(dIndex);
end
% Convert back to original grouping variable
if isa(group,'categorical')
    labels = getlabels(group);
    if isa(group,'nominal')
        groups = nominal(groups,[],labels);
    else
        groups = ordinal(groups,[],getlabels(group));
    end
    outClass = groups(outClass);
elseif isnumeric(group) || islogical(group)
    groups = str2num(char(groups)); %#ok
    outClass = groups(outClass);
elseif ischar(group)
    groups = char(groups);
    outClass = groups(outClass,:);
else %if iscellstr(group)
    outClass = groups(outClass);
end
fid = fopen(base, 'w');
fprintf(fid,'%s\n', num2str(dSorted));
fprintf(fid,'%s\n', num2str(dIndex));
fclose(fid);
MM = dlmread(base);
MN = vertcat(MM);
fid = fopen(base, 'w');
fprintf(fid,'%d\t%d\n', MN);
fclose(fid);


function [dSorted,dIndex]  = distfun(Sample, Train, dist,K)
%DISTFUN Calculate distances from training points to test points.
numSample = size(Sample,1);
dSorted = zeros(numSample,K);
dIndex = zeros(numSample,K);

switch dist
    
    case 'euclidean'  % we actually calculate the squared value
        for i = 1:numSample
            Dk = sum(bsxfun(@minus,Train,Sample(i,:)).^2, 2);
            [dSorted(i,:),dIndex(i,:)] = getBestK(Dk,K);
        end
        
    case 'cityblock'
        for i = 1:numSample
            Dk = sum(abs(bsxfun(@minus,Train,Sample(i,:))), 2);
            [dSorted(i,:),dIndex(i,:)] = getBestK(Dk,K);
        end
        
    case {'cosine'}
        % Normalize both the training and test data.
        normSample = sqrt(sum(Sample.^2, 2));
        normTrain = sqrt(sum(Train.^2, 2));
        if any(min(normTrain) <= eps(max(normTrain))) || any(min(normSample) <= eps(max(normSample)))
            warning('Bioinfo:knnclassify:ConstantDataForCos', ...
                ['Some points have small relative magnitudes, making them ', ...
                'effectively zero.\nEither remove those points, or choose a ', ...
                'distance other than ''cosine''.']);
        end
        Train = Train ./ normTrain(:,ones(1,size(Train,2)));
        for i = 1:numSample
            Dk = 1 - (Train * Sample(i,:)') ./ normSample(i);
            [dSorted(i,:),dIndex(i,:)] = getBestK(Dk,K);
        end
    case {'correlation'}
        % Normalize both the training and test data.
        Sample = bsxfun(@minus,Sample,mean(Sample,2));
        Train = bsxfun(@minus,Train,mean(Train,2));
        normSample = sqrt(sum(Sample.^2, 2));
        normTrain = sqrt(sum(Train.^2, 2));
        if any(min(normTrain) <= eps(max(normTrain))) || any(min(normSample) <= eps(max(normSample)))
            warning('Bioinfo:knnclassify:ConstantDataForCorr', ...
                ['Some points have small relative standard deviations, making them ', ...
                'effectively constant.\nEither remove those points, or choose a ', ...
                'distance other than ''correlation''.']);
        end
        
        Train = Train ./ normTrain(:,ones(1,size(Train,2)));
        
        for i = 1:numSample
            Dk = 1 - (Train * Sample(i,:)') ./ normSample(i);
            [dSorted(i,:),dIndex(i,:)] = getBestK(Dk,K);
        end
        
        
    case 'hamming'
        if ~all(ismember(Sample(:),[0 1]))||~all(ismember(Train(:),[0 1]))
            error('Bioinfo:knnclassify:HammingNonBinary',...
                'Non-binary data cannot be classified using Hamming distance.');
        end
        p = size(Sample,2);
        for i = 1:numSample
            Dk = sum(abs(bsxfun(@minus,Train,Sample(i,:))), 2) / p;
            [dSorted(i,:),dIndex(i,:)] = getBestK(Dk,K);
        end
        
end
% utility function to get the best K values from a vector
function [sorted,index] = getBestK(Dk,K)
% sort if needed
if K>1
    [sorted,index] = sort(Dk);
    sorted = sorted(1:K);
    index = index(1:K);
else
    [sorted,index] = min(Dk);
end

