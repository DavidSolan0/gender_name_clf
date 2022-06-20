# Goal
This repo contains raw data and codes to construct a gender classifier based on the first name. Also, the link, files, and codes of a shiny app where you could use the model for inference purposes. 

# Folders
## clf

In [clf]() folder, you will find the data used to train and test the model and the R code with four classifications with their hyperparameter tunning using cv with three folds. 

The preprocessing only includes lowercase and remove punctuation from text. I used glove embeddings from the [textdata](https://cran.r-project.org/web/packages/textdata/textdata.pdf) package. Based on metrics, I picked a SVM as the best classifier. The **AUC** from my model is equal to 0.84 with an **accuracy** of 0.8. Below you could take a look to the ROC CURVE.

![image](https://user-images.githubusercontent.com/80591909/174524685-4da305ab-c372-4629-8a12-86f9200a607a.png)

It is worth mentioning that the XGB classifier has similar metrics **AUC** equal to 0.838 to and **accuracy** of 0.793, followed by Random Forest with **AUC** equal to 0.793 and an **accuracy** of 0.762. Finally, it is a naivebayes classifier with **AUC** equal to 0.733 and **accuracy** of 0.561. 

## shiny_app 

This folder includes the UI and server codes to deploy a [shinyApp](https://david-solan0.shinyapps.io/shiny_app/?_ga=2.44617639.288317254.1655696939-1777886789.1650917161) with the model. Keep in mind you have to save the model as a .rds file and save it in this folder for work on your machine.  

# Discussion

Future work could include trying different length embeddings, and other classifiers. 

# DATA WAS TAKEN FROM [HERE](https://github.com/vijayanandrp/ML-001-Name-Text-Gender-Predictor-Classifier)
