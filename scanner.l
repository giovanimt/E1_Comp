/*
Giovani Tirello 252741
Vinicius Castro 193026
*/


%{

#include "tokens.h"

int LineNumber = 1;
int getLineNumber(void) { return LineNumber; }

%}

%x SingleLineComment
%x Comment

%%

[\t ]+      { ; } /* ignora tabs e espacos */

","		{ printf(", on line %d",getLineNumber()); return (int)','; }
";"		{ printf("; on line %d",getLineNumber()); return (int)';'; }
":"		{ printf(": on line %d",getLineNumber()); return (int)':'; }
"("		{ printf("( on line %d",getLineNumber()); return (int)'('; }
")"		{ printf(") on line %d",getLineNumber()); return (int)')'; }
"["		{ printf("[ on line %d",getLineNumber()); return (int)'['; }
"]"		{ printf("] on line %d",getLineNumber()); return (int)']'; }
"{"		{ printf("{ on line %d",getLineNumber()); return (int)'{'; }
"}"		{ printf("} on line %d",getLineNumber()); return (int)'}'; }
"+"		{ printf("+ on line %d",getLineNumber()); return (int)'+'; }
"-"		{ printf("- on line %d",getLineNumber()); return (int)'-'; }
"|"		{ printf("| on line %d",getLineNumber()); return (int)'|'; }
"?"		{ printf("? on line %d",getLineNumber()); return (int)'?'; }
"*"		{ printf("* on line %d",getLineNumber()); return (int)'*'; }
"/"		{ printf("/ on line %d",getLineNumber()); return (int)'/'; }
"<"		{ printf("< on line %d",getLineNumber()); return (int)'<'; }
">"		{ printf("> on line %d",getLineNumber()); return (int)'>'; }
"="		{ printf("= on line %d",getLineNumber()); return (int)'='; }
"!"		{ printf("! on line %d",getLineNumber()); return (int)'!'; }
"&"		{ printf("& on line %d",getLineNumber()); return (int)'&'; }
"%"		{ printf("percent on line %d",getLineNumber()); return (int)'%'; }
"#"		{ printf("# on line %d",getLineNumber()); return (int)'#'; }
"^"		{ printf("^ on line %d",getLineNumber()); return (int)'^'; }
"."		{ printf(". on line %d",getLineNumber()); return (int)'.'; }
"$"		{ printf("$ on line %d",getLineNumber()); return (int)'$'; }


