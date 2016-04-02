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
  real logk[nParticipants];
  real groupLogKmu;
  real<lower=0> groupLogKsigma;
}

transformed parameters {

  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;

  for (t in 1:totalTrials){ // TODO Can this be vectorized?

    VA[t] <- A[t] / (1+(exp(logk[ID[t]])*DA[t]));
    VB[t] <- B[t] / (1+(exp(logk[ID[t]])*DB[t]));

    P[t] <- 0.01 + (1-2*0.01) * Phi( (VB[t]-VA[t]) / 10 );
  }
}

model {
  // group level priors
  groupLogKmu       ~ normal(-0.243,1000);
  groupLogKsigma    ~ uniform(0,100);

  // participant level
  for (p in 1:nParticipants){
    logk[p] ~ normal(groupLogKmu, groupLogKsigma^2);
  }

  R ~ bernoulli(P);
}

generated quantities {
  real logkGroupPredictive;
  logkGroupPredictive <- normal_rng(groupLogKmu, groupLogKsigma^2);
}
