functions {
  vector matrix_pow_elementwise(vector delay, vector tau){
    // can't (currently) do elementwise matrix power operation, so manually loop
    vector[rows(delay)] output;
    for (i in 1:num_elements(delay)){
      output[i] = pow(delay[i], tau[i]);
    }
    return output;
  }
  
  real psychometric_function(real alpha, real epsilon, real VA, real VB){
    // returns probability of choosing B (delayed reward)
    return epsilon + (1-2*epsilon) * Phi( (VB-VA) / alpha);
  }

  vector df_exp_power(vector reward, vector k, vector tau, vector delay){
    //return reward .*( exp( -k .* (delay ^ tau) ) );
    vector[rows(delay)] delay_to_power_tau;
    delay_to_power_tau = matrix_pow_elementwise(delay,tau);
    return reward .*( exp( -k .* delay_to_power_tau ) );
  }
  
  vector discounting(vector A, vector B, vector DA, vector DB, vector k, vector tau, vector epsilon, vector alpha){
    vector[rows(A)] VA;
    vector[rows(B)] VB;
    vector[rows(A)] P;
    // calculate present subjective values
    VA = df_exp_power(A, k, tau, DA);
    VB = df_exp_power(B, k, tau, DB);
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
  
  real tau_mu;
  real<lower=0> tau_sigma;
  vector<lower=0>[nRealExperimentFiles+1] tau; // +1 for unobserved participant
  
  real alpha_mu;
  real <lower=0> alpha_sigma;
  vector<lower=0>[nRealExperimentFiles+1] alpha; // +1 for unobserved participant

  real <lower=0,upper=1> omega;
  real <lower=0> kappa;
  vector<lower=0,upper=0.5>[nRealExperimentFiles+1] epsilon; // +1 for unobserved participants
}

transformed parameters {
  vector[totalTrials] P;
  P = discounting(A, B, DA, DB, k[ID], tau[ID], epsilon[ID], alpha[ID]);
}

model {
  k_mu ~ normal(0.01, 2.5); // TODO      : pick this in a more meaningul manner
  k_sigma ~ exponential(0.1);
  k ~ normal(k_mu, k_sigma);
  
  tau_mu ~ normal(0.01, 2.5); // TODO    : pick this in a more meaningul manner
  tau_sigma ~ inv_gamma(0.1,0.1); // TODO: pick this in a more meaningul manner
  tau ~ normal(tau_mu, tau_sigma);
  
  alpha_mu ~ uniform(0,100);
  alpha_sigma ~ exponential(0.1);
  alpha ~ normal(alpha_mu, alpha_sigma);
  
  omega ~ beta(1.1, 10.9); // mode for lapse rate
  kappa ~ gamma(0.1,0.1); // concentration parameter
  epsilon ~ beta(omega*(kappa-2)+1 , (1-omega)*(kappa-2)+1 );
  
  R ~ bernoulli(P);
}

generated quantities {  // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];
  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
