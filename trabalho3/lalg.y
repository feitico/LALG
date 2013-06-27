%{
	//#define YYSTYPE double
    #define YYDEBUG 1 /*For Debugging */

	#include <math.h>
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include "simbolTable.h"

    int yylex (void);
    void yyerror (char *);

    /* Contador de erros */
    int numerrors;

    /* Flag para continuar ou parar a execucao de codigo */
    int code_generate;

    /* Proxima posicao na memoria */
    int next_position;

    /* Arquivo onde sera armazenado o codigo */
    FILE *code_file;

    extern int num_lines;
    extern char *yytext;
	extern int column;

    /* Manipulacao da Tabela de simbolos */
    void addInTable( char *name, int type, int i_value, float f_value );

%}

%union YYSTYPE {
	int i_number;
	float r_number;
	char* name;
	int type;
    struct snode {
		int i_value;
		float f_value;
		int type;
	} snode;
	char math_op;
}

/* Token utilizado para verificar fim de arquivo */
%token T_EOF

/* Tokens do programa */
%token T_PROGRAM 	"program"
%token T_BEGIN 		"begin"
%token T_END 		"end"
%token T_VAR 		"var"
%token T_CONST 		"const"
%token T_REAL 		"real"
%token T_INTEGER 	"integer"
%token T_PROCEDURE 	"procedure"	
%token T_READ 		"read"
%token T_WRITE 		"write"
%token T_WHILE 		"while"
%token T_IF 		"if"
%token T_THEN 		"then"
%token T_ELSE 		"else"
%token T_FOR 		"for"
%token T_TO 		"to"
%token T_DO 		"do"
%token T_EQUAL 		"="
%token T_DIFF 		"<>"
%token T_GREATER_EQ 	">="
%token T_LESSER_EQ 	"<="
%token T_GREATER 	">"
%token T_LESSER 	"<"
%token T_PLUS 		"+"
%token T_MINUS 		"-"
%token T_TIMES 		"*" 		
%token T_DIVISION 	"/"
%token T_ASSIGN 	":="
%token T_SEMICOLON 	";"
%token T_COLON 		":"
%token T_L_PAREN 	"("
%token T_R_PAREN 	")"
%token T_COMMA 		","
%token T_DOT 		"."

/* Tokens para erros */
%token ERR_MF_INTEGER /* Número inteiro mal formado */
%token ERR_MF_REAL /* Número real mal formado */
%token ERR_MF_ID /* Identificador mal formado */
%token ERR_LONG_ID /* Identificador muito longo */
%token ERR_COMMENT /* Comentário não fechado */
%token ERR_UNKNOWN /* Simbolo não pertence a linguagem */      
/*%nonassoc error*/

/* Tipo terminais */
%token<name> T_ID /*"identificador"*/
%token<i_number> T_INUMBER /*"numero inteiro"*/
%token<r_number> T_RNUMBER /*"numero real"*/

/* Tipo dos nao terminais */
%type <snode> numero
%type <snode> fator
%type <math_op> op_mul
%type <snode> expressao
%type <snode> fator_exp

%%

/* Regras da gramatica */
/* Regra 1 <programa> ::= program ident ; <corpo> . */
programa : T_PROGRAM programa1 {}
	| error T_SEMICOLON { yyerror("program"); } corpo programa3
    | error { yyerror("program");} corpo programa3
    | error T_DOT { yyerror("program");}
    ;

programa1 : T_ID {} programa2 {}
    | error T_SEMICOLON { yyerror("id");} corpo programa3
    | error { yyerror("id"); } corpo programa3
    | error T_DOT { yyerror("id");}
    ;
    
programa2 : T_SEMICOLON corpo programa3 {}
    | error T_DOT { yyerror(";");}
    ;
    
programa3 : T_DOT {}
    | error { yyerror(".");}
    ;

/* Regra 2 <corpo> ::= <dc> begin <comandos> end */
corpo : dc T_BEGIN comandos corpo1 {}
    | dc error T_END { yyerror("begin"); }
    ;
    
corpo1 : T_END {}
    ;
    
/* Regra 3 <dc> ::= <dc_c> <dc_v> <dc_p> */
dc : dc_c dc_v dc_p {}
    ;

/* Regra 4 <dc_c> ::= const ident = <numero> ; <dc_c> | lambda */
dc_c : dc_c0 dc_c {}
    |
    ;

dc_c0 : T_CONST {} T_ID dc_c1 {}
    | T_CONST error T_EQUAL { yyerror("id"); } numero T_SEMICOLON
    | T_CONST error T_SEMICOLON { yyerror("id"); }
    ;

dc_c1 : T_EQUAL dc_c2 {}
    | error T_SEMICOLON { yyerror("="); }
    ;
    
dc_c2 : numero dc_c3 {}
    | error T_SEMICOLON { yyerror("numero"); }
    ;
    
dc_c3 : T_SEMICOLON {}
    | error { yyerror(";"); }
    ;

