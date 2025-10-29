#!/bin/bash

# Mapa Conceptual
mkdir -p /home/isem/workspace/glit-platform-v2/src/features/mechanics/module1/MapaConceptual

cat > /home/isem/workspace/glit-platform-v2/src/features/mechanics/module1/MapaConceptual/mapaConceptualTypes.ts << 'EOF'
import { BaseExercise } from '@shared/components/mechanics/mechanicsTypes';

export interface ConceptNode {
  id: string;
  label: string;
  x: number;
  y: number;
  category: string;
}

export interface Connection {
  id: string;
  fromId: string;
  toId: string;
  label: string;
}

export interface MapaConceptualData extends BaseExercise {
  nodes: ConceptNode[];
  connections: Connection[];
  correctConnections: string[];
}
EOF

cat > /home/isem/workspace/glit-platform-v2/src/features/mechanics/module1/MapaConceptual/mapaConceptualSchemas.ts << 'EOF'
import { z } from 'zod';

export const conceptNodeSchema = z.object({
  id: z.string(),
  label: z.string().min(1),
  x: z.number(),
  y: z.number(),
  category: z.string()
});

export const connectionSchema = z.object({
  id: z.string(),
  fromId: z.string(),
  toId: z.string(),
  label: z.string()
});

export const mapaConceptualDataSchema = z.object({
  id: z.string(),
  title: z.string().min(1),
  description: z.string().min(1),
  difficulty: z.enum(['facil', 'medio', 'dificil', 'experto']),
  estimatedTime: z.number().int().positive(),
  topic: z.string().min(1),
  hints: z.array(z.object({ id: z.string(), text: z.string(), cost: z.number() })),
  nodes: z.array(conceptNodeSchema),
  connections: z.array(connectionSchema),
  correctConnections: z.array(z.string())
});
EOF

cat > /home/isem/workspace/glit-platform-v2/src/features/mechanics/module1/MapaConceptual/mapaConceptualMockData.ts << 'EOF'
import { MapaConceptualData } from './mapaConceptualTypes';

export const mockMapaConceptualExercises: MapaConceptualData[] = [{
  id: 'mapa-001',
  title: 'Mapa Conceptual: Descubrimientos de Marie Curie',
  description: 'Conecta los conceptos relacionados con los descubrimientos de Marie Curie',
  difficulty: 'medio',
  estimatedTime: 600,
  topic: 'Marie Curie - Conceptos',
  hints: [{ id: 'hint-m1', text: 'El polonio y el radio son elementos', cost: 5 }],
  nodes: [
    { id: 'n1', label: 'Marie Curie', x: 400, y: 50, category: 'persona' },
    { id: 'n2', label: 'Radioactividad', x: 200, y: 150, category: 'fenomeno' },
    { id: 'n3', label: 'Polonio', x: 400, y: 250, category: 'elemento' },
    { id: 'n4', label: 'Radio', x: 600, y: 250, category: 'elemento' },
    { id: 'n5', label: 'Premio Nobel', x: 400, y: 350, category: 'premio' }
  ],
  connections: [],
  correctConnections: ['n1-n2', 'n1-n3', 'n1-n4', 'n2-n3', 'n2-n4', 'n1-n5']
}];
EOF

echo "Mapa Conceptual files created"
