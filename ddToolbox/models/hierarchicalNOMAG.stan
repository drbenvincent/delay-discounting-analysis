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
}

parameters {
  real logk;
}

transformed parameters {

  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;

  for (t in 1:totalTrials){ // TODO Can this be vectorized?

    VA[t] <- A[t] / (1+(exp(logk)*DA[t]));
    VB[t] <- B[t] / (1+(exp(logk)*DB[t]));

    P[t] <- 0.01 + (1-2*0.01) * Phi( (VB[t]-VA[t]) / 10 );
  }
}

model {
  logk ~ normal(0, 10);
  R ~ bernoulli(P);
}
