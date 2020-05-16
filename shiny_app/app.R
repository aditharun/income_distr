library(shiny)
library(tidyverse)

path <- "../modeledData.csv"
data <- read_csv(path)

# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("Where does your income rank?"),
   
   sidebarLayout(
      sidebarPanel(
        selectInput("state", "State", choices = unique(data$STATE)),
        selectInput("county", "County", choices = NULL),
        sliderInput("incomeslide","Income",min=0,max=10000000,value=60000,step=20000),
        numericInput("incomenumber","Income",value=60000,step=1000)   ),
      #,     width="auto" <-- if we want inputs to take up full width of screen
      mainPanel(
        textOutput("selected_var"),
         plotOutput("distPlot")
      )
   )
)

server <- function(input, output,session) {
  observeEvent(input$incomenumber, {
    updateSliderInput(session, "incomeslide", value = input$incomenumber)
  })  
  observeEvent(input$incomeslide, {
    updateNumericInput(session, "incomenumber", value = input$incomeslide)
  })  
  
  state <- reactive({
    filter(data, STATE==input$state)
  })
  observeEvent(state(), {
    choices <- unique(state()$COUNTYNAME)
    updateSelectInput(session, "county", choices = choices) 
  })
  

  
   output$distPlot <- renderPlot({
       tib <- data %>% filter(STATE==input$state, COUNTYNAME==input$county)
       param <- tib$param
     #TO DO
      #why are these estimates so bad all of a sudden??
     #show quantile information 
     #show where on histogram the income is
     
     #show some overall state summaries that are static below the interactive stuff
     
 
      
      fin.exp <- data.frame(vals = rexp(1e6,rate=param))
      ggplot(fin.exp,aes(vals)) + geom_histogram(color="grey",binwidth=5000) + theme(
        panel.background = element_rect(fill = "transparent"), 
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        legend.background = element_rect(fill = "transparent"),
        legend.box.background = element_rect(fill = "transparent")) +xlab("Income")+ylab("Frequency")
      
      
   })
   
   output$selected_var <- renderText({
       tib <- data %>% filter(STATE==input$state, COUNTYNAME==input$county)
       param <- tib$param
       top.percent <- round((exp(-param*input$incomenumber) * 100), 2)
       paste0("You are in the top ", top.percent, "% of people")
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

