/*** HELP START ***//*

Macro:      outlier_SD

Purpose:
  Detect outliers based on standard deviation (Z-score) using PROC STDIZE.
  Observations are flagged when |Z| exceeds the specified criterion.

Parameters:
  data      = Input dataset name.
  var       = Analysis variable (single numeric variable).
  by        = (Optional) BY variable for group-wise detection.
              Note: BY supports ONE variable only.
  criteria  = Z-score threshold for outlier flagging.
              Default: 3
  out       = Output dataset name.
              Default: outlier_SD

Output:
  The output dataset contains all original variables plus:
    std_<var>         : Standardized value (Z-score).
    std_<var>_abs     : Absolute Z-score.
    Criteria_SD       : Criterion used.
    outlier_SDFL      : Outlier flag ("Y"/"N").
  The original variable is preserved with its original name.

Usage Example:
  %outlier_SD(data=adsl, var=age);
  %outlier_SD(data=advs, var=aval, by=paramcd, criteria=2.5, out=sd_out);

Notes:
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).
  - Missing values in &var are retained and flagged as "N".

*//*** HELP END ***/

%macro outlier_SD(data = ,  var= ,  by=, criteria = 3 , out= outlier_SD );
%if %length(&by) ne 0 %then %do;
  proc sort data = &data;
    by &by;
  run;
%end;
proc stdize data=&data. out=outlier_SD1 sprefix=std_ oprefix=ori_ method=std;
  var &var. ;
  %if %length(&by) ne 0 %then %do;
      by &by;
  %end;
run;
data &out.;
  set outlier_SD1;
  std_&var._abs = abs(std_&var.);
  Criteria_SD = &criteria.;
  if Criteria_SD < std_&var._abs then outlier_SDFL="Y";
   else outlier_SDFL="N";
  rename ori_&var.=&var.;
run;
proc delete data=outlier_SD1;
run;
%mend;
