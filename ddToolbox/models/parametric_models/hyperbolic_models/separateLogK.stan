// RANDOM FACTORS:   logk[p], epsilon[p], alpha[p]
// HYPER-PRIORS ON:  none

functions {
  real psychometric_function(real alpha, real epsilon, real VA, real VB){
    // returns probability of choosing B (delayed reward)
    return epsilon + (1-2*epsilon) * Phi( (VB-VA) / alpha);
  }

  vector df_hyperbolic1(vector reward, vector logk, vector delay){
    return reward ./ (1+(exp(logk).*delay));
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
  vector[nRealExperimentFiles] logk;
  vector<lower=0>[nRealExperimentFiles] alpha;
  vector<lower=0,upper=0.5>[nRealExperimentFiles] epsilon;
}

transformed parameters {
  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;

  VA = df_hyperbolic1(A, logk[ID], DA);
  VB = df_hyperbolic1(B, logk[ID], DB);

  for (t in 1:totalTrials){
    P[t] = psychometric_function(alpha[ID[t]], epsilon[ID[t]], VA[t], VB[t]);
  }
}

model {
  // no hierarchical inference for logk, alpha, epsilon
  logk    ~ normal(log(1.0/50.0), 2.5);
  alpha   ~ exponential(0.01);
  epsilon ~ beta(1.1, 10.9);
  R       ~ bernoulli(P);
}

generated quantities {  // NO VECTORIZATION IN THIS BLOCK ?
  int <lower=0,upper=1> Rpostpred[totalTrials];

  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
