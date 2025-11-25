/*** HELP START ***//*

Macro:      outlier_IQR

Purpose:
  Detect outliers based on the Interquartile Range (IQR) rule.
  Flags observations outside:
    - Q1 - 1.5*IQR to Q3 + 1.5*IQR (mild outliers)
    - Q1 - 3*IQR   to Q3 + 3*IQR   (extreme outliers)

Parameters:
  data      = Input dataset name.
  var       = Analysis variable (single numeric variable).
  by        = (Optional) BY variable for group-wise detection.
              Note: BY supports ONE variable only.
  out       = Output dataset name.
              Default: outlier_IQR

Output:
  The output dataset contains all original variables plus:
    Q1, Q3, IQR               : Quartiles and IQR.
    Lower1_5, Upper1_5        : 1.5*IQR bounds.
    Lower3, Upper3            : 3*IQR bounds.
    outlier_IQR1_5FL          : Mild outlier flag ("Y"/"N").
    outlier_IQR3FL            : Extreme outlier flag ("Y"/"N").

Usage Example:
  %outlier_IQR(data=adsl, var=age);
  %outlier_IQR(data=advs, var=aval, by=paramcd, out=iqr_out);

Notes:
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).

*//*** HELP END ***/

%macro outlier_IQR(data = ,  var= ,  by=,  out= outlier_IQR );
%if %length(&by) ne 0 %then %do;
  proc sort data = &data;
    by &by;
  run;
%end;
proc univariate data=&data noprint;
  var &var. ;
  %if %length(&by) ne 0 %then %do;
   by &by;
  %end;
  output out=_iqr_
    q1=Q1
    q3=Q3;
run;
data &out.;
  set &data;
  %if %length(&by) eq 0 %then %do;
  if _n_=1 then set _iqr_;
  %end;
  %if %length(&by) ne 0 %then %do;
    if 0 then set _iqr_;
    if _n_ = 1 then do;
      declare hash h1(dataset:"_iqr_");
      h1.definekey("&by");
      h1.definedata("Q1","Q3");
      h1.definedone();
    end;
    if h1.find() ne 0 then call missing(of Q1 Q3);
  %end;
  IQR = Q3 - Q1;
  Lower1_5 = Q1 - 1.5*IQR;
  Upper1_5 = Q3 + 1.5*IQR;
  Lower3  = Q1 - 3*IQR;
  Upper3  = Q3 + 3*IQR;

  if &var. < Lower1_5 or &var. > Upper1_5 then outlier_IQR1_5FL = "Y";
  else  outlier_IQR1_5FL = "N";
  if &var. < Lower3 or &var. > Upper3 then outlier_IQR3FL = "Y";
  else  outlier_IQR3FL = "N";

run;
proc delete data=_iqr_;
run;

%mend;
