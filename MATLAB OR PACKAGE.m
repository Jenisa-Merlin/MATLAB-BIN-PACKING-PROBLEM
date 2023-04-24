m = input("Number of items to be packed: ");
fprintf("\n");

% Items input
labels = zeros(m,2);

for i = 1:m
    for j = 1:2
        if(j==1)
            labels(i, j) = input(sprintf("Width of item (%d): ",i));
        else
            labels(i, j) = input(sprintf("Height of item (%d): ",i));
            fprintf("\n");
        end
    end
end


fprintf("\n");
W = input("Enter width of Bin : ");
H = input("Enter height of Bin : ");
fprintf("\n");


% Test case 1
heuristic = 'first-fit';
[num_bins, bin_contents, leftover_space] = bin_packing_modified(labels, W, H, heuristic);
hBin1 = num_bins;
fprintf('Test case 1 - First fit\n\n');
fprintf('Number of bins: %d\n', num_bins);
for i = 1:num_bins
    fprintf('Bin %d contents: %s\n', i, mat2str(bin_contents{i}));
    fprintf('Bin %d leftover space: %s\n', i, mat2str(leftover_space(i,:)));
end
fprintf("\n");

% Test case 2
heuristic = 'best-fit';
[num_bins, bin_contents, leftover_space] = bin_packing_modified(labels, W, H, heuristic);
hBin2 = num_bins;
fprintf('Test case 2 - Best fit\n\n');
fprintf('Number of bins: %d\n', num_bins);
for i = 1:num_bins
    fprintf('Bin %d contents: %s\n', i, mat2str(bin_contents{i}));
    fprintf('Bin %d leftover space: %s\n', i, mat2str(leftover_space(i,:)));
end

% Test case 3
heuristic = 'worst-fit';
[num_bins, bin_contents, leftover_space] = bin_packing_modified(labels, W, H, heuristic);
hBin3 = num_bins;
fprintf('\nTest case 3 - Worst fit\n\n');
fprintf('Number of bins: %d\n', num_bins);
for i = 1:num_bins
    fprintf('Bin %d contents: %s\n', i, mat2str(bin_contents{i}));
    fprintf('Bin %d leftover space: %s\n', i, mat2str(leftover_space(i,:)));
end

% Test case 4
heuristic = 'first-fit-decreasing';
[num_bins, bin_contents, leftover_space] = bin_packing_modified(labels, W, H, heuristic);
hBin4 = num_bins;
fprintf('\nTest case 4 - First fit decreasing\n\n');
fprintf('Number of bins: %d\n', num_bins);
for i = 1:num_bins
    fprintf('Bin %d contents: %s\n', i, mat2str(bin_contents{i}));
    fprintf('Bin %d leftover space: %s\n', i, mat2str(leftover_space(i,:)));
end

%bar graph
X = categorical({'First fit','Best fit','Worst fit','First fit decreasing'});
X = reordercats(X,{'First fit','Best fit','Worst fit','First fit decreasing'});
Y = [hBin1 hBin2 hBin3 hBin4];
bar(X,Y,'FaceColor',[0.3010 0.7450 0.9330])
title('Optimization in usage of bins')
xlabel('Heuristic')
ylabel('Number of bins used')


function [num_bins, bin_contents, leftover_space] = bin_packing_modified(labels, W, H, heuristic)
% labels: a matrix of size nx2 where each row represents the width and
%         height of a label
% W, H: the width and height of the available label material
% heuristic: a string representing the heuristic to use for packing
%            ('first-fit', 'best-fit', 'worst-fit', 'first-fit-decreasing')
%
% Returns:
% num_bins: the minimum number of bins required to pack all the labels
% bin_contents: a cell array where each element represents the contents of
%               a bin as a matrix of size mx2 where each row represents the
%               width and height of a label
% leftover_space: a matrix of size num_binsx2 where each row represents the
%                 leftover space in a bin as the width and height of the space

n = size(labels, 1);
bins = {};
bin_space = [];
num_bins = 0;
switch heuristic
    case 'first-fit'
        for i = 1:n
            label = labels(i,:);
            bin_found = false;
            for j = 1:num_bins
                if label(1) <= bin_space(j,1) && label(2) <= bin_space(j,2)
                    bins{j}(end+1,:) = label;
                    bin_space(j,1) = bin_space(j,1) - label(1);
                    bin_space(j,2) = bin_space(j,2) - label(2);
                    bin_found = true;
                    break;
                end
            end
            if ~bin_found
                num_bins = num_bins + 1;
                bins{num_bins} = label;
                bin_space(num_bins,:) = [W-label(1), H-label(2)];
            end
        end

    case 'best-fit'
        for i = 1:n
            label = labels(i,:);
            min_space = inf;
            min_index = 0;
            for j = 1:num_bins
                if label(1) <= bin_space(j,1) && label(2) <= bin_space(j,2) && bin_space(j,1)*bin_space(j,2) < min_space
                    min_space = bin_space(j,1)*bin_space(j,2);
                    min_index = j;
                end
            end
            if min_index > 0
                bins{min_index}(end+1,:) = label;
                bin_space(min_index,1) = bin_space(min_index,1) - label(1);
                bin_space(min_index,2) = bin_space(min_index,2) - label(2);
            else
                num_bins = num_bins + 1;
                bins{num_bins} = label;
                bin_space(num_bins,:) = [W-label(1), H-label(2)];
            end
        end

        case 'worst-fit'
            for i = 1:n
                label = labels(i,:);
                max_space = -1;
                max_index = 0;
                for j = 1:num_bins
                    if label(1) <= bin_space(j,1) && label(2) <= bin_space(j,2) && bin_space(j,1)*bin_space(j,2) > max_space
                        max_space = bin_space(j,1)*bin_space(j,2);
                        max_index = j;
                    end
                end
                if max_index > 0
                    bins{max_index}(end+1,:) = label;
                    bin_space(max_index,1) = bin_space(max_index,1) - label(1);
                    bin_space(max_index,2) = bin_space(max_index,2) - label(2);
                else
                    num_bins = num_bins + 1;
                    bins{num_bins} = label;
                    bin_space(num_bins,:) = [W-label(1), H-label(2)];
                end
            end

       case 'first-fit-decreasing'
         % sort labels by non-increasing height
            [~, sort_idx] = sort(labels(:,2), 'descend');
            sorted_labels = labels(sort_idx,:);

            for i = 1:n
                label = sorted_labels(i,:);
                bin_found = false;
                for j = 1:num_bins
                    if label(1) <= bin_space(j,1) && label(2) <= bin_space(j,2)
                        bins{j}(end+1,:) = label;
                        bin_space(j,1) = bin_space(j,1) - label(1);
                        bin_space(j,2) = bin_space(j,2) - label(2);
                        bin_found = true;
                        break;
                    end
                end
                if ~bin_found
                    num_bins = num_bins + 1;
                    bins{num_bins} = label;
                    bin_space(num_bins,:) = [W-label(1), H-label(2)];
                end
            end

        otherwise
            error('Invalid heuristic specified');
end

bin_contents = bins;
leftover_space = bin_space;

end