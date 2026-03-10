import { useForm, Controller } from "react-hook-form";
import { signUpSchema, type SignUpValue } from "../lib/schemas"
import { zodResolver } from "@hookform/resolvers/zod";
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
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
import { EyeIcon, EyeOffIcon, UploadIcon, UserIcon, SearchIcon, Loader2 } from "lucide-react";
import { useState, useRef, useEffect } from "react";
import supabase from "@/lib/supabase";
import { toast } from "sonner";
import { useNavigate, Link } from "react-router-dom";
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group";

const formatPhone = (value: string) => {
    const v = value.replace(/\D/g, "").slice(0, 13);
    if (v.length === 0) return "";
    if (v.length <= 2) return v;
    if (v.length <= 4) return `${v.slice(0, 2)} (${v.slice(2)}`;
    if (v.length <= 9) return `${v.slice(0, 2)} (${v.slice(2, 4)}) ${v.slice(4)}`;
    return `${v.slice(0, 2)} (${v.slice(2, 4)}) ${v.slice(4, 9)}-${v.slice(9, 13)}`;
};

export default function SignUp() {
    const navigate = useNavigate()
    const fileInputRef = useRef<HTMLInputElement>(null)

    const signForm = useForm<SignUpValue>({
        resolver: zodResolver(signUpSchema),
        defaultValues: {
            fullName: "",
            email: "",
            phone: "",
            cpf: "",
            birthDate: "",
            baptismDate: "",
            gender: "masculino",
            maritalStatus: "solteiro",
            addressZipCode: "",
            addressStreet: "",
            addressNumber: "",
            addressNeighborhood: "",
            addressCity: "Belo Horizonte",
            addressState: "MG",
            addressComplement: "",
            password: "",
            confirmPassword: "",
        }
    })

    const [showPassword, setShowPassword] = useState(false)
    const [showConfirmPassword, setShowConfirmPassword] = useState(false)
    const [submitting, setSubmitting] = useState(false)
    const [searchingCep, setSearchingCep] = useState(false)
    const [avatarFile, setAvatarFile] = useState<File | null>(null)
    const [avatarPreview, setAvatarPreview] = useState<string | null>(null)

    const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.files && e.target.files[0]) {
            const file = e.target.files[0]
            setAvatarFile(file)
            setAvatarPreview(URL.createObjectURL(file))
        }
    }

    // Busca CEP automaticamente
    const zipCode = signForm.watch("addressZipCode");
    useEffect(() => {
        const fetchCep = async () => {
            const cleanCep = zipCode?.replace(/\D/g, "");
            if (cleanCep?.length === 8) {
                setSearchingCep(true);
                try {
                    const response = await fetch(`https://viacep.com.br/ws/${cleanCep}/json/`);
                    const data = await response.json();
                    
                    if (!data.erro) {
                        signForm.setValue("addressStreet", data.logradouro);
                        signForm.setValue("addressNeighborhood", data.bairro);
                        signForm.setValue("addressCity", data.localidade);
                        signForm.setValue("addressState", data.uf);
                        toast.success("Endereço preenchido automaticamente");
                    } else {
                        toast.error("CEP não encontrado");
                    }
                } catch (error) {
                    toast.error("Erro ao buscar CEP");
                } finally {
                    setSearchingCep(false);
                }
            }
        };

        fetchCep();
    }, [zipCode, signForm]);

    async function onSubmit(data: SignUpValue) {
        setSubmitting(true)
        try {
            let avatarUrl = ""

            // 1. Upload Avatar
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

            // 2. Auth SignUp
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

            // 3. Update Profile
            if (authData.user) {
                const { error: profileError } = await supabase
                    .from('profiles')
                    .update({
                        phone: data.phone,
                        cpf: data.cpf,
                        birth_date: data.birthDate,
                        baptism_date: data.baptismDate || null,
                        gender: data.gender,
                        marital_status: data.maritalStatus,
                        address_zip_code: data.addressZipCode,
                        address_street: data.addressStreet,
                        address_number: data.addressNumber,
                        address_neighborhood: data.addressNeighborhood,
                        address_city: data.addressCity,
                        address_state: data.addressState,
                        address_complement: data.addressComplement,
                    })
                    .eq('user_id', authData.user.id)

                if (profileError) throw profileError
            }

            toast.success("Cadastro realizado com sucesso!")
            navigate('/')

        } catch (error) {
            toast.error(`Erro no cadastro: ${error instanceof Error ? error.message : String(error)}`);
        } finally {
            setSubmitting(false)
        }
    }

    return (
        <div className="relative min-h-screen flex items-center justify-center py-10 px-4 bg-background">
            {/* Dynamic Background Elements */}
            <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
                <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-primary/20 blur-[120px]" />
                <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-secondary/20 blur-[120px]" />
            </div>

            <Card className="w-full max-w-2xl border-border bg-card/50 backdrop-blur-xl shadow-2xl relative z-10">
                <CardHeader className="space-y-1 text-center">
                    <CardTitle className="text-3xl font-bold tracking-tight text-foreground">Cadastro</CardTitle>
                    <CardDescription className="text-muted-foreground">Preencha os dados abaixo para criar sua conta</CardDescription>
                </CardHeader>
                <CardContent>
                    <form id="sign-up-form" onSubmit={signForm.handleSubmit(onSubmit)} className="space-y-6">
                        
                        {/* Seção: Avatar */}
                        <div className="flex flex-col items-center gap-4 mb-6">
                            <div className="relative h-24 w-24 rounded-full border-2 border-dashed border-muted-foreground flex items-center justify-center overflow-hidden bg-muted group cursor-pointer" onClick={() => fileInputRef.current?.click()}>
                                {avatarPreview ? (
                                    <img src={avatarPreview} alt="Preview" className="h-full w-full object-cover" />
                                ) : (
                                    <UserIcon className="h-12 w-12 text-muted-foreground" />
                                )}
                                <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 flex items-center justify-center transition-opacity">
                                    <UploadIcon className="h-6 w-6 text-white" />
                                </div>
                            </div>
                            <p className="text-xs text-muted-foreground">Clique na imagem para carregar sua foto</p>
                            <input 
                                type="file" 
                                ref={fileInputRef} 
                                className="hidden" 
                                accept="image/*" 
                                onChange={handleFileChange}
                            />
                        </div>

                        <FieldGroup className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <Controller
                                name="fullName"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Nome Completo*</FieldLabel>
                                        <Input {...field} placeholder="Seu Nome Completo" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            <Controller
                                name="email"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Email*</FieldLabel>
                                        <Input {...field} type="email" placeholder="seu@email.com" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            <Controller
                                name="phone"
                                control={signForm.control}
                                render={({ field: { onChange, value, ...fieldProps }, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Telefone* (55 31 9XXXX-XXXX)</FieldLabel>
                                        <Input
                                            {...fieldProps}
                                            value={value || ""}
                                            onChange={(e) => {
                                                const formatted = formatPhone(e.target.value);
                                                onChange(formatted);
                                            }}
                                            placeholder="55 (31) 99999-9999"
                                            maxLength={19}
                                        />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            <Controller
                                name="cpf"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>CPF*</FieldLabel>
                                        <Input {...field} placeholder="000.000.000-00" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            <Controller
                                name="birthDate"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Data de Nascimento*</FieldLabel>
                                        <Input {...field} type="date" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />

                            <Controller
                                name="baptismDate"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Data de Batismo*</FieldLabel>
                                        <Input {...field} type="date" value={field.value || ""} />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />


                            <Controller
                                name="gender"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Gênero*</FieldLabel>
                                        <RadioGroup 
                                            value={field.value} 
                                            onValueChange={field.onChange}
                                            className="grid grid-cols-1 gap-2 mt-2"
                                        >
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="masculino" id="g-masc" />
                                                <FieldLabel htmlFor="g-masc" className="font-normal cursor-pointer">Masculino</FieldLabel>
                                            </div>
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="feminino" id="g-fem" />
                                                <FieldLabel htmlFor="g-fem" className="font-normal cursor-pointer">Feminino</FieldLabel>
                                            </div>
                                        </RadioGroup>
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                            <Controller
                                name="maritalStatus"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Estado Civil*</FieldLabel>
                                        <RadioGroup 
                                            value={field.value} 
                                            onValueChange={field.onChange}
                                            className="grid grid-cols-1 md:grid-cols-2 gap-2 mt-2"
                                        >
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="solteiro" id="ms-solt" />
                                                <FieldLabel htmlFor="ms-solt" className="font-normal cursor-pointer">Solteiro</FieldLabel>
                                            </div>
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="casado" id="ms-casa" />
                                                <FieldLabel htmlFor="ms-casa" className="font-normal cursor-pointer">Casado</FieldLabel>
                                            </div>
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="divorciado" id="ms-divo" />
                                                <FieldLabel htmlFor="ms-divo" className="font-normal cursor-pointer">Divorciado</FieldLabel>
                                            </div>
                                            <div className="flex items-center space-x-2">
                                                <RadioGroupItem value="viuvo" id="ms-viuv" />
                                                <FieldLabel htmlFor="ms-viuv" className="font-normal cursor-pointer">Viúvo</FieldLabel>
                                            </div>
                                        </RadioGroup>
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                        </FieldGroup>

                        <FieldSeparator>Endereço*</FieldSeparator>

                        <FieldGroup className="grid grid-cols-1 md:grid-cols-3 gap-4">
                            <Controller
                                name="addressZipCode"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>CEP*</FieldLabel>
                                        <InputGroup>
                                            <InputGroupInput {...field} placeholder="00000-000" />
                                            <InputGroupAddon align="inline-end">
                                                {searchingCep ? <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" /> : <SearchIcon className="h-4 w-4 text-muted-foreground" />}
                                            </InputGroupAddon>
                                        </InputGroup>
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
                                            <FieldLabel>Rua*</FieldLabel>
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
                                        <FieldLabel>Número*</FieldLabel>
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
                                        <FieldLabel>Bairro*</FieldLabel>
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
                                        <FieldLabel>Cidade*</FieldLabel>
                                        <Input {...field} />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                            <Controller
                                name="addressState"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Estado*</FieldLabel>
                                        <Input {...field} maxLength={2} placeholder="UF" />
                                        <FieldError errors={[fieldState.error]} />
                                    </Field>
                                )}
                            />
                            <div className="md:col-span-2">
                                <Controller
                                    name="addressComplement"
                                    control={signForm.control}
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel>Complemento (Opcional)</FieldLabel>
                                            <Input {...field} placeholder="Apto, Bloco, etc" />
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />
                            </div>
                        </FieldGroup>

                        <FieldSeparator>Segurança</FieldSeparator>

                        <FieldGroup className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <Controller
                                name="password"
                                control={signForm.control}
                                render={({ field, fieldState }) => (
                                    <Field data-invalid={fieldState.invalid}>
                                        <FieldLabel>Senha*</FieldLabel>
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
                                        <FieldLabel>Confirmar Senha*</FieldLabel>
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
                <CardFooter className="flex flex-col space-y-4">
                    <Button 
                        className="w-full bg-primary hover:bg-primary/90 text-primary-foreground text-lg font-semibold h-12 transition-all active:scale-[0.98]" 
                        type="submit" 
                        form="sign-up-form" 
                        disabled={submitting}
                    >
                        {submitting ? (
                            <>
                                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                                Processando...
                            </>
                        ) : "Confirmar Cadastro"}
                    </Button>

                    <p className="text-center text-sm text-muted-foreground mt-2">
                        Já tem uma conta?{" "}
                        <Link
                            to="/signin"
                            className="text-primary hover:text-primary/80 font-medium transition-colors"
                        >
                            Faça login
                        </Link>
                    </p>
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
                <span className="bg-background px-2 text-muted-foreground font-semibold">
                    {children}
                </span>
            </div>
        </div>
    )
}
