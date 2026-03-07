# 04 - UI/UX Design

> Interface que equilibra a informação vital (recursos, fogo) com a imersão tribal do gameplay.

---

## 1. Layout Principal (HUD)

### Estrutura da Tela

```
┌─────────────────────────────────┐
│  🪵 1.2K   🍖 850   ⛏️ 2.1K    │ ← Recursos (topo, sempre visível)
│  ████████████░░░░  🔥 67%       │ ← Barra de Fogo (vital)
├─────────────────────────────────┤
│                                 │
│        [FLAME CANVAS]           │ ← Mundo do jogo (isométrico)
│                                 │
│   ┌─────┐  ┌─────┐  ┌─────┐   │
│   │Zona1│  │Zona2│  │Zona3│   │ ← Zonas de Trabalho
│   │ Lv5 │  │ Lv3 │  │ 🔒  │   │
│   └─────┘  └─────┘  └─────┘   │
│                                 │
│        🔥 Fogueira Central      │
│                                 │
├─────────────────────────────────┤
│  [⬆ Upgrade] [👤 Gerentes] [⚙] │ ← Nav Bar (bottom)
└─────────────────────────────────┘
```

### Camadas de UI

| Layer | Tecnologia | Conteúdo |
|-------|-----------|----------|
| **Background** | Flame Canvas | Parallax (céu, montanhas) |
| **Gameplay** | Flame Canvas | Zonas, NPCs, Fogueira |
| **HUD** | Flutter Overlay | Recursos, Barra de Fogo |
| **Nav** | Flutter Overlay | Botões de ação (bottom) |
| **Modals** | Flutter Overlay | Menus, Shop, Settings |

---

## 2. Barra de Fogo (Elemento Central)

### Estados Visuais

| Estado | Visual | Áudio |
|--------|--------|-------|
| **Cheio (80-100%)** | Barra verde/azul, estável | Crepitar suave |
| **Normal (40-79%)** | Barra laranja, leve pulso | Crepitar normal |
| **Baixo (20-39%)** | Barra vermelha, pulso forte | Alarme sutil |
| **Crítico (1-19%)** | Barra vermelha piscante, screen tint | Tambor de alarme |
| **Apagado (0%)** | Barra vazia, tela escurece | Silêncio + vento |

### Feedback ao Restaurar

1. Flash branco na tela (200ms)
2. Barra enche com animação smooth
3. Som tribal festivo
4. Vibração háptica (se disponível)

---

## 3. Zonas de Trabalho (Cards)

### Card de Zona

```
┌─────────────────────┐
│  🏚️ Pedreira          │
│  Nível: 5            │
│  Produção: 12/s      │
│  👤 Ugh (+25%)       │
│                      │
│  [⬆ Upgrade: 1.2K 🪨]│
└─────────────────────┘
```

### Interações

| Gesto | Ação |
|-------|------|
| **Tap na zona** | Abre painel de detalhes |
| **Tap no upgrade** | Compra upgrade (se tem recursos) |
| **Long press** | Informações detalhadas |
| **Swipe horizontal** | Navegar entre zonas (scroll) |

### Feedback de Upgrade

1. Botão faz **squash & stretch** (100ms compress, 200ms bounce back)
2. Número de nível anima (+1 com scale up)
3. Floating text com recurso gasto (-1.2K 🪨)
4. NPCs na zona aceleram momentaneamente

---

## 4. Contadores de Recursos (Topo)

### Design dos Contadores

```
  ┌──────────────┐
  │  🪵  1.2K    │ ← Ícone + Valor formatado
  │  +12/s       │ ← Taxa de produção (menor, sutil)
  └──────────────┘
```

### Animações

| Evento | Animação |
|--------|----------|
| **Recurso ganho** | Número sobe e volta (bump) |
| **Recurso gasto** | Flash vermelho momentâneo |
| **Suficiente para compra** | Ícone brilha suavemente |
| **Insuficiente** | Ícone fica opaco |

---

## 5. NPCs (Visual Feedback de Progresso)

### Escala Visual por Nível

| Nível da Zona | NPC Aparência |
|---------------|---------------|
| 1-5 | Cesta pequena, andar lento |
| 6-15 | Cesta média, andar normal |
| 16-30 | Cesta grande, andar rápido |
| 31+ | Carroça, correndo |

### Animações de NPC

- **Idle:** Respiração sutil (4 frames, 8 FPS)
- **Caminhando:** Walk cycle (6 frames, 12 FPS)
- **Coletando:** Animação de coleta (4 frames)
- **Entregando:** Caminhando com cesta (sprites maiores)

---

## 6. Navegação (Bottom Bar)

### Botões Principais

| Botão | Ação | Overlay |
|-------|------|---------|
| **⬆ Upgrade** | Abre painel de upgrades de zonas | `upgrade_menu` |
| **👤 Gerentes** | Gerenciamento de gerentes | `manager_menu` |
| **🏆 Missões** | Missões diárias e eventos | `missions_menu` |
| **⚙ Config** | Configurações e som | `settings` |

### Princípios de Navegação

- Bottom bar **sempre visível** (não esconde)
- Touch targets mínimo **44x44 points**
- Haptic feedback ao tocar
- Badge de notificação para novas missões/gerentes

---

## 7. Overlays e Modais

### Hierarquia de Overlays

| Prioridade | Overlay | Sobre outros? |
|------------|---------|---------------|
| 1 (base) | HUD + Nav Bar | Sempre ativo |
| 2 | Painel de zona | Sobre HUD |
| 3 | Shop / Gerentes | Modal sobre tudo |
| 4 | Pause / Settings | Bloqueia gameplay |
| 5 | Ad / Offline | Prioridade máxima |

### Transições

- **Abrir modal:** Slide up + backdrop fade (300ms)
- **Fechar modal:** Slide down (200ms)
- **Trocar tab:** Cross-fade (150ms)

---

## 8. Acessibilidade e Responsividade

### Requisitos de Acessibilidade

| Item | Implementação |
|------|--------------|
| **Contraste** | Texto com contraste mínimo 4.5:1 |
| **Touch targets** | Mínimo 44x44 pts |
| **Sem dependência de cor** | Usar ícones + texto além de cor |
| **Font scaling** | Respeitar font size do sistema |
| **Safe area** | Não cobrir notch/camera |

### Responsividade

| Tela | Adaptação |
|------|-----------|
| **< 375px** | HUD compacto, 1 coluna de zonas |
| **375-414px** | HUD normal, 2 colunas |
| **> 414px** | HUD expandido, info extra visível |
| **Tablet** | HUD lateral, mais zonas visíveis |

---

## 9. Anti-Patterns de UI/UX

| ❌ Don't | ✅ Do |
|----------|-------|
| Desenhar UI complexa no Canvas | Usar Flutter overlays |
| Botões menores que 44x44 | Touch targets generosos |
| HUD cobrindo gameplay | Áreas bem definidas |
| Modais sem backdrop | Backdrop + tap to dismiss |
| Ignorar safe area | SafeArea em todos os overlays |
| Feedback silencioso em ações | Animação + som + háptico |