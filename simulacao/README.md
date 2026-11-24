# Simulações (MATLAB / Simulink)

Simulação do cálculo do ângulo do joelho com dois sensores inerciais (coxa e
tíbia), para medir o efeito de montagem, atraso entre sensores, taxa de
amostragem, perda de pacotes, ruído e deriva antes dos ensaios com hardware.

## Como começar

No MATLAB, com esta pasta (`simulacao/`) como pasta atual:

```matlab
setup_simulacao        % adiciona o path e lista o que o seu MATLAB tem
testar_quaternion      % confere as funções de quaternion
etapa1_modelo_ideal    % etapa 1 em script: gráficos e números
criar_modelo_etapa1    % etapa 1 no Simulink: gera, roda e abre os Scopes
```

## Organização

| Pasta | Conteúdo |
|---|---|
| `funcoes/quaternion/` | Operações com quaternions, espelhando `include/quat.h` do firmware |
| `funcoes/joelho/` | Calibração e cálculo do ângulo, iguais ao firmware (`04_joelho.cpp`) |
| `funcoes/cenario/` | Geradores de movimento da perna e dos sensores virtuais |
| `etapas/` | Um script por etapa do roteiro, com gráficos e números |
| `testes/` | Scripts que conferem as funções contra resultados conhecidos |
| `modelos/` | Scripts que geram os modelos Simulink (`.slx`). Edite o script, não o `.slx` |
| `resultados/` | Figuras e tabelas geradas (os `.mat` não vão para o git) |

## Convenções

- Quaternion como vetor linha `[w x y z]`, produto de Hamilton, igual ao firmware.
- Séries temporais como matrizes `Nx4` (uma amostra por linha). Todas as funções
  aceitam `1x4` ou `Nx4`.
- Ângulos em graus nas entradas e saídas das funções.
- Só MATLAB base nas funções: nada depende de toolbox, e o código pode ser
  chamado dentro de blocos *MATLAB Function* do Simulink.

## Diferença conhecida em relação ao firmware

`q_twist_deg` leva o quaternion ao hemisfério `w >= 0` antes de calcular o
ângulo. O `qTwistDeg()` atual do firmware não faz isso, e um quaternion com
`w < 0` (mesma rotação, sinal oposto) dá -330° em vez de +30°. O teste 7 de
`testar_quaternion` mostra o caso. A correção deve ser levada ao firmware.

## Roteiro

0. Ambiente e funções base (feita)
1. Modelo ideal: perna rígida, montagens arbitrárias, erro esperado zero (feita)
2. Desalinhamento de montagem do sensor
3. Atraso entre sensores (define o requisito de sincronia)
4. Taxa de amostragem e perda de pacotes
5. Ruído e deriva
6. Figuras e tabelas para o documento
