
Step1DisplayAllTrials();

%Katie: change this
%5NoL
%BadStartDurationSeconds = [16, 4, 6.6, 7, 6, 8, 4, 6];
%BadEndDurationSeconds = [2, 4, 4, 2.4, 3, 3, 4, 2.4];

%7JR
%BadStartDurationSeconds = [4, 5,2, 3, 2.4, 3, 2.4, 4];
%BadEndDurationSeconds = [1, 3, 3, 3, 6, 3, 2.4, 3];

%22DB
%BadStartDurationSeconds = [2, 2.5,1,1.5, 1.2, 1.5, 1.2, 2]
%BadEndDurationSeconds = [.5, 1.5,1.5,1.5, 3, 1.5, 1.2, 1.5]

BadStartDurationSeconds = [4.5,0,6,0,5,3.5,3,0]
BadEndDurationSeconds = [2,2.5,2,2,0,1.5,4,1]


eegsWithICA = Step2ICA(filteredTrials, BadStartDurationSeconds, BadEndDurationSeconds);

%idealPeak = [ 0,2,7,12,18,21,21,19,18,16,14,11,10,8,3,0 ];

normalizedIdealPeak = [0, 1.3, 2.7, 4.6, 6.4, 7.4, 7.4, 7, 6.7, 6.2, 5.3, 4.4, 4,4, 3.2, 1.6]

%Katie: change "2,2" here.
blinkGuesses = Step3CorrmapAndThreshold(eegsWithICA, 6,2, normalizedIdealPeak, 5);




























blink1_21 = eegsWithICA{1}.icaact(1, 2742:2765); %Refined. Size: 23

blink2_11 = eegsWithICA{2}.icaact(2, 1500:1516); %Refined. Size: 17
blink2_17 = eegsWithICA{2}.icaact(2, 2262:2284); %Refined. Size: 23
blink2_51 = eegsWithICA{2}.icaact(2, 6548:6565); %Refined. Size: 19

blink4_18 = eegsWithICA{4}.icaact(2, 2369:2386); %Refined. Size: 18
blink4_23 = eegsWithICA{4}.icaact(2, 3016:3037); %Refined. Size: 22

blink5_7 = eegsWithICA{5}.icaact(3, 984:1007) %Refined. Size: 24

normalized2 = zscore(eegsWithICA{2}.icaact(2,:));
normalized2(1498:1516)

%mean( (idealPeak - blinkComp4_18(66:(66+15)) ).^2)
