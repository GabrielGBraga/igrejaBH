import type { IncomingMessage, ServerResponse } from "node:http"

interface VercelRequest extends IncomingMessage {
  body: any
  query: { [key: string]: string | string[] }
  cookies: { [key: string]: string }
}

interface VercelResponse extends ServerResponse {
  send: (body: any) => VercelResponse
  json: (jsonBody: any) => VercelResponse
  status: (statusCode: number) => VercelResponse
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  // CORS Headers
  res.setHeader("Access-Control-Allow-Credentials", "true")
  res.setHeader("Access-Control-Allow-Origin", "*")
  res.setHeader("Access-Control-Allow-Methods", "GET,OPTIONS,PATCH,DELETE,POST,PUT")
  res.setHeader(
    "Access-Control-Allow-Headers",
    "X-CSRF-Token, X-Requested-With, Accept, Accept-Version, Content-Length, Content-MD5, Content-Type, Date, X-Api-Version, Authorization"
  )

  if (req.method === "OPTIONS") {
    return res.status(200).end()
  }

  if (req.method !== "POST") {
    return res.status(405).json({ error: "Método não permitido. Utilize POST." })
  }

  try {
    const resendApiKey = process.env.RESEND_API_KEY || ""
    const defaultFrom = process.env.RESEND_FROM_EMAIL || "Igreja em Belo Horizonte <onboarding@resend.dev>"

    if (!resendApiKey) {
      return res.status(500).json({ error: "RESEND_API_KEY não configurada no ambiente." })
    }

    const { to, subject, html, text, from, reply_to, cc, bcc } = req.body || {}

    if (!to || !subject || (!html && !text)) {
      return res.status(400).json({
        error: "Campos obrigatórios ausentes: 'to', 'subject' e ('html' ou 'text').",
      })
    }

    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: from || defaultFrom,
        to: Array.isArray(to) ? to : [to],
        subject,
        html,
        text,
        reply_to,
        cc,
        bcc,
      }),
    })

    const data = await response.json()

    if (!response.ok) {
      return res.status(response.status).json({
        error: "Falha ao enviar e-mail pelo Resend.",
        details: data,
      })
    }

    return res.status(200).json({ success: true, data })
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error)
    return res.status(500).json({ error: "Erro interno no servidor.", details: message })
  }
}
