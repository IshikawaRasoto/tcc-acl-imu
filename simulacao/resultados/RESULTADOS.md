# Registro de resultados das simulações

Cada etapa registra aqui o que foi rodado, quando e o que deu. As figuras
ficam nesta mesma pasta.

## Etapa 1: modelo ideal (20/11/2026)

**Objetivo:** conferir que o algoritmo do ângulo (calibração com a perna
estendida + decomposição swing-twist, igual ao firmware) reproduz a flexão de
referência quando não há nenhuma fonte de erro.

**Cenário:** perna rígida, joelho em dobradiça ideal, flexão de 0 a 120° em
dois ciclos de 5 s, coxa se movendo em 3D (quadril ±30°, abdução ±10°, giro
±45°), 100 Hz, 12 s, sensores em montagens sorteadas e quaternions com sinal
sorteado (q ou -q). Os dois sensores usam o mesmo referencial de mundo.

**Como reproduzir:** `etapa1_modelo_ideal` (script) e `criar_modelo_etapa1`
(Simulink), com `rng(1)`.

| Ensaio | Resultado |
|---|---|
| Script, ensaio de 12 s | RMSE 1,84e-14°, erro máximo 5,68e-14° |
| Script, 300 montagens sorteadas por eixo (X, Y, Z) | erro máximo 1,42e-13° |
| Simulink, mesmo ensaio | erro dentro de ±6e-14° (Scope) |
| Fórmula atual do firmware (sem correção de sinal) | 596 de 1201 amostras com erro > 1° |

**Conclusão:** o erro é só arredondamento de ponto flutuante (ordem de
1e-14°), então a matemática do algoritmo está correta. A fórmula do firmware
precisa da correção de hemisfério antes dos ensaios com hardware.

Figuras: `etapa1_ensaio.png` (script) e `etapa1_simulink_scopes.png` (Scopes).
