// JAGS model of temporal discounting behaviour
// - 1-parameter hyperbolic discount function
// - magnitude effect
// - hierarchical: estimates participant- and group-level parameters

// INTEGERS HAVE TO BE IN ARRAYS

data {
  int <lower=1> totalTrials;
  int <lower=1> nParticipants;

  vector[totalTrials] A;
  vector[totalTrials] B;
  vector<lower=0>[totalTrials] DA;
  vector<lower=0>[totalTrials] DB;
  int <lower=0,upper=1> R[totalTrials];
  int <lower=0,upper=nParticipants> ID[totalTrials];
}

parameters {
  // group level
  real groupLogKmu;
  real<lower=0> groupLogKsigma;

  real groupALPHAmu;
  real <lower=0> groupALPHAsigma;

  real <lower=0,upper=1>groupW;
  real groupKminus2;

  // particiant level
  vector[nParticipants] logk;
  vector<lower=0>[nParticipants] alpha;
  vector<lower=0,upper=1>[nParticipants] epsilon;


}

transformed parameters {
  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;
  real groupK;
  //real groupK_prior;

  groupK <- groupKminus2+2;
  //groupK_prior <- groupKminus2_prior+2;

  for (t in 1:totalTrials){
    // calculate present subjective value for each reward
    VA[t] <- A[t] / (1+(exp(logk[ID[t]])*DA[t]));
    VB[t] <- B[t] / (1+(exp(logk[ID[t]])*DB[t]));
    // Psychometric function
    P[t] <- epsilon[ID[t]] + (1-(2*epsilon[ID[t]])) * Phi_approx( (VB[t]-VA[t]) / alpha[ID[t]] );
  }
}

model {
  // group level priors
  groupLogKmu      ~ normal(-3.9120,2.5);
  groupLogKsigma   ~ inv_gamma(0.01,0.01);

  groupALPHAmu     ~ uniform(0,100);
  groupALPHAsigma  ~ inv_gamma(0.01,0.01);

  groupW           ~ beta(1.1, 10.9);  // mode for lapse rate
  groupKminus2     ~ gamma(0.1,0.1); // concentration parameter


  // participant level - these are vectors
  logk    ~ normal(groupLogKmu, groupLogKsigma);
  alpha   ~ normal(groupALPHAmu, groupALPHAsigma); // truncate?
  epsilon ~ beta(groupW*(groupK-2)+1 , (1-groupW)*(groupK-2)+1 ); // truncate?
  
  R ~ bernoulli(P);
}

generated quantities {  // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];
  // posterior predictive responses
  for (t in 1:totalTrials){
    Rpostpred[t] <- bernoulli_rng(P[t]);
  }

}
