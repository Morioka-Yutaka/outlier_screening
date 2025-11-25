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

<img width="656" height="385" alt="image" src="https://github.com/user-attachments/assets/20588328-a534-4c4c-91d0-c6eb751d0e3b" />


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

<img width="486" height="353" alt="image" src="https://github.com/user-attachments/assets/e19aa9ef-a5b8-4d14-8bff-c4a1cc72895a" />

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

<img width="746" height="362" alt="image" src="https://github.com/user-attachments/assets/435a48c9-e0a2-4b0a-a454-65891587077e" />


### Notes:  
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).

---

## `%outlier_all3()` macro <a name="outlierall3-macro-1"></a> ######
### Purpose:  
  Run three outlier detection methods in sequence and provide a unified  
  review-ready output plus visualization:  
  ~~~text
    1) SD-based Z-score method   (%outlier_SD)  
    2) MAD robust Z-score method(%outlier_MAD)  
    3) IQR rule method          (%outlier_IQR)
  ~~~
  After combining flags, this macro also:  
    - Adds dense ranks in ascending and descending order of &var
      (asc_rank, desc_rank) for quick extreme-value review.
    - Produces a scatter + boxplot figure labeled by detected methods.
    - Prints PROC UNIVARIATE ExtremeObs for &var.

### Parameters:  
~~~text
  data         = Input dataset name.
  var          = Analysis variable (single numeric variable).
  by           = (Optional) BY variable for group-wise detection/plotting.
                 Note: BY supports ONE variable only.
  SD_criteria  = Z-score threshold for SD method.
                 Default: 3
  MAD_criteria = Robust Z-score threshold for MAD method.
                 Default: 3.5
~~~

### Output:  
~~~text
  Creates the following datasets in WORK:
    outlier_<data>_sd    : SD method results.
    outlier_<data>_mad   : MAD method results.
    outlier_<data>_iqr   : IQR method results.
    outlier_<data>_all3   : Combined dataset including:
         outlier_SDFL, outlier_MADFL, outlier_IQR1_5FL, outlier_IQR3FL,
         asc_rank, desc_rank,
         and retained absolute scores (std_<var>_abs, mad_<var>_abs).
    outlier_<data>_graph : Dataset for plotting with method label text.

  Generates a PROC SGPLOT figure and a PROC UNIVARIATE ExtremeObs table.
~~~

### Test Data
~~~sas
data adsl;
  call streaminit(20251126);
  length USUBJID $12 SEX $1 TRT01A $8;
  do i = 1 to 200;
    USUBJID = cats("SUBJ", put(i, z4.));
    SEX = ifc(rand("Bernoulli", 0.5)=1, "M", "F");
    TRT01A = ifc(rand("Bernoulli", 0.5)=1, "Drug", "Placebo");
    AGE = round(rand("Normal", 55, 10), 1);
    if AGE < 18 then AGE = 18;
    if AGE > 90 then AGE = 90;
    output;
  end;
  do j = 1 to 6;
    i + 1;
    USUBJID = cats("SUBJ", put(i, z4.));
    SEX = ifc(mod(i,2)=0, "M", "F");
    TRT01A = ifc(mod(i,2)=0, "Drug", "Placebo");
    select (j);
      when (1,2) AGE = 19;          
      when (3)   AGE = 95;          
      when (4)   AGE = 101;         
      when (5)   AGE = 17;          
      when (6)   AGE = 110;         
      otherwise;
    end;
    output;
  end;
  drop i j;
run;

data advs;
  call streaminit(20251126);
  length USUBJID $12 PARAMCD $8;

  array params[3] $8 _temporary_ ("SBP","DBP","HR");

  do i = 1 to 160;
    USUBJID = cats("SUBJ", put(i, z4.));

    do p = 1 to dim(params);
      PARAMCD = params[p];

      select (PARAMCD);
        when ("SBP") do;  
          AVAL = rand("Normal", 120, 12);
          if i in (5, 77)  then AVAL = 175;
          if i in (33)     then AVAL = 85;
        end;

        when ("DBP") do;  
          AVAL = rand("Normal", 75, 8);
          if i in (12, 90) then AVAL = 110;
          if i in (48)     then AVAL = 45;
        end;

        when ("HR") do;   
          AVAL = rand("Normal", 70, 10);
          if i in (22)     then AVAL = 130;
          if i in (101)    then AVAL = 35;
        end;

        otherwise;
      end;

      AVAL = round(AVAL, 0.1);

      output;
    end;
  end;

  drop i p;
run;
~~~

### Usage Example:
~~~sas
  %outlier_all3(data=adsl, var=age);
~~~

~~~sas
  %outlier_all3(data=advs, var=aval, by=paramcd, SD_criteria=2.8, MAD_criteria=3.8);
~~~

### Notes:
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).

  
---
