library(shiny)
library(shinydashboard)
library(tidyverse)
library(scales)


# Reads the college graduation data
read_data <- function(){ 
  
  college_grads <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2018/2018-10-16/recent-grads.csv")
  return(college_grads)
}

# Header
header <- dashboardHeader(title = "My Dashboard")

# Sidebar
sidebar <- dashboardSidebar(
  selectInput(
    inputId = "category",
    label = "Major category:",
    choices = unique(read_data() %>% select("Major_category")),
    selectize = FALSE
  )
)

# Body
body <- dashboardBody(
  
  # Row 1
  fluidRow(
    
    # A static valueBox
    valueBox(Sys.Date(), 
             icon = icon("star"), 
             subtitle = "Date", 
             color = "yellow",
             width = 3),
    
    # Dynamic valueBoxes
    valueBoxOutput("nrow", width = 3),
    valueBoxOutput("min",  width = 3),
    valueBoxOutput("max",  width = 3)
  ),
  
  # Row 2
  fluidRow(
    box(
      width = 6, status = "info", solidHeader = TRUE,
      title = "TOP 5 LOWEST SALARIES",
      tableOutput("lowTable")
    ),
    box(
      width = 6, status = "info", solidHeader = TRUE,
      title = "TOP 5 HIGHEST SALARIES",
      tableOutput("highTable")
    )
  ),
  
  # Row 3
  fluidRow(
    box(plotOutput("gradPlot"), width = 10)
  )
)


server <- function(input, output) {
  
  df_grads <- reactive({
    res <- read_data() %>%
      filter(Major_category == input$category)
    res
  })
  
  # No. of rows
  output$nrow <- renderValueBox({

    valueBox(
      value = nrow(df_grads()),
      icon = icon("table"),
      subtitle = "No. of rows",
      color = "green"
    )
    
  })
  
  # Min salary
  output$min <- renderValueBox({
    
    valueBox(
      value = min(df_grads()$Median)%>% 
                  scales::dollar(),
      icon = icon("comment-dollar"),
      subtitle = "Minimum median salary",
      color = "red"
    )
    
  })
  
  # Max salary
  output$max <- renderValueBox({
    
    valueBox(
      value = max(df_grads()$Median) %>% 
              scales::dollar(),
      icon = icon("comment-dollar"),
      subtitle = "Maximum median salary",
      color = "blue"
    )
    
  })
  
  # Lowest salaries table
  output$lowTable <- renderTable({
    df_grads() %>%
      arrange(Median) %>%
      select(Major, Median, Unemployment_rate, ShareWomen) %>%
      as.data.frame() %>%
      head(5)
  })
  
  # Highest salaries table
  output$highTable <- renderTable({
    df_grads() %>%
      arrange(desc(Median)) %>%
      select(Major, Median, Unemployment_rate, ShareWomen) %>%
      as.data.frame() %>%
      head(5)
  })
  
  # Salaries plot
  output$gradPlot <- renderPlot({
    
    g <- df_grads() %>%
         tail(15) %>%
         ggplot(aes(Major, Median, color = Major)) +
         geom_point(size=3) +
         geom_errorbar(aes(ymin = P25th, ymax = P75th), size=1) +
         expand_limits(y = 0) +
         coord_flip()
    
    g
    
  })
  
  
}


# Create the UI 
ui <- dashboardPage(skin='purple', header, sidebar, body)



shinyApp(ui, server)

