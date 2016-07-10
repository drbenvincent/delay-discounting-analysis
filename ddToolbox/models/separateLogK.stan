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
  vector[nParticipants] logk;
  vector<lower=0>[nParticipants] alpha;
  vector<lower=0,upper=1>[nParticipants] epsilon;
}

transformed parameters {
  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;

  for (t in 1:totalTrials){
    // calculate present subjective value for each reward
    VA[t] <- A[t] / (1+(exp(logk[ID[t]])*DA[t]));
    VB[t] <- B[t] / (1+(exp(logk[ID[t]])*DB[t]));
    // Psychometric function
    P[t] <- epsilon[ID[t]] + (1-(2*epsilon[ID[t]])) * Phi_approx( (VB[t]-VA[t]) / alpha[ID[t]] );
  }
}

model {
  // participant level - these are vectors
  logk    ~ normal(-3.9120, 2.5);
  alpha   ~ exponential(0.01);
  epsilon ~ beta(1.1, 10.9); # T[,0.5]
  R       ~ bernoulli(P);
}

generated quantities {  // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];
  real logk_prior;
  real alpha_prior; // TODO: NEEDS TO BE POSTIVE-VALUED ONLY
  real <lower=0,upper=1> epsilon_prior;

  // POSTERIOR PREDICTION
  for (t in 1:totalTrials){
    Rpostpred[t] <- bernoulli_rng(P[t]);
  }

  // SAMPLING FROM PRIORS
  logk_prior <- normal_rng(-3.9120, 2.5);
  alpha_prior <- exponential_rng(0.01);
  epsilon_prior <- beta_rng(1.1, 10.9); // how do I trunate <0.5
}
