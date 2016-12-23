functions {
  real psychometric_function(real alpha, real epsilon, real VA, real VB){
    // returns probability of choosing B (delayed reward)
    return epsilon + (1-2*epsilon) * Phi( (VB-VA) / alpha);
  }

  vector magnitude_effect(vector m, vector c, vector reward){
    return m .* log(reward) + c; // we assume reward is positive
  }

  vector df_hyperbolic1(vector reward, vector logk, vector delay){
    return reward ./ (1+(exp(logk).*delay));
  }
  
  vector discounting(vector A, vector B, vector DA, vector DB, vector m, vector c, vector epsilon, vector alpha){
    vector[rows(A)] logkA;
    vector[rows(B)] logkB;
    vector[rows(A)] VA;
    vector[rows(B)] VB;
    vector[rows(A)] P;
    // magnitude effect: note, operates on ABSOLUTE reward values
    logkA = magnitude_effect(m, c, fabs(A));
    logkB = magnitude_effect(m, c, fabs(B));
    // calculate present subjective values
    VA = df_hyperbolic1(A, logkA, DA);
    VB = df_hyperbolic1(B, logkB, DB);
    // calculate probability of choosing delayed reward (B; coded as R=1)
    for (t in 1:rows(A)){
      P[t] = psychometric_function(alpha[t], epsilon[t], VA[t], VB[t]);
    }
    return P;
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
  vector[nRealExperimentFiles] m;
  vector[nRealExperimentFiles] c;
  vector<lower=0>[nRealExperimentFiles] alpha;
  vector<lower=0,upper=0.5>[nRealExperimentFiles] epsilon;
}

transformed parameters {
  vector[totalTrials] P;
  P = discounting(A, B, DA, DB, m[ID], c[ID], epsilon[ID], alpha[ID]);
}

model {
  m        ~ normal(-0.243, 0.5);
  c        ~ normal(0, 10);
  epsilon  ~ beta(1.1, 10.9);
  alpha    ~ exponential(0.01);

  R ~ bernoulli(P);
}

generated quantities { // see page 76 of manual // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];

  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
