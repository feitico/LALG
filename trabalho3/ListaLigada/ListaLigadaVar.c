#include <stdio.h>
#include <stdlib.h>

#include "ListaLigadaVar.h"

void llvar_criar(ListaLigadaVar *lista) {
  lista->inicio = NULL;
  lista->fim = NULL;
}

int llvar_vazia(ListaLigadaVar *lista) {
  return (lista->inicio == NULL);
}

void llvar_apagar_lista(ListaLigadaVar *lista) {
  if (!llvar_vazia(lista)) {
    NoVar *paux = lista->inicio;

    while (paux != NULL) {
      NoVar *prem = paux;
      paux = paux->proximo;
      free(prem);
    }
  }

  lista->inicio = NULL;
  lista->fim = NULL;
}

void llvar_imprimir(ListaLigadaVar *lista) {
  NoVar *paux = lista->inicio;

  while (paux != NULL) {
    printf("%s - %d\n", paux->variable.name, paux->variable.type);
    paux = paux->proximo;
  }
}

int llvar_buscar(ListaLigadaVar *lista, char* name, Variable *variable) {
  NoVar *paux = lista->inicio;

  while (paux != NULL) {
    if (strcmp(paux->variable.name,name) == 0) {
      *variable = paux->variable;
      return 1;
    }
    paux = paux->proximo;
  }

  return 0;
}

int llvar_inserir(ListaLigadaVar *lista, Variable *variable) {
  //cria um novo n�
  NoVar *pnovo = (NoVar *)malloc(sizeof(NoVar));

  if (pnovo != NULL) { //verifica se a mem�ria foi alocada
    pnovo->variable = *variable; //preenche os dados
    pnovo->proximo = NULL; //define que o pr�ximo � nulo

    if (lista->inicio == NULL) { //se a lista for vazia
      lista->inicio = pnovo; //inicio aponta para novo
    } else {
      lista->fim->proximo = pnovo; //proximo do fim aponto para novo
    }

    lista->fim = pnovo; //fim aponta para novo

    return 1;
  } else {
    return 0;
  }
}

int llvar_remover_fim(ListaLigadaVar *lista) {
  if (!llvar_vazia(lista)) {
    //procura o pen�ltimo n�
    NoVar *paux  = lista->inicio;
    while (paux->proximo != NULL && paux->proximo != lista->fim) {
      paux = paux->proximo;
    }

    if (lista->inicio == lista->fim) {//a lista tem um n�
      free(paux->proximo); //libera o �nico n�
      lista->inicio = lista->fim = NULL; //lista vazia
    } else {
      free(lista->fim); //libera �ltimo n�
      lista->fim = paux; //pen�ltimo n� vira �ltimo
      lista->fim->proximo = NULL;
    }

    return 1;
  } else {
    return 0;
  }
}

int llvar_remover_posicao(ListaLigadaVar *lista, int pos) {
  int i;

  if (!llvar_vazia(lista)) { //verifica se a lista est� vazia
    if (pos == 0) { //removendo o primeiro n�
      if (lista->inicio == lista->fim) { //se a lista tem um n�
        lista->fim = NULL;
      }

      NoVar *paux = lista->inicio;
      lista->inicio = lista->inicio->proximo;
      free(paux);
    } else { //removendo do segundo n� para frente
      //aponta para o n� anterior a ser retirado
      NoVar *paux = lista->inicio;
      for (i = 0; i < pos-1; i++) {
        if (paux->proximo != lista->fim) {
          paux = paux->proximo;
        } else {
          return 0;
        }
      }

      NoVar *pos = paux->proximo;
      paux->proximo = paux->proximo->proximo;

      if (pos->proximo == NULL) { //�ltimo n� retirado
        lista->fim = paux;
      }

      free(pos);
    }
    return 1;
  } else {
    return 0;
  }
}
