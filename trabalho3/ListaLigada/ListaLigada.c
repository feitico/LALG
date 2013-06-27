#include <stdio.h>
#include <stdlib.h>

#include "ListaLigada.h"

void criar(LISTA_LIGADA *lista) {
  lista->inicio = NULL;
  lista->fim = NULL;
}

int vazia(LISTA_LIGADA *lista) {
  return (lista->inicio == NULL);
}

void apagar_lista(LISTA_LIGADA *lista) {
  if (!vazia(lista)) {
    NO *paux = lista->inicio;

    while (paux != NULL) {
      NO *prem = paux;
      paux = paux->proximo;
      free(prem);
    }
  }

  lista->inicio = NULL;
  lista->fim = NULL;
}

void imprimir(LISTA_LIGADA *lista) {
  NO *paux = lista->inicio;

  while (paux != NULL) {
    printf("%d - %d\n", paux->item.chave, paux->item.valor);
    paux = paux->proximo;
  }
}

int buscar(LISTA_LIGADA *lista, int chave,  ITEM *item) {
  NO *paux = lista->inicio;

  while (paux != NULL) {
    if (paux->item.chave == chave) {
      *item = paux->item;
      return 1;
    }
    paux = paux->proximo;
  }

  return 0;
}

int inserir(LISTA_LIGADA *lista, ITEM *item) {
  //cria um novo n�
  NO *pnovo = (NO *)malloc(sizeof(NO));

  if (pnovo != NULL) { //verifica se a mem�ria foi alocada
    pnovo->item = *item; //preenche os dados
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

int remover_fim(LISTA_LIGADA *lista) {
  if (!vazia(lista)) {
    //procura o pen�ltimo n�
    NO *paux  = lista->inicio;
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

int remover_posicao(LISTA_LIGADA *lista, int pos) {
  int i;

  if (!vazia(lista)) { //verifica se a lista est� vazia
    if (pos == 0) { //removendo o primeiro n�
      if (lista->inicio == lista->fim) { //se a lista tem um n�
        lista->fim = NULL;
      }

      NO *paux = lista->inicio;
      lista->inicio = lista->inicio->proximo;
      free(paux);
    } else { //removendo do segundo n� para frente
      //aponta para o n� anterior a ser retirado
      NO *paux = lista->inicio;
      for (i = 0; i < pos-1; i++) {
        if (paux->proximo != lista->fim) {
          paux = paux->proximo;
        } else {
          return 0;
        }
      }

      NO *pos = paux->proximo;
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
