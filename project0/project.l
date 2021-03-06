%{
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "project.h"
#include "project.tab.h"

%}

%%

[ \t\n]+								{ ; }
(\/\/.*)								{ ; }
(\/\*(\n|.)*\*\/)							{ ; }
[+|-]?[0-9]+							{	
											censorInt(&yytext);
											printf("<INTEGER>\t%s\n", yytext);
										}

[+|-]?(([0-9]+)|([0-9]*\.[0-9]+)([eE][-+]?[0-9]+)?) { printf("<FLOAT>\t\t%s\n", yytext); }

[+\-*/=]|(and)|(or)|(eq)|(gt)			{ censorOper(yytext); }

\".*\"									{ censorStr(yytext); }


[a-zA-Z_][a-zA-Z0-9_]*					{ censorId(yytext); }


[",();]									{ censorSpec(yytext); }

.                     					{ printf("Aaa");yyerror(); }

<<EOF>>									{ printTable(); exit(0); }

%%

// 테스트용 주석추가
// 문자열, 주석 개행 처리하기
int main(int argc, char* argv[])
{
	yyparse();
    return 0;
}

int yywrap(void)
{
	return 1;
}

int yyerror(void)
{
    printf("Error\n");
    exit(1);
}

void printTable() {
	int bigNum = id_ptr > str_ptr ? id_ptr : str_ptr;
	if(bigNum > 0) {
		printf("\n\n***IDENTIFIER TABLE***\t\t\t\t\t******STRING TABLE******\n");
		printf("idx\t\tID\t\t\t\t\tidx\t\tSTRING\n");

		for(int i = 1 ; i < bigNum + 1 ; i++) {
			printf("%d\t\t%s\t\t\t\t\t%d\t\t%s\n", i, id_table[i], i, str_table[i]);
		}
	}
}
void toUpper(char* text) {
	for(int i = 0 ; i < strlen(text) ; i++)
		if(text[i] >= 'a' && text[i] <= 'z')
			text[i] -= 32;
}

void censorId(char* text) { 
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
			printf("<%s>\t\t%s\n", tmp, text);
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
		strcpy(id_table[++id_ptr], text);
		printf("<ID, %d>\t\t%s\n", id_ptr, text);
	} else {
		printf("<ID, %d>\t\t%s\n", idx, text);
	}

}

void censorStr(char* text) {
	/* censorId의 인덱싱과 동일 알고리즘 */
	bool strAppear = false;
	int idx = 0;

	for(int i = 0 ; i < MAX_DBNUM ; i++) {
		if(!(strcmp(text, str_table[i]))) {
			strAppear = true;
			idx = i;
			break;
		}
	}

	if(!strAppear) {
		strcpy(str_table[++str_ptr], text);
		printf("<STRING, %d>\t\t%s\n", str_ptr, text);
	} else {
		printf("<STRING, %d>\t\t%s\n", idx, text);
	}
}

void censorInt(char** text) {
	int length = strlen(*text);
	/* 길이가 10 이상일 때는 나머지 cut */
	if(length > 10) *text += length - 10;
}

void censorSpec(char* text) {
	/* 개인적인 사용 빈도 수에 따라 상위에 배치 */
	if(text[0] == ';')			printf("<SEMICOLON>\t\t%s\n", text);
	else if(text[0] == '(')		printf("<LPAREN>\t\t%s\n", text);
	else if(text[0] == ')')		printf("<RPAREN>\t\t%s\n", text);
	else if(text[0] == '"')		printf("<DQUOTE>\t\t%s\n", text);
	else 						printf("<COMMA>\t\t%s\n", text);
}

void censorOper(char* text) {
	if(strlen(text) == 1) {
		if(text[0] == '=') 		printf("<ASSIGN>\t\t%s\n", text);
		else if(text[0] == '+')	printf("<PLUS>\t\t%s\n", text);
		else if(text[0] == '-') printf("<MINUS>\t\t%s\n", text);
		else if(text[0] == '*')	printf("<MULTI>\t\t%s\n", text);
		else					printf("<DIVIS>\t\t%s\n", text);
	} else {
		/* and, or, eq, gt는 keyword인가 operator인가? */
		if(!(strcmp(text, "and")))		printf("<AND>\t\t%s\n", text);
		else if(!(strcmp(text, "or")))	printf("<OR>\t\t%s\n", text);
		else if(!(strcmp(text, "eq")))	printf("<EQ>\t\t%s\n", text);
		else							printf("<GT>\t\t%s\n", text);
	}
}
