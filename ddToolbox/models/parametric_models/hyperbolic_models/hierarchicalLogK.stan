functions {
  real psychometric_function(real alpha, real epsilon, real VA, real VB){
    // returns probability of choosing B (delayed reward)
    return epsilon + (1-2*epsilon) * Phi( (VB-VA) / alpha);
  }

  vector df_hyperbolic1(vector reward, vector logk, vector delay){
    return reward ./ (1+(exp(logk).*delay));
  }
  
  vector discounting(vector A, vector B, vector DA, vector DB, vector logk, vector epsilon, vector alpha){
    vector[rows(A)] VA;
    vector[rows(B)] VB;
    vector[rows(A)] P;
    // calculate present subjective values
    VA = df_hyperbolic1(A, logk, DA);
    VB = df_hyperbolic1(B, logk, DB);
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
  real logk_mu;
  real<lower=0> logk_sigma;
  vector[nRealExperimentFiles+1] logk; // +1 for unobserved participant

  real <lower=0> alphaMode;
  real <lower=0> alphaSD;
  vector<lower=0>[nRealExperimentFiles+1] alpha; // +1 for unobserved participant

  real <lower=0,upper=1> epsilonMode;
  real <lower=0> epsilonConcentration;
  vector<lower=0,upper=0.5>[nRealExperimentFiles+1] epsilon; // +1 for unobserved participants
}

transformed parameters {
  vector[totalTrials] P;
  real <lower=0>alphaRate;
  real <lower=0>alphaShape;
  real <lower=0>epsilonAlpha;
  real <lower=0>epsilonBeta;
  
  P = discounting(A, B, DA, DB, logk[ID], epsilon[ID], alpha[ID]);
  
  // reparameterisation for alpha
  alphaRate = (alphaMode + sqrt(alphaMode^2 + 4*alphaSD^2) ) / (2*alphaSD^2);
  alphaShape = 1 + alphaMode * alphaRate;
  
  // reparameterisation for epsilon
  epsilonAlpha = epsilonMode*(epsilonConcentration-2)+1;
  epsilonBeta =(1-epsilonMode)*(epsilonConcentration-2)+1;
}

model {
  // Response error parameters -------------------------------------------------
  // alpha
  alpha       ~ gamma(alphaShape, alphaRate);
  // alpha: hyperpriors
  alphaMode   ~ exponential(0.1);
  alphaSD     ~ cauchy(0,2.5);
  
  // epsilon
  epsilon               ~ beta(epsilonAlpha , epsilonBeta );
  // epsilon: hyperpriors
  epsilonMode           ~ beta(1.1, 10.9);
  epsilonConcentration  ~ exponential(1);
  
  
  // Discounting parameters ----------------------------------------------------
  // logk
  logk        ~ normal(logk_mu, logk_sigma);
  // logk (hyperpriors)
  logk_mu     ~ normal(-3.9120,2.5);
  logk_sigma  ~ cauchy(0,2.5);
  
  // Likelihood function -------------------------------------------------------
  R ~ bernoulli(P);
}

generated quantities {  // NO VECTORIZATION IN THIS BLOCK
  int <lower=0,upper=1> Rpostpred[totalTrials];
  for (t in 1:totalTrials){
    Rpostpred[t] = bernoulli_rng(P[t]);
  }
}
