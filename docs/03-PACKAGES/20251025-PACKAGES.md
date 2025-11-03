# 📦 Documentation des Packages Migrés
## Monorepo blancherenaudin

*Généré automatiquement le 25/10/2025 14:19*

---


# 🎯 Packages Core

## 📦 @repo/database

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - client-admin.ts
            - client-browser.ts
            - client-server.ts
            - index.ts
            - types.ts
```n
### 📤 Exports

```typescript
// Export types
export * from "./types"
// Export clients
export { createBrowserClient } from "./client-browser"
export { createServerClient } from "./client-server"
export { supabaseAdmin } from "./client-admin"
// Re-export sous un alias plus cohérent
export { supabaseAdmin as createAdminClient } from "./client-admin"
```n
### 📚 Dépendances

- **@supabase/ssr:** ^0.5.2
- **@supabase/supabase-js:** ^2.47.10

---

## 📦 @repo/auth

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - index.ts
            - requireAdmin.ts
            - types.ts
```n
### 📤 Exports

```typescript
export { requireAdmin } from './requireAdmin'
```n
### 📚 Dépendances

- **@repo/database:** workspace:*
- **@supabase/ssr:** ^0.5.2
- **@supabase/supabase-js:** ^2.47.10
- **next:** ^15.1.6

---

## 📦 @repo/sanity

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - config.ts
            - index.ts
            - lib/
              - client.ts
              - image-helpers.ts
              - queries.ts
            - schemas/
              - index.ts
              - types/
                - blockContent.ts
                - collectionEditoriale.ts
                - homepage.ts
                - impactPage.ts
                - lookbook.ts
                - page.ts
                - seo.ts
            - structure.ts
```n
### 📤 Exports

```typescript
export * from './config'
export * from './structure'
export * from './schemas'
// Exports des lib
export * from './lib/client'
export * from './lib/queries'
export * from './lib/image-helpers'
// Exports nommés
export { client, client as sanityClient } from './lib/client'
export { urlFor } from './lib/image-helpers'
```n
### 📚 Dépendances

- **@sanity/client:** ^7.12.0
- **@sanity/image-url:** ^1.0.2
- **@sanity/vision:** ^4.11.0
- **next-sanity:** ^9.0.0
- **sanity:** ^3.0.0

---

# 🎨 UI & Utils

## 📦 @repo/ui

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - components/
              - accordion.tsx
              - alert.tsx
              - alert-dialog.tsx
              - aspect-ratio.tsx
              - avatar.tsx
              - badge.tsx
              - breadcrumb.tsx
              - button.tsx
              - calendar.tsx
              - card.tsx
              - carousel.tsx
              - chart.tsx
              - checkbox.tsx
              - collapsible.tsx
              - command.tsx
              - context-menu.tsx
              - dialog.tsx
              - drawer.tsx
              - dropdown-menu.tsx
              - form.tsx
              - hover-card.tsx
              - input.tsx
              - input-otp.tsx
              - label.tsx
              - menubar.tsx
              - navigation-menu.tsx
              - pagination.tsx
              - popover.tsx
              - progress.tsx
              - radio-group.tsx
              - resizable.tsx
              - scroll-area.tsx
              - select.tsx
              - separator.tsx
              - sheet.tsx
              - sidebar.tsx
              - skeleton.tsx
              - slider.tsx
              - sonner.tsx
              - switch.tsx
              - table.tsx
              - tabs.tsx
              - textarea.tsx
              - toast.tsx
              - toaster.tsx
              - toggle.tsx
              - toggle-group.tsx
              - tooltip.tsx
            - hooks/
              - use-mobile.ts
              - use-toast.ts
            - index.ts
            - lib/
              - utils.ts
```n
### 📤 Exports

