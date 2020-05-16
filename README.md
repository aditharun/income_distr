
## Modeling The Income of Counties and States Using Tax Data 
Input an income and see where you rank compared to others in any state and county. 
To See The Results: https://aditharun.shinyapps.io/income_ranker/


### Question
What is the minimal amount of information and simplest model from which we can estimate the top 1% income of each state in the US?

### How is it done? 
Tax data is collected for each county. For a given county, 8 Adjusted Gross Income Levels and the number of households that fall in that window are reported. An average income for each window is collected by dividing the total reported income for that window by the number of filings. Fit a bounded pareto distribution with mean equal to average income for that level when possible, otherwise fit an unbounded pareto distribution. Take samples from this distribution according to the number of households that filed in that income window. If all else fails, draw random samples from the income window uniformly. 

Now that we have constructed a distribution of incomes, we want to condense down that information into a simpler form. After investigating the data, an exponential distribution best resembled the data (Gamma distribution, log normal, was also considered but deemed not as good by AIC and looking at the fits). The parameter, lambda, was estimated using the MLE of the exponential. A lambda was found for each county and state in the US. 

See [here](income_info.R) for the code. 

#### Inspiration: https://www.businessinsider.com/personal-finance/income-family-top-1-percent-every-state-2019-4

#### Benchmarking Against 2015 Data
The estimates we generate for the minimum income necessary to be considered top 1% is compared against this [study by the Economic Policy Institute (EPI)] (https://www.epi.org/publication/the-new-gilded-age-income-inequality-in-the-u-s-by-state-metropolitan-area-and-county/#epi-toc-5). 

The folder [income_benchmark](income_benchmark) contains visualizations of how the estimates compare to the EPI study results. The estimates generated here are useful and relatively accurate. They are able to order the states by income with a 0.87 correlation to EPI ordering. 

#### R Shiny App Code
Interactive tool for playing with income in different counties are presented [here] (https://aditharun.shinyapps.io/income_ranker/). Code for the app is in [income_ranker](income_ranker)

#### Raw data 
Raw Data at the County Level is in the raw data folder. Taken from [SOI Tax Stats](https://www.irs.gov/statistics/soi-tax-stats-county-data). Data presented in the user interface is from 2017. Data used for benchmarking, for valid comparison against EPI results, was from 2015. 
