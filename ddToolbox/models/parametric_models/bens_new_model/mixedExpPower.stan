// RANDOM FACTORS:   k[p], tau[p], epsilon[p], alpha[p]
// HYPER-PRIORS ON:  epsilon[p], alpha[p]

functions {  
  real psychometric_function(real alpha, real epsilon, real VA, real VB){
    // returns probability of choosing B (delayed reward)
    return epsilon + (1-2*epsilon) * Phi( (VB-VA) / alpha);
  }

  vector df_exp_power(vector reward, vector delay, vector k, vector tau){
    vector[rows(reward)] V;
    for (t in 1:rows(reward)){
       V[t] = reward[t] *( exp( -k[t] * (delay[t]^tau[t]) ) );
    }
    return V;
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
  // Discounting parameters
  vector[nRealExperimentFiles] k; 
  vector<lower=0>[nRealExperimentFiles] tau;

  // Psychometric function parameters
  real <lower=0>alpha_mu;
  real <lower=0>alpha_sigma;
  vector<lower=0>[nRealExperimentFiles+1] alpha;

  real <lower=0,upper=1> omega;
  real <lower=0> kappa;
  vector<lower=0,upper=0.5>[nRealExperimentFiles+1] epsilon;
}

transformed parameters {
  vector[totalTrials] VA;
  vector[totalTrials] VB;
  vector[totalTrials] P;
    
  VA = df_exp_power(A, DA, k[ID], tau[ID]);
  VB = df_exp_power(B, DB, k[ID], tau[ID]);
  for (t in 1:totalTrials){
    P[t] = psychometric_function(alpha[ID[t]], epsilon[ID[t]], VA[t], VB[t]);
  }
}

model {
  alpha_mu     ~ uniform(0,100);
  alpha_sigma  ~ inv_gamma(0.01,0.01);
  alpha        ~ normal(alpha_mu, alpha_sigma);

  omega        ~ beta(1.1, 10.9);  // mode for lapse rate
  kappa        ~ gamma(0.1,0.1);   // concentration parameter
  epsilon      ~ beta(omega*(kappa-2)+1 , (1-omega)*(kappa-2)+1 );

  // no hierarchical inference for k or tau
  k       ~ normal(0, 2);
  tau     ~ exponential(0.01);
  
  R ~ bernoulli(P);
}

generated quantities {  // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];
  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
