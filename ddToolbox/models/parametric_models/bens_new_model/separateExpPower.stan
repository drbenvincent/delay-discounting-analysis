// RANDOM FACTORS:   k[p], tau[p], epsilon[p], alpha[p]
// HYPER-PRIORS ON:  none

functions {  
  real psychometric_function(real alpha, real epsilon, real VA, real VB){
    // returns probability of choosing B (delayed reward)
    return epsilon + (1-2*epsilon) * Phi( (VB-VA) / alpha);
  }
  real df_exp_power(real reward, real delay, real k, real tau){
    return reward *( exp( -k * (delay^tau) ) );
  }
}

data {
  int <lower=1> totalTrials;
  int <lower=1> nRealExperimentFiles;
  vector[totalTrials] A;
  vector[totalTrials] B;
  vector<lower=0>[totalTrials] DA;
  vector<lower=0>[totalTrials] DB;
  int <lower=0,upper=1> R[totalTrials];
  int <lower=0,upper=nRealExperimentFiles> ID[totalTrials];
}

parameters {
  vector[nRealExperimentFiles] k;
  vector<lower=0>[nRealExperimentFiles] tau;
  vector<lower=0>[nRealExperimentFiles] alpha;
  vector<lower=0,upper=0.5>[nRealExperimentFiles] epsilon;
  
  real tauM;
  real kM;
}

transformed parameters {
  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;
  
  vector[nRealExperimentFiles] tauMvec;
  vector[nRealExperimentFiles] kMvec;
  

  for (t in 1:totalTrials){
    VA[t] = df_exp_power(A[t], DA[t], k[ID[t]], tau[ID[t]]);
    VB[t] = df_exp_power(B[t], DB[t], k[ID[t]], tau[ID[t]]);
    P[t] = psychometric_function(alpha[ID[t]], epsilon[ID[t]], VA[t], VB[t]);
  }
}

model {
  // no hierarchical inference for k, tau, alpha, epsilon
  k       ~ normal(0, 0.01); # sigma = 0.1
  tau     ~ exponential(0.001);
  
  alpha   ~ exponential(0.001);
  epsilon ~ beta(1+1, 1+20);
  
  R       ~ bernoulli(P);
}

generated quantities {  // NO VECTORIZATION IN THIS BLOCK ?
  int <lower=0,upper=1> Rpostpred[totalTrials];

  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
