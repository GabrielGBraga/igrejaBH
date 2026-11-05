// Supabase Edge Function: send-email
// Envio seguro de e-mails transacionais via API do Resend

import "jsr:@supabase/functions-js/edge-runtime.d.ts"

const RESEND_API_ENDPOINT = "https://api.resend.com/emails"

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
}

interface SendEmailPayload {
  to: string | string[]
  subject: string
  html?: string
  text?: string
  from?: string
  reply_to?: string | string[]
  cc?: string | string[]
  bcc?: string | string[]
}

Deno.serve(async (req: Request) => {
  // Tratamento de preflight CORS
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders })
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Método não permitido. Utilize POST." }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  }

  try {
    const resendApiKey = Deno.env.get("RESEND_API_KEY") || ""
    const defaultFrom = Deno.env.get("RESEND_FROM_EMAIL") || "Igreja em Belo Horizonte <onboarding@resend.dev>"

    if (!resendApiKey) {
      return new Response(
        JSON.stringify({
          error: "RESEND_API_KEY não configurada no ambiente.",
        }),
        {
          status: 500,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      )
    }

    const body: SendEmailPayload = await req.json()

    if (!body.to || !body.subject || (!body.html && !body.text)) {
      return new Response(
        JSON.stringify({
          error: "Campos obrigatórios ausentes: 'to', 'subject' e ('html' ou 'text').",
        }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      )
    }

    const payload = {
      from: body.from || defaultFrom,
      to: Array.isArray(body.to) ? body.to : [body.to],
      subject: body.subject,
      html: body.html,
      text: body.text,
      reply_to: body.reply_to,
      cc: body.cc,
      bcc: body.bcc,
    }

    const resendRes = await fetch(RESEND_API_ENDPOINT, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    })

    const data = await resendRes.json()

    if (!resendRes.ok) {
      console.error("Erro na API do Resend:", data)
      return new Response(
        JSON.stringify({
          error: "Falha ao enviar e-mail pelo Resend.",
          details: data,
        }),
        {
          status: resendRes.status,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      )
    }

    return new Response(
      JSON.stringify({
        success: true,
        data,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    )
  } catch (err: unknown) {
    const errorMsg = err instanceof Error ? err.message : String(err)
    console.error("Erro inesperado na Edge Function send-email:", errorMsg)
    return new Response(
      JSON.stringify({
        error: "Erro interno no processamento do e-mail.",
        details: errorMsg,
      }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    )
  }
})
