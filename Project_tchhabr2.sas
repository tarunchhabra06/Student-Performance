
ods rtf file="c:\Stat 448\Project_Final.rtf";



proc import datafile="C:\Sttat 448\student-por.csv" out=Portugese dbms=dlm replace;
   delimiter=";";
   getnames=yes;
run;

title2'Portuguese Data';
/*Define Data Set*/
data test_pt;
	set Portugese;
	G1N=input(G1,3.);
	G2N=input(G2,3.);
	drop G1 G2;
	total=G1N+G2N+G3;
run;
proc univariate data=test_pt noprint;
var total;
output out=percentiles1 pctlpts=40 44 45 46 pctlpre=P;
run;
proc print data=percentiles1;
run;

/*We can observe that there is clear distinction between 45th and 46th percentle*/
/*Define Performance variable*/
data new_pt;
	set test_pt;
	length Performance $40;
	if total<33.5 then Performance='Below cut-off';
	else Performance='Above cut-off';		
run;

title2'Logistic regression Port First attempt';
/*Fit logistic regression model*/
proc logistic data=new_pt plots=influence;
	class school sex address--health Performance;
	model Performance=school absences sex age address--health /selection=stepwise;
	output out=diagnosticsP1 cbar=cbar;
	ods select ModelBuildingSummary InfluencePlots OddsRatios;
run;



/*There is an issue of quasicomplete separation and hence we remove the Failure from data*/ 

/*Removing Failure from the data*/
data new_pt2;
	set new_pt;
	drop failures;
run;

title2'Logistic regresion without failure Port';
proc logistic data=new_pt2 desc plots=influence;
	class school sex address--health Performance;
	model Performance(event='Below cut-off')=school absences sex age address--health /selection=stepwise;
	output out=diagnostics_pt2 cbar=cbar;
	ods select ModelBuildingSummary  InfluencePlots;
run;

title2' LR without Failure Port Refit';
proc logistic data=diagnostics_pt2 plots=influence;
	where cbar<0.4;
	class school sex address--health Performance;
	model Performance=school absences sex age address--health /selection=stepwise;
	output out=diagnostics_pt22 cbar=cbar;
	ods select ModelBuildingSummary InfluencePlots;
run;

title2'LR Model Statistics Portuguese';
proc logistic data=diagnostics_pt22 plots=influence;
	class school sex address--health Performance;
	model Performance(event='Below cut-off')=school higher schoolsup Medu sex Dalc absences /lackfit;
	ods select FitStatistics GlobalTests LackFitChiSq ParameterEstimates OddsRatios;
run;


/*Mathematics DataSet*/
proc import datafile="C:/Stat 448/student-mat.csv" out=Maths dbms=dlm replace;
   delimiter=";";
   getnames=yes;
run;

/*Define Data Set*/
data math_ft;
	set Maths;
	G1N=input(G1,3.);
	G2N=input(G2,3.);
	drop G1 G2;
	total=G1N+G2N+G3;
run;

proc univariate data=math_ft noprint;
var total;
output out=percentiles2 pctlpts=40 41 45 46 50 54 55 56 pctlpre=P;
run;
proc print data=percentiles2;
run;


/*Define Performance variable*/
data math_sd;
	set math_ft;
	length Performance $40;
	if total<33.5 then Performance='Below cut-off';
	else Performance='Above cut-off';		
run;

title2' LR  Maths First attempt';
/*Fit logistic regression model*/
proc logistic data=math_sd  plots=influence;
	class school sex address--health Performance;
	model Performance(event='Above cut-off')=school absences sex age address--health /selection=stepwise;
	output out=diagnosticsF cbar=cbar;
	ods select OddsRatios InfluencePlots ModelBuildingSummary ;
run;

/*Even after refitting the model, cbar value is high and there's an issue of convergence for failure. So I remove the Failure variable*/


/*Removing Failure from the data*/
data maths_pt2;
	set math_sd;
	drop failures;
run;

title2' LR  Maths without failure';
proc logistic data=maths_pt2 plots=influence;
	class school sex address--health Performance;
	model Performance(event='Above cut-off')=school absences sex age address--health /selection=stepwise;
	output out=diagnostics_pt2 cbar=cbar;
	ods select ModelBuildingSummary InfluencePlots;
run;

title2 'LR Maths model stats';
proc logistic data=maths_pt2;
class Performance schoolsup freetime;
model Performance(event='Above cut-off')=schoolsup freetime age/lackfit;
ods select FitStatistics GlobalTests LackFitChiSq ParameterEstimates OddsRatios;
run;


ods rtf close;