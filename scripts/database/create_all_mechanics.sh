#!/bin/bash

BASE="/home/isem/workspace/glit-platform-v2/src/features/mechanics"

# EMPAREJAMIENTO (Module 1 - #5)
mkdir -p "$BASE/module1/Emparejamiento"

cat > "$BASE/module1/Emparejamiento/emparejamientoTypes.ts" << 'EOF'
import { BaseExercise } from '@shared/components/mechanics/mechanicsTypes';

export interface MatchingCard {
  id: string;
  content: string;
  matchId: string;
  type: 'question' | 'answer';
  isFlipped: boolean;
  isMatched: boolean;
}

export interface EmparejamientoData extends BaseExercise {
  cards: MatchingCard[];
}
EOF

cat > "$BASE/module1/Emparejamiento/emparejamientoSchemas.ts" << 'EOF'
import { z } from 'zod';

export const matchingCardSchema = z.object({
  id: z.string(),
  content: z.string(),
  matchId: z.string(),
  type: z.enum(['question', 'answer']),
  isFlipped: z.boolean(),
  isMatched: z.boolean()
});

export const emparejamientoDataSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  difficulty: z.enum(['facil', 'medio', 'dificil', 'experto']),
  estimatedTime: z.number(),
  topic: z.string(),
  hints: z.array(z.object({ id: z.string(), text: z.string(), cost: z.number() })),
  cards: z.array(matchingCardSchema)
});
EOF

cat > "$BASE/module1/Emparejamiento/emparejamientoMockData.ts" << 'EOF'
import { EmparejamientoData } from './emparejamientoTypes';

export const mockEmparejamientoExercises: EmparejamientoData[] = [{
  id: 'emp-001',
  title: 'Emparejamiento: Fechas y Eventos de Marie Curie',
  description: 'Empareja cada fecha con el evento correspondiente',
  difficulty: 'facil',
  estimatedTime: 300,
  topic: 'Marie Curie - Cronología',
  hints: [{ id: 'h1', text: 'Su primer Nobel fue en 1903', cost: 5 }],
  cards: [
    { id: 'q1', content: '1867', matchId: 'm1', type: 'question', isFlipped: false, isMatched: false },
    { id: 'a1', content: 'Nacimiento', matchId: 'm1', type: 'answer', isFlipped: false, isMatched: false },
    { id: 'q2', content: '1903', matchId: 'm2', type: 'question', isFlipped: false, isMatched: false },
    { id: 'a2', content: 'Primer Premio Nobel', matchId: 'm2', type: 'answer', isFlipped: false, isMatched: false },
    { id: 'q3', content: '1911', matchId: 'm3', type: 'question', isFlipped: false, isMatched: false },
    { id: 'a3', content: 'Segundo Premio Nobel', matchId: 'm3', type: 'answer', isFlipped: false, isMatched: false }
  ]
}];
EOF

echo "Emparejamiento created"

# QUIZ TIKTOK (Module 4 - #6)
mkdir -p "$BASE/module4/QuizTikTok"

cat > "$BASE/module4/QuizTikTok/quizTikTokTypes.ts" << 'EOF'
import { BaseExercise } from '@shared/components/mechanics/mechanicsTypes';

export interface TikTokQuestion {
  id: string;
  question: string;
  options: string[];
  correctAnswer: number;
  backgroundVideo?: string;
  backgroundColor?: string;
}

export interface QuizTikTokData extends BaseExercise {
  questions: TikTokQuestion[];
}
EOF

cat > "$BASE/module4/QuizTikTok/quizTikTokSchemas.ts" << 'EOF'
import { z } from 'zod';

export const tikTokQuestionSchema = z.object({
  id: z.string(),
  question: z.string(),
  options: z.array(z.string()),
  correctAnswer: z.number(),
  backgroundVideo: z.string().optional(),
  backgroundColor: z.string().optional()
});

export const quizTikTokDataSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  difficulty: z.enum(['facil', 'medio', 'dificil', 'experto']),
  estimatedTime: z.number(),
  topic: z.string(),
  hints: z.array(z.object({ id: z.string(), text: z.string(), cost: z.number() })),
  questions: z.array(tikTokQuestionSchema)
});
EOF

cat > "$BASE/module4/QuizTikTok/quizTikTokMockData.ts" << 'EOF'
import { QuizTikTokData } from './quizTikTokTypes';

