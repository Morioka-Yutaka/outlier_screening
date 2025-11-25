# outlier_screening
outlier_screening is a SAS macro toolkit for fast, review-friendly outlier detection.  
It flags extremes using SD (Z-score), MAD (robust Z), and IQR rules, adds ranks, and generates an annotated boxscatter plot for quick data screening.

<img width="360" height="360" alt="outlier_screening_small" src="https://github.com/user-attachments/assets/ae29dcca-4ada-4792-8659-50dd075f3a91" />

## `%outlier_sd()` macro <a name="outliersd-macro-4"></a> ######
Purpose:
  Detect outliers based on standard deviation (Z-score) using PROC STDIZE.  
  Observations are flagged when |Z| exceeds the specified criterion.  

### Parameters:  
~~~text
  data      = Input dataset name.
  var       = Analysis variable (single numeric variable).
  by        = (Optional) BY variable for group-wise detection.
              Note: BY supports ONE variable only.
  criteria  = Z-score threshold for outlier flagging.
              Default: 3
  out       = Output dataset name.
              Default: outlier_SD
~~~

### Output:  
~~~text
  The output dataset contains all original variables plus:
    std_<var>         : Standardized value (Z-score).
    std_<var>_abs     : Absolute Z-score.
    Criteria_SD       : Criterion used.
    outlier_SDFL      : Outlier flag ("Y"/"N").
  The original variable is preserved with its original name.
~~~

### Usage Example:   
~~~text
  %outlier_SD(data=adsl, var=age);
  %outlier_SD(data=advs, var=aval, by=paramcd, criteria=2.5, out=sd_out);
~~~

### Notes:  
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).
  - Missing values in &var are retained and flagged as "N".

  
---
