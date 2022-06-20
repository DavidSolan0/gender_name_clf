library(ROCR)
library(themis)
library(readxl)
library(discrim)
library(tidytext)
library(textdata)
library(tidyverse)
library(tidymodels)
library(naivebayes)
library(textrecipes)

setwd('C:/Users/David.Solano/OneDrive - Ipsos/David/machine_learning/NameGenderClassification/ML-001-Name-Text-Gender-Predictor-Classifier/data_set')
theme_set(theme_minimal())

# Get data
f_cp = read.csv('global_female_names_parsed.txt', header = F) 
colnames(f_cp) = c('name','gender','id') 
f_cp = f_cp %>%
  mutate(gender = 'F')

m_cp = read.csv('global_male_names_parsed.txt', header = F) 
colnames(m_cp) = c('name','gender','id')

cp = rbind(f_cp, m_cp) %>% as_tibble() %>%
  dplyr::select(-id) %>%
  mutate(gender = as.factor(gender)) 

summary(cp)

# Split

cp_split <- initial_split(data = cp, strata = gender, prop = .8)
cp_train <- training(cp_split)
cp_test <- testing(cp_split)

# Recipe creation

cp_rec <- recipe(gender ~ ., data = cp_train)

cp_rec <- cp_rec %>%
  step_text_normalization(name) %>%
  step_tokenize(name) %>%
  step_word_embeddings(name, 
                       embeddings = embedding_glove27b(dimensions = 50))

# Fold creation 

cp_folds <- vfold_cv(data = cp_train, v = 3, strata = gender)

# Naive Bayes workflow 

args(naive_Bayes)
nb_spec <- naive_Bayes(smoothness=tune()) %>%
  set_mode("classification") %>%
  set_engine("naivebayes")

nb_wf <- workflow() %>%
  add_recipe(cp_rec) %>%
  add_model(nb_spec)

# Hyperparametres Tunning 
nb_grid <- tibble(smoothness = 10^seq(-4, -1, length.out = 30))

nb_tun <- 
  nb_wf %>% 
  tune_grid(resamples = cp_folds,
            grid = nb_grid,
            control = control_grid(save_pred = TRUE))

nb_tun_metrics <- collect_metrics(nb_tun)
nb_tun_predictions <- collect_predictions(nb_tun)

nb_tun_metrics

# Select the best 

best_nb <- nb_tun %>%
  select_best("roc_auc")

# NB Final 

final_nb_wf <- nb_wf %>% 
  finalize_workflow(best_nb)

final_nb <- final_nb_wf %>% 
  fit(data = cp_train)

# Final fit 

final_nb_fit <- 
  final_nb_wf %>%
  last_fit(cp_split) 

final_nb_fit %>%
  collect_metrics()

final_nb_fit %>%
  collect_predictions() %>% 
  roc_curve(gender, .pred_F) %>% 
  autoplot()

# Support vector machine workflow

args(svm_rbf)
svm_spec <- svm_rbf(cost=tune()) %>%
  set_mode("classification") %>%
  set_engine("kernlab")

svm_wf <- workflow() %>%
  add_recipe(cp_rec) %>%
  add_model(svm_spec)

# Hyperparameter tunning 

svm_grid = tibble(cost = 10^seq(-4, -1, length.out = 30))

svm_tun <- svm_wf %>%
  tune_grid(resamples = cp_folds,
            grid = svm_grid,
            control = control_grid(save_pred = TRUE))

svm_tun_metrics <- collect_metrics(svm_tun)
svm_tun_predictions <- collect_predictions(svm_tun)

svm_tun_metrics

# Select the best 

best_svm <- svm_tun  %>%
  select_best("roc_auc")

final_svm_wf <- 
  svm_wf %>% 
  finalize_workflow(best_svm)

final_svm <- final_svm_wf %>% 
  fit(data = cp_train) 

# Final fit 

final_svm_fit <- 
  final_svm_wf %>%
  last_fit(cp_split) 

final_svm_fit %>%
  collect_metrics()

final_svm_fit %>%
  collect_predictions() %>% 
  roc_curve(gender, .pred_F) %>% 
  autoplot()

