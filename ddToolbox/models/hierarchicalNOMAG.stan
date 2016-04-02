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
  alpha   ~ normal(groupALPHAmu, groupALPHAsigma^2);
  epsilon ~ beta(1 , 1 );
  // for (p in 1:nParticipants){
  //   logk[p] ~ normal(groupLogKmu, groupLogKsigma^2);
  // }

  R ~ bernoulli(P);
}

generated quantities {
  real logk_group;
  real alpha_group;
  //int <lower=0,upper=1> Rpostpred[totalTrials];

  logk_group    <- normal_rng(groupLogKmu, groupLogKsigma^2);
  alpha_group   <- normal_rng(groupALPHAmu, groupALPHAsigma^2);

  //Rpostpred <- bernoulli_rng(P);
}
