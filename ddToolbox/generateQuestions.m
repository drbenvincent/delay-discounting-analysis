function [A, B, D] = generateQuestions(type)
% This function will generate sets of roughly N questions
%
% Types:
% 'BVgrid1'
%
%
%
% [A, B, D] = generateQuestions('ABslice');
% [A, B, D] = generateQuestions('Dslice');
% [A, B, D] = generateQuestions('Dshotgun');
% [A, B, D] = generateQuestions('Bslice');
% [A, B, D] = generateQuestions('BSLICES');
% [A, B, D] = generateQuestions('Kirby27');

switch type
	
	case{'ABslice'}
		% All values have constant A/B. This is intended for when we are
		% interested in the magnitude effect
		ab=0.8;
		
		dvec=[7 356/12, 356/4, 356/2, 356];
		bvec=[50 250 500 750 1000 10000];
		[D,B] =meshgrid(dvec,bvec);
		AB = ones(size(D)).*ab;
		% A is the free variable to compute
		A = AB.*B;
		
	case{'Dslice'}
% 		d=28;
% 		bvec=[50 500 1000 10000];
% 		kvec=logspace(-3,-1,7) .*5;
% 		[B,K] =meshgrid(bvec,kvec);
% 		
% 		A = B ./ (1+K.*d);
% 		D = ones(size(A)).*d;
		
		% multiple d-slices
		d=[7 29];
		bvec=[50 250 1000 10000];
		kvec=logspace(-3,-1,7);
		[BB,K] =meshgrid(bvec,kvec);
		for n=1:numel(d)
			A(:,n) = vec(BB ./ (1+K.*d(n)));
			D(:,n) = ones(size(A(:,n))).*d(n);
			B(:,n) = BB(:);
		end
		A=A(:);
		D=D(:);
		B=B(:);	
		K=K(:);
		
		
	case{'Dshotgun'}
		
		bvec=[50 250 1000 10000];
		kvec=logspace(-3,-1,10);
		[B,K] =meshgrid(bvec,kvec);
		
		D = randi([7 356/2], size(B));
		
		A = B ./ (1+K.*D);
		%D = ones(size(A)).*d;

	case{'Bslice'}
		% Fixed delayed reward
		nQUESTIONS=49;
		b = 100;
		K=logspace(-3,-1,nQUESTIONS);
		dvec=[7 356/12, 356/4, 356/2, 356];
		for n=1:nQUESTIONS
			D(n) = dvec( randi(numel(dvec),1));
		end
		A = b ./ (1+ K.*D);
		B = ones(size(D)).*b;
		
	case{'BsliceRD'} % days randomised
		% Fixed delayed reward
		nQUESTIONS=49;
		b = 100;
		K=logspace(-3,-1,nQUESTIONS);
		for n=1:nQUESTIONS
			D(n) = randi([7 356],1);
		end
		%dvec=[7 356/12, 356/4, 356/2, 356];
		%abvec=[0.8 0.6 0.4 0.2];
		
		%[D,K] =meshgrid(dvec,kvec);
		A = b ./ (1+ K.*D);
		B = ones(size(D)).*b;
		
		
		
% 	case{'BDdiag'}
% 		% Fixed delayed reward
% 		kvec=logspace(-4,-1,7) .*5;
% 		dvec=[28*1, 28*3, 356/2, 356];
% 		bvec=dvec
% 		
% 		[D,K] =meshgrid(dvec,kvec);
% 		A = b ./ (1+ K.*D);
% 		B = ones(size(D)).*b;
		
		
		
	case{'BSLICES'}
		% Fixed delayed reward
		bvec = [50 100 500 1000 10000];
		kvec=logspace(-3,-2,5);
		dvec=[7 356/12, 356/4, 356/2, 356];
		%abvec=[0.8 0.6 0.4 0.2];
		
		[B, D, K] =meshgrid(bvec,dvec,kvec);
		
		% Add noise to B
		
		A = B ./ (1+ K.*D);
		%B = ones(size(D)).*b;
% 		
% 	case{'FIR'}
% 		% Fixed immediate reward
% % 		a = 100;
% % 		dvec=[28, 28*3, 365/2];
% % 		%abvec=[0.8 0.6 0.4 0.2];
% % 		kvec=logspace(-4,-1,6);
% % 		
% % 		[D,K] =meshgrid(dvec,kvec);
% % 		
% % 		% B is the free variable to compute
% % 		B = a + a.*K.*D;
% % 		%A = ones(size(D)).*a;
% % 		% B is the free variable to compute
% % 		%B = A./AB;
% % 		A = ones(size(D)).*a;
% 
% 		a = 100;
% 		bvec=[150 200 250 500  ];
% 		kvec=logspace(-3,-1,7) .*5;
% 		
% 		[B,K] =meshgrid(bvec,kvec);
% 		
% 		% D is the free variable to compute
% 		D = (B-a) ./ (a.*K);
% 		%A = ones(size(D)).*a;
% 		% B is the free variable to compute
% 		%B = A./AB;
% 		A = ones(size(D)).*a;
		
% 	case{'FIR2'}
% 		a = 100;
% 		abvec=[0.25 0.5 0.75 0.9];
% 		kvec=logspace(-3,-1,7) .*5;
% 		
% 		[AB,K] =meshgrid(abvec,kvec);
% 		
% 		B = a./AB;
% 		
% 		% D is the free variable to compute
% 		D = (B-a) ./ (a.*K);
% 		%A = ones(size(D)).*a;
% 		% B is the free variable to compute
% 		%B = A./AB;
% 		A = ones(size(D)).*a;
	
	case{'Kirby27'}
		 A= [54    55    19    31    14    47    15    25    78    40    11    67    34    27    69		49    80    24    33    28    34    25    41    54    54    22    20];
		 B= [55    75    25    85    25    50    35    60    80    55    30    75    35    50    85		60    85    35    80    30    50    30    75    60    80    25    55];
		 D =[117    61    53     7    19   160    13    14   162    62     7   119   186    21    91	89   157    29    14   179    30    80    20   111    30   136     7];

end

%% concatenate & Export text file of questions
A = A(:);
B = B(:);
D = D(:);
N = length(A);

% round
A=floor(A);
B=floor(B);
D=floor(D);


% randomise the order
idx=randperm(N);
A = A(idx);
B = B(idx);
D = D(idx);

% output text file
filename = ['QUESTIONS-' type];
fid=fopen([ filename '.txt'],'w');
fprintf(fid, 'A\tB\tD\tR\n');
for n=1:N
	fprintf(fid, '%d\t%d\t%d\t\n', A(n), B(n), D(n));
end
fclose(fid);

%% Plot in 3D space and in 2D space
% figure(1)
% clf

% subplot(1,2,1) % --------------------------------------
% plot(D, A./B, 'o')
% xlabel('D')
% ylabel('A/B ratio')
% ylim([0 1])
% box off
% axis square
% 
% subplot(1,2,2) % --------------------------------------
% plot imm
h = stem3(B, D, A./B);
axis tight
axis vis3d
view([-45, 34])
set(gca,'YDir','reverse')

h.MarkerFaceColor = 'w';
h.Color = 'k';
hold on

xlabel('B')
set(gca,'XScale','log')

ylabel('D')

zlabel('A/B ratio')
zlim([0 1])

axis square
title(type)





%% Export Figure

cd('figs')
%latex_fig(16, 10, 10)
figName = ['QUESTIONS-' type];
export_fig(figName,'-png','-m3')
hgsave(figName)
cd('..')
fprintf('Figure saved: %s\n\n', figName);