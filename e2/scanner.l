/*
Giovani Tirello 252741
Vinicius Castro 193026
*/


%{

#include "parser.tab.h"

int LineNumber = 1;
int ColNumber = 0;
int get_line_number(void) { return LineNumber; }
int get_col_number(void) { return ColNumber; }
void count_cols();

%}

%x Comment

%%

[\t ]+      { count_cols(); } /* ignora tabs e espacos */

","|";"|":"|"("|")"|"["|"]"|"{"|"}"|"+"|"-"|"|"|"?"|"*"|"/"|"<"|">"|"="|"!"|"&"|"%"|"#"|"^"|"."|"$"        { count_cols();return yytext[0]; }

int         { count_cols();return TK_PR_INT; }
float       { count_cols();return TK_PR_FLOAT; }
bool        { count_cols();return TK_PR_BOOL; }
char        { count_cols();return TK_PR_CHAR; }
string      { count_cols();return TK_PR_STRING; }
if          { count_cols();return TK_PR_IF; }
then        { count_cols();return TK_PR_THEN; }
else        { count_cols();return TK_PR_ELSE; }
while       { count_cols();return TK_PR_WHILE; }
do          { count_cols();return TK_PR_DO; }
input       { count_cols();return TK_PR_INPUT; }
output      { count_cols();return TK_PR_OUTPUT; }
return      { count_cols();return TK_PR_RETURN; }
const       { count_cols();return TK_PR_CONST; }
static      { count_cols();return TK_PR_STATIC; }
foreach     { count_cols();return TK_PR_FOREACH; }
for         { count_cols();return TK_PR_FOR; }
switch      { count_cols();return TK_PR_SWITCH; }
case        { count_cols();return TK_PR_CASE; }
break       { count_cols();return TK_PR_BREAK; }
continue    { count_cols();return TK_PR_CONTINUE; }
class       { count_cols();return TK_PR_CLASS; }
private     { count_cols();return TK_PR_PRIVATE; }
public      { count_cols();return TK_PR_PUBLIC; }
protected   { count_cols();return TK_PR_PROTECTED; }
true        { count_cols();return TK_LIT_TRUE; }
false       { count_cols();return TK_LIT_FALSE; }

"<="        { count_cols();return TK_OC_LE; }
">="        { count_cols();return TK_OC_GE; }
"=="        { count_cols();return TK_OC_EQ; }
"!="        { count_cols();return TK_OC_NE; }
"&&"        { count_cols();return TK_OC_AND; }
"||"        { count_cols();return TK_OC_OR; }
"<<"        { count_cols();return TK_OC_SL; }
">>"        { count_cols();return TK_OC_SR; }
"%>%"       { count_cols();return TK_OC_FORWARD_PIPE; }
"%|%"       { count_cols();return TK_OC_BASH_PIPE; }

[0-9]+                             { count_cols();return TK_LIT_INT; }
[0-9]+\.[0-9]+([eE][+-]?[0-9]+)?   { count_cols();return TK_LIT_FLOAT; }

\'.\'                      { count_cols();return TK_LIT_CHAR; } 
\".*\"                     { count_cols();return TK_LIT_STRING; } 
[a-zA-Z_][a-zA-Z_0-9]*     { count_cols();return TK_IDENTIFICADOR; }

"//".*   			     { count_cols(); }

"/*"          { count_cols();BEGIN(Comment); }
<Comment>\n   { count_cols();LineNumber++;}
<Comment>.	  { count_cols();}
<Comment>"*/" { count_cols();BEGIN(INITIAL); }

\n   { count_cols();LineNumber++; }
.    { count_cols();return TOKEN_ERRO; }

%%

void count_cols(){
  int i;
  for(i=0 ; yytext[i] != '\0' ; i++){
    if(yytext[i] != '\n')
      ColNumber++;
    else
      ColNumber=0;
  } 
}
