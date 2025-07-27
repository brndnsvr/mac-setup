# React TypeScript Template

A modern React application template with TypeScript, Vite, and production-ready features.

## Features

- ⚛️ React 18 with TypeScript
- ⚡ Vite for fast development
- 🎨 Tailwind CSS for styling
- 📦 Component library setup (shadcn/ui ready)
- 🧪 Testing with Vitest and Testing Library
- 📊 State management with Zustand
- 🚀 React Router for navigation
- 🔧 ESLint and Prettier configured
- 📱 Responsive design
- 🌙 Dark mode support
- 🐳 Docker ready

## Quick Start

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Build for production
npm run build

# Run tests
npm test

# Run linting
npm run lint
```

## Project Structure

```
.
├── src/
│   ├── components/       # Reusable components
│   │   ├── ui/          # Base UI components
│   │   └── common/      # Common components
│   ├── pages/           # Page components
│   ├── hooks/           # Custom hooks
│   ├── services/        # API services
│   ├── store/           # State management
│   ├── utils/           # Utility functions
│   ├── types/           # TypeScript types
│   ├── styles/          # Global styles
│   ├── App.tsx          # Main app component
│   └── main.tsx         # Entry point
├── public/              # Static assets
├── tests/               # Test files
├── .env.example         # Environment variables
├── vite.config.ts       # Vite configuration
├── tailwind.config.js   # Tailwind configuration
├── tsconfig.json        # TypeScript configuration
├── package.json
└── README.md
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm test` - Run tests
- `npm run test:watch` - Run tests in watch mode
- `npm run test:coverage` - Run tests with coverage
- `npm run lint` - Run ESLint
- `npm run lint:fix` - Fix ESLint issues
- `npm run format` - Format code with Prettier
- `npm run type-check` - Run TypeScript compiler

## State Management

This template uses Zustand for state management. Example store:

```typescript
// src/store/useAppStore.ts
import { create } from 'zustand'

interface AppState {
  user: User | null
  setUser: (user: User | null) => void
}

export const useAppStore = create<AppState>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}))
```

## API Integration

API services are organized in the `services` directory:

```typescript
// src/services/api.ts
const API_BASE_URL = import.meta.env.VITE_API_URL

export const api = {
  async get<T>(endpoint: string): Promise<T> {
    const response = await fetch(`${API_BASE_URL}${endpoint}`)
    return response.json()
  },
  // ... other methods
}
```

## Styling

This template uses Tailwind CSS for styling. Custom styles can be added to:
- `src/styles/globals.css` - Global styles
- Component-specific CSS modules
- Tailwind utility classes

## Testing

Tests are written using Vitest and React Testing Library:

```typescript
// src/components/Button.test.tsx
import { render, screen } from '@testing-library/react'
import { Button } from './Button'

test('renders button with text', () => {
  render(<Button>Click me</Button>)
  expect(screen.getByText('Click me')).toBeInTheDocument()
})
```

## Environment Variables

Create a `.env` file based on `.env.example`:

```bash
VITE_API_URL=http://localhost:8000/api
VITE_APP_TITLE=My React App
```

## Docker

```bash
# Build Docker image
docker build -t react-app .

# Run container
docker run -p 3000:80 react-app
```

## Deployment

### Vercel
```bash
npm i -g vercel
vercel
```

### Netlify
```bash
npm run build
# Drag and drop dist folder to Netlify
```

### AWS S3 + CloudFront
See `deploy/aws/` for deployment scripts