```typescript
export { useMobile } from "./hooks/use-mobile"
export { cn } from "./lib/utils"
// Components - Auto-generated exports
export { Accordion, AccordionContent, AccordionItem, AccordionTrigger } from "./components/accordion"
export { Alert, AlertDescription, AlertTitle } from "./components/alert"
export { AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent, AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogOverlay, AlertDialogPortal, AlertDialogTitle, AlertDialogTrigger } from "./components/alert-dialog"
export { AspectRatio } from "./components/aspect-ratio"
export { Avatar, AvatarFallback, AvatarImage } from "./components/avatar"
export { Badge, badgeVariants } from "./components/badge"
export { Breadcrumb, BreadcrumbEllipsis, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbPage, BreadcrumbSeparator } from "./components/breadcrumb"
export { Button, buttonVariants } from "./components/button"
export { Calendar } from "./components/calendar"
export { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "./components/card"
export { Carousel, CarouselContent, CarouselItem, CarouselNext, CarouselPrevious, type CarouselApi } from "./components/carousel"
export { ChartContainer, ChartLegend, ChartLegendContent, ChartTooltip, ChartTooltipContent, type ChartConfig } from "./components/chart"
export { Checkbox } from "./components/checkbox"
export { Collapsible, CollapsibleContent, CollapsibleTrigger } from "./components/collapsible"
export { Command, CommandDialog, CommandEmpty, CommandGroup, CommandInput, CommandItem, CommandList, CommandSeparator, CommandShortcut } from "./components/command"
export { ContextMenu, ContextMenuCheckboxItem, ContextMenuContent, ContextMenuGroup, ContextMenuItem, ContextMenuLabel, ContextMenuPortal, ContextMenuRadioGroup, ContextMenuRadioItem, ContextMenuSeparator, ContextMenuShortcut, ContextMenuSub, ContextMenuSubContent, ContextMenuSubTrigger, ContextMenuTrigger } from "./components/context-menu"
export { Dialog, DialogClose, DialogContent, DialogDescription, DialogFooter, DialogHeader, DialogOverlay, DialogPortal, DialogTitle, DialogTrigger } from "./components/dialog"
export { Drawer, DrawerClose, DrawerContent, DrawerDescription, DrawerFooter, DrawerHeader, DrawerOverlay, DrawerPortal, DrawerTitle, DrawerTrigger } from "./components/drawer"
export { DropdownMenu, DropdownMenuCheckboxItem, DropdownMenuContent, DropdownMenuGroup, DropdownMenuItem, DropdownMenuLabel, DropdownMenuPortal, DropdownMenuRadioGroup, DropdownMenuRadioItem, DropdownMenuSeparator, DropdownMenuShortcut, DropdownMenuSub, DropdownMenuSubContent, DropdownMenuSubTrigger, DropdownMenuTrigger } from "./components/dropdown-menu"
export { Form, FormControl, FormDescription, FormField, FormItem, FormLabel, FormMessage, useFormField } from "./components/form"
export { HoverCard, HoverCardContent, HoverCardTrigger } from "./components/hover-card"
export { Input } from "./components/input"
export { InputOTP, InputOTPGroup, InputOTPSeparator, InputOTPSlot } from "./components/input-otp"
export { Label } from "./components/label"
export { Menubar, MenubarCheckboxItem, MenubarContent, MenubarGroup, MenubarItem, MenubarLabel, MenubarMenu, MenubarPortal, MenubarRadioGroup, MenubarRadioItem, MenubarSeparator, MenubarShortcut, MenubarSub, MenubarSubContent, MenubarSubTrigger, MenubarTrigger } from "./components/menubar"
export { NavigationMenu, NavigationMenuContent, NavigationMenuIndicator, NavigationMenuItem, NavigationMenuLink, NavigationMenuList, NavigationMenuTrigger, NavigationMenuViewport, navigationMenuTriggerStyle } from "./components/navigation-menu"
export { Pagination, PaginationContent, PaginationEllipsis, PaginationItem, PaginationLink, PaginationNext, PaginationPrevious } from "./components/pagination"
export { Popover, PopoverContent, PopoverTrigger } from "./components/popover"
export { Progress } from "./components/progress"
export { RadioGroup, RadioGroupItem } from "./components/radio-group"
export { ResizableHandle, ResizablePanel, ResizablePanelGroup } from "./components/resizable"
export { ScrollArea, ScrollBar } from "./components/scroll-area"
export { Select, SelectContent, SelectGroup, SelectItem, SelectLabel, SelectScrollDownButton, SelectScrollUpButton, SelectSeparator, SelectTrigger, SelectValue } from "./components/select"
export { Separator } from "./components/separator"
export { Sheet, SheetClose, SheetContent, SheetDescription, SheetFooter, SheetHeader, SheetOverlay, SheetPortal, SheetTitle, SheetTrigger } from "./components/sheet"
export { Sidebar, SidebarContent, SidebarFooter, SidebarGroup, SidebarGroupAction, SidebarGroupContent, SidebarGroupLabel, SidebarHeader, SidebarInput, SidebarInset, SidebarMenu, SidebarMenuAction, SidebarMenuBadge, SidebarMenuButton, SidebarMenuItem, SidebarMenuSkeleton, SidebarMenuSub, SidebarMenuSubButton, SidebarMenuSubItem, SidebarProvider, SidebarRail, SidebarSeparator, SidebarTrigger, useSidebar } from "./components/sidebar"
export { Skeleton } from "./components/skeleton"
export { Slider } from "./components/slider"
export { Toaster as Sonner } from "./components/sonner"
export { Switch } from "./components/switch"
export { Table, TableBody, TableCaption, TableCell, TableFooter, TableHead, TableHeader, TableRow } from "./components/table"
export { Tabs, TabsContent, TabsList, TabsTrigger } from "./components/tabs"
export { Textarea } from "./components/textarea"
export { Toast, ToastAction, ToastClose, ToastDescription, ToastProvider, ToastTitle, ToastViewport } from "./components/toast"
export { Toaster } from "./components/toaster"
export { Toggle, toggleVariants } from "./components/toggle"
export { ToggleGroup, ToggleGroupItem } from "./components/toggle-group"
export { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "./components/tooltip"
export { useToast, toast } from "./hooks/use-toast"
```n
### 📚 Dépendances

