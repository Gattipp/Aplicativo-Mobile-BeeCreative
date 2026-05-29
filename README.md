# 🎨 BeeCreative — Aplicativo de Desenho Livre

O **BeeCreative** é um aplicativo móvel funcional multiplataforma desenvolvido em **Flutter** para o Trabalho Final da disciplina de Desenvolvimento de Aplicativo Mobile. O projeto consiste em um canvas de desenho digital integrado que responde a eventos de toque em tempo real, permitindo ao usuário criar, customizar e exportar as suas ilustrações diretamente do dispositivo.

---

## 🚀 Funcionalidades Principais

### OBRIGATÓRIAS (Requisitos Mínimos)
* **✏️ Desenho Livre:** Criação de traços suaves na tela utilizando gestos e eventos de toque com o dedo (`GestureDetector` + `CustomPaint`).
* **🎨 Seleção de Cores:** Paleta interativa e seletor de cores completo (via `flutter_colorpicker`) para alterar o tom do pincel.
* **📏 Espessura do Pincel:** Ajuste dinâmico do tamanho e diâmetro do traço através de um controle deslizante (*Slider*).
* **🗑️ Limpar Tela:** Botão dedicado na barra superior para apagar instantaneamente todo o progresso do canvas e reiniciar o fundo.
* **💾 Salvar no Dispositivo:** Captura isolada da folha de desenho (renderização via `RepaintBoundary`), convertendo os traços em arquivo `.png` e exportando diretamente para a galeria nativa do aparelho.

### INOVAÇÕES (Diferenciais / Extras)
* **🌙 Modo Escuro (Dark Mode):** Alternância completa de tema (Claro/Escuro) na interface por meio de um botão de estado na barra superior, recalculando dinamicamente o fundo do canvas e adaptando as cores da borracha.
* **↩️ Desfazer e Refazer (Undo/Redo):** Histórico estruturado de ações que permite reverter ou restaurar traços anteriores com total precisão.
* **🧪 Conta-Gotas (Color Eyedropper):** Ferramenta avançada que lê a matriz de pixels do canvas por meio de chaves globais, permitindo ao usuário tocar em qualquer parte do desenho já feito para extrair e clonar a cor exata.

---

## 🛠️ Arquitetura e Estrutura de Pastas

O projeto adota uma arquitetura modular baseada em **Widgets e Utilitários (Helpers)** separados para garantir a legibilidade do código e o desacoplamento de lógica de UI:

```text
lib/
│
├── main.dart                  # Ponto de entrada do aplicativo e inicialização
│
├── models/
│   └── drawing_point.dart     # Definição das classes de modelo (traços, pontos e ferramentas)
│
├── utils/
│   ├── color_picker_helper.dart  # Lógica de captura de pixel da tela (Conta-Gotas)
│   └── image_saver_helper.dart   # Lógica nativa de exportação e arquivo (Salvar Desenho)
│
└── widgets/
    ├── drawing_canvas.dart    # Canvas principal, gestão de estado e árvore do Scaffold
    ├── drawing_painter.dart   # Classe CustomPainter responsável pela renderização dos traços
    └── tool_bar_widget.dart   # Painel inferior de seleção de ferramentas, cores e espessura
