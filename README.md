
Repository for R-ladies meetup 19.11.2019.

# Overview

During this workshop you will learn how to create interactive dashboards with Shiny. Dashboards are great to communicate and present your analysis and results.

We will go through following subjects:

- Overview and structure of a Shiny Dashboard
- Adding dynamic content for your dashboard
- Customize your dashboard with skin

Prerequisites if you want to code by yourself:

- R and RStudio installed on your machine
- Packages shiny, shinydashboard, ggplot, scales and tidyverse installed



# Create your own Dashboard

We are going to create our very own dasboard using`recent-grads.csv` from `TidyTuesday` github repo.

![Final dashboard](https://github.com/fieevrasi/r-ladies-shiny/blob/master/pictures/final_dashboard.PNG)

## Step 1

Create an empty R-file called `my_dashboard.R`.
Add following code block to your R-file. Install needed packages with command `install.packages("shiny")` if needed.
Click `Run App` icon to verify that everything works.

```{r, eval=FALSE}

library(shiny)
library(shinydashboard)
library(tidyverse)
library(scales)

# Header
header <- dashboardHeader(title = "My Dashboard")

# Sidebar
sidebar <- dashboardSidebar()

# Body
body <- dashboardBody()

# Create the UI 
ui <- dashboardPage(header, sidebar, body)

server <- function(input, output) {
}

shinyApp(ui, server)

```
![Step 1: Dashboard](https://github.com/fieevrasi/r-ladies-shiny/blob/master/pictures/step1_dashboard.PNG)


## Step 2

Add some content to your dashboards by adding a `fluidRow()` with `valueBox()`inside the `dashboardBody()` element.

```{r, eval=FALSE}

# Body
body <- dashboardBody(
  
  fluidRow(
    # A static valueBox
    valueBox(Sys.Date(), 
             icon = icon("star"), 
             subtitle = "Date", 
             color = "yellow",
             width = 3),
  )
  
)

```

You can also try different color themes by adding a `skin` attribute inside the `dashboardPage()`.
Valid skin values are _blue, black, purple, green, red and yellow_.
Icons are drawn from the https://fontawesome.com/icons?from=io.

```{r, eval=FALSE}

# Create the UI 
ui <- dashboardPage(skin='purple', header, sidebar, body)

```

![Step 2: Dashboard](https://github.com/fieevrasi/r-ladies-shiny/blob/master/pictures/step2_dashboard.PNG)

## Step 3

Next we will add some dynamic content to our dashboard. Add following function at the beginning of your R file. Right after the library-commands.
This function will read `recent-grads.csv` from `TidyTuesday` github repo.

```{r, eval=FALSE}

# Reads the college graduation data
read_data <- function(){ 
  
  college_grads <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2018/2018-10-16/recent-grads.csv")
  return(college_grads)
}

```

Add `selectInput` inside the `dashboardSidebar()` function.

```{r, eval=FALSE}
# Sidebar
sidebar <- dashboardSidebar(
  selectInput(
    inputId = "category",
    label = "Major category:",
    choices = unique(read_data() %>% select("Major_category")),
    selectize = FALSE
  )
)
```

Add following lines inside the `server()` function.

```{r, eval=FALSE}

server <- function(input, output) {
  
    df_grads <- reactive({
    res <- read_data() %>%
      filter(Major_category == input$category)
    res
  })
}

```
![Step 3: Dashboard](https://github.com/fieevrasi/r-ladies-shiny/blob/master/pictures/step3_dashboard.PNG)

## Step 4

Add three dynamic `valueBoxOutput` components inside the `dashboardBody()` function.

```{r, eval=FALSE}

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
  )
)

```

Copy following lines of code to the `server()` function.

```{r, eval=FALSE}

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
}
```

![Step 4: Dashboard](https://github.com/fieevrasi/r-ladies-shiny/blob/master/pictures/step4_dashboard.PNG)

## Step 5

Next we add a new row with two tables. Copy following lines inside the `dashboardBody()` function.

```{r, eval=FALSE}

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
  )
)

```

Copy following lines of code to the `server()` function.

```{r, eval=FALSE}

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
  
```

![Step 5: Dashboard](https://github.com/fieevrasi/r-ladies-shiny/blob/master/pictures/step5_dashboard.PNG)

## Step 6

Final step is to add a plot to our dashboard. Copy following lines inside the `dashboardBody()` function.

```{r, eval=FALSE}

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
```

Add following lines of code inside the `server()` function.

```{r, eval=FALSE}

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
  
```
![Step 6: Dashboard](https://github.com/fieevrasi/r-ladies-shiny/blob/master/pictures/final_dashboard.PNG)