export const mockQuizTikTokExercises: QuizTikTokData[] = [{
  id: 'tiktok-001',
  title: 'Quiz TikTok: Marie Curie',
  description: 'Responde preguntas sobre Marie Curie con formato vertical',
  difficulty: 'medio',
  estimatedTime: 180,
  topic: 'Marie Curie - Quiz Rápido',
  hints: [],
  questions: [
    { id: 'q1', question: '¿En qué año nació Marie Curie?', options: ['1865', '1867', '1870', '1872'], correctAnswer: 1, backgroundColor: '#f59e0b' },
    { id: 'q2', question: '¿Cuántos Premios Nobel ganó?', options: ['1', '2', '3', '4'], correctAnswer: 1, backgroundColor: '#3b82f6' },
    { id: 'q3', question: '¿Qué elemento descubrió primero?', options: ['Radio', 'Polonio', 'Curio', 'Uranio'], correctAnswer: 1, backgroundColor: '#8b5cf6' }
  ]
}];
EOF

echo "Quiz TikTok created"

# NAVEGACION HIPERTEXTUAL (Module 4 - #7)
mkdir -p "$BASE/module4/NavegacionHipertextual"

cat > "$BASE/module4/NavegacionHipertextual/navegacionHipertextualTypes.ts" << 'EOF'
import { BaseExercise } from '@shared/components/mechanics/mechanicsTypes';

export interface HypertextNode {
  id: string;
  title: string;
  content: string;
  links: { targetId: string; label: string }[];
}

export interface NavegacionHipertextualData extends BaseExercise {
  nodes: HypertextNode[];
  startNodeId: string;
  targetNodeId: string;
}
EOF

cat > "$BASE/module4/NavegacionHipertextual/navegacionHipertextualSchemas.ts" << 'EOF'
import { z } from 'zod';

export const hypertextNodeSchema = z.object({
  id: z.string(),
  title: z.string(),
  content: z.string(),
  links: z.array(z.object({ targetId: z.string(), label: z.string() }))
});

export const navegacionHipertextualDataSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  difficulty: z.enum(['facil', 'medio', 'dificil', 'experto']),
  estimatedTime: z.number(),
  topic: z.string(),
  hints: z.array(z.object({ id: z.string(), text: z.string(), cost: z.number() })),
  nodes: z.array(hypertextNodeSchema),
  startNodeId: z.string(),
  targetNodeId: z.string()
});
EOF

cat > "$BASE/module4/NavegacionHipertextual/navegacionHipertextualMockData.ts" << 'EOF'
import { NavegacionHipertextualData } from './navegacionHipertextualTypes';

export const mockNavegacionHipertextualExercises: NavegacionHipertextualData[] = [{
  id: 'nav-001',
  title: 'Navegación Hipertextual: Vida de Marie Curie',
  description: 'Explora la biografía de Marie Curie siguiendo enlaces',
  difficulty: 'medio',
  estimatedTime: 480,
  topic: 'Marie Curie - Biografía Interactiva',
  hints: [],
  nodes: [
    { id: 'n1', title: 'Inicio', content: 'Marie Curie fue una científica polaca...', links: [{ targetId: 'n2', label: 'Infancia' }, { targetId: 'n3', label: 'Estudios' }] },
    { id: 'n2', title: 'Infancia', content: 'Nació en Varsovia en 1867...', links: [{ targetId: 'n3', label: 'Siguente' }] },
    { id: 'n3', title: 'Estudios', content: 'Estudió en la Sorbona...', links: [{ targetId: 'n1', label: 'Volver' }] }
  ],
  startNodeId: 'n1',
  targetNodeId: 'n3'
}];
EOF

echo "Navegacion Hipertextual created"

# ANALISIS MEMES (Module 4 - #8)
mkdir -p "$BASE/module4/AnalisisMemes"

cat > "$BASE/module4/AnalisisMemes/analisisMemesTypes.ts" << 'EOF'
import { BaseExercise } from '@shared/components/mechanics/mechanicsTypes';

export interface MemeAnnotation {
  id: string;
  x: number;
  y: number;
  text: string;
  category: 'texto' | 'contexto' | 'humor' | 'critica';
}

export interface AnalisisMemesData extends BaseExercise {
  memeUrl: string;
  memeTitle: string;
  expectedAnnotations: MemeAnnotation[];
}
EOF

cat > "$BASE/module4/AnalisisMemes/analisisMemesSchemas.ts" << 'EOF'
import { z } from 'zod';