int         { printf("TK_PR_INT on line %d",getLineNumber()); return TK_PR_INT; }
float       { printf("TK_PR_FLOAT on line %d",getLineNumber()); return TK_PR_FLOAT; }
bool        { printf("TK_PR_BOOL on line %d",getLineNumber()); return TK_PR_BOOL; }
char        { printf("TK_PR_CHAR on line %d",getLineNumber()); return TK_PR_CHAR; }
string      { printf("TK_PR_STRING on line %d",getLineNumber()); return TK_PR_STRING; }
if          { printf("TK_PR_IF on line %d",getLineNumber()); return TK_PR_IF; }
then        { printf("TK_PR_THEN on line %d",getLineNumber()); return TK_PR_THEN; }
else        { printf("TK_PR_ELSE on line %d",getLineNumber()); return TK_PR_ELSE; }
while       { printf("TK_PR_WHILE on line %d",getLineNumber()); return TK_PR_WHILE; }
do          { printf("TK_PR_DO on line %d",getLineNumber()); return TK_PR_DO; }
input       { printf("TK_PR_INPUT on line %d",getLineNumber()); return TK_PR_INPUT; }
output      { printf("TK_PR_OUTPUT on line %d",getLineNumber()); return TK_PR_OUTPUT; }
return      { printf("TK_PR_RETURN on line %d",getLineNumber()); return TK_PR_RETURN; }
const       { printf("TK_PR_CONST on line %d",getLineNumber()); return TK_PR_CONST; }
static      { printf("TK_PR_STATIC on line %d",getLineNumber()); return TK_PR_STATIC; }
foreach     { printf("TK_PR_FOREACH on line %d",getLineNumber()); return TK_PR_FOREACH; }
for         { printf("TK_PR_FOR on line %d",getLineNumber());return TK_PR_FOR; }
switch      { printf("TK_PR_SWITCH on line %d",getLineNumber());return TK_PR_SWITCH; }
case        { printf("TK_PR_CASE on line %d",getLineNumber());return TK_PR_CASE; }
break       { printf("TK_PR_BREAK on line %d",getLineNumber());return TK_PR_BREAK; }
continue    { printf("TK_PR_CONTINUE on line %d",getLineNumber());return TK_PR_CONTINUE; }
class       { printf("TK_PR_CLASS on line %d",getLineNumber());return TK_PR_CLASS; }
private     { printf("TK_PR_PRIVATE on line %d",getLineNumber());return TK_PR_PRIVATE; }
public      { printf("TK_PR_PUBLIC on line %d",getLineNumber());return TK_PR_PUBLIC; }
protected   { printf("TK_PR_PROTECTED on line %d",getLineNumber()); return TK_PR_PROTECTED; }
"<="        { printf("TK_OC_LE on line %d",getLineNumber());return TK_OC_LE; }
">="        { printf("TK_OC_GE on line %d",getLineNumber());return TK_OC_GE; }
"=="        { printf("TK_OC_EQ on line %d",getLineNumber());return TK_OC_EQ; }
"!="        { printf("TK_OC_NE on line %d",getLineNumber());return TK_OC_NE; }
"&&"        { printf("TK_OC_AND on line %d",getLineNumber());return TK_OC_AND; }
"||"        { printf("TK_OC_OR on line %d",getLineNumber());return TK_OC_OR; }
"<<"        { printf("TK_OC_SL on line %d",getLineNumber());return TK_OC_SL; }
">>"        { printf("TK_OC_SR on line %d",getLineNumber());return TK_OC_SR; }
"%>%"       { printf("TK_OC_FORWARD_PIPE on line %d",getLineNumber());return TK_OC_FORWARD_PIPE; }
"%|%"       { printf("TK_OC_LE on line %d",getLineNumber());return TK_OC_BASH_PIPE; }
[+-]?[0-9]+           { printf("TK_LIT_INT on line %d",getLineNumber()); return TK_LIT_INT; }
[+-]?[0-9]+\.[0-9]+([eE][+-][0-9]+)?   { printf("TK_LIT_FLOAT on line %d",getLineNumber()); return TK_LIT_FLOAT; }
true                       { printf("TK_LIT_TRUE on line %d",getLineNumber()); return TK_LIT_TRUE; }
false                      { printf("TK_LIT_FALSE on line %d",getLineNumber()); return TK_LIT_FALSE; }
\'.\'                      { printf("TK_LIT_CHAR on line %d",getLineNumber()); return TK_LIT_CHAR; } 
\".*\"                     { printf("TK_LIT_STRING on line %d",getLineNumber()); return TK_LIT_STRING; } 
[a-zA-Z_][0-9]*            { printf("TK_IDENTIFICADOR on line %d",getLineNumber());return TK_IDENTIFICADOR; }

"//".*   			{ BEGIN(SingleLineComment); }
<SingleLineComment>\n 		{ LineNumber++; printf("new line %d \n",getLineNumber()); BEGIN(INITIAL); }

"/*"          		{ BEGIN(Comment); }
<Comment>\n             { LineNumber++; printf("new line %d \n",getLineNumber()); }
<Comment>"*/"  		{ BEGIN(INITIAL); }
<Comment>.		{;}


\n   { LineNumber++;  printf("new line %d \n",getLineNumber());}

.    { printf("error on line %d", getLineNumber()); return TOKEN_ERRO; }


%%
