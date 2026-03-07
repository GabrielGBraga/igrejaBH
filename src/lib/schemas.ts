import { z } from "zod";

export const passwordSchema = z.string()
  .min(8, { message: "A senha deve ter pelo menos 8 caracteres." })
  .max(32, { message: "A senha deve ter no máximo 32 caracteres." })
  .refine((val) => /[A-Z]/.test(val), {
    message: "A senha deve conter pelo menos uma letra maiúscula.",
  })
  .refine((val) => /[0-9]/.test(val), {
    message: "A senha deve conter pelo menos um número.",
  })
  .refine((val) => /[!@#$%^&*(),.?":{}|<>]/.test(val), {
    message: "A senha deve conter pelo menos um caractere especial.",
});

export const signInSchema = z.object({
  email: z.email({ message: "Email inválido" }),
  password: passwordSchema,
});
export type SignInValue = z.infer<typeof signInSchema>;

export const signUpSchema = z.object({
  name: z.string().min(2, { message: "O nome deve ter pelo menos 2 caracteres." }),
  email: z.email({ message: "Email inválido" }),
  password: passwordSchema,
  confirmPassword: z.string()
}).refine((data) => data.password === data.confirmPassword, {
  message: "As senhas não coincidem.",
  path: ["confirmPassword"],
});
export type SignUpSchema = z.infer<typeof signUpSchema>;