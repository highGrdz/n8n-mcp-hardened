import { z } from 'zod';

/**
 * DOE Framework: Middleware de Sanitização
 * Valida estritamente o input do LLM antes de chegar ao n8n.
 * Evita instabilidade silenciosa por alucinação.
 */
export const validateMcpInput = <T>(schema: z.ZodSchema<T>, data: unknown): T => {
    const result = schema.safeParse(data);
    if (!result.success) {
        // Retorna um erro detalhado para a IA aprender e auto-corrigir o payload
        throw new Error(`Validation Error: Payload format is invalid. ${result.error.message}`);
    }
    return result.data;
};
