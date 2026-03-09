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
import { EyeIcon, EyeOffIcon, UploadIcon, UserIcon } from "lucide-react";
import { useState, useRef } from "react";
import supabase from "@/lib/supabase";
import { toast } from "sonner";
import { useNavigate } from "react-router-dom";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";

export default function SignUp() {
    const navigate = useNavigate()
    const fileInputRef = useRef<HTMLInputElement>(null)

    const signForm = useForm<SignUpValue>({
        resolver: zodResolver(signUpSchema),
        defaultValues: {
            addressCity: "Belo Horizonte",
            addressState: "MG",
            gender: "masculino",
            maritalStatus: "solteiro",
        }
    })

    const [showPassword, setShowPassword] = useState(false)
    const [showConfirmPassword, setShowConfirmPassword] = useState(false)
    const [submitting, setSubmitting] = useState(false)
    const [avatarFile, setAvatarFile] = useState<File | null>(null)
    const [avatarPreview, setAvatarPreview] = useState<string | null>(null)

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            const file = e.target.files[0]
            setAvatarFile(file)
            setAvatarPreview(URL.createObjectURL(file))
        }
    }

    async function onSubmit(data: SignUpValue) {
        setSubmitting(true)
        try {
            let avatarUrl = ""

            // 1. Upload Avatar if exists
            if (avatarFile) {
                const fileExt = avatarFile.name.split('.').pop()
                const fileName = `${Math.random()}.${fileExt}`
                const filePath = `avatars/${fileName}`

                const { error: uploadError } = await supabase.storage
                    .from('avatars')
                    .upload(filePath, avatarFile)

                if (uploadError) throw uploadError

                const { data: { publicUrl } } = supabase.storage
                    .from('avatars')
                    .getPublicUrl(filePath)
                
                avatarUrl = publicUrl
            }

            // 2. Sign Up in Auth
            // The handle_new_user database trigger will automatically create the profile row
            const { data: authData, error: authError } = await supabase.auth.signUp({
                email: data.email,
                password: data.password,
                options: {
                    data: {
                        full_name: data.fullName,
                        avatar_url: avatarUrl,
                    }
                }
            })
            
            if (authError) throw authError

            // 3. Update the profile with remaining fields
            // Profiles trigger creates the row, but we need to fill the rest
            if (authData.user) {
                const { error: profileError } = await supabase
                    .from('profiles')
                    .update({
                        phone: data.phone,
                        cpf: data.cpf,
                        birth_date: data.birthDate,
                        gender: data.gender,
                        marital_status: data.maritalStatus,
                        address_zip_code: data.addressZipCode,
                        address_street: data.addressStreet,
                        address_number: data.addressNumber,
                        address_neighborhood: data.addressNeighborhood,
                        address_city: data.addressCity,
                        address_state: data.addressState,
                    })
                    .eq('user_id', authData.user.id)

                if (profileError) throw profileError
            }

            toast.success("Cadastro feito com sucesso")
            navigate('/')

        } catch (error) {
            toast.error(`Erro no cadastro: ${error instanceof Error ? error.message : String(error)}`);
        } finally {
            setSubmitting(false)
        }
    }

    return (
        <div className="flex items-center justify-center min-h-screen py-10 px-4">
            <Card className="w-full max-w-2xl">
                <CardHeader className="text-center">
                    <CardTitle className="text-2xl font-bold">Cadastro de Membro</CardTitle>
                </CardHeader>
                <CardContent>
                    <form id="sign-up-form" onSubmit={signForm.handleSubmit(onSubmit)} className="space-y-6">
                        
                        {/* Seção: Avatar */}
                        <div className="flex flex-col items-center gap-4 mb-6">
                            <div className="relative h-24 w-24 rounded-full border-2 border-dashed border-muted-foreground flex items-center justify-center overflow-hidden bg-muted">
                                {avatarPreview ? (
                                    <img src={avatarPreview} alt="Preview" className="h-full w-full object-cover" />
                                ) : (
                                    <UserIcon className="h-12 w-12 text-muted-foreground" />
                                )}
                            </div>
                            <Button 
                                type="button" 
                                variant="outline" 
                                size="sm"
                                onClick={() => fileInputRef.current?.click()}
                            >
                                <UploadIcon className="h-4 w-4 mr-2" />
                                Carregar Foto
                            </Button>
                            <input 
                                type="file" 
                                ref={fileInputRef} 
                                className="hidden" 
                                accept="image/*" 
                                onChange={handleFileChange}
                            />
                        </div>

                        <FieldGroup className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            {/* Nome Completo */}
                            <Controller
                                name="fullName"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Nome Completo</FieldLabel>
                                        <Input {...field} placeholder="Seu Nome Completo" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            {/* Email */}
                            <Controller
                                name="email"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Email</FieldLabel>
                                        <Input {...field} type="email" placeholder="seu@email.com" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            {/* Telefone */}
                            <Controller
                                name="phone"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Telefone</FieldLabel>
                                        <Input {...field} placeholder="(31) 99999-9999" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            {/* CPF */}
                            <Controller
                                name="cpf"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>CPF</FieldLabel>
                                        <Input {...field} placeholder="000.000.000-00" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            {/* Data de Nascimento */}
                            <Controller
                                name="birthDate"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Data de Nascimento</FieldLabel>
                                        <Input {...field} type="date" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                             {/* Gênero */}
                             <Controller
                                name="gender"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Gênero</FieldLabel>
                                        <RadioGroup 
                                            value={field.value} 
                                            onValueChange={field.onChange}
                                            className="flex gap-4"
                                        >
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="masculino" id="g-masc" />
                                                <FieldLabel htmlFor="g-masc" className="font-normal cursor-pointer">Masc</FieldLabel>
                                            </div>
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="feminino" id="g-fem" />
                                                <FieldLabel htmlFor="g-fem" className="font-normal cursor-pointer">Fem</FieldLabel>
                                            </div>
                                        </RadioGroup>
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            {/* Estado Civil */}
                            <Controller
                                name="maritalStatus"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Estado Civil</FieldLabel>
                                        <RadioGroup 
                                            value={field.value} 
                                            onValueChange={field.onChange}
                                            className="grid grid-cols-2 gap-2"
                                        >
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="solteiro" id="ms-solt" />
                                                <FieldLabel htmlFor="ms-solt" className="font-normal cursor-pointer text-xs">Solteiro</FieldLabel>
                                            </div>
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="casado" id="ms-casa" />
                                                <FieldLabel htmlFor="ms-casa" className="font-normal cursor-pointer text-xs">Casado</FieldLabel>
                                            </div>
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="divorciado" id="ms-divo" />
                                                <FieldLabel htmlFor="ms-divo" className="font-normal cursor-pointer text-xs">Divorciado</FieldLabel>
                                            </div>
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="viuvo" id="ms-viuv" />
                                                <FieldLabel htmlFor="ms-viuv" className="font-normal cursor-pointer text-xs">Viúvo</FieldLabel>
                                            </div>
                                        </RadioGroup>
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                        </FieldGroup>

                        <FieldSeparator>Endereço</FieldSeparator>

                        <FieldGroup className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <Controller
                                name="addressZipCode"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>CEP</FieldLabel>
                                        <Input {...field} placeholder="00000-000" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                            <div className="md:col-span-2">
                                <Controller
                                    name="addressStreet"
                                    control={signForm.control}
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel>Rua</FieldLabel>
                                            <Input {...field} placeholder="Rua / Avenida" />
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />
                            </div>
                            <Controller
                                name="addressNumber"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Número</FieldLabel>
                                        <Input {...field} placeholder="123" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                            <Controller
                                name="addressNeighborhood"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Bairro</FieldLabel>
                                        <Input {...field} placeholder="Centro" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                            <Controller
                                name="addressCity"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Cidade</FieldLabel>
                                        <Input {...field} />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                        </FieldGroup>

                        <FieldSeparator>Segurança</FieldSeparator>

                        <FieldGroup className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <Controller
                                name="password"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Senha</FieldLabel>
                                        <InputGroup>
                                            <InputGroupInput
                                                {...field}
                                                type={showPassword ? "text" : "password"}
                                                placeholder="********"
                                            />
                                            <InputGroupAddon align="inline-end">
                                                <Button
                                                    variant="ghost"
                                                    size="icon"
                                                    type="button"
                                                    onClick={() => setShowPassword(!showPassword)}
                                                >
                                                    {showPassword ? <EyeOffIcon className="h-4 w-4" /> : <EyeIcon className="h-4 w-4" />}
                                                </Button>
                                            </InputGroupAddon>
                                        </InputGroup>
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                            <Controller
                                name="confirmPassword"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Confirmar Senha</FieldLabel>
                                        <InputGroup>
                                            <InputGroupInput
                                                {...field}
                                                type={showConfirmPassword ? "text" : "password"}
                                                placeholder="********"
                                            />
                                            <InputGroupAddon align="inline-end">
                                                <Button
                                                    variant="ghost"
                                                    size="icon"
                                                    type="button"
                                                    onClick={() => setShowConfirmPassword(!showConfirmPassword)}
                                                >
                                                    {showConfirmPassword ? <EyeOffIcon className="h-4 w-4" /> : <EyeIcon className="h-4 w-4" />}
                                                </Button>
                                            </InputGroupAddon>
                                        </InputGroup>
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                        </FieldGroup>

                    </form>
                </CardContent>
                <CardFooter>
                    <Button 
                        className="w-full" 
                        type="submit" 
                        form="sign-up-form" 
                        disabled={submitting}
                    >
                        {submitting ? "Cadastrando..." : "Confirmar Cadastro"}
                    </Button>
                </CardFooter>
            </Card>
        </div>
    )
}

function FieldSeparator({ children }: { children: React.ReactNode }) {
    return (
        <div className="relative my-6">
            <div className="absolute inset-0 flex items-center">
                <span className="w-full border-t" />
            </div>
            <div className="relative flex justify-center text-xs uppercase">
                <span className="bg-background px-2 text-muted-foreground">
                    {children}
                </span>
            </div>
        </div>
    )
}
