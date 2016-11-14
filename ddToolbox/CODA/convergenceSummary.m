function convergenceSummary(Rhat, savePath, IDnames)
% TODO: export Rhat stats in the form of a Table. Would need a
% table for participant-level variables. This would now include
% a "group" unobserved participant. But we may also have other
% group-level parameters in addition to this, and these might
% have to go into a separate table.

assert(isstruct(Rhat))
assert(ischar(savePath))
assert(iscellstr(IDnames))


[fid, fname] = setupTextFile(savePath, 'ConvergenceReport.txt');
printRhatInformation(IDnames, Rhat, fid);
fclose(fid);
fprintf('Convergence report saved in:\n\t%s\n\n',fname)

end


function printRhatInformation(IDnames, Rhat, fid)
% TODO: export this in a longform table ?
nExperimentFiles = numel(IDnames);
varNames = fieldnames(Rhat);

% TODO: This is a filter then a map ---------------------------------------
isVectorOfParticipants = @(x,p) isvector(x) && numel(x)==p;
isVectorForEachParticipant = @(x,p) ismatrix(x) && size(x,1)==p;
for n = 1:numel(varNames)
	% skip posterior predictive variables
	if strcmp(varNames{n},'Rpostpred'), continue, end
	RhatValues = Rhat.(varNames{n});
	
	print_variable_of_interest()
	
	if isscalar(RhatValues)
		print_scalar()
	elseif isVectorOfParticipants(RhatValues,nExperimentFiles)
		print_vector()
	elseif isVectorForEachParticipant(RhatValues,nExperimentFiles)
		print_matrix_2D()
	end
end

for n = 1:numel(varNames)
	if any(RhatValues > RHAT_THRESHOLD())
		logInfo(fid,'\n\n\n**** WARNING: convergence issues :( ****\n\n\n')
		% Uncomment if you want auditory feedback
		% try
		%	speak('there were some convergence issues')
		% catch
		%	beep
		% end
	end
	logInfo(fid,'\n\n\n**** No convergence issues :) ****\n\n\n')
end





	function print_variable_of_interest()
		logInfo(fid,'\nRhat for: %s\t',varNames{n});
	end

	function print_participant_name(i)
		logInfo(fid,'%s:\t', IDnames{i}); % participant name
	end

	% ------------------------------------------------------
	% TODO: refactor these into a single function?
	function print_scalar
		logInfo(fid,'%2.5f', RhatValues);
		printConvergenceAchivedOrNot(RhatValues);
	end

	function print_vector()
		for i=1:numel(IDnames)
			print_participant_name(i)
			logInfo(fid,'%2.5f\t', RhatValues(i));
			printConvergenceAchivedOrNot(RhatValues(i));
			logInfo(fid,'\n');
		end
	end

	function print_matrix_2D()
		for i=1:numel(IDnames)
			print_participant_name(i)
			logInfo(fid,'%2.5f\t', RhatValues(i,:));
			printConvergenceAchivedOrNot(RhatValues);
			logInfo(fid,'\n');
		end
	end
	% ------------------------------------------------------

	function printConvergenceAchivedOrNot(RhatValues)
		if any(RhatValues > RHAT_THRESHOLD() )
			logInfo(fid,'(WARNING: poor convergence)');
		end
	end
end