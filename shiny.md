
Why shiny apps tend to become unwieldy quickly:

>Input and output IDs in Shiny apps share a global namespace, meaning, each ID must be unique across the entire app. If you’re using functions to generate UI, and those functions generate inputs and outputs, then you need to ensure that none of the IDs collide. [1][1]

## Shiny modules

* piece of a Shiny app
* can’t be directly run
* included as part of a larger app (or as part of a larger Shiny module–they are composable)
* add namespacing to Shiny UI and server logic

Modules can represent input, output, or both.

* composed of two functions that represent 1) a piece of UI, and 2) a fragment of server logic that uses that UI

---------------
[1]: https://shiny.rstudio.com/articles/modules.html
