## Mine course project for Practical Machine Learning

Script placed in PracticalMachineLearningAssignment.Rmd file, plus related MarkDown & HTML files with same name.

## (obsolete) Mine course project for Getting & Cleaning Data

Script placed in rn_analysis.R file, and requires 'reshape2' package for it's work.

### Step-by-step explanation of the script:

1. Loading both test & train data sets into 6 separate data frames.
1. Merging test data sets with train ones - so we now how 3 data frames with same rownum: measures, subjects & activity IDs.
1. Cleaning measure dataset, leaving only mean/stddev features in it.
1. Loading description of activites, joining it with activity dataframe.
1. Cleaning activity dataframe from IDs, leaving only textual activity labels.
1. Merging our 3 data frames into a single one, called "merged data frame".
1. Setting human-readable names to first two cols if "merged" df (subject & activity, according to merge procedure above).
1. Aggregating values of "merged" data frame per subject/activity col using melt/dcast methods from reshape2 package.
1. Writing result dataframe into "analysis_result.txt" file into the current working dir.
