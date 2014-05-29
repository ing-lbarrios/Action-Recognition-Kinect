function [training testing] = Separate_Body_Parts(label_training, label_testing)

%----------------------------Training----------------------------------------
topLeftLabel = cellfun(@(X) {X(1,1)}, {label_training.bodypart});
topLeftBop = cellfun(@(X) X(1,1), {label_training.bop});

botLeftLabel = cellfun(@(X) {X(1,2)}, {label_training.bodypart});
botLeftBop = cellfun(@(X) X(1,2), {label_training.bop});

topRightLabel = cellfun(@(X) {X(1,3)}, {label_training.bodypart});
topRightBop = cellfun(@(X) X(1,3), {label_training.bop});

botRightLabel = cellfun(@(X) {X(1,4)}, {label_training.bodypart});
botRightBop = cellfun(@(X) X(1,4), {label_training.bop});

ActionTrain = cellfun(@(X) {X(1,:)}, {label_training.action});

Labels = {'label', 'bop', 'action'};

tLstructTrain = {topLeftLabel{:}; topLeftBop{:}; ActionTrain{:}}'; %tLstructTrain(cellfun(@(x) ~x(1),tLstructTrain(:,1)),:) = [];%{'Idle'};
bLstructTrain = {botLeftLabel{:}; botLeftBop{:}; ActionTrain{:}}'; %bLstructTrain(cellfun(@(x) ~x(1),bLstructTrain(:,1)),:) = [];%{'Idle'};
tRstructTrain = {topRightLabel{:}; topRightBop{:}; ActionTrain{:}}'; %tRstructTrain(cellfun(@(x) ~x(1),tRstructTrain(:,1)),:) = [];%{'Idle'};
bRstructTrain = {botRightLabel{:}; botRightBop{:}; ActionTrain{:}}'; %bRstructTrain(cellfun(@(x) ~x(1),bRstructTrain(:,1)),:) = [];%{'Idle'};

training.topleft = cell2struct(tLstructTrain, Labels, 2);
training.botleft = cell2struct(bLstructTrain, Labels, 2);
training.topright = cell2struct(tRstructTrain, Labels, 2);
training.botright = cell2struct(bRstructTrain, Labels, 2);

%----------------------------Testing----------------------------------------
topLeftTest = cellfun(@(X) {X(1,1)}, {label_testing.bodypart});
topLeftTestBop = cellfun(@(X) X(1,1), {label_testing.bop});

botLeftTest = cellfun(@(X) {X(1,2)}, {label_testing.bodypart});
botLeftTestBop = cellfun(@(X) X(1,2), {label_testing.bop});

topRightTest = cellfun(@(X) {X(1,3)}, {label_testing.bodypart});
topRightTestBop = cellfun(@(X) X(1,3), {label_testing.bop});

botRightTest = cellfun(@(X) {X(1,4)}, {label_testing.bodypart});
botRightTestBop = cellfun(@(X) X(1,4), {label_testing.bop});

ActionTest = cellfun(@(X) {X(1,:)}, {label_testing.action});

tLstructTest = {topLeftTest{:}; topLeftTestBop{:}; ActionTest{:}}'; %tLstructTest(cellfun(@(x) ~x(1),tLstructTest(:,1)),:) = [];
bLstructTest = {botLeftTest{:}; botLeftTestBop{:}; ActionTest{:}}'; %bLstructTest(cellfun(@(x) ~x(1),bLstructTest(:,1)),:) = [];
tRstructTest = {topRightTest{:}; topRightTestBop{:}; ActionTest{:}}'; %tRstructTest(cellfun(@(x) ~x(1),tRstructTest(:,1)),:) = [];
bRstructTest = {botRightTest{:}; botRightTestBop{:}; ActionTest{:}}'; %bRstructTest(cellfun(@(x) ~x(1),bRstructTest(:,1)),:) = [];

testing.topleft = cell2struct(tLstructTest, Labels, 2);
testing.botleft = cell2struct(bLstructTest, Labels, 2);
testing.topright = cell2struct(tRstructTest, Labels, 2);
testing.botright = cell2struct(bRstructTest, Labels, 2);


