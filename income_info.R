#lets start from the basics
library(tidyverse)
soi.data <- read_csv("17incyallagi.csv")

#the upper bound on the last interval will not matter so we can set it to the placeholder value of 0
agi <- c(0.001,1, 10000,25000,50000,75000,100000,200000,0)

#N2 according to SIS IRS lady is the number of people who filed so gives income per person

soi.data$avg.agi <- (soi.data$A00100 / soi.data$N1) * 1000

mean.pareto.bounded <- function(lower, upper, val){
    v <- val
    return(((lower^v) / (1 - ((lower/upper)^v))) * (v / (v - 1)) * ((1 / (lower^(v-1))) - (1 / (upper^(v-1)))))
  
}

#linear narrowing down should work
estimate.alpha <- function(lower, upper, average){
    bounds <- c(0.00000001,50)
    
    limits <- c(mean.pareto.bounded(lower=lower,upper=upper, val=bounds[1]), mean.pareto.bounded(lower=lower,upper=upper,val=bounds[2]))
    
    if (sum(average < limits)!=1){
        return("can't be found using bounded estimate")
    }
    
    midpt <- mean(bounds)
    guess <- mean.pareto.bounded(lower=lower, upper=upper, val=midpt)
    
    loss <- abs(guess - average)
    while (loss > 100){
        if (guess >= average){
            bounds <- c(midpt, max(bounds))
            midpt <- mean(c(midpt, max(bounds)))
        } else{
            bounds <- c(midpt, min(bounds))
            midpt <- mean(c(midpt, min(bounds)))
        }
        
        guess <- mean.pareto.bounded(lower=lower,upper=upper, val=midpt)
        loss <- abs(guess - average)
    }
    
    return(midpt)
}

income.distr <- function(data){
    
    samples <- list()
    for (x in 1:8){
        sampling <- agi[x:(x+1)]
        
        idx <- data$N1[x]
        
        if (is.na(data$avg.agi[x])){
            y <- seq(sampling[1],sampling[2],length=7000)
            out <- sample(y, replace=TRUE, idx)
        } else{
        
        if (x %in% c(2,3,4,5,6,7)){
            lower <- sampling[1]
            upper <- sampling[2]
            
            alpha <- estimate.alpha(lower=lower,upper=upper, average=data$avg.agi[x])
            
            if (typeof(alpha)=="character"){
                alpha <- -data$avg.agi[x] / ((sampling[1])-data$avg.agi[x])
                out <- sampling[1]/((1 - runif(idx))^(1/alpha))
            } else{
                out <- ((lower^alpha) / (1 - (runif(idx)*(1 - ((lower/upper)^alpha)))))^(1/alpha)
            }
            
        } else if (x==8) {
            #regular pareto
            alpha <- -data$avg.agi[x] / ((sampling[1])-data$avg.agi[x])
            out <- sampling[1]/((1 - runif(idx))^(1/alpha))
        } else{
            out <- rep(0, idx)
        }
        }
        
        out <- sample(out, replace=FALSE,round(idx*0.5))
        samples[[x]] <- out
    }
    
    samples <- unlist(samples)
    lambda.exp <- 1 / mean(samples)
    
    return(lambda.exp)
}


tax.data <- soi.data
y <- tax.data %>% group_by(COUNTYNAME, STATE) %>% select(c(STATE, COUNTYNAME, N1, avg.agi)) %>% nest() %>% mutate(param=map(data,~income.distr(.))) %>% unnest(param)
y$data <- NULL


write.csv(y, "modeledData.csv")



# how to find quantile info for exponential distribution:
#quantile <- 1 - exp(-param*income)





