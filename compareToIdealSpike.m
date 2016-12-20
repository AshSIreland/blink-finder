%TODO: Doesn't yet handle exclusion of consecutive good matches
function goodMatchingIndices = compareToIdealSpike(componentActivationTimeCourse, idealPeak, stepSize, mseThreshold)

	trialLength = size(componentActivationTimeCourse, 2);
	
	goodMatchingIndices = [];
	
	idealPeakLength = size(idealPeak, 2) - 1;
	
	%At every step, compare mean squared error
	for i = 1:stepSize:trialLength
		
		if i+idealPeakLength > trialLength
			continue
		end
		
		mseForSegment = mean( (idealPeak - componentActivationTimeCourse(i:(i+idealPeakLength)) ).^2);
		
		
		if mseForSegment < mseThreshold
			goodMatchingIndices = [goodMatchingIndices i];

		end
	end
end