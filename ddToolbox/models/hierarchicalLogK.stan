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
  int <lower=1> nRealParticipants;
  vector[totalTrials] A;
  vector[totalTrials] B;
  vector<lower=0>[totalTrials] DA;
  vector<lower=0>[totalTrials] DB;
  int <lower=0,upper=1> R[totalTrials];
  int <lower=0,upper=nRealParticipants> ID[totalTrials];
}

parameters {
  real logk_mu;
  real<lower=0> logk_sigma;
  vector[nRealParticipants+1] logk; // +1 for unobserved participant

  real alpha_mu;
  real <lower=0> alpha_sigma;
  vector<lower=0>[nRealParticipants+1] alpha; // +1 for unobserved participant

  real <lower=0,upper=1> omega;
  real <lower=0> kappa;
  vector<lower=0,upper=0.5>[nRealParticipants+1] epsilon; // +1 for unobserved participants
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
  logk_mu     ~ normal(-3.9120,2.5);
  logk_sigma  ~ inv_gamma(0.01,0.01);
  logk        ~ normal(logk_mu, logk_sigma);

  alpha_mu    ~ uniform(0,100);
  alpha_sigma ~ inv_gamma(0.01,0.01);
  alpha       ~ normal(alpha_mu, alpha_sigma);

  omega       ~ beta(1.1, 10.9);  // mode for lapse rate
  kappa       ~ gamma(0.1,0.1); // concentration parameter
  epsilon     ~ beta(omega*(kappa-2)+1 , (1-omega)*(kappa-2)+1 );

  R ~ bernoulli(P);
}

generated quantities {  // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];
  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
