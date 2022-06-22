make_predictions = function (df, clf){
  
  df = as_tibble(df)  
  predictions = predict(clf, new_data = df, type = 'prob')[,1] 
  predictions = ifelse(predictions > 0.5, 'F', 'M')
  df$gender_prediction = predictions
  
  return(df)
  
}

labels = c('F', 'M')

label_pred = function(x) 
  labels[which.max(x)]