export const memeAnnotationSchema = z.object({
  id: z.string(),
  x: z.number(),
  y: z.number(),
  text: z.string(),
  category: z.enum(['texto', 'contexto', 'humor', 'critica'])
});

export const analisisMemesDataSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  difficulty: z.enum(['facil', 'medio', 'dificil', 'experto']),
  estimatedTime: z.number(),
  topic: z.string(),
  hints: z.array(z.object({ id: z.string(), text: z.string(), cost: z.number() })),
  memeUrl: z.string(),
  memeTitle: z.string(),
  expectedAnnotations: z.array(memeAnnotationSchema)
});
EOF

cat > "$BASE/module4/AnalisisMemes/analisisMemesMockData.ts" << 'EOF'
import { AnalisisMemesData } from './analisisMemesTypes';

export const mockAnalisisMemesExercises: AnalisisMemesData[] = [{
  id: 'meme-001',
  title: 'Análisis de Meme: Marie Curie en la Cultura Popular',
  description: 'Analiza un meme sobre Marie Curie identificando elementos clave',
  difficulty: 'medio',
  estimatedTime: 420,
  topic: 'Marie Curie - Análisis Visual',
  hints: [{ id: 'h1', text: 'Busca referencias a la radioactividad', cost: 5 }],
  memeUrl: '/images/marie-curie-meme.jpg',
  memeTitle: 'Marie Curie trabajando con elementos radioactivos',
  expectedAnnotations: [
    { id: 'a1', x: 100, y: 100, text: 'Referencia a radioactividad', category: 'contexto' },
    { id: 'a2', x: 200, y: 150, text: 'Humor sobre peligros del laboratorio', category: 'humor' }
  ]
}];
EOF

echo "Analisis Memes created"

# INFOGRAFIA INTERACTIVA (Module 4 - #9)
mkdir -p "$BASE/module4/InfografiaInteractiva"

cat > "$BASE/module4/InfografiaInteractiva/infografiaInteractivaTypes.ts" << 'EOF'
import { BaseExercise } from '@shared/components/mechanics/mechanicsTypes';

export interface InfoCard {
  id: string;
  title: string;
  content: string;
  position: { x: number; y: number };
  icon: string;
  revealed: boolean;
}

export interface InfografiaInteractivaData extends BaseExercise {
  cards: InfoCard[];
  backgroundImage?: string;
}
EOF

cat > "$BASE/module4/InfografiaInteractiva/infografiaInteractivaSchemas.ts" << 'EOF'
import { z } from 'zod';

export const infoCardSchema = z.object({
  id: z.string(),
  title: z.string(),
  content: z.string(),
  position: z.object({ x: z.number(), y: z.number() }),
  icon: z.string(),
  revealed: z.boolean()
});

export const infografiaInteractivaDataSchema = z.object({
  id: z.string(),
  title: z.string(),
  description: z.string(),
  difficulty: z.enum(['facil', 'medio', 'dificil', 'experto']),
  estimatedTime: z.number(),
  topic: z.string(),
  hints: z.array(z.object({ id: z.string(), text: z.string(), cost: z.number() })),
  cards: z.array(infoCardSchema),
  backgroundImage: z.string().optional()
});
EOF

cat > "$BASE/module4/InfografiaInteractiva/infografiaInteractivaMockData.ts" << 'EOF'
import { InfografiaInteractivaData } from './infografiaInteractivaTypes';

export const mockInfografiaInteractivaExercises: InfografiaInteractivaData[] = [{
  id: 'info-001',
  title: 'Infografía Interactiva: Logros de Marie Curie',
  description: 'Explora los principales logros de Marie Curie haciendo clic en cada tarjeta',
  difficulty: 'facil',
  estimatedTime: 360,
  topic: 'Marie Curie - Logros',
  hints: [],
  cards: [
    { id: 'c1', title: 'Primer Nobel', content: 'Premio Nobel de Física en 1903', position: { x: 100, y: 100 }, icon: 'trophy', revealed: false },
    { id: 'c2', title: 'Segundo Nobel', content: 'Premio Nobel de Química en 1911', position: { x: 300, y: 100 }, icon: 'trophy', revealed: false },
    { id: 'c3', title: 'Descubrimiento', content: 'Descubrió Radio y Polonio', position: { x: 200, y: 250 }, icon: 'atom', revealed: false }
  ]
}];
EOF

echo "Infografia Interactiva created"
echo "All mechanics data structures created successfully!"

