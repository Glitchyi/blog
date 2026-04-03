import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

const architectures = defineCollection({
  loader: glob({ pattern: '**/README.md', base: './architectures' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    post: z.number(),
    tier: z.number(),
    namespace: z.string(),
    slug: z.string().optional(),
    date: z.string(),
    tags: z.array(z.string()).optional(),
  }),
});

export const collections = { architectures };