/* Regra 5 <dc_v> ::= var <variaveis> : <tipo_var> ; <dc_v> | lambda */
dc_v : dc_v0 dc_v {}
    |
    ;

dc_v0 : T_VAR variaveis T_COLON tipo_var dc_v1 {  }
    | T_VAR variaveis error T_SEMICOLON { yyerror(":"); }
    ;
    
dc_v1 : T_SEMICOLON {}
    | error { yyerror(";"); }
    ;

/* Regra 6 <tipo_var> ::= real | integer */
tipo_var : T_REAL {}
    | T_INTEGER {}
    | error { yyerror("tipo"); }
    ;

/* Regra 7 <variaveis> ::= ident <mais_var> */
variaveis : T_ID mais_var {}
    | error { yyclearin; yyerror("id"); } mais_var {}
    ;

/* Regra 8 <mais_var> ::= , <variaveis> | lambda */
mais_var : T_COMMA variaveis {}
    | /*lambda*/ {}
    ;

/* Regra 9 <dc_p> ::= procedure ident <parametros> ; <corpo_p> <dc_p> | lambda */
dc_p : dc_p0 {} dc_p
    |
    ;

dc_p0 : T_PROCEDURE {} T_ID parametros {} dc_p1
    | T_PROCEDURE error T_SEMICOLON { yyclearin; yyerror("id"); } corpo_p
    ;
   
dc_p1 : T_SEMICOLON corpo_p {}
    | error { yyclearin; yyerror(";"); } corpo_p
    ; 

/* Regra 10 <parametros> ::= ( <lista_par> ) | lambda */
parametros : T_L_PAREN lista_par T_R_PAREN {}
    | T_L_PAREN lista_par error { yyclearin; yyerror(")"); }
    | {}
    ;
    
/* Regra 11 <lista_par> ::= <variaveis> : <tipo_var> <mais_par> */
lista_par : variaveis T_COLON tipo_var mais_par {}
    ;

/* Regra 12 <mais_par> ::= ; <lista_par> | lambda */
mais_par : T_SEMICOLON lista_par {}
    | {}
    ;

/* Regra 13 <corpo_p> ::= <dc_loc> begin <comandos> end ; */
corpo_p : dc_loc T_BEGIN comandos corpo_p1 {}
    | dc_loc error T_END { yyerror("begin"); } corpo_p2
    | dc_loc error T_SEMICOLON { yyerror("begin"); }
    ;
    
corpo_p1 : T_END corpo_p2 {}
    | error T_SEMICOLON { yyerror("end"); }
    ;
    
corpo_p2 : T_SEMICOLON
    | error { yyerror(";"); }
    ;
    
/* Regra 14 <dc_loc> ::= <dc_v> */
dc_loc : dc_v
    ;

/* Regra 15 <lista_arg> ::= ( <argumentos> ) | lambda */
lista_arg : T_L_PAREN argumentos T_R_PAREN  {}
    | T_L_PAREN argumentos error { yyerror(")"); }
    | {}
    ;

/* Regra 16 <argumentos> ::= ident <mais_ident> */
argumentos : T_ID mais_ident {}
    | error { yyclearin; yyerror("id"); } mais_ident {}
    ;
    
/* Regra 17 <mais_ident> ::= ; <argumentos> | lambda */
mais_ident : T_SEMICOLON argumentos {}
    | {}
    ;
    
/* Regra 18 <pfalsa> ::= else <cmd> | lambda */
pfalsa : T_ELSE {} cmd
    | /* empty */ 
    ;

/* Regra 19 <comandos> ::= <cmd> ; <comandos> | lambda */
comandos : cmd T_SEMICOLON comandos
    | cmd error { yyclearin; yyerror(";"); } comandos
    | error T_SEMICOLON  { yyerror("cmd"); } comandos
    | /* empty */ 
    ;

/* Regra 20 <cmd> ::= read(<variaveis>) | write (<variaveis>) | while(<condicao>) do <cmd> |
| if <condicao> then <cmd> <pfalsa> | ident := <expressao> | ident <lista_arg> | begin <comandos> end | for <ATR> TO <expressao> do <cmd> */
cmd : T_READ {} cmd_param {}
    | T_WRITE {} cmd_param {}
    | T_IF {} cmd_if
    | T_ID {} T_ASSIGN expressao {}
    | T_ID {} lista_arg {}
    | T_BEGIN cmd_begin {}
    | T_WHILE {} cmd_while {}
    | T_FOR {} T_ID {} T_ASSIGN expressao T_TO expressao T_DO cmd {}
//	| error { yyclearin; yyerror("cmd"); }
    ;

cmd_param : T_L_PAREN variaveis T_R_PAREN {}
    ;

cmd_if : condicao T_THEN {} cmd pfalsa {}
    | condicao error {yyerror("then");} cmd pfalsa {}
    ;

cmd_begin : comandos T_END
    ;

cmd_while : T_L_PAREN condicao T_R_PAREN T_DO {} cmd {}
    | T_L_PAREN condicao T_R_PAREN error { yyerror("do") } cmd 
    ;

