// ********************************************** WORK IN PROGRESS

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
  real groupMmu;
  real <lower=0> groupMsigma;

  real groupCmu;
  real <lower=0> groupCsigma;

  real groupALPHAmu;
  real <lower=0> groupALPHAsigma;

  real <lower=0,upper=1>groupW;
  real groupKminus2;

  // participant level
  vector[nParticipants] m;
  vector[nParticipants] c;
  vector<lower=0>[nParticipants] alpha;
  vector<lower=0,upper=0.5>[nParticipants] epsilon;
}

transformed parameters {
  // group LEVEL
  real groupK;

  vector[totalTrials] lkA;
  vector[totalTrials] lkB;

  vector[totalTrials] VA;
  vector[totalTrials] VB;

  vector[totalTrials] P;

  groupK <- groupKminus2+2;

  for (t in 1:totalTrials){
    // Magnitude Effect
    lkA[t] <- m[ID[t]]*log(fabs(A[t]))+c[ID[t]];
    lkB[t] <- m[ID[t]]*log(fabs(B[t]))+c[ID[t]];

    // calculate present subjective value for each reward
    VA[t] <- A[t] / (1+(exp(lkA[t])*DA[t]));
    VB[t] <- B[t] / (1+(exp(lkB[t])*DB[t]));

    // Psychometric function
    P[t] <- epsilon[ID[t]] + (1-2*epsilon[ID[t]]) * Phi( (VB[t]-VA[t]) / alpha[ID[t]] );
  }
}

model {
  // GROUP LEVEL PRIORS ======================================================
  groupMmu        ~ normal(-0.243, 0.27);
  groupMsigma     ~ normal(0,5);
  groupCmu        ~ normal(0, 100);
  groupCsigma     ~ normal(0,10);
  groupALPHAmu    ~ exponential(0.01);
  groupALPHAsigma ~ normal(0,5);
  groupW          ~ beta(1.1, 10.9);  // mode for lapse rate
  groupKminus2    ~ gamma(0.01, 0.01); // concentration parameter

  // PARTICIPANT LEVEL =======================================================
  m        ~ normal(groupMmu, groupMsigma);
  c        ~ normal(groupCmu, groupCsigma);
  epsilon  ~ beta(groupW*(groupK-2)+1 , (1-groupW)*(groupK-2)+1 );
  alpha    ~ normal(groupALPHAmu, groupALPHAsigma);

  R ~ bernoulli(P);
}

generated quantities { // see page 76 of manual
  // NO VECTORIZATION IN THIS BLOCK

  real groupMmu_prior;
  real groupMsigma_prior;
  real groupCmu_prior;
  real groupCsigma_prior;
  real groupALPHAmu_prior;
  real groupALPHAsigma_prior;
  real groupW_prior;
  real groupKminus2_prior;
  real groupK_prior;

  real m_group;
  real c_group;
  real alpha_group;
  real epsilon_group;

  real m_group_prior;
  real c_group_prior;
  real alpha_group_prior;
  real epsilon_group_prior;

  int <lower=0,upper=1> Rpostpred[totalTrials];


  for (t in 1:totalTrials){
    Rpostpred[t] <- bernoulli_rng(P[t]);
  }


    # slope
    groupMmu_prior       <- normal_rng(-0.243, 0.027*10);
    groupMsigma_prior    <- normal_rng(0.072, 0.025*10);

    # intercept (sample from the prior, independent from the data)
    groupCmu_prior        <- normal_rng(0, 100);
    groupCsigma_prior     <- uniform_rng(0, 100);

    # comparison acuity
    groupALPHAmu_prior    <- uniform_rng(0,100);
    groupALPHAsigma_prior <- uniform_rng(0,100);

    # error rates
    groupW_prior          <- beta_rng(1.1, 10.9);  # mode for lapse rate
    groupKminus2_prior    <- gamma_rng(0.01,0.01); # concentration parameter
    groupK_prior          <- groupKminus2_prior+2;


    // # Group-level posterior predictive distributions. These samples can be seen as inferences about an as yet unobserved participant who represents what we know about the parameters at the group level.
    m_group         <- normal_rng(groupMmu_prior, groupMsigma_prior);
    c_group         <- normal_rng(groupCmu_prior, groupCsigma_prior);
    epsilon_group   <- beta_rng(groupW_prior*(groupK_prior-2)+1 , (1-groupW_prior)*(groupK_prior-2)+1 );
    alpha_group     <- normal_rng(groupALPHAmu_prior, groupALPHAsigma_prior);

    m_group_prior   <- normal_rng(groupMmu_prior, groupMsigma_prior);
    c_group_prior   <- normal_rng(groupCmu_prior, groupCsigma_prior);
    epsilon_group_prior   <- beta_rng(groupW_prior*(groupK_prior-2)+1 , (1-groupW_prior)*(groupK_prior-2)+1 );
    alpha_group_prior     <- normal_rng(groupALPHAmu_prior, groupALPHAsigma_prior);

}
