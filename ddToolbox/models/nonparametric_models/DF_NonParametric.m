classdef DF_NonParametric < DF1
	%DF_NonParametric The classic 1-parameter discount function
	
	methods (Access = public)

		function obj = DF_NonParametric(varargin)
			obj = obj@DF1(varargin{:});
		end

		function AUC = calcAUC(~, ~)
			% Currently not calculating AUC for 2D discount functions (eg Magnitude Effect)
			
			% return an empty Stochastic object
			AUC = Stochastic('AUC');
		end

%         function Z = calcAUC(obj)
% 
% 			x = obj.getDelayValues()';
% 			
% 			% TODO: this should be a get method from Stochastic arrays
% 			
% 			for n=1:numel(obj.theta.Rstar)
% 				y(:,n) = obj.theta.Rstar(n).samples;
% 			end
% 			%y(:,1) = zeros(1,size(y,1));
% 			
% % 			% convert from log(A/B) to A/B
% % 			y = exp(y);
% 			
% 			% Calculate the trapezoidal area under curve. NOTE: Normalized x-axis.
% 			
% 
% 			%% Add new column representing (delay=0, discount fraction=1)
% 			nCols = size(y,1);
% 			%x = [0 x];
% 			y = [ones(nCols,1) , y];
% 			
% 			assert(isrow(x), 'x must be a row vector, ie [1, N]')
% 			assert(size(y,2)==numel(x),'y must have same number of columns as x')
% 			
% 			
% 			%% Normalise x
% 			x = x ./ max(x);
% 			
% 			%% Calculate trapezoidal AUC
% 			Z = zeros(nCols,1);
% 			for s=1:nCols
% 				Z(s) = trapz(x,y(s,:));
% 			end
% 
%         end
        
	end
    
    
	methods (Access = protected)
		
		% OVERRIDDEN FROM SUPERCLASS
		function delayValues = getDelayValues(obj)
			delayValues = obj.data.getUniqueDelays;
		end
	end
	
	methods (Static, Access = protected)
		
		function y = function_evaluation(~, theta)
			% TODO: basically, return theta as a matrix, but add zeros for
			% zero delay
			y = theta.Rstar;
			y = [ ones(1,size(y,2)); y  ];
		end
		
	end

end
