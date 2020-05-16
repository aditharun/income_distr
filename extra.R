#failed work with gamma distr to model income 

junk <- '
----------------------unstructured code--------
#maximum likelihood estimate of gamma
gamma.mle <- function(params,input){
  r <- params[1]
  lambda <- params[2]
  lsum <- sum(log(input))
  ssum <- sum(input)
  n <- length(input)
  log.lik <- (r*n*log(lambda)) - (n*log(gamma(r))) + ((r-1)*(lsum)) - (lambda*ssum)
  log.lik <- (-1) *log.lik
  log.lik
}

#where does a specific salary stand in the income distribution?

unscaled.income <- 150000
income <- unscaled.income / 1000

#how do we account for the fact that the income may be so high that
#the person is in the 0th percentile income!
#easiest answer: add some noise; harder answer: figure out why sat can never have 100th percentile scorers!

find.gamma.quantile <- function(x, param){
  
  shape <- param[1]
  scale <- 1/param[2]
  
  bounds <- c(0,1)
  quantile <- mean(bounds)
  guess <- qgamma(quantile, shape=shape, scale=scale)
  loss <- abs(guess - x)
  while (loss > 0.005){
    
    if (guess <=  x ){
      bounds <- c(quantile, max(bounds))
      quantile <- mean(c(quantile, max(bounds)))
    } else{
      bounds <- c(quantile, min(bounds))
      quantile <- mean(c(quantile, min(bounds)))
    }
    
    guess <- qgamma(quantile, shape=shape, scale=scale)
    loss <- abs(guess - x)
    
  }
  
  return(quantile)
  
}

if (model=="exp"){
  quantile <- 1 - exp(-parameters*income)
} else{
  quantile <- find.gamma.quantile(income, parameters)
}

top.percent <- (1 - quantile) * 100





#for each 8 rows, we want to find the parameters and model that sum it up


#ranges for adjusted gross income

income.distr <- function(data){
  
  #doesnt change density even if change length beyond a certain level or idx scale factor
  
  
  #MOM estimates for r and lambda as initial points for estimating mle of gamma and exp
  init.r <- (mean(samples)^2) / var(samples)
  init.lambda.gamma <- mean(samples) / var(samples)
  #note that mom and mle of exp is the same!
  init.lambda.exp <- 1 / mean(samples)
  
  gamma.estimate <- nlm(gamma.mle,c(init.r,init.lambda.gamma),input=samples )
  
  #which model
  n <- length(samples)
  AIC.exp <- (2 *1) - (2*((n*log(init.lambda.exp)) - ((init.lambda.exp)*sum(samples))))
  AIC.gamma <- ( 2 * 2) - (-2*gamma.mle(c(gamma.estimate$estimate[1],gamma.estimate$estimate[2]),samples))
  
  if (AIC.exp <= AIC.gamma){
    model <- "exp"
    parameters <- init.lambda.exp
  } else{
    model <- "gamma"
    parameters <- gamma.estimate$estimate
  }
  
  return(paste(model,paste0(parameters,collapse=";"),sep=","))
  
}

y <- soi.data[1:40,] %>% group_by(COUNTYNAME, STATE) %>% select(c(STATE, COUNTYNAME, N1)) %>% nest() %>% mutate(combine=map(data,~income.distr(.))) %>% unnest(combine)
t <- unlist(str_split(y$combine, ","))
y$model <- t[c(TRUE, FALSE)]
y$parameters <- t[c(FALSE, TRUE)]
y <- y[,c(1,2,5,6)]
'
