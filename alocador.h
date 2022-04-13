#ifndef ALOCADOR_H
#define ALOCADOR_H

/**
 * @brief Inicializa alocador
 *
 * Executa a syscall brk para obter o o endereço do topo corrente da heap e o
 *      em uma variável global 'topoInicialHeap'
 */
void iniciaAlocador(void);

/**
 * @brief Finaliza alocador
 *
 * Executa syscall brk para restaurar o valor original da heap contido em
 *      'topoInicialHeap'
 */
void finalizaAlocador(void);

/**
 * @brief Aloca um bloco de `num_bytes`
 * 
 * 1. Procura um bloco livre com tamanho maior ou igual a `num_bytes`
 * 2. Se encontrar, indica que o bloco está ocupado e retorna o endereço
 *      inicial do bloco
 * 3. Se não encontrar, abre espaço para um novo bloco usando a syscall brk,
 *      indica que o bloco está ocupado e retorna o endereço inicial o bloco.
 * @param num_bytes quantidade de bytes a ser alocado
 * @return o endereço do novo bloco alocado 
 */
void *alocaMem(int num_bytes);

/**
 * @brief Libera o bloco de memória fornecido
 *
 * Indica se o bloco foi liberado ou não
 * @param bloco bloco a ser liberado
 * @return `1` para sucesso e `0` para falha
 */
int liberaMem(void *block);

#endif /* ALOCADOR_H */
