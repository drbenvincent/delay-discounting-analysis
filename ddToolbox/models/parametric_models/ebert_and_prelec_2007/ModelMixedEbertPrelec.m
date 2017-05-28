classdef ModelMixedEbertPrelec < EbertPrelec
    %ModelMixedEbertPrelec XXXXXXX.
    %   model = MODELMIXEDEBERTPRELEC(...) conducts parameter estimation on the 
    %       data provided.
    %
    %   ModelMixedEbertPrelec methods:
    %       export - xxxx
    %       experimentMultiPanelFigure - xxx
    %       getInferredPresentSubjectiveValues - xxx
    %       plot - xxx
    %       plotDiscountFunction - xxx
    %       plotDiscountFunctionGrid - xxx
    %       plotDiscountFunctionsOverlaid - xxx
    %       plotParameterCornerPlot - xxx
    %
    %   See also ModelSeparateEbertPrelec, ModelHierarchicalEbertPrelec.

	methods (Access = public, Hidden = true)
		function obj = ModelMixedEbertPrelec(data, varargin)
			obj = obj@EbertPrelec(data, varargin{:});
			obj.modelFilename = 'mixedEbertPrelec';
            obj = obj.addUnobservedParticipant('GROUP');
            
            % MUST CALL THIS METHOD AT THE END OF ALL MODEL-SUBCLASS CONSTRUCTORS
            obj = obj.conductInference();
		end

    end
    
    methods (Access = protected)
    
		function initialParams = initialiseChainValues(obj, nchains)
			% Generate initial values of the root nodes
			nExperimentFiles = obj.data.getNExperimentFiles();
			for chain = 1:nchains
				initialParams(chain).groupW             = rand;
				initialParams(chain).groupALPHAmu		= rand*100;
				initialParams(chain).groupALPHAsigma	= rand*100;
			end
		end
        
	end

end
