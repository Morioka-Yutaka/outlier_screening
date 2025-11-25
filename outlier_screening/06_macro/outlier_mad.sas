/*** HELP START ***//*

Macro:      outlier_MAD

Purpose:
  Detect outliers using Median Absolute Deviation (MAD)-based robust Z-scores
  via PROC STDIZE METHOD=MAD. Observations are flagged when the robust
  |Z*| exceeds the specified criterion.

Parameters:
  data      = Input dataset name.
  var       = Analysis variable (single numeric variable).
  by        = (Optional) BY variable for group-wise detection.
              Note: BY supports ONE variable only.
  criteria  = Robust Z-score threshold for outlier flagging.
              Default: 3.5
  out       = Output dataset name.
              Default: outlier_MAD

Output:
  The output dataset contains all original variables plus:
    mad_<var>         : MAD-standardized value from PROC STDIZE.
    mad_<var>_abs     : Absolute robust Z-score (0.6745 * mad_<var>).
    Criteria_MAD      : Criterion used.
    outlier_MADFL     : Outlier flag ("Y"/"N").
  The original variable is preserved with its original name.

Usage Example:
  %outlier_MAD(data=adsl, var=age);
  %outlier_MAD(data=advs, var=aval, by=paramcd, criteria=4, out=mad_out);

Notes:
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).
  - The constant 0.6745 rescales MAD-based scores to be comparable to
    standard normal Z-scores under normality.

*//*** HELP END ***/

%macro outlier_MAD(data = ,  var= ,  by=, criteria = 3.5 , out= outlier_MAD );
%if %length(&by) ne 0 %then %do;
  proc sort data = &data;
    by &by;
  run;
%end;
proc stdize data=&data out=outlier_MAD1 sprefix=mad_ oprefix=ori_ method=mad;
  var &var.;
  %if %length(&by) ne 0 %then %do;
    by &by;
  %end;
run;
data &out.;
set outlier_MAD1;
mad_&var._abs=abs(0.6745 * mad_&var.);
Criteria_MAD=&criteria.;
if Criteria_MAD < mad_&var._abs then outlier_MADFL="Y";
else outlier_MADFL="N";
rename ori_&var.= &var.;
run;
proc delete data=outlier_MAD1;
run;
%mend;
