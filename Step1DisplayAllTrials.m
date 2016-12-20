%Load the edf data
[FILENAME, PATHNAME, FILTERINDEX] = uigetfile('*.edf','MultiSelect','ON');
file = strcat(PATHNAME,FILENAME);
[header,data]= edfread(file);

%Set SR
dt = 1/128;

%Full description in header.label
Markers = data(20,:);

%The order is 10 for start and 20 end.
positionStart = find(Markers==10);
positionEnd = find(Markers==20);

%Restriccions
%There cannot be two consecutive 10s before a 20
%There cannot be two consecutive 20s before a 10
counter = 1;

positionEndCorrected = zeros(size(positionEnd));
for endPos = 1:size(positionEnd,2)
	for startPos = 1:size(positionStart,2)
        if positionEnd(endPos)>positionStart(startPos)
            counter = startPos;
            continue;
        else
            counter = startPos - 1;
            break;
        end
    end
    positionEndCorrected(endPos) = counter;
end

positionStartCorrected = zeros(size(positionStart));
for startPos = size(positionStart,2):-1:1
    for endPos = 1:size(positionEnd,2)
        if positionStart(startPos)>positionEnd(endPos)
            counter = endPos;
            continue;
        else
            counter = endPos;
            break;
        end
    end
    positionStartCorrected(startPos) = counter;
end
positionStartCorrected = flip(positionStartCorrected);
%Now those number that are duplicated has to be set to zero because they
%are blinks and not real start or stop values
for i = 1:(size(positionEndCorrected,2)-1)
    if positionEndCorrected(i) == positionEndCorrected(i+1)
        positionEndCorrected(i+1) = 0;
    end
end
for i = 1:(size(positionStartCorrected,2)-1)
    if positionStartCorrected(i) == positionStartCorrected(i+1)
        positionStartCorrected(i+1) = 0;
    end
end

%Modify the markers plot to see if now there are no duplicates
Markers(positionStart(positionStartCorrected==0)) = 1;
Markers(positionEnd(positionEndCorrected==0)) = 1;
figure;
plot(Markers);

%Cut the arrays to remove those duplicates and have the exact start and
%stop values
positionStart(positionStartCorrected==0) = [];
positionEnd(positionEndCorrected==0) = [];


%BEGIN: ASH
onlyDataChannels = data(3:16,:);

numChannels = 14

numOfTrialsFound = size(positionStartCorrected, 2)


%Cut all data channels into epochs
for i = 1:numChannels
	for j = 1:numOfTrialsFound
		Trials{i,j} = onlyDataChannels(i, positionStart(j):positionEnd(j));
	end
end

%Populate list of EEGLab objects with HiLo filtered data
for i = 1:numOfTrialsFound
	%Extract the first epoch, for now, just to test
	SingleTrial = cell2mat(Trials(:,i,:));

	%Use matlab array to initialize EEGlab EEG data structure
	eegStruct = pop_importdata('data', SingleTrial,'srate',128);

	%Initialize channel locations (required for ICA)
	eegStruct.chanlocs = readlocs('emotivTS.ced')

	%Bandpass filter excluding <1 and >30 Hz
	%This gives a few warnings, but seems to work ok
	loFilteredDataChannels = pop_eegfilt(eegStruct, 1, 0, [])
	hiLoFilteredDataChannels = pop_eegfilt(loFilteredDataChannels, 0, 30, [])
	
	filteredTrials{i} = hiLoFilteredDataChannels
end

%Display all trials
for i = 1:numOfTrialsFound
	eegplot(filteredTrials{i}.data, 'title', ['Trial number ', num2str(i), ' raw'],'srate',128)
end