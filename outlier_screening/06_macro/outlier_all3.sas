/*** HELP START ***//*

Macro:      outlier_all3

Purpose:
  Run three outlier detection methods in sequence and provide a unified
  review-ready output plus visualization:
    1) SD-based Z-score method   (%outlier_SD)
    2) MAD robust Z-score method(%outlier_MAD)
    3) IQR rule method          (%outlier_IQR)
  After combining flags, this macro also:
    - Adds dense ranks in ascending and descending order of &var
      (asc_rank, desc_rank) for quick extreme-value review.
    - Produces a scatter + boxplot figure labeled by detected methods.
    - Prints PROC UNIVARIATE ExtremeObs for &var.

Parameters:
  data         = Input dataset name.
  var          = Analysis variable (single numeric variable).
  by           = (Optional) BY variable for group-wise detection/plotting.
                 Note: BY supports ONE variable only.
  SD_criteria  = Z-score threshold for SD method.
                 Default: 3
  MAD_criteria = Robust Z-score threshold for MAD method.
                 Default: 3.5

Output:
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

Usage Example:
  %outlier_all3(data=adsl, var=age);
  %outlier_all3(data=advs, var=aval, by=paramcd, SD_criteria=2.8, MAD_criteria=3.8);

Notes:
  - BY processing is performed only when BY is provided.
  - BY variable must be a single variable (multiple BY variables are not supported).

*//*** HELP END ***/

%macro outlier_all3(
data = ,
var= ,
by=, 
SD_criteria=3,
MAD_criteria=3.5
);
%outlier_SD(data=&data, var =&var,by =&by, criteria=&SD_criteria, out=outlier_&data._sd);
%outlier_MAD(data=outlier_&data._sd, var =&var,by =&by, criteria=&MAD_criteria,out=outlier_&data._mad);
%outlier_IQR(data=outlier_&data._mad, var =&var,by =&by,out=outlier_&data._iqr);
data outlier_&data._all3;
set outlier_&data._iqr;
drop std_&var. Criteria_SD mad_&var. Criteria_MAD Q3 Q1 IQR Lower1_5 Upper1_5 Lower3 Upper3 ;
run;

proc rank data=outlier_&data._all3 out=outlier_&data._all3 ties=dense;
var &var;
ranks asc_rank;
run;

proc rank data=outlier_&data._all3 out=outlier_&data._all3 descending ties=dense;
var &var;
ranks desc_rank;
run;


data outlier_&data._graph;
set  outlier_&data._all3;
 if outlier_SDFL ="Y" then  text=cats("SD");
 if outlier_MADFL ="Y" then  text=catx("/",text,"MAD");
 if outlier_IQR3FL ="Y" then  text=catx("/",text,"IQR3");
 if outlier_IQR1_5FL ="Y" and  outlier_IQR3FL ="N" then  text=catx("/",text,"IQR1.5");
dummy=1;
label dummy="SD: &SD_criteria. < |z|, MAD: &MAD_criteria <|z*|";
run; 
 %if %length(&by) ne 0 %then %do;
proc sort data = outlier_&data._graph;
      by &by.;
run; 
%end;
proc format;
 value dummy 1 =" ";
run;
proc sgplot data=outlier_&data._graph noautolegend;
  scatter x=dummy y=&var /  name="sp1" 
              transparency=0.5 jitter markerattrs=(symbol=circle size=5) datalabel=text datalabelattrs=(color=red)
              ;
  vbox &var / category=dummy noFill noOutliers
              meanAttrs=(color=black symbol=diamondFilled);
 %if %length(&by) ne 0 %then %do;
      by &by.;
%end;

format dummy dummy.;
run;

ods select ExtremeObs;
proc univariate data=&data ;
  var &var. ;
  %if %length(&by) ne 0 %then %do;
   by &by;
  %end;
run;

%mend;