/* Regra 21 <condicao> ::= <expressao> <relacao> <expressao> */
condicao : expressao relacao expressao {}
    ;

/* Regra 22 <relacao> ::= = | <> | >= | <= | > | < */
relacao : T_EQUAL {}
    | T_DIFF {}
    | T_GREATER_EQ {}
    | T_LESSER_EQ {}
    | T_GREATER {}
    | T_LESSER {}
    | error { yyerror("sinal de relacao"); }
    ;
    
/* Regra 23 <expressao> ::= <termo> <outros_termos> */
expressao : termo outros_termos {}
    ;

/* Regra 24 <op_un> ::= + | - | lambda */
op_un : T_PLUS {}
    | T_MINUS {}
    | {}
    ;

/* Regra 25 <outros_termos> ::= <op_ad> <termo> <outros_termos> | lambda */
outros_termos : op_ad termo outros_termos {}
    | {}
    ;

/* Regra 26 <op_ad> ::= + | - */
op_ad : T_PLUS {}
    | T_MINUS {}
    ;

/* Regra 27 <termo> ::= <op_un> <fator> <mais_fatores> */
termo : op_un fator mais_fatores {}
    ;
    
/* Regra 28 <mais_fatores> ::= <op_mul> <fator> <mais_fatores> | lambda */
mais_fatores : op_mul fator mais_fatores { /*$$ = $1;
        if($3 == NULL) { $$->right = $2; }
        else { $3->left = $2; $$->right = $3; }*/ }
    | { /*$$ = NULL;*/ }
    ;    

/* Regra 29 <op_mul> ::= * | / */
op_mul : T_TIMES { /*$$ = new ExpressionTree;*/ /*$$->type = OPERATOR; $$->math_op = TIMES;*/ }
    | T_DIVISION { /*$$ = new ExpressionTree;*/ /*$$->type = OPERATOR; $$->math_op = DIVISION;*/ }
    ;

/* Regra 30 <fator> ::= ident | <numero> | ( <expressao> ) */
fator : T_ID 
        { 
            /* Verificando se o identificador foi declarado */
            Node* ident = find( $1 );
            if ( ident == NULL ) {
                code_generate = FALSE;
                fprintf (stderr, 
                "Erro Semantico: Linha %d, Coluna %d. Identificador %s nao declarado\n", 
                num_lines, column, $1);

                $$.type = INDEFINED;
            } else {
                $$.type = ident->type;
                /* buildReadMemory */
            }
        } 
    | numero 
        { 
            if($1.type == INTEGER) {
                $$.type = INTEGER;
                $$.i_value = $1.i_value;
            } else {
                $$.type = REAL;
                $$.i_value = $1.f_value;
            }
        }  
    | T_L_PAREN fator_exp { $$ = $2; }
    | error { yyclearin; yyerror("sinal de relacao"); /*$$ = new ExpressionTree;*/ /*$$->type = ERROR;*/ }
    ;

fator_exp
    : expressao T_R_PAREN { $$ = $1; }
    | expressao error { yyerror(")"); $$ = $1; }
    ;
    
/* Regra 31 <numero> ::= numero_int | numero_real */
numero : T_INUMBER { $$.type = INTEGER; $$.i_value = $1; }
    | T_RNUMBER { $$.type = REAL; $$.f_value = $1; }
    ;

%%

extern FILE *yyin;

int main (int argc, char *argv[])
{
#ifdef YYDEBUG
	yydebug=1;
#endif
   /*
   if(argc != 2) {
        printf("Uso: %s programa.lalg\n", argv[0]);
        return -1;
    }
*/
    FILE *entrada = fopen(argv[1], "r");
    if(!entrada) {
        printf("Nao foi possivel abrir o arquivo %s\n", argv[1]);
        return -1;
    }
    // Lex ira ler arquivo de entrada inves do STDIN
    yyin = entrada;

    /* Inicia a tabela de simbolos */
    init();

    /* Inicializando variaveis auxiliarer */
    numerrors = 0;
    code_generate = 1;
    next_position = 0;

    /* Abrindo o arquivo de codigo */
    code_file = fopen("code.p", "w");
    fprintf( code_file, "INPP\n");

    int res = yyparse();

    fclose( code_file );

    if(numerrors==0)
        printf ( "Analise Sintatica Completada\n" );
    else
        printf ( "Analise Sintatica Completada Com %d Erros\n", numerrors);

    /* Remove o arquivo, caso a geracao tenha parado */
    if (!code_generate)
        remove( "code.p");

    return res;
}

void yyerror (char *s)
{
    code_generate = 0;
    /*Descartamos as mensagens padrões "syntax error do Bison*/
    if(strcmp(s,"syntax error")){
        fprintf (stderr, 
        "Erro Sintatico: Linha %d, Coluna %d. Era esperado %s, encontrado: %s\n", 
        num_lines, column, s, yytext);
        numerrors++;
    } 
}
