import { z } from "zod";

export const passwordSchema = z.string()
  .min(8, { message: "A senha deve ter pelo menos 8 caracteres." })
  .max(32, { message: "A senha deve ter no máximo 32 caracteres." })
  .refine((val) => /[A-Z]/.test(val), {
    message: "A senha deve conter pelo menos uma letra maiúscula.",
  })
  .refine((val) => /[a-z]/.test(val), {
    message: "A senha deve conter pelo menos uma letra minúscula.",
  })
  .refine((val) => /[0-9]/.test(val), {
    message: "A senha deve conter pelo menos um número.",
  })
  .refine((val) => /[!@#$%^&*(),.?":{}|<>]/.test(val), {
    message: "A senha deve conter pelo menos um caractere especial.",
});

export const signInSchema = z.object({
  email: z.string().email({ message: "Email inválido" }),
  password: z.string().min(1, { message: "Senha é obrigatória" }),
});
export type SignInValue = z.infer<typeof signInSchema>;

export const signUpSchema = z.object({
  fullName: z.string().min(3, { message: "Nome completo deve ter pelo menos 3 caracteres." }),
  email: z.string().email({ message: "Email inválido" }),
  phone: z.string().min(10, { message: "Telefone inválido" }),
  cpf: z.string().min(11, { message: "CPF inválido" }).max(14),
  birthDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, { message: "Data de nascimento inválida (AAAA-MM-DD)" }),
  gender: z.enum(["masculino", "feminino", "outro"]),
  maritalStatus: z.enum(["solteiro", "casado", "divorciado", "viuvo"]),
  addressZipCode: z.string().min(8, { message: "CEP inválido" }),
  addressStreet: z.string().min(3, { message: "Rua é obrigatória" }),
  addressNumber: z.string().min(1, { message: "Número é obrigatório" }),
  addressNeighborhood: z.string().min(2, { message: "Bairro é obrigatório" }),
  addressCity: z.string().min(2, { message: "Cidade é obrigatória" }),
  addressState: z.string().length(2, { message: "Estado deve ser a sigla (ex: MG)" }),
  password: passwordSchema,
  confirmPassword: z.string(),
  avatarUrl: z.string().optional(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "As senhas não coincidem.",
  path: ["confirmPassword"],
});
export type SignUpValue = z.infer<typeof signUpSchema>;