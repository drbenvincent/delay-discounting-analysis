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

  // particiant LEVEL
  real logk[nParticipants];
  vector<lower=0>[nParticipants] alpha;
  vector<lower=0,upper=0.5>[nParticipants] epsilon;

}

transformed parameters {

  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;

  for (t in 1:totalTrials){ // TODO Can this be vectorized?
    // calculate present subjective value for each reward
    VA[t] <- A[t] / (1+(exp(logk[ID[t]])*DA[t]));
    VB[t] <- B[t] / (1+(exp(logk[ID[t]])*DB[t]));

    // Psychometric function
    P[t] <- epsilon[ID[t]] + (1-(2*epsilon[ID[t]])) * Phi( (VB[t]-VA[t]) / alpha[ID[t]] );
  }
}

model {
  // group level priors
  groupLogKmu       ~ normal(-0.243,1000);
  groupLogKsigma    ~ uniform(0,100);

  groupALPHAmu      ~ uniform(0,1000);
  groupALPHAsigma   ~ uniform(0,1000);

  // participant level - these are vectors
  logk    ~ normal(groupLogKmu, groupLogKsigma^2);
  alpha   ~ normal(groupALPHAmu, groupALPHAsigma^2); // truncate?
  epsilon ~ beta(1 , 1 ); // truncate?
  // for (p in 1:nParticipants){
  //   logk[p] ~ normal(groupLogKmu, groupLogKsigma^2);
  // }

  R ~ bernoulli(P);
}

generated quantities {
  // NO VECTORIZATION IN THIS BLOCK

  real logk_group;
  // real <lower=0> alpha_group;
  // real <lower=0,upper=0.5> epsilon_group;
  int <lower=0,upper=1> Rpostpred[totalTrials];

  // group level posterior predictive distributions
  logk_group    <- normal_rng(groupLogKmu, groupLogKsigma^2);
  // alpha_group   <- normal_rng(groupALPHAmu, groupALPHAsigma^2) T[0,];
  // epsilon_group <- beta_rng(1, 1) T[0,0.5];

  for (t in 1:totalTrials){
    Rpostpred[t] <- bernoulli_rng(P[t]);
  }

  //Rpostpred <- bernoulli_rng(P);
}
