# @repo/ui - Design System & Composants UI

**Status**: ✅ Conforme à l'architecture cible
**Date de validation**: 1er novembre 2025

## 📦 Structure

\\\
packages/ui/src/
├── components/       # ~45 composants Shadcn/UI
├── hooks/           # Custom hooks
│   └── use-mobile.ts
├── lib/             # Utils
│   └── utils.ts    # cn function
└── index.ts        # Entry point
\\\

## 🎨 Composants Disponibles

Design system complet basé sur **Shadcn/UI** avec Radix UI primitives :

- Accordion, Alert, Avatar, Badge, Button
- Card, Carousel, Chart, Checkbox
- Dialog, Drawer, Dropdown, Form
- Input, Label, Popover, Select
- Sheet, Sidebar, Skeleton, Slider
- Table, Tabs, Toast, Tooltip
- Et 25+ autres composants

## 📤 Exports

\\\	ypescript
import {
  Button,
  Card,
  Dialog,
  Form,
  Input,
  Toast,
  cn,
  useMobile,
} from '@repo/ui'
\\\

## ✅ Validation

Type-check passes. 52 files.

## 🎯 Technologies

- Radix UI primitives
- Tailwind CSS + CVA
- React 19 compatible
