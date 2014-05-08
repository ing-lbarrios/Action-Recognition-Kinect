function [precision recall ap thr] = precrec2(binLabels, scores, show)

if nargin<3
    show = 0;
end

if ~islogical(binLabels)
	error('binLabels must be logical')
end

binLabels = double(binLabels);

nElem = numel(binLabels);
numPos = sum(binLabels);

[sortedScores sortIdx] = sort(scores(:),'descend');
sortedLabels = binLabels(sortIdx);

truepos = cumsum(sortedLabels(:));

precision = truepos./(1:nElem)';
recall = truepos./numPos;

thr = sortedScores;

ap = sum(precision.*sortedLabels)/numPos;

if show
    plot(recall,precision,'LineWidth',3)
    xlabel('recall')
    ylabel('precision')
    axis([0 1 0 1])
    grid on
    disp(['Average Precision = ' sprintf('%g',100*ap) ' %'])
end

% return all data in a structure if give a single output variable
if nargout == 1
    out.precision = precision;
    out.recall = recall;
    out.ap = ap;
    out.thr = thr;
    precision = out;
end