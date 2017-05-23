// RANDOM FACTORS:   k[p], epsilon[p], alpha[p]
// HYPER-PRIORS ON:  epsilon[p], alpha[p]

functions {
  real psychometric_function(real alpha, real epsilon, real VA, real VB){
    // returns probability of choosing B (delayed reward)
    return epsilon + (1-2*epsilon) * Phi( (VB-VA) / alpha);
  }

  vector df_exponential1(vector reward, vector k, vector delay){
    return reward .* exp(-k .* delay);
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
  real alpha_mu;
  real <lower=0> alpha_sigma;
  vector<lower=0>[nRealExperimentFiles+1] alpha;

  real <lower=0,upper=1> omega;
  real <lower=0> kappa;
  vector<lower=0,upper=0.5>[nRealExperimentFiles+1] epsilon;

  vector[nRealExperimentFiles] k; // No hierarchical, so no +1
}

transformed parameters {
  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;

  VA = df_exponential1(A, k[ID], DA);
  VB = df_exponential1(B, k[ID], DB);

  for (t in 1:totalTrials){
    P[t] = psychometric_function(alpha[ID[t]], epsilon[ID[t]], VA[t], VB[t]);
  }
}

model {
  alpha_mu     ~ uniform(0,100);
  alpha_sigma  ~ inv_gamma(0.01,0.01);
  alpha        ~ lognormal(alpha_mu, alpha_sigma); // positive values for alpha 

  omega        ~ beta(1.1, 10.9);  // mode for lapse rate
  kappa        ~ gamma(0.1,0.1);   // concentration parameter
  epsilon      ~ beta(omega*(kappa-2)+1 , (1-omega)*(kappa-2)+1 );

  // no hierarchical inference for k
  k            ~ normal(0.01, 0.5^2);

  R ~ bernoulli(P);
}

generated quantities {  // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];

  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
