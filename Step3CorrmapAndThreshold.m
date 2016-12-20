%Takes selected blink component and previously generated ICAs, runs corrmap to find best matching components in other trials.
%Then searches blink component for matches of a typical blink shape (using MSE)

%Parameters
%	(1) trialsWithICA (1 x [N trials] cell array of EEG structs): With ICA weights populated (return value of Step 2)
%	(2) templateSet(int): the trial number from which to take the blink component exemplar
%	(3) templateComponent(int): the IC component that corresponds to blinks
%	(4) idealPeak(array of double): example blink trace to compare against
%	(5) threshold(int): max threshold of mean-squared error difference between ideal blink and component time course. All  segments with mse < threshold are considered blinks
function blinksForAllTrials = Step3CorrmapAndThreshold(trialsWithICA, templateSet, templateComponent, idealPeak, threshold)

	argFail = false;

	if(nargin < 5)
		disp('Too few arguments');
		argFail = true;
	end
		
	if(nargin > 5) %This half doesn't work on 2016
		disp('Too many arguments')
		argFail = true;
	end
		
	if(argFail)
		disp('Parameters')
		disp('(1) trialsWithICA (1 x [N trials] cell array of EEG structs): With ICA weights populated (return value of Step 2)')
		disp('(2) templateSet(int): the trial number from which to take the blink component exemplar')
		disp('(3) templateComponent(int): the IC component that corresponds to blinks')
		disp('(4) idealPeak(array of double): example blink trace to compare against')
		disp('(5) threshold(int): max threshold of mean-squared error difference between ideal blink and component time course. All  segments with mse < threshold are considered blinks')
		return
	end
	
	%Transform cell array to struct array
	eegsStruct = makeEEGsStruct(trialsWithICA);

	%Make a dummy study object
	[newstudy neweegs] = pop_study([], eegsStruct);

	%TODO: Need to pass in real template each time
	corrMapMatches = corrmap(newstudy, neweegs, templateSet, templateComponent, 'title', 'Corrmap output: independent components from other ads matching template component');

	%Manually created from example in Ad 2. Maybe not fully representative?
	%idealPeak = [ 0,2,7,12,18,21,21,19,18,16,14,11,10,8,3,0 ];

	resultsDictionary = containers.Map
	
	setsToAnalyze = size(corrMapMatches.output.sets{1},1);
	
	
	stream = trialsWithICA{templateSet}.icaact(templateComponent,:);
	
	lengthInSeconds = size(stream, 2)/128;
	
	
	blinksForAllTrials{1} = SingleCompare(trialsWithICA, templateSet, templateComponent, idealPeak, threshold);

	disp([num2str(size(blinksForAllTrials{1})), ' blinks in ', num2str(lengthInSeconds),' seconds'])

	
	%dictionaryKey = strcat( int2str() )	
	
	for i = 1:setsToAnalyze
		[blinksForAllTrials{i+1}, set, component] = DoSingleThreshold(trialsWithICA, corrMapMatches, idealPeak, i, threshold);	
	end
	
end
	
function [singleBlinkArray, currentTrial, bestMatchIC] = DoSingleThreshold(eegsWithICA, corrMapMatches, idealPeak, setToMatch, threshold)

	%Take the first collection of Sets/ICs. They're the best matches
	corrMapSets = corrMapMatches.output.sets{1};
	bestMatchICs = corrMapMatches.output.ics{1};

	currentTrial = corrMapSets(setToMatch);
	bestMatchIC = bestMatchICs(setToMatch);

	
	singleBlinkArray = SingleCompare(eegsWithICA, currentTrial, bestMatchIC, idealPeak, threshold);
	
	stream = eegsWithICA{currentTrial}.icaact(bestMatchIC,:);
	
	lengthInSeconds = size(stream, 2)/128;
	
	disp([num2str(size(singleBlinkArray)), ' blinks in ', num2str(lengthInSeconds),' seconds'])
	% disp(['Current set:' , num2str(currentTrial) , ' Current IC: ' , num2str(bestMatchIC)])
	
	% stream = eegsWithICA{currentTrial}.icaact(bestMatchIC,:);

	% rawMatches = compareToIdealSpike(stream, idealPeak, 1, threshold);

	%%remove adjacent matches and scale to seconds
	% singleBlinkArray = removeAdjacentNumbers(rawMatches)/128;
end


function singleBlinkArray = SingleCompare(eegsWithICA, currentSet, currentIC, idealPeak, threshold)
	
	disp(['Current set:' , num2str(currentSet) , ' Current IC: ' , num2str(currentIC)])

	stream = eegsWithICA{currentSet}.icaact(currentIC,:);

	stream = zscore(stream);
	
	rawMatches = compareToIdealSpike(stream, idealPeak, 1, threshold);

	%remove adjacent matches and scale to seconds
	singleBlinkArray = removeAdjacentNumbers(rawMatches)/128;

	disp(round(singleBlinkArray))
	
	if(isempty(singleBlinkArray))
		disp('<Empty>')
	end
	
end 

function vectorWithoutAdjacentNumbers = removeAdjacentNumbers(listOfNumbers)
	
	vectorWithoutAdjacentNumbers = [];
	
	if(length(listOfNumbers) == 0)
		return
	end
	%Put first value into output vector
	vectorWithoutAdjacentNumbers = [listOfNumbers(1)];
	
	for i = 2:length(listOfNumbers)
		lastElementInCurrentOutput = vectorWithoutAdjacentNumbers(length(vectorWithoutAdjacentNumbers));
		currentNumberInInput = listOfNumbers(i);
		
		if(lastElementInCurrentOutput + 1 == currentNumberInInput)
			vectorWithoutAdjacentNumbers(length(vectorWithoutAdjacentNumbers)) = currentNumberInInput;
		else
			vectorWithoutAdjacentNumbers = [vectorWithoutAdjacentNumbers currentNumberInInput];
		end
	end %for
end

function fullStruct = makeEEGsStruct(eegsCellArray)
	
	fullStruct = struct([])
	
	for i = 1:size(eegsCellArray, 2)
		newStruct = struct(eegsCellArray{i});
		fullStruct = [fullStruct newStruct];
	end %for	
end