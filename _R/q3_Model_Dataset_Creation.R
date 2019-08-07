## Model dataset creation


# Model idea
''' group by party id
label customers as repeat or not repeat
group by party id and take the min of the order date - representing their first order
train a model on this, using the repeat labels as a target'''

library(lubridate)

df <- read.csv('Data/qvc_data_compiled_new_variables_sample.csv')

df$Order_Dt <- as.Date(df$Order_Dt)


first_orders <- df %>%
  group_by(Party_Id) %>%
  slice(which.min(Order_Dt))


first_orders %>%
  write.csv('model_dataset_no_labels.csv')

first_orders %>%
  n_distinct(first_orders$Party_Id)
         

# Read in target labels

targets <- read.csv('Data/qvc_customer_repeat_sample.csv')


model_df <- first_orders %>%
  inner_join(targets)

model_df %>%
  write.csv('model_dataset_with_labels.csv')