- **@radix-ui/react-accordion:** ^1.2.2
- **@radix-ui/react-alert-dialog:** ^1.1.4
- **@radix-ui/react-aspect-ratio:** ^1.1.1
- **@radix-ui/react-avatar:** ^1.1.2
- **@radix-ui/react-checkbox:** ^1.1.3
- **@radix-ui/react-collapsible:** ^1.1.2
- **@radix-ui/react-context-menu:** ^2.2.4
- **@radix-ui/react-dialog:** ^1.1.4
- **@radix-ui/react-dropdown-menu:** ^2.1.4
- **@radix-ui/react-hover-card:** ^1.1.4
- **@radix-ui/react-label:** ^2.1.1
- **@radix-ui/react-menubar:** ^1.1.4
- **@radix-ui/react-navigation-menu:** ^1.2.3
- **@radix-ui/react-popover:** ^1.1.4
- **@radix-ui/react-progress:** ^1.1.1
- **@radix-ui/react-radio-group:** ^1.2.2
- **@radix-ui/react-scroll-area:** ^1.2.2
- **@radix-ui/react-select:** ^2.1.4
- **@radix-ui/react-separator:** ^1.1.1
- **@radix-ui/react-slider:** ^1.2.2
- **@radix-ui/react-slot:** ^1.1.1
- **@radix-ui/react-switch:** ^1.1.2
- **@radix-ui/react-tabs:** ^1.1.2
- **@radix-ui/react-toast:** ^1.2.4
- **@radix-ui/react-toggle:** ^1.1.1
- **@radix-ui/react-toggle-group:** ^1.1.1
- **@radix-ui/react-tooltip:** ^1.1.6
- **class-variance-authority:** ^0.7.1
- **clsx:** ^2.1.1
- **cmdk:** ^1.0.4
- **date-fns:** ^3.6.0
- **embla-carousel-react:** ^8.5.2
- **input-otp:** ^1.4.1
- **lucide-react:** ^0.468.0
- **next-themes:** ^0.4.4
- **react-day-picker:** ^9.4.3
- **react-resizable-panels:** ^2.1.7
- **recharts:** ^2.15.0
- **sonner:** ^1.7.3
- **tailwind-merge:** ^2.6.0
- **tailwindcss-animate:** ^1.0.7
- **vaul:** ^1.1.2
- **react-hook-form:** ^7.54.2

---

## 📦 @repo/utils

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - formatters.ts
            - images.ts
            - index.ts
            - validators.ts
```n
### 📤 Exports

```typescript
export * from "./formatters"
export * from "./validators"
export * from './images'
```n
### 📚 Dépendances

- **date-fns:** ^3.6.0
- **zod:** ^3.24.1

---

# 🔧 Services

## 📦 @repo/email

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - index.ts
            - templates/
              - index.ts
              - newsletter-campaign.tsx
              - newsletter-confirmation.tsx
              - order-confirmation.tsx
              - order-delivered.tsx
              - order-shipped.tsx
              - password-reset.tsx
              - welcome.tsx
            - utils/
              - config.ts
              - send.ts
              - send-order-confirmation-hook.ts
```n
### 📤 Exports

