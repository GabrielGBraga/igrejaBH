import { useForm, Controller } from "react-hook-form";
import { signUpSchema, type SignUpValue } from "../lib/schemas"
import { zodResolver } from "@hookform/resolvers/zod";
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import {
  Field,
  FieldError,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import {
  InputGroup,
  InputGroupAddon,
  InputGroupInput,
} from "@/components/ui/input-group"
import { EyeIcon, EyeOffIcon } from "lucide-react";
import { useState } from "react";
import supabase from "@/lib/supabase";
import { toast } from "sonner";
import { useNavigate } from "react-router-dom";

export default function SignUp() {

    const navigate = useNavigate()

    const signForm = useForm<SignUpValue>({
        resolver: zodResolver(signUpSchema),
    })

    const [showPassword, setShowPassword] = useState(false)
    const [showConfirmPassword, setShowConfirmPassword] = useState(false)
    const [submitting, setSubmitting] = useState(false)

    async function onSubmit(data: SignUpValue) {
        setSubmitting(true)
        try {
            const { error } = await supabase.auth.signUp({
                email: data.email,
                password: data.password,
            })
            
            if (error) throw error

            toast.success("Cadastro feito com sucesso")
            setSubmitting(false)
            navigate('/')

        } catch (error) {
            toast.error(`Erro no cadastro: ${error instanceof Error ? error.message : String(error)}`);
        }
        setSubmitting(false)
    }

    return (
        <div className="flex items-center justify-center h-screen">
            <Card className="w-full sm:max-w-md">
                <CardHeader className="text-center">
                    <CardTitle>Cadastro</CardTitle>
                </CardHeader>
                <CardContent>
                    <form id="form-rhf-demo" onSubmit={signForm.handleSubmit(onSubmit)}>
                    <FieldGroup>
                        <Controller
                            name="name"
                            control={signForm.control}
                            render={({ field, fieldState }) => (
                                <Field data-invalid={fieldState.invalid}>
                                    <FieldLabel htmlFor="form-rhf-demo-title">
                                        Nome
                                    </FieldLabel>
                                    <Input
                                        {...field}
                                        id="form-rhf-demo-title"
                                        aria-invalid={fieldState.invalid}
                                        placeholder="Seu Nome"
                                        type="name"
                                        autoComplete="off"
                                    />
                                    {fieldState.invalid && (
                                        <FieldError errors={[fieldState.error]} />
                                    )}
                                </Field>
                            )}
                        />
                        <Controller
                            name="email"
                            control={signForm.control}
                            render={({ field, fieldState }) => (
                                <Field data-invalid={fieldState.invalid}>
                                    <FieldLabel htmlFor="form-rhf-demo-title">
                                        Email
                                    </FieldLabel>
                                    <Input
                                        {...field}
                                        id="form-rhf-demo-title"
                                        aria-invalid={fieldState.invalid}
                                        placeholder="seu-email@exemplo.com"
                                        type="email"
                                        autoComplete="off"
                                    />
                                    {fieldState.invalid && (
                                        <FieldError errors={[fieldState.error]} />
                                    )}
                                </Field>
                            )}
                        />
                        <Controller
                            name="password"
                            control={signForm.control}
                            render={({ field, fieldState }) => (
                                <Field data-invalid={fieldState.invalid}>
                                    <FieldLabel htmlFor="form-rhf-demo-title">
                                        Senha
                                    </FieldLabel>
                                    <InputGroup>
                                        <InputGroupInput
                                            {...field}
                                            id="inline-end-input"
                                            type={showPassword ? "text" : "password"}
                                            placeholder="Enter password"
                                        />
                                        <InputGroupAddon align="inline-end">
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                type="button"
                                                onClick={() => setShowPassword(!showPassword)}
                                            >
                                                {showPassword 
                                                    ? <EyeOffIcon/>
                                                    : <EyeIcon/> 
                                                }
                                            </Button>
                                        </InputGroupAddon>
                                    </InputGroup>
                                    {fieldState.invalid && (
                                        <FieldError errors={[fieldState.error]} />
                                    )}
                                </Field>
                            )}
                        />
                        <Controller
                            name="confirmPassword"
                            control={signForm.control}
                            render={({ field, fieldState }) => (
                                <Field data-invalid={fieldState.invalid}>
                                    <FieldLabel htmlFor="form-rhf-demo-title">
                                        Confirme sua senha
                                    </FieldLabel>
                                    <InputGroup>
                                        <InputGroupInput
                                            {...field}
                                            id="inline-end-input"
                                            type={showConfirmPassword ? "text" : "password"}
                                            placeholder="Enter password"
                                        />
                                        <InputGroupAddon align="inline-end">
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                type="button"
                                                onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                                            >
                                                {showConfirmPassword 
                                                    ? <EyeOffIcon/>
                                                    : <EyeIcon/> 
                                                }
                                            </Button>
                                        </InputGroupAddon>
                                    </InputGroup>
                                    {fieldState.invalid && (
                                        <FieldError errors={[fieldState.error]} />
                                    )}
                            </Field>
                        )}
                        />
                    </FieldGroup>
                    </form>
                </CardContent>
                <CardFooter>
                    <Field orientation="horizontal" className="justify-center">
                        <Button className=" w-full " type="submit" form="form-rhf-demo" disabled={submitting}>
                            Submit
                        </Button>
                    </Field>
                </CardFooter>
            </Card>
        </div>
    )
}
