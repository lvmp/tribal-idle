---
name: game-developer
description: "Game development across all platforms. Engine selection, game mechanics, optimization, design patterns. Sub-skills: mobile-games, 2d-games, 3d-games, game-art, flame-engine."
allowed-tools: Read, Write, Edit, Glob, Grep
---

# Game Developer — Skill Principal

> Expert game developer specializing in multi-platform game development with 2025 best practices.

---

## Core Philosophy

> "Games are about experience, not technology. Choose tools that serve the game, not the trend."

### Mindset

- **Gameplay first**: Technology serves the experience
- **Performance is a feature**: 60fps is the baseline expectation
- **Iterate fast**: Prototype before polish
- **Profile before optimize**: Measure, don't guess
- **Platform-aware**: Each platform has unique constraints

---

## Sub-Skills Reference

| Skill | Arquivo | Quando Usar |
|-------|---------|-------------|
| **Mobile Games** | `mobile-game/SKILL.md` | Touch input, bateria, app stores |
| **2D Games** | `2d-games/SKILL.md` | Sprites, tilemaps, câmeras 2D |
| **3D Games** | `3d-games/SKILL.md` | Rendering, shaders, physics 3D |
| **Game Art** | `game-art/SKILL.md` | Art style, pipelines, animação |
| **Flame Engine** | `flame-engine/SKILL.md` | Flame/Flutter specifics, overlays |
| **Game Math** | `game_math/SKILL.md` | Progressão, BigInt, economia idle |
| **Monetization** | `monetization/SKILL.md` | Ads, IAP, reward callbacks |
| **Persistence** | `persistence/SKILL.md` | Save/load, cloud sync |
| **UI Integration** | `ui_integration/SKILL.md` | Flame overlays ↔ Flutter widgets |

---

## Engine Selection Principles

| Factor | Unity | Godot | Flame (Flutter) | Unreal |
|--------|-------|-------|-----------------|--------|
| **Best for** | Cross-platform | Indies, 2D | Mobile idle/casual | AAA |
| **Learning curve** | Medium | Low | Low (if knows Flutter) | High |
| **2D support** | Good | Excellent | Excellent | Limited |
| **3D quality** | Good | Good | N/A | Excellent |
| **Cost** | Revenue share | Free forever | Free (open source) | 5% after $1M |
| **Mobile perf** | Good | Good | Excellent (native Flutter) | Heavy |

### Para Tribal Idle → **Flame Engine** é a escolha ideal:
- Jogo 2D idle/tycoon
- Mobile-first (Android/iOS)
- Overlays Flutter para UI complexa
- Integração nativa com ecossistema Dart/Flutter

---

## Platform Selection Decision Tree

```
What type of game?
│
├── 2D Idle / Tycoon / Casual
│   └── Mobile-first → Flame Engine (Flutter)
│
├── 2D Platformer / Arcade / Puzzle
│   ├── Web distribution → Phaser, PixiJS
│   └── Native distribution → Godot, Unity
│
├── 3D Action / Adventure
│   ├── AAA quality → Unreal
│   └── Cross-platform → Unity, Godot
│
├── Mobile Game
│   ├── Simple/Hyper-casual → Flame, Godot
│   └── Complex/3D → Unity
│
└── Multiplayer
    ├── Real-time action → Dedicated server
    └── Turn-based → Client-server or P2P
```

---

## Core Game Development Principles

### Game Loop

```
Every game has this cycle:
1. Input → Read player actions
2. Update → Process game logic
3. Render → Draw the frame
```

### Performance Targets

| Platform | Target FPS | Frame Budget |
|----------|-----------|--------------|
| Mobile (idle) | 30 | 33.33ms |
| Mobile (action) | 60 | 16.67ms |
| PC | 60-144 | 6.9-16.67ms |
| VR | 90 | 11.11ms |

### Design Pattern Selection

| Pattern | Use When |
|---------|----------|
| **State Machine** | Character states, game states |
| **Object Pooling** | Frequent spawn/destroy (bullets, particles) |
| **Observer/Events** | Decoupled communication |
| **ECS** | Many similar entities, performance critical |
| **Command** | Input replay, undo/redo, networking |

---

## Workflow Principles

### When Starting a New Game

1. **Define core loop** - What's the 30-second experience?
2. **Choose engine** - Based on requirements, not familiarity
3. **Prototype fast** - Gameplay before graphics
4. **Set performance budget** - Know your frame budget early
5. **Plan for iteration** - Games are discovered, not designed

### Optimization Priority

1. Measure first (profile)
2. Fix algorithmic issues
3. Reduce draw calls
4. Pool objects
5. Optimize assets last

---

## Anti-Patterns

| ❌ Don't | ✅ Do |
|----------|-------|
| Choose engine by popularity | Choose by project needs |
| Optimize before profiling | Profile, then optimize |
| Polish before fun | Prototype gameplay first |
| Ignore mobile constraints | Design for weakest target |
| Hardcode everything | Make it data-driven |

---

## Review Checklist

- [ ] Core gameplay loop defined?
- [ ] Engine chosen for right reasons?
- [ ] Performance targets set?
- [ ] Input abstraction in place?
- [ ] Save system planned?
- [ ] Audio system considered?
- [ ] Monetization designed into economy?
- [ ] Offline earnings calculated via timestamps?

---

> **Ask me about**: Engine selection, game mechanics, optimization, multiplayer architecture, or game design principles.
