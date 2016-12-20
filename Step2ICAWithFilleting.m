%Step 2. Chop off the bad start and end and run ICA

%Parameters
%	(1) filteredTrials (1 x [N trials] cell array of EEG structs): eeg separated into different trials and HiLo filtered. Step 1 creates them as "filteredTrials"
%	(2) BadStartDurationSeconds (array of double): representing number of seconds that look corrupted at start of trial
%	(3) BadEndDurationSeconds (array of double): representing number of seconds that look corrupted at start of trial
function allICA = Step2ICAWithFilleting(filteredTrials, goodCells)

	argFail = false;

	if(nargin < 2)
		disp('Too few arguments');
		argFail = true;
	end
		
	if(nargin > 2) %This half doesn't work on 2016
		disp('Too many arguments')
		argFail = true;
	end
		
	if(argFail)
		disp('Parameters')
		disp('(1) filteredTrials (1 x [N trials] cell array of EEG structs): eeg separated into different trials and HiLo filtered. Step 1 creates them as "filteredTrials"')
		disp('(2) BadStartDurationSeconds (array of double): representing number of seconds that look corrupted at start of trial')
		disp('(3) BadEndDurationSeconds (array of double): representing number of seconds that look corrupted at start of trial')
		return
	end
	
	numChannels = 14;
	numOfTrialsFound = size(filteredTrials, 2);
	
	samplingRate = 128
	
	for i = 1:numOfTrialsFound
		for j = 1:numChannels
			%onlyTheGoodStuff{j,i} = filteredTrials{j}.data(i, startPos:end - endCut);
			onlyTheGoodStuff{i,j} = filletMignonTrial(filteredTrials{i}.data(j, 1:end), goodCells{i}, samplingRate)
		end
	end
	
	for i = 1:numOfTrialsFound
		ogTranspose = onlyTheGoodStuff'
		%Extract the first epoch, for now, just to test
		SingleTrial = cell2mat(ogTranspose(:,i,:));

		%Use matlab array to initialize EEGlab EEG data structure
		eegStruct = pop_importdata('data', SingleTrial,'srate',128);

		%Initialize channel locations (required for ICA)
		eegStruct.chanlocs = readlocs('emotivTS.ced');
		onlyGoodEEGStruct{i} = eegStruct;
	end
	
	option_computerunica = 1

	for i = 1:numOfTrialsFound
		%Run ICA
		eegsWithICA{i} = pop_runica(onlyGoodEEGStruct{i}, 'extended', 1);
	end
	
	allICA = eegsWithICA
	
	pop_topoplot(eegsWithICA{2}, 0, 1:10, 'Second Advertisement Independent Component Scalp map', 0)
	pop_eegplot(eegsWithICA{2}, 0, 0, 0);
	
	disp('%%%%%%%%%%')
	disp('Displaying only the ICA components scalp map and activation time course from the first trial. ')
	disp('If it looks like there is no good blink component here, display ICA components for other trials using: ')
	disp('SCALP MAP: pop_topoplot(step2OutputVar{numOfTrial}, 0, 1:10)')
	disp('Component ACTIVATIONS: pop_eegplot(step2OutputVar{numOfTrial}, 0, 0, 0)')
	disp('%%%%%%%%%%')