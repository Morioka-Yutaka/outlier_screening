# outlier_screening
outlier_screening is a SAS macro toolkit for fast, review-friendly outlier detection.  
It flags extremes using SD (Z-score), MAD (robust Z), and IQR rules, adds ranks, and generates an annotated boxscatter plot for quick data screening.

<img width="360" height="360" alt="outlier_screening_small" src="https://github.com/user-attachments/assets/ae29dcca-4ada-4792-8659-50dd075f3a91" />

## `%outlier_sd()` macro <a name="outliersd-macro-4"></a> ######
### Purpose:
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
~~~sas
  %outlier_SD(data=adsl, var=age);
  %outlier_SD(data=advs, var=aval, by=paramcd, criteria=2.5, out=sd_out);
~~~

### Notes:  
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).
  - Missing values in &var are retained and flagged as "N".

---

## `%outlier_mad()` macro <a name="outliermad-macro-3"></a> ######
### Purpose:  
  Detect outliers using Median Absolute Deviation (MAD)-based robust Z-scores  
  via PROC STDIZE METHOD=MAD. Observations are flagged when the robust  
  |Z*| exceeds the specified criterion.  

### Parameters:
~~~text
  data      = Input dataset name.
  var       = Analysis variable (single numeric variable).
  by        = (Optional) BY variable for group-wise detection.
              Note: BY supports ONE variable only.
  criteria  = Robust Z-score threshold for outlier flagging.
              Default: 3.5
  out       = Output dataset name.
              Default: outlier_MAD
~~~

### Output:  
~~~text
  The output dataset contains all original variables plus:
    mad_<var>         : MAD-standardized value from PROC STDIZE.
    mad_<var>_abs     : Absolute robust Z-score (0.6745 * mad_<var>).
    Criteria_MAD      : Criterion used.
    outlier_MADFL     : Outlier flag ("Y"/"N").
  The original variable is preserved with its original name.
~~~

### Usage Example:
~~~sas
  %outlier_MAD(data=adsl, var=age);
  %outlier_MAD(data=advs, var=aval, by=paramcd, criteria=4, out=mad_out);
~~~

### Notes:
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).
  - The constant 0.6745 rescales MAD-based scores to be comparable to
    standard normal Z-scores under normality.
  
---

## `%outlier_iqr()` macro <a name="outlieriqr-macro-2"></a> ######
### Purpose:
  Detect outliers based on the Interquartile Range (IQR) rule.  
  Flags observations outside:  
    - Q1 - 1.5*IQR to Q3 + 1.5*IQR (mild outliers)  
    - Q1 - 3*IQR   to Q3 + 3*IQR   (extreme outliers)  

### Parameters:
~~~text
  data      = Input dataset name.
  var       = Analysis variable (single numeric variable).
  by        = (Optional) BY variable for group-wise detection.
              Note: BY supports ONE variable only.
  out       = Output dataset name.
              Default: outlier_IQR
~~~

### Output:  
~~~text
  The output dataset contains all original variables plus:
    Q1, Q3, IQR               : Quartiles and IQR.
    Lower1_5, Upper1_5        : 1.5*IQR bounds.
    Lower3, Upper3            : 3*IQR bounds.
    outlier_IQR1_5FL          : Mild outlier flag ("Y"/"N").
    outlier_IQR3FL            : Extreme outlier flag ("Y"/"N").
~~~

### Usage Example:  
~~~sas
  %outlier_IQR(data=adsl, var=age);
  %outlier_IQR(data=advs, var=aval, by=paramcd, out=iqr_out);
~~~

### Notes:  
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).

  
---
