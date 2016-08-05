function convergenceSummary(Rhat, saveFolder, IDnames)
% TODO: export Rhat stats in the form of a Table. Would need a
% table for participant-level variables. This would now include
% a "group" unobserved participant. But we may also have other
% group-level parameters in addition to this, and these might
% have to go into a separate table.

assert(isstruct(Rhat))
assert(ischar(saveFolder))
assert(iscellstr(IDnames))

R_HAT_THRESHOLD = 1.01;

[fid, fname] = setupTextFile(saveFolder, 'ConvergenceReport.txt');
%MCMCParameterReport();
printRhatInformation(IDnames);
fclose(fid);
fprintf('Convergence report saved in:\n\t%s\n\n',fname)


% 			function MCMCParameterReport()
% 				logInfo(fid,'MCMC inference was conducted with %d chains. ', obj.mcmcparams.nchains)
% 				logInfo(fid,'The first %d samples were discarded from each chain, ', obj.mcmcparams.nburnin )
% 				logInfo(fid,'resulting in a total of %d samples to approximate the posterior distribution. ', obj.mcmcparams.nsamples )
% 				logInfo(fid,'\n\n\n');
% 			end

	function printRhatInformation(IDnames)
		% TODO: export this in a longform table ?
		nParticipants = numel(IDnames);
		
		isRhatThresholdExceeded = false;
		varNames = fieldnames(Rhat);
		
		for varName = each(varNames)
			% skip posterior predictive variables
			if strcmp(varName,'Rpostpred'), continue, end
			RhatValues = Rhat.(varName);
			
			% conditions
			isVectorOfParticipants = @(x,p) isvector(x) && numel(x)==p;
			isVecorForEachParticipant = @(x,p) ismatrix(x) && size(x,1)==p;
			
			if isscalar(RhatValues)
				logInfo(fid,'\nRhat for: %s\t',varName);
				logInfo(fid,'%2.5f', RhatValues);
			elseif isVectorOfParticipants(RhatValues,nParticipants)
				logInfo(fid,'\nRhat for: %s\n',varName);
				for i=1:numel(IDnames)
					logInfo(fid,'%s:\t', IDnames{i}); % participant name
					logInfo(fid,'%2.5f\t', RhatValues(i));
					checkRhatExceedThreshold(RhatValues(i));
					logInfo(fid,'\n');
				end
			elseif isVecorForEachParticipant(RhatValues,nParticipants)
				logInfo(fid,'\nRhat for: %s\n',varName);
				for i=1:numel(IDnames)
					logInfo(fid,'%s\t', IDnames{i}); % participant name
					logInfo(fid,'%2.5f\t', RhatValues(i,:));
					checkRhatExceedThreshold(RhatValues);
					logInfo(fid,'\n');
				end
			end
		end
		
		if isRhatThresholdExceeded
			logInfo(fid,'\n\n\n**** WARNING: convergence issues :( ****\n\n\n')
			% Uncomment this line if you want auditory feedback
			% speak('there were some convergence issues')
			% beep
		else
			logInfo(fid,'\n\n\n**** No convergence issues :) ****\n\n\n')
		end
		
		function checkRhatExceedThreshold(RhatValues)
			if any(RhatValues>R_HAT_THRESHOLD)
				isRhatThresholdExceeded = true;
				logInfo(fid,'(WARNING: poor convergence)');
			end
		end
	end
end