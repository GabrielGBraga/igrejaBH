// Cloudflare Pages Function: /api/send-email
// Disparo transacional de e-mails via Resend API

interface Env {
  RESEND_API_KEY?: string
  RESEND_FROM_EMAIL?: string
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

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "Content-Type, Authorization",
}

export const onRequestOptions = async () => {
  return new Response(null, {
    status: 204,
    headers: corsHeaders,
  })
}

export const onRequestPost = async (context: { request: Request; env: Env }) => {
  const { request, env } = context

  try {
    const resendApiKey = env.RESEND_API_KEY || ""
    const defaultFrom = env.RESEND_FROM_EMAIL || "Igreja em Belo Horizonte <onboarding@resend.dev>"

    if (!resendApiKey) {
      return new Response(
        JSON.stringify({ error: "RESEND_API_KEY não configurada no ambiente." }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    const body: SendEmailPayload = await request.json()

    if (!body.to || !body.subject || (!body.html && !body.text)) {
      return new Response(
        JSON.stringify({
          error: "Campos obrigatórios ausentes: 'to', 'subject' e ('html' ou 'text').",
        }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
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

    const resendRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    })

    const data = await resendRes.json()

    if (!resendRes.ok) {
      return new Response(
        JSON.stringify({ error: "Falha ao enviar e-mail pelo Resend.", details: data }),
        { status: resendRes.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      )
    }

    return new Response(JSON.stringify({ success: true, data }), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    })
  } catch (err: unknown) {
    const errorMsg = err instanceof Error ? err.message : String(err)
    return new Response(
      JSON.stringify({ error: "Erro interno no processamento do e-mail.", details: errorMsg }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    )
  }
}
