functions {
  real psychometric_function(real alpha, real epsilon, real VA, real VB){
    // returns probability of choosing B (delayed reward)
    return epsilon + (1-2*epsilon) * Phi( (VB-VA) / alpha);
  }

  vector df_exponential1(vector reward, vector k, vector delay){
    return reward .* exp(-k .* delay);
  }
  
  vector discounting(vector A, vector B, vector DA, vector DB, vector k, vector epsilon, vector alpha){
    vector[rows(A)] VA;
    vector[rows(B)] VB;
    vector[rows(A)] P;
    // calculate present subjective values
    VA = df_exponential1(A, k, DA);
    VB = df_exponential1(B, k, DB);
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
  real k_mu;
  real<lower=0> k_sigma;
  vector[nRealExperimentFiles+1] k; // +1 for unobserved participant

  real alpha_mu;
  real <lower=0> alpha_sigma;
  vector<lower=0>[nRealExperimentFiles+1] alpha; // +1 for unobserved participant

  real <lower=0,upper=1> omega;
  real <lower=0> kappa;
  vector<lower=0,upper=0.5>[nRealExperimentFiles+1] epsilon; // +1 for unobserved participants
}

transformed parameters {
  vector[totalTrials] P;
  P = discounting(A, B, DA, DB, k[ID], epsilon[ID], alpha[ID]);
}

model {
  k_mu     ~ normal(0.01, 2.5);      // TODO: pick this in a more meaningul manner
  k_sigma  ~ inv_gamma(0.1,0.1);     // TODO: pick this in a more meaningul manner
  k        ~ normal(k_mu, k_sigma);

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