# Random Forest workflow
args(rand_forest)
rf_spec <- rand_forest( trees =tune()) %>%
  set_mode("classification") %>%
  set_engine("ranger") %>%
  translate()

rf_wf <- workflow() %>%
  add_recipe(cp_rec) %>%
  add_model(rf_spec)

# hyperparaeter tunning

rf_grid <- grid_regular(trees(),levels = 15)

rf_tun <- rf_wf %>%
  tune_grid(resamples = cp_folds,
            grid = rf_grid,
            control = control_grid(save_pred = TRUE))

rf_tun_metrics <- collect_metrics(rf_tun)
rf_tun_predictions <- collect_predictions(rf_tun)

rf_tun_metrics

# Select the best 

best_rf <- rf_tun  %>%
  select_best("roc_auc")

final_rf_wf <- 
  rf_wf %>% 
  finalize_workflow(best_rf)

final_rf <- final_rf_wf %>%
  fit(data = cp_train) 

# Final fit 

final_rf_fit <- 
  final_rf_wf %>%
  last_fit(cp_split) 

final_rf_fit %>%
  collect_metrics()

final_rf_fit %>%
  collect_predictions() %>% 
  roc_curve(gender, .pred_F) %>% 
  autoplot()

# XGB workflow 

xgb_spec <- boost_tree(
  trees = 1000, 
  tree_depth = tune(), min_n = tune(), 
  loss_reduction = tune(),                     ## first three: model complexity
  sample_size = tune(), mtry = tune(),         ## randomness
  learn_rate = tune(),                         ## step size
) %>% 
  set_engine("xgboost") %>% 
  set_mode("classification")

xgb_wf <- workflow() %>%
  add_recipe(cp_rec) %>%
  add_model(xgb_spec)

# hyperparaeter tunning

xgb_grid <- grid_latin_hypercube(
  tree_depth(),
  min_n(),
  loss_reduction(),
  sample_size = sample_prop(),
  finalize(mtry(), cp_train),
  learn_rate(),
  size = 30)

xgb_tun <- xgb_wf %>%
  tune_grid(resamples = cp_folds,
            grid = xgb_grid,
            control = control_grid(save_pred = TRUE))

xgb_tun_metrics <- collect_metrics(xgb_tun)
xgb_tun_predictions <- collect_predictions(xgb_tun)

xgb_tun_metrics

# Select the best 

best_xgb <- xgb_tun  %>%
  select_best("roc_auc")

final_xgb_wf <- 
  xgb_wf %>% 
  finalize_workflow(best_xgb)

final_xgb <- final_xgb_wf %>%
  fit(data = cp_train) 

# Final fit 

final_xgb_fit <- 
  final_xgb_wf %>%
  last_fit(cp_split) 

final_xgb_fit %>%
  collect_metrics()

final_xgb_fit %>%
  collect_predictions() %>% 
  roc_curve(gender, .pred_F) %>% 
  autoplot()

# Baseline model comparation
null_classification <- null_model() %>%
  set_engine("parsnip") %>%
  set_mode("classification")

null_cv <- workflow() %>%
  add_recipe(cp_rec) %>%
  add_model(null_classification) %>%
  fit_resamples(
    cp_folds
  )

null_cv %>%
  collect_metrics()

ggplot(data = cp, mapping = aes(x = fct_infreq(seg) %>% fct_rev())) +
  geom_bar() +
  coord_flip() +
  labs(
    title = "Distribution of legislation",
    subtitle = "By major policy topic",
    x = NULL,
    y = "Number of bills"
  )

### Final model Threshoold estimation

predictTest = predict(final_svm, type = "prob", new_data = cp_test)
predictionsROCR = prediction(predictTest[,2], cp_test$gender)
ROCRPerf = performance(predictionsROCR, "tpr", "fpr")
plot(ROCRPerf, colorize = TRUE, print.cutoffs.at=seq(0,1,0.1),text.adj=c(-0.2,1.7))

auc = as.numeric(performance(predictionsROCR,"auc")@y.values)
auc

### Save the model

predict(final_svm, new_data = cp_test)
saveRDS(final_svm, 'gender_name_clf.rds')

