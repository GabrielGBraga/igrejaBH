import { useForm, Controller } from "react-hook-form";
import { signInSchema, type SignInValue } from "../lib/schemas";
import { zodResolver } from "@hookform/resolvers/zod";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Field,
  FieldError,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field";
import {
  InputGroup,
  InputGroupAddon,
  InputGroupInput,
} from "@/components/ui/input-group";
import { EyeIcon, EyeOffIcon, LockIcon, MailIcon, Loader2 } from "lucide-react";
import { useState } from "react";
import supabase from "@/lib/supabase";
import { Link, useNavigate } from "react-router-dom";
import { toast } from "sonner";

export default function SignIn() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const signForm = useForm<SignInValue>({
    resolver: zodResolver(signInSchema),
    defaultValues: {
      email: "",
      password: "",
    },
  });

  async function onSubmit(data: SignInValue) {
    setLoading(true);
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email: data.email,
        password: data.password,
      });

      if (error) throw error;

      toast.success("Login realizado com sucesso!");
      navigate("/");
    } catch (error) {
      console.error("Error on sign in: ", error);
      toast.error(
        error instanceof Error ? error.message : "Erro ao realizar login"
      );
    } finally {
      setLoading(false);
    }
  }

  return (
    <div className="relative min-h-screen flex items-center justify-center p-4 bg-background">
      {/* Dynamic Background Elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-primary/20 blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-secondary/20 blur-[120px]" />
      </div>

      <Card className="w-full max-w-md border-border bg-card/50 backdrop-blur-xl shadow-2xl">
        <CardHeader className="space-y-1 text-center">
          <div className="flex justify-center mb-4">
            <div className="p-3 rounded-2xl bg-primary/10 border border-primary/20 shadow-inner">
              <LockIcon className="w-8 h-8 text-primary" />
            </div>
          </div>
          <CardTitle className="text-3xl font-bold tracking-tight text-foreground">
            Igreja em BH
          </CardTitle>
          <CardDescription className="text-muted-foreground">
            Entre com suas credenciais para acessar o portal
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form
            id="signin-form"
            onSubmit={signForm.handleSubmit(onSubmit)}
            className="space-y-4"
          >
            <FieldGroup className="space-y-4">
              <Controller
                name="email"
                control={signForm.control}
                render={({ field, fieldState }) => (
                  <Field data-invalid={fieldState.invalid}>
                    <FieldLabel className="text-muted-foreground">Email</FieldLabel>
                    <InputGroup>
                      <InputGroupAddon align="inline-start">
                        <MailIcon className="h-4 w-4 text-muted-foreground" />
                      </InputGroupAddon>
                      <InputGroupInput
                        {...field}
                        className="bg-background border-border text-foreground placeholder:text-muted-foreground focus:ring-primary/20"
                        placeholder="seu@email.com"
                        type="email"
                        autoComplete="email"
                      />
                    </InputGroup>
                    {fieldState.invalid && (
                      <FieldError
                        className="text-red-400"
                        errors={[fieldState.error]}
                      />
                    )}
                  </Field>
                )}
              />

              <Controller
                name="password"
                control={signForm.control}
                render={({ field, fieldState }) => (
                  <Field data-invalid={fieldState.invalid}>
                    <div className="flex items-center justify-between">
                      <FieldLabel className="text-muted-foreground">Senha</FieldLabel>
                      <button
                        type="button"
                        className="text-xs text-primary hover:text-primary/80 transition-colors"
                        onClick={() => toast.info("Funcionalidade em breve")}
                      >
                        Esqueceu a senha?
                      </button>
                    </div>
                    <InputGroup>
                      <InputGroupInput
                        {...field}
                        className="bg-background border-border text-foreground placeholder:text-muted-foreground focus:ring-primary/20"
                        type={showPassword ? "text" : "password"}
                        placeholder="********"
                        autoComplete="current-password"
                      />
                      <InputGroupAddon align="inline-end">
                        <Button
                          variant="ghost"
                          size="icon"
                          type="button"
                          className="text-muted-foreground hover:text-foreground hover:bg-transparent"
                          onClick={() => setShowPassword(!showPassword)}
                        >
                          {showPassword ? (
                            <EyeOffIcon className="h-4 w-4" />
                          ) : (
                            <EyeIcon className="h-4 w-4" />
                          )}
                        </Button>
                      </InputGroupAddon>
                    </InputGroup>
                    {fieldState.invalid && (
                      <FieldError
                        className="text-red-400"
                        errors={[fieldState.error]}
                      />
                    )}
                  </Field>
                )}
              />
            </FieldGroup>
          </form>
        </CardContent>
        <CardFooter className="flex flex-col space-y-4">
          <Button
            className="w-full bg-primary hover:bg-primary/90 text-primary-foreground font-semibold py-6 transition-all active:scale-[0.98]"
            type="submit"
            form="signin-form"
            disabled={loading}
          >
            {loading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Entrando...
              </>
            ) : (
              "Acessar Conta"
            )}
          </Button>

          <p className="text-center text-sm text-muted-foreground">
            Ainda não tem uma conta?{" "}
            <Link
              to="/signup"
              className="text-primary hover:text-primary/80 font-medium transition-colors"
            >
              Cadastre-se agora
            </Link>
          </p>
        </CardFooter>
      </Card>
    </div>
  );
}
