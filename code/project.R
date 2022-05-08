library(readr)   # Load the readr library to more easily load my data.
library(lubridate)
library(dplyr)
library(tidyr)   # For drop_na()
library(ggplot2)   # For plotting

# Import data and view data
vehicles <- read_csv("data/vehicles.csv")
View(vehicles)

### FIGURE OUT THE DATES ####

# Create a column for posting date without the time.
vehicles$posting_date_no_time = substr(vehicles$posting_date,1,10)
View(vehicles)

# Drop na rows for that column.
vehicles <- drop_na(vehicles, posting_date_no_time)

# Check the data type of each column.
str(vehicles)

# Check what's the minimum and maximum of the posting dates.
vehicles %>%
  mutate(posting_date_no_time = ymd(posting_date_no_time)) %>%
  summarise(min = min(posting_date_no_time),
            max = max(posting_date_no_time))   # The data covers around one month.

###  WHAT'S THE MOST POPULAR USED CAR SOLD IN IDAHO? #####

# Create a new df for Idaho.
vehicles_id <- vehicles[vehicles$state=="id",]

# Amount of unique manufacturers.
length(unique(vehicles_id$manufacturer))

# Amount of unique models.
length(unique(vehicles_id$model))

table(vehicles_id["manufacturer"])

unique_manufacturers <- table(vehicles_id['manufacturer'])
unique_models <- table(vehicles_id['model'])

# Create a sorted table for manufacturers.
manufacturers_sort <- unique_manufacturers %>%
  as.data.frame() %>%
  arrange(desc(Freq))

# Create a sorted table for models.
models_sort <- unique_models %>%
  as.data.frame() %>%
  arrange(desc(Freq))

# Select the top 10 manufacturers and models.
top_manufacturers <- head(manufacturers_sort, 10)
top_manufacturers

top_models <- head(models_sort, 10)
top_models

# Graph the top manufacturers
top_man_graph = ggplot(data=top_manufacturers, aes(x=manufacturer, y=Freq)) +
  geom_bar(stat="identity", fill="steelblue")

top_man_graph = top_man_graph + labs(title="Top Used Cars Sold In Idaho",
                                     x = "Manufacturer", y = "Posts on Craiglist")

ggsave("output/top_man_graph.png", plot = top_man_graph)


# Graph the top models
top_mod_graph = ggplot(data=top_models, aes(x=reorder(model, -Freq), y=Freq)) +
  geom_bar(stat="identity", fill="steelblue")

top_mod_graph = top_mod_graph + labs(title="Top Used Cars Sold In Idaho",
                                     x = "Model", y = "Posts on Craiglists")


### WHAT WAS THE CHEAPEST CAR BEING SOLD IN EASTERN IDAHO? ####

# Check all the unique values for the region column
unique(vehicles_id$region)

# Create a dataframe for only Eastern Idaho
vehicles_eastern <- vehicles_id[vehicles_id$region=="east idaho",]
View(vehicles_eastern)

# Create a sorted vehicles_eastern by price
vehicles_eastern_sorted <- vehicles_eastern %>%
  arrange(price)
View(vehicles_eastern_sorted)

# Drop very low prices
vehicles_eastern_sorted <- vehicles_eastern_sorted[!(vehicles_eastern_sorted$price==0 | vehicles_eastern_sorted$price==1),]
View(vehicles_eastern_sorted)

# Only the 10 cheapest
cheapest_sold_eastern <- head(vehicles_eastern_sorted, 10)
View(cheapest_sold_eastern)

# Graph the 10 cheapest
top_cheap_graph = ggplot(data=cheapest_sold_eastern, aes(x=reorder(model, price), y=price)) +
  geom_bar(stat="identity", fill="steelblue")

top_cheap_graph = top_cheap_graph + labs(title="Top Cheap Used Cars Sold In Eastern Idaho",
                                         x="Model", y="Listed Price")

ggsave("output/top_cheap_graph.png", plot = top_cheap_graph)

