%Rename: filletChannel
function filleted = filletMignonTrial(trial, goodCells, sampleRate)
	
	filleted = [];
	
	trialLength = length(trial)
	
	numOfGoodSectors = length(goodCells)
	
	for i = 1:numOfGoodSectors
		currentGoodSector = goodCells{i}
		
		startSlice = currentGoodSector(1)*sampleRate;
		endSlice = currentGoodSector(2)*sampleRate
		
		if startSlice == 0
			startSlice = 1
		end
		
		if endSlice > trialLength
			%Extract the next good segment
			filleted = cat(2, filleted, trial(startSlice:end));
		else
			%Extract the next good segment
			filleted = cat(2, filleted, trial(startSlice:endSlice));
		end
	end
	
return