# The Atelier

Agent-native task management for creative teams. Built for Every.to's design team.

## What is this?

The Atelier is an AI-powered design team management tool with three views:

- **Manager** — Command center with AI chat + live task board
- **Designer** — Focus mode with primary task, interruptions, and AI coaching
- **Requester** — AI intake interview + full queue visibility

## Core Concepts

- **Primary/Interruption model**: Each designer gets 1 primary task + max 2 interruptions per week
- **80% copy gate**: Requesters must have copy ready before design work begins
- **AI intake**: The requester chat interviews people, creates task cards with auto-generated checklists
- **Person-based**: No ticket numbers — the system knows who you are

## Design

Claude.ai-inspired aesthetic: warm beige, white cards, terracotta accent, Inter + Playfair Display typography. Minimal and restrained.

## Tech

Single HTML file with inline CSS and JavaScript. Uses Claude API (Sonnet) for all AI interactions. No build step, no dependencies beyond CDN links (Lucide icons, Google Fonts).

## Live

[taskflow-every.surge.sh](https://taskflow-every.surge.sh)
