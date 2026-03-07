import { Link } from "react-router-dom";
import { useForm } from "react-hook-form";
import { signInSchema, type SignInValue } from "../lib/schemas"
import { zodResolver } from "@hookform/resolvers/zod";

export default function SignIn() {

    const signForm = useForm<SignInValue>({
        resolver: zodResolver(signInSchema),
    })

    return (
        <div className="flex flex-col items-center justify-center h-screen">
            <h1>Sign In</h1>
            
        </div>
    )
}
