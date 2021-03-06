%{
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "project.tab.h"
#include "project.h"
#include "Grammar.h"
#include "BinaryTree.h"

%}

%%
[ \t]+									{ ; }
(\/\/.*)									{ ; }
(\/\*(\n|.)*\*\/)							{ ; }

[+\-*/=]|(and)|(or)|(eq)|(gt)			{ censorOper(yytext); }

[0-9]+									{	
											censorInt(&yytext);
										}

(([0-9]+)|([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?) { 
	tok_ptr++;
	strcpy(token_table[tok_ptr], "float");	
	strcpy(float_table[++float_ptr], yytext);
}

[\n] 	{ 
//	for(int i = 0 ; i < tok_ptr + 1 ; i++) printf("%s\n", token_table[i]);
	strcpy(token_table[++tok_ptr], "EOF"); XML(); printf("%s", print); tok_ptr = -1; }

[a-zA-Z_][a-zA-Z0-9_]*					{ censorId(yytext); }


[",();]									{ censorSpec(yytext); }

.                     					{ yyerror(); }

<<EOF>>									{ exit(0); }

%%

int main(int argc, char* argv[])
{
	yyparse();
    return 0;
}

int yywrap(void)
{
//	strcpy(token_table[++tok_ptr], "EOF");
//	for(int i = 0 ; i < tok_ptr + 1 ; i++) printf("%s\n", id_table[i]);
//	XML();
//	printf("%s", print);
	return 1;
}

int yyerror(void)
{
    printf("Error\n");
    exit(1);
}

void toUpper(char* text) {
	for(int i = 0 ; i < strlen(text) ; i++)
		if(text[i] >= 'a' && text[i] <= 'z')
			text[i] -= 32;
}

void censorId(char* text) { 
	tok_ptr++;
	char* keyword[] = {"and", "begin", "def", "end", 
					"else", "eq", "gt", "if", "or", 
					"print", "return", "while", "identifiers"};
	bool idAppear = false;
	int idx = 0;

	/* 길이가 16 이상일 때는 우선적으로 길이 16으로 맞춰준다. */
	if(strlen(text) > 16) text[16] = '\0';

	/* 길이를 재정의 */
	int length = strlen(text);
	int isAll_ = true;


	/* 키워드 검사 키워드와 같으면 출력이후 즉시 리턴 */
	for(int i = 0 ; i < 13 ; i++) {
		if(!strcmp(text, keyword[i])){
			char tmp[STR_LENG];
			strcpy(tmp, text);
			toUpper(tmp);
//			printf("<%s>\t\t%s\n", tmp, text);
			return;
		}
	}

	/* _로만 이루어진 identifier를 거른다 */
	for(int i = 0 ; i < length ; i++){
		if(text[i] != '_')	{
			isAll_ = false;
			break;
		}
	}
	if(isAll_) yyerror();

	
	for(int i = 0 ; i < MAX_DBNUM ; i++) {
		if(!(strcmp(text, id_table[i]))) {
			idAppear = true;
			idx = i;
			break;
		}
	}

	if(!idAppear){
//		strcpy(id_table[++id_ptr], text);
		strcpy(token_table[tok_ptr], "id");
//		printf("<ID, %d>\t\t%s\n", id_ptr, text);
//		for(int i = 0 ; i < tok_ptr + 1 ; i++)
//			printf("%s\n", token_table[i]);
	} else {
		strcpy(token_table[tok_ptr], "id");
//		printf("<ID, %d>\t\t%s\n", idx, text);
	}
	strcpy(id_table[++id_ptr], text);

}
void censorInt(char** text) {
	tok_ptr++;
	int length = strlen(*text);
	/* 길이가 10 이상일 때는 나머지 cut */
	if(length > 10) *text += length - 10;
	strcpy(token_table[tok_ptr], "int");
	strcpy(int_table[++int_ptr], *text);
}

void censorSpec(char* text) {
	tok_ptr++;
	/* 개인적인 사용 빈도 수에 따라 상위에 배치 */
	if(text[0] == ';')			strcpy(token_table[tok_ptr], ";");
	else if(text[0] == '(')		strcpy(token_table[tok_ptr], "(");
	else if(text[0] == ')')		strcpy(token_table[tok_ptr], ")");
	else if(text[0] == '"')		strcpy(token_table[tok_ptr], "\"");
	else 						strcpy(token_table[tok_ptr], ",");
}

void censorOper(char* text) {
	tok_ptr++;
	if(strlen(text) == 1) {
		if(text[0] == '=') 		strcpy(token_table[tok_ptr], "assign");
		else if(text[0] == '+')	strcpy(token_table[tok_ptr], "plus");
		else if(text[0] == '-') strcpy(token_table[tok_ptr], "minus");
		else if(text[0] == '*')	strcpy(token_table[tok_ptr], "mult");
		else if(text[0] == '/')	strcpy(token_table[tok_ptr], "div");
		else;
	}
}
