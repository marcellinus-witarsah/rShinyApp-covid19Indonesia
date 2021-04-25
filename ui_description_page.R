bodyDesc <- dashboardBody(
  fluidRow(
    fluidRow(
      column(
        box(
          title = div("Description", style="padding-left: 20px", class="h1"),
          column(width=12, "Project by Marcellinus Aditya Witarsah, Kevin Subiyantoro, 
                 Kelvin Wyeth, Kevin Edward and Klemens", style="padding: 20px"),
          width = 12,
          height = 1000
        ),
        width = 12,
        style = "padding: 15px"
      )
    )
  )
)


pageDescription <- dashboardPage(
  title = "Description",
  header = dashboardHeader(disable = TRUE),
  sidebar = dashboardSidebar(disable = TRUE),
  body = bodyDesc
)