```typescript
export * from './templates'
export * from './utils/send'
export * from './utils/config'
export { sendOrderConfirmationHook } from './utils/send-order-confirmation-hook'
```n
### 📚 Dépendances

- **@react-email/components:** ^0.0.25
- **@react-email/render:** ^1.0.1
- **@repo/database:** workspace:*
- **react:** ^19.0.0
- **resend:** ^4.0.0

---

## 📦 @repo/analytics

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - analytics.ts
            - AnalyticsTracker.tsx
            - index.ts
            - track.ts
```n
### 📤 Exports

```typescript
export * from './track'
export * from './analytics'
export { AnalyticsTracker } from './AnalyticsTracker'
```n
### 📚 Dépendances

- **@vercel/analytics:** ^1.4.1
- **next:** ^15.1.6
- **react:** ^19.0.0

---

## 📦 @repo/shipping

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - calculator.ts
            - config.ts
            - index.ts
            - types.ts
```n
### 📤 Exports

```typescript
export * from './calculator'
export * from './config'
export * from './types'
```n
### 📚 Dépendances

- **@repo/config:** workspace:*
- **date-fns:** ^4.1.0

---

## 📦 @repo/newsletter

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - images.ts
            - index.ts
            - render.ts
            - types.ts
            - utils.ts
            - validation.ts
```n
### 📤 Exports

```typescript
export * from './images'
export * from './render'
export * from './utils'
export * from './validation'
```n
### 📚 Dépendances

- **@react-email/render:** ^1.0.1
- **@repo/database:** workspace:*
- **@supabase/supabase-js:** ^2.47.10
- **react:** ^19.0.0
- **sharp:** ^0.33.5
- **zod:** ^3.24.1

---

# ⚙️ Configuration

## 📦 @repo/config

**Version:** 0.0.0

### 📁 Structure

```text
src/
            - index.ts
```n
### 📤 Exports

```typescript
export const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000"
export const ADMIN_URL = process.env.NEXT_PUBLIC_ADMIN_URL || "http://localhost:3001"
export const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL!
export const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
export const STRIPE_PUBLIC_KEY = process.env.NEXT_PUBLIC_STRIPE_PUBLIC_KEY!
export const STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY!
export const STRIPE_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET!
export const RESEND_API_KEY = process.env.RESEND_API_KEY
export const EMAIL_FROM = process.env.EMAIL_FROM || "noreply@blancherenaudin.com"
export const FREE_SHIPPING_THRESHOLD = 100 // €
export const DEFAULT_SHIPPING_COST = 8.5 // €
export const MAX_CART_QUANTITY = 99
export const SESSION_COOKIE_NAME = "sb-session"
export const PRODUCTS_PER_PAGE = 12
export const ORDERS_PER_PAGE = 20
export const IMAGE_SIZES = {
export const ORDER_STATUSES = {
export type OrderStatus = (typeof ORDER_STATUSES)[keyof typeof ORDER_STATUSES]
export const PAYMENT_STATUSES = {
export type PaymentStatus = (typeof PAYMENT_STATUSES)[keyof typeof PAYMENT_STATUSES]
```n
---

---

# 🚀 Application Storefront

## 📊 Statistiques

- **Routes totales:** 90
- **Composants app-specific:** 9
- **Stores Zustand:** 6

### 🗄️ Stores

- index.ts
- useAuthStore.ts
- useCartStore.ts
- useCollectionStore.ts
- useProductStore.ts
- useWishListStore.ts

---

# 📈 Résumé de la Migration

## Packages

- **Total packages:** 10
- **Total composants:** 57

## Status Global

| Package | Status | Fichiers | Notes |
|---------|--------|----------|-------|
| @repo/database | ✅ Migré | 5 | |
| @repo/auth | ✅ Migré | 3 | |
| @repo/sanity | ✅ Migré | 14 | |
| @repo/ui | ✅ Migré | 52 | |
| @repo/utils | ✅ Migré | 4 | |
| @repo/email | ✅ Migré | 12 | |
| @repo/analytics | ✅ Migré | 4 | |
| @repo/shipping | ✅ Migré | 4 | |
| @repo/newsletter | ✅ Migré | 6 | |

---

*📝 Documentation générée automatiquement. Relancez `npm run doc` pour mettre à jour